import { ParserRule } from '../parser.types';
import { ParsedEmail, ParsedTransaction } from '../../gmail/gmail.types';

export class MandiriRule implements ParserRule {
  canParse(email: ParsedEmail): boolean {
    return (
      email.from.toLowerCase().includes('bankmandiri.co.id') ||
      email.subject.toLowerCase().includes('mandiri')
    );
  }

  parse(email: ParsedEmail): ParsedTransaction | null {
    const body = email.textBody + email.htmlBody;

    // Pola email Mandiri: "Rp150.000,00" atau "IDR 150,000.00"
    const amountMatch = body.match(/Rp\s*([\d.]+),\d{2}/i);
    const merchantMatch = body.match(/(?:Merchant|Kepada|To)\s*:\s*(.+?)(?:\n|<)/i);
    const dateMatch = body.match(/(\d{2}[-\/]\w{3}[-\/]\d{4})/);
    const refMatch = body.match(/(?:No\.\s*Transaksi|Ref(?:erence)?)\s*:\s*([A-Z0-9]+)/i);
    const typeMatch: 'DEBIT' | 'CREDIT' =
      /(?:debit|transfer keluar|pembayaran)/i.test(body) ? 'DEBIT' : 'CREDIT';

    if (!amountMatch) return null;

    const rawAmount = amountMatch[1].replace(/\./g, '');
    const amount = parseFloat(rawAmount);

    return {
      amount,
      currency: 'IDR',
      type: typeMatch,
      description: email.subject,
      merchant: merchantMatch?.[1]?.trim() || null,
      referenceNumber: refMatch?.[1] || null,
      transactionDate: dateMatch ? new Date(dateMatch[1]) : email.date,
      source: 'MANDIRI',
      rawEmailBody: email.textBody,
      isParsed: true,
    };
  }
}
