import { ParserRule } from '../parser.types';
import { ParsedEmail, ParsedTransaction } from '../../gmail/gmail.types';

export class OvoRule implements ParserRule {
  canParse(email: ParsedEmail): boolean {
    return (
      email.from.toLowerCase().includes('ovo.id') ||
      email.subject.toLowerCase().includes('ovo')
    );
  }

  parse(email: ParsedEmail): ParsedTransaction | null {
    const body = email.textBody + email.htmlBody;

    // Pola email OVO: "Rp 75.000"
    const amountMatch = body.match(/(?:Rp\.?\s*|IDR\s*)([\d.,]+)/i);
    const merchantMatch = body.match(/(?:ke|Merchant|Toko|pembayaran ke)\s*(.+?)(?:\n|<|\r)/i);
    const refMatch = body.match(/(?:Ref(?:erence)?|ID)\s*(?:No\.?)?\s*:\s*([A-Z0-9-]+)/i);
    const typeMatch: 'DEBIT' | 'CREDIT' =
      /(?:pembayaran|bayar|kirim|transfer keluar)/i.test(body) ? 'DEBIT' : 'CREDIT';

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
      transactionDate: email.date,
      source: 'OVO',
      rawEmailBody: email.textBody,
      isParsed: true,
    };
  }
}
