// SQLite dev mode: type enum diganti string literal
export type TransactionType = 'DEBIT' | 'CREDIT';

export interface TransactionFilters {
  startDate?: Date;
  endDate?: Date;
  categoryId?: string;
  type?: TransactionType;
  source?: string;
  page?: number;
  limit?: number;
}

export interface CreateTransactionDto {
  amount: number;
  currency?: string;
  type: TransactionType;
  description: string;
  merchant?: string;
  categoryId?: string;
  source?: string;
  transactionDate: string;
  referenceNumber?: string;
}

export interface UpdateTransactionDto {
  categoryId?: string;
  description?: string;
  merchant?: string;
}
