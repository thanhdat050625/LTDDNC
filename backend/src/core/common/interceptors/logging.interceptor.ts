import { Injectable, NestInterceptor, ExecutionContext, CallHandler, Logger } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const req = context.switchToHttp().getRequest();
    const method = req.method;
    const url = req.url;
    const now = Date.now();

    return next.handle().pipe(
      tap({
        next: () => {
          const res = context.switchToHttp().getResponse();
          const statusCode = res?.statusCode || 200;
          const responseTime = Date.now() - now;
          this.logger.log(`${method} ${url} - ${statusCode} - ${responseTime}ms`);
        },
        error: (err) => {
          const statusCode =
            err?.status ||
            (typeof err?.getStatus === 'function' ? err.getStatus() : 500);
          const responseTime = Date.now() - now;
          this.logger.warn(`${method} ${url} - ${statusCode} - ${responseTime}ms`);
        },
      }),
    );
  }
}