import { Response } from 'express';

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  message?: string;
  pagination?: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export function sendSuccess<T>(
  res: Response,
  data: T,
  message?: string,
  statusCode = 200,
  pagination?: ApiResponse['pagination']
): Response {
  const response: ApiResponse<T> = {
    success: true,
    data,
    ...(message && { message }),
    ...(pagination && { pagination }),
  };
  return res.status(statusCode).json(response);
}

export function sendError(
  res: Response,
  message: string,
  statusCode = 500,
  details?: unknown
): Response {
  const response: ApiResponse = {
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && details ? { data: details } : {}),
  };
  return res.status(statusCode).json(response);
}
