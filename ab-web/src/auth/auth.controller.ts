import { Controller, Post, Body, UnauthorizedException, HttpCode, HttpStatus, Res, Get, UseInterceptors, Req } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response } from 'express';
import type { Request } from 'express';
import { AuthService } from './auth.service';
import { InertiaService } from '../common/inertia/inertia.service';
import { resolvePostAuthRedirect } from './post-auth-redirect';
import { redirectWithFlash } from '../common/inertia/flash';

@Controller('auth')
export class AuthController {
  constructor(
    private authService: AuthService,
    private inertia: InertiaService
  ) {}

  @Get('check-user')
  async checkUser(@Res() res: Response) {
    try {
      const user = await this.authService['prisma'].user.findFirst({
        where: { email: 'test@example.com' }
      });
      
      if (user) {
        const isPasswordValid = await require('bcryptjs').compare('password123', user.password);
        return res.json({ 
          exists: true,
          email: user.email,
          passwordValid: isPasswordValid,
          user: {
            id: user.id,
            email: user.email,
            fullName: user.fullName,
            role: user.role
          }
        });
      } else {
        return res.json({ 
          exists: false,
          message: 'Utilisateur non trouvé'
        });
      }
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  }

  @Post('register')
  async register(@Req() req: Request, @Res() res: Response) {
    try {
      // Parser manuellement le FormData ou utiliser le Body JSON
      let registerDto: any;
      
      if (req.body && typeof req.body === 'object' && Object.keys(req.body).length > 0) {
        // FormData
        registerDto = {
          fullName: req.body.fullName,
          email: req.body.email,
          phone: req.body.phone,
          city: req.body.city,
          password: req.body.password,
          confirmPassword: req.body.confirmPassword,
          companyName: req.body.companyName,
          neighborhood: req.body.neighborhood,
          registrationNumber: req.body.registrationNumber,
          isSeller: req.body.isSeller,
        };
      } else {
        // JSON
        registerDto = req.body;
      }
      
      
      const data = await this.authService.register(registerDto);
      res.cookie('access_token', data.access_token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        path: '/',
      });
      const dest = resolvePostAuthRedirect({ role: data.user.role });
      return redirectWithFlash(res, dest, {
        type: 'success',
        title: 'Inscription',
        message: 'Compte créé avec succès. Bienvenue !',
      });
    } catch (error: any) {
      const raw =
        error?.response?.message ?? error?.message ?? 'Erreur lors de l’inscription';
      const flat = Array.isArray(raw) ? raw[0] : String(raw);
      const status = typeof error?.getStatus === 'function' ? error.getStatus() : error?.status;
      const emailMsg =
        status === 409 ||
        /already exists|déjà utilisé|duplicate/i.test(flat)
          ? 'Cette adresse e-mail est déjà utilisée.'
          : flat;
      return this.inertia.render('auth/register', {
        errors: {
          email: [emailMsg],
          password: [],
          fullName: [],
          phone: [],
          city: [],
        },
      });
    }
  }

  @Post('login')
  @UseInterceptors(FileInterceptor('none'))
  async login(@Req() req: Request, @Res() res: Response) {
    
    // Parser manuellement le FormData
    let uid = '';
    let password = '';
    
    if (req.body && typeof req.body === 'object') {
      uid = req.body.uid || req.body.email || '';
      password = req.body.password || '';
    }
    
    
    // Validation des entrées côté contrôleur
    if (!uid || uid.trim() === '') {
      return this.inertia.render('auth/login', {
        errors: {
          uid: ['Veuillez entrer votre email ou numéro de téléphone']
        }
      });
    }
    
    if (!password || password.trim() === '') {
      return this.inertia.render('auth/login', {
        errors: {
          uid: ['Veuillez entrer votre mot de passe']
        }
      });
    }
    
    try {
      const user = await this.authService.validateUser(uid, password);
      
      if (!user) {
        return this.inertia.render('auth/login', {
          errors: {
            uid: ['Email ou mot de passe incorrect']
          }
        });
      }
      
      const data = await this.authService.login(user);
      
      // Setting JWT as HttpOnly cookie
      res.cookie('access_token', data.access_token, { 
        httpOnly: true, 
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'lax',
        path: '/'
      });
      
      req.authenticatedUser = user;
      req.userRoles = user.roles ? user.roles.map((r: any) => r.slug) : [];

      const dest = resolvePostAuthRedirect(user);

      return redirectWithFlash(res, dest, {
        type: 'success',
        title: 'Connexion',
        message: 'Bienvenue !',
      });
    } catch (error) {
      return this.inertia.render('auth/login', {
        errors: {
          uid: ['Email ou mot de passe incorrect']
        }
      });
    }
  }

  @Post('logout')
  async logout(@Res() res: Response) {
    res.clearCookie('access_token', {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/'
    });
    return redirectWithFlash(res, '/', {
      type: 'success',
      title: 'Déconnexion',
      message: 'À bientôt.',
    });
  }

  @Get('logout')
  async logoutGet(@Res() res: Response) {
    res.clearCookie('access_token', {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/'
    });
    return redirectWithFlash(res, '/', {
      type: 'success',
      title: 'Déconnexion',
      message: 'À bientôt.',
    });
  }
}
