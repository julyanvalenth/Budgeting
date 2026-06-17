import { ParserRule } from '../parser.types';
import { ParsedEmail, ParsedTransaction } from '../../gmail/gmail.types';

export class GopayRule implements ParserRule {
  canParse(email: ParsedEmail): boolean {
    return (
      email.from.toLowerCase().includes('gopay.co.id') ||
      email.from.toLowerCase().includes('gojek') ||
      email.subject.toLowerCase().includes('gopay')
    );
  }

  parse(email: ParsedEmail): ParsedTransaction | null {
    const body = email.textBody + email.htmlBody;

    // Pola email GoPay: "Rp 50.000" atau "IDR 50,000"
    const amountMatch = body.match(/(?:Rp\.?\s*|IDR\s*)([\d.,]+)/i);
    const merchantMatch = body.match(/(?:ke|to|Merchant|Toko)\s*:\s*(.+?)(?:\n|<|\r)/i);
    const refMatch = body.match(/(?:ID Transaksi|Transaction ID|Order ID)\s*:\s*([A-Z0-9-]+)/i);
    const typeMatch: 'DEBIT' | 'CREDIT' =
      /(?:pembayaran|bayar|kirim|transfer)/i.test(body) ? 'DEBIT' : 'CREDIT';

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
      source: 'GOPAY',
      rawEmailBody: email.textBody,
      isParsed: true,
    };
  }
}
