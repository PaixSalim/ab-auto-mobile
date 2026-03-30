import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcryptjs';
import { canonicalRoleSlug, prismaSlugsForEnum } from './role-slug.util';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(data: any) {
    const {
      email,
      password,
      fullName,
      phone,
      city,
      companyName,
      neighborhood,
      registrationNumber,
    } = data;

    const wantsSeller =
      data.isSeller === true ||
      data.isSeller === 'true' ||
      data.isSeller === 'on';
    const wantsCustomer =
      data.isSeller === false ||
      data.isSeller === 'false';

    let userRole: 'customer' | 'seller' = 'customer';
    if (wantsSeller) {
      userRole = 'seller';
    } else if (wantsCustomer) {
      userRole = 'customer';
    } else {
      // Ancien formulaire (page inscription) : indices « pro » sans champ isSeller
      const proSignals =
        [companyName, neighborhood, registrationNumber].some(
          (v) => v != null && String(v).trim().length > 0,
        );
      userRole = proSignals ? 'seller' : 'customer';
    }

    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictException('Email already exists');
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const roleSlug = userRole === 'seller' ? 'seller' : 'customer';
    const roleRow = await this.prisma.role.findUnique({
      where: { slug: roleSlug },
    });

    const user = await this.prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        fullName,
        role: userRole,
        phone: phone || null,
        city: city || null,
        companyName: companyName || null,
        neighborhood: neighborhood || null,
        registrationNumber: registrationNumber || null,
        isValidated: userRole !== 'seller',
        ...(roleRow
          ? { roles: { connect: { id: roleRow.id } } }
          : {}),
      },
    });

    return this.login(user);
  }

  async login(user: any) {
    const payload = { sub: user.id, email: user.email, role: user.role };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
      },
    };
  }

  async validateUser(uid: string, pass: string): Promise<any> {
    
    // Validation des entrées
    if (!uid || uid.trim() === '') {
      return null;
    }
    
    if (!pass || pass.trim() === '') {
      return null;
    }
    
    const trimmed = uid.trim();
    const emailCandidates = trimmed.includes('@')
      ? Array.from(new Set([trimmed, trimmed.toLowerCase()]))
      : [trimmed];

    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          ...emailCandidates.map((e) => ({ email: e })),
          { phone: trimmed },
        ],
      },
      include: { roles: true },
    });


    if (user) {
      const stored = user.password ?? '';
      const looksBcrypt = /^\$2[aby]\$\d{2}\$/.test(stored);
      let isPasswordValid = looksBcrypt
        ? await bcrypt.compare(pass, stored)
        : pass === stored;

      // Anciens comptes (ex. créés depuis le dashboard sans hash) : migrer vers bcrypt
      if (isPasswordValid && !looksBcrypt) {
        const hashed = await bcrypt.hash(pass, 10);
        await this.prisma.user.update({
          where: { id: user.id },
          data: { password: hashed },
        });
      }

      
      if (isPasswordValid) {
        // Validation supplémentaire : s'assurer que l'email n'est pas vide
        if (!user.email || user.email.trim() === '') {
          return null;
        }
        
        const { password, ...result } = user;
        return result;
      } else {
      }
    } else {
    }
    
    return null;
  }

  async getUserWithPermissions(token: string) {
    try {
      const payload = this.jwtService.verify(token);
      if (!payload || !payload.sub) return null;

      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
        include: {
          roles: {
            include: { permissions: true }
          }
        }
      });

      if (!user) return null;

      let roles = user.roles.map((r: any) => canonicalRoleSlug(r.slug));
      // Comptes créés sans liaison Role (legacy) : utiliser l’enum `user.role`
      if (roles.length === 0 && user.role) {
        roles = [user.role];
      }
      roles = [...new Set(roles)];

      const permissionsSlugs = new Set<string>();
      for (const role of user.roles) {
        role.permissions?.forEach((p: any) => permissionsSlugs.add(p.slug));
      }

      // Toujours fusionner les permissions liées à l’enum `user.role` (slugs alias :
      // admin / administrateur, etc.). Sinon un utilisateur peut être connecté à une
      // ligne `Role` vide alors que les droits sont sur l’autre slug, ou inversement.
      if (user.role) {
        const rolesForEnum = await this.prisma.role.findMany({
          where: { slug: { in: prismaSlugsForEnum(user.role) } },
          include: { permissions: true },
        });
        for (const r of rolesForEnum) {
          r.permissions?.forEach((p: any) => permissionsSlugs.add(p.slug));
        }
      }

      const { password, roles: _roles, ...safeUser } = user;

      return {
        user: safeUser,
        roles,
        permissions: Array.from(permissionsSlugs)
      };
    } catch (e) {
      return null;
    }
  }
}
