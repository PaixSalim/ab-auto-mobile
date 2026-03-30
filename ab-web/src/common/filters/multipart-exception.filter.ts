import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class MultipartExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(MultipartExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';

    // Gérer les erreurs de multer/multipart
    if (exception instanceof Error) {
      if (exception.message.includes('Multipart: Unexpected end of form') ||
          exception.message.includes('Unexpected field') ||
          exception.message.includes('File too large') ||
          exception.message.includes('Too many files')) {
        status = HttpStatus.BAD_REQUEST;
        message = exception.message;
      }
    }

    // Vérifier si c'est une requête Inertia
    const isInertiaRequest = request.headers['x-inertia'] === 'true';
    const isInertiaPartial = request.headers['x-inertia-partial-component'];

    if (isInertiaRequest) {
      // Pour les requêtes Inertia, rediriger avec un message d'erreur
      const referer = request.headers.referer || '/';
      
      if (isInertiaPartial) {
        // Pour les requêtes partielles, retourner une réponse JSON avec l'erreur
        return response.status(status).json({
          message: message,
          error: true,
        });
      } else {
        // Pour les requêtes complètes, rediriger avec un flash message
        return response.status(303).header('Location', referer).send();
      }
    }

    // Pour les requêtes non-Inertia, retourner JSON normal (sans détails techniques en prod)
    if (!response.headersSent) {
      const isProd = process.env.NODE_ENV === 'production';
      const safeMessage =
        status >= 500 && isProd
          ? 'Une erreur interne est survenue.'
          : message;
      const payload: Record<string, unknown> = {
        statusCode: status,
        message: safeMessage,
        timestamp: new Date().toISOString(),
      };
      if (!isProd) {
        payload.path = request.url;
      }
      response.status(status).json(payload);
    }
  }
}
