import { ParserRule } from '../parser.types';
import { ParsedEmail, ParsedTransaction } from '../../gmail/gmail.types';

export class BcaRule implements ParserRule {
  canParse(email: ParsedEmail): boolean {
    return (
      email.from.toLowerCase().includes('bca.co.id') ||
      email.subject.toLowerCase().includes('bca')
    );
  }

  parse(email: ParsedEmail): ParsedTransaction | null {
    const body = email.textBody + email.htmlBody;

    // Pola email notifikasi BCA: "Debit Rp 150.000"
    const amountMatch = body.match(
      /(?:Debit|Kredit|sebesar)\s+Rp\s*([\d,.]+)/i
    );
    const merchantMatch = body.match(/(?:Merchant|Toko|di)\s*:\s*(.+?)(?:\n|<)/i);
    const dateMatch = body.match(/(\d{2}\/\d{2}\/\d{4}\s+\d{2}:\d{2}:\d{2})/);
    const refMatch = body.match(/(?:No\.?\s*Ref|Referensi)\s*:\s*(\d+)/i);
    const typeMatch: 'DEBIT' | 'CREDIT' =
      /(?:debit|pembayaran|pembelian)/i.test(body) ? 'DEBIT' : 'CREDIT';

    if (!amountMatch) return null;

    const rawAmount = amountMatch[1].replace(/\./g, '').replace(',', '.');
    const amount = parseFloat(rawAmount);

    return {
      amount,
      currency: 'IDR',
      type: typeMatch,
      description: email.subject,
      merchant: merchantMatch?.[1]?.trim() || null,
      referenceNumber: refMatch?.[1] || null,
      transactionDate: dateMatch
        ? this.parseIndonesianDate(dateMatch[1])
        : email.date,
      source: 'BCA',
      rawEmailBody: email.textBody,
      isParsed: true,
    };
  }

  private parseIndonesianDate(dateStr: string): Date {
    // Format: "15/01/2024 14:30:00"
    const [datePart, timePart] = dateStr.split(' ');
    const [day, month, year] = datePart.split('/');
    return new Date(`${year}-${month}-${day}T${timePart}`);
  }
}
