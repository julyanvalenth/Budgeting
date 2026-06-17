import Anthropic from '@anthropic-ai/sdk';
import { ParsedEmail, ParsedTransaction } from '../gmail/gmail.types';
import { ParserRule } from './parser.types';
import { BcaRule } from './rules/bca.rule';
import { MandiriRule } from './rules/mandiri.rule';
import { GopayRule } from './rules/gopay.rule';
import { OvoRule } from './rules/ovo.rule';
import { logger } from '../../utils/logger';

export class ParserService {
  private rules: ParserRule[] = [
    new BcaRule(),
    new MandiriRule(),
    new GopayRule(),
    new OvoRule(),
    // Tambah rule baru di sini
  ];

  async parse(email: ParsedEmail): Promise<ParsedTransaction | null> {
    // Cari rule yang cocok
    for (const rule of this.rules) {
      if (rule.canParse(email)) {
        try {
          const result = rule.parse(email);
          if (result) return result;
        } catch (err) {
          logger.warn(`Parser rule failed for email from ${email.from}:`, err);
        }
      }
    }

    // Fallback ke AI parser jika tidak ada rule yang cocok
    if (process.env.ANTHROPIC_API_KEY) {
      logger.info(`Using AI fallback parser for email: ${email.subject}`);
      return this.aiParse(email);
    }

    logger.debug(`No parser found for email from ${email.from}: ${email.subject}`);
    return null;
  }

  // AI fallback menggunakan Claude untuk email format tidak standar
  private async aiParse(email: ParsedEmail): Promise<ParsedTransaction | null> {
    const client = new Anthropic();

    const prompt = `
Parse the following bank/e-wallet email notification and extract transaction data.
Return ONLY valid JSON with this structure:
{
  "amount": number,
  "currency": "IDR",
  "type": "DEBIT" | "CREDIT",
  "description": "string",
  "merchant": "string or null",
  "referenceNumber": "string or null",
  "transactionDate": "ISO 8601 date string",
  "source": "bank/wallet name"
}
If this is NOT a transaction email, return null.

Email Subject: ${email.subject}
From: ${email.from}
Body: ${email.textBody.substring(0, 2000)}
    `;

    const response = await client.messages.create({
      model: 'claude-haiku-4-5-20251001',
      max_tokens: 500,
      messages: [{ role: 'user', content: prompt }],
    });

    try {
      const text = response.content[0].type === 'text' ? response.content[0].text : '';
      const parsed = JSON.parse(text);
      if (!parsed) return null;

      return {
        ...parsed,
        transactionDate: new Date(parsed.transactionDate),
        rawEmailBody: email.textBody,
        isParsed: true,
      };
    } catch {
      return null;
    }
  }
}

export const parserService = new ParserService();
