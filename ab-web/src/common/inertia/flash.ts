import type { Response } from 'express';

export const FLASH_COOKIE = 'inertia_flash';

export type FlashPayload = {
  type: 'success' | 'error' | 'warning' | 'info';
  title?: string;
  message: string;
};

const cookieOpts = () => ({
  maxAge: 60_000,
  httpOnly: true,
  sameSite: 'lax' as const,
  path: '/',
  secure: process.env.NODE_ENV === 'production',
});

export function setFlashCookie(res: Response, flash: FlashPayload): void {
  res.cookie(FLASH_COOKIE, encodeURIComponent(JSON.stringify(flash)), cookieOpts());
}

export function redirectWithFlash(
  res: Response,
  url: string,
  flash: FlashPayload,
  status = 303,
) {
  setFlashCookie(res, flash);
  return res.redirect(status, url);
}

export function clearFlashCookie(res: Response): void {
  res.clearCookie(FLASH_COOKIE, {
    path: '/',
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
  });
}
