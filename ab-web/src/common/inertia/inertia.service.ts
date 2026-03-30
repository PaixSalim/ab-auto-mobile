import { Injectable, Scope } from '@nestjs/common';
import { Request, Response } from 'express';
import { readFileSync, existsSync } from 'fs';
import { join } from 'path';

@Injectable({ scope: Scope.REQUEST })
export class InertiaService {
  private sharedProps: Record<string, any> = {};
  private req: Request;
  private res: Response;

  init(req: Request, res: Response) {
    this.req = req;
    this.res = res;
  }

  share(key: string, value: any) {
    this.sharedProps[key] = value;
  }

  /**
   * @param urlOverride — après un POST Inertia, fixe l’URL affichée (ex. /dashboard/products)
   */
  async render(
    component: string,
    props: Record<string, any> = {},
    urlOverride?: string,
  ) {
    const url = urlOverride ?? (this.req.originalUrl || this.req.url);
  const version = '1.2';

  // Deep-merge 'auth' so page-level auth doesn't erase shared permissions/roles.
  const mergedProps = { ...this.sharedProps, ...props };
  if (this.sharedProps['auth'] && props['auth']) {
    mergedProps['auth'] = { ...this.sharedProps['auth'], ...props['auth'] };
  }

  const page = {
    component,
    props: mergedProps,
    url,
    version,
  };

  if (this.req.headers['x-inertia']) {
    this.res.setHeader('X-Inertia', 'true');
    this.res.setHeader('Vary', 'X-Inertia');
    const body = JSON.stringify(page);
    this.res.setHeader('Content-Type', 'application/json; charset=utf-8');
    return this.res.end(Buffer.from(body, 'utf8'));
  }

  const manifestPath = join(process.cwd(), 'public/build/.vite/manifest.json');
  let mainJs = ''; 
  let mainCss = ''; 
  const isDev = process.env.NODE_ENV !== 'production' && !existsSync(manifestPath);

  if (existsSync(manifestPath)) {
    try {
      const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
      const entry = manifest['inertia/app/app.ts'];
      if (entry) {
        mainJs = `/build/${entry.file}`;
        if (entry.css && entry.css.length > 0) {
          mainCss = `/build/${entry.css[0]}`;
        }
      }
    } catch (e) {
    }
  }

  return this.res.render('app', {
    inertiaPage: Buffer.from(JSON.stringify(page)).toString('base64'),
    mainJs,
    mainCss,
    isDev,
  });
}


}
