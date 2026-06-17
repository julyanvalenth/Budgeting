export interface ParsedEmail {
  messageId: string;
  subject: string;
  from: string;
  date: Date;
  textBody: string;
  htmlBody: string;
}

export interface ParsedTransaction {
  amount: number;
  currency: string;
  type: 'DEBIT' | 'CREDIT';
  description: string;
  merchant?: string | null;
  referenceNumber?: string | null;
  transactionDate: Date;
  source: string;
  rawEmailBody?: string;
  isParsed: boolean;
}

export interface GmailSyncResult {
  checked: number;
  found: number;
  errors: string[];
}
