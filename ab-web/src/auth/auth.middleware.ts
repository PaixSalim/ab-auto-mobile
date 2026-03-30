import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';

// Étendre l'interface Request pour inclure nos propriétés personnalisées
declare global {
  namespace Express {
    interface Request {
      authenticatedUser?: any;
      userRoles?: string[];
      // user est déjà déclaré par Passport, on ne le redéclare pas
    }
  }
}

@Injectable()
export class AuthMiddleware implements NestMiddleware {
  constructor(
    private jwtService: JwtService,
    private prisma: PrismaService,
  ) {}

  async use(req: Request, res: Response, next: NextFunction) {
    // TEMPORAIRE : Bypass COMPLET de l'authentification pour TOUTES les routes
    return next();
    
    // Code original désactivé temporairement...
    /*
    // TEMPORAIRE : Bypass COMPLET de l'authentification pour TOUTES les routes
');
    return next();

    try {
      // Récupérer le token depuis le cookie
      const token = req.cookies?.access_token;
      
      if (token) {
        try {
          // Vérifier et décoder le token
          const payload = this.jwtService.verify(token);
          
          // Récupérer l'utilisateur avec ses rôles
          const user = await this.prisma.user.findUnique({
            where: { id: payload.sub },
            include: { 
              roles: true
            }
          });

          if (user) {
            // Ajouter l'utilisateur et ses rôles à la requête
            req.authenticatedUser = user;
            req.userRoles = user.roles.map((role: any) => role.slug);
            // req.user est déjà géré par Passport, on le met à jour
            (req as any).user = user;
            
          }
        } catch (error) {
          // Token invalide, effacer le cookie
          res.clearCookie('access_token', {
            httpOnly: true,
            secure: process.env.NODE_ENV === 'production',
            sameSite: 'lax',
            path: '/'
          });
        }
      } else {
      }
    } catch (error) {
    }

    next();
    */
  }
}
