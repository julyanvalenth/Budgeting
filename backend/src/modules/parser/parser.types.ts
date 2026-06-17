import { ParsedEmail, ParsedTransaction } from '../gmail/gmail.types';

export interface ParserRule {
  canParse(email: ParsedEmail): boolean;
  parse(email: ParsedEmail): ParsedTransaction | null;
}
