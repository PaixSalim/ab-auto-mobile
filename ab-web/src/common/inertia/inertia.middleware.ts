import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { InertiaService } from './inertia.service';
import { AuthService } from '../../auth/auth.service';
import { FLASH_COOKIE, clearFlashCookie, type FlashPayload } from './flash';

@Injectable()
export class InertiaMiddleware implements NestMiddleware {
  constructor(
    private inertiaService: InertiaService,
    private authService: AuthService,
  ) {}

  async use(req: Request, res: Response, next: NextFunction) {
    this.inertiaService.init(req, res);
    (res as any).inertia = this.inertiaService;
    
    // Auth Sharing
    let authData = { user: null, roles: [], permissions: [] };
    
    const cookieHeader = req.headers.cookie;
    if (cookieHeader) {
      const cookies = Object.fromEntries(
        cookieHeader.split('; ').map(c => {
          const parts = c.split('=');
          return [parts[0], decodeURIComponent(parts.slice(1).join('='))]
        })
      );
      
      if (cookies['access_token']) {
        const data = await this.authService.getUserWithPermissions(cookies['access_token']);
        if (data) {
          authData = data as any;
          (req as any).auth = authData;
          (req as any).user = authData.user;
        }
      }

      if (cookies[FLASH_COOKIE]) {
        try {
          const parsed = JSON.parse(
            decodeURIComponent(cookies[FLASH_COOKIE]),
          ) as FlashPayload;
          if (parsed?.message) {
            this.inertiaService.share('flash', parsed);
            clearFlashCookie(res);
          }
        } catch {
          clearFlashCookie(res);
        }
      }
    }
    
    this.inertiaService.share('auth', authData);

    // Handle Inertia redirects (303 for non-GET requests)
    const oldRedirect = res.redirect.bind(res);
    res.redirect = function (statusOrUrl: any, url?: string) {
      const address = typeof statusOrUrl === 'number' ? url : statusOrUrl;
      const status = typeof statusOrUrl === 'number' ? statusOrUrl : 302;

      // Inertia exige une redirection 303 après POST/PUT/PATCH/DELETE (évite bug de navigation).
      if (
        req.headers['x-inertia'] &&
        !['GET', 'HEAD'].includes(req.method)
      ) {
        return res.status(303).header('Location', address as string).send();
      }

      if (url) {
        return oldRedirect(status, url);
      }
      return oldRedirect(statusOrUrl);
    } as any;

    next();
  }
}
