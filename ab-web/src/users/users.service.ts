import { Injectable, ConflictException, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { User, UserRole } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

export type CreateUserDto = {
  fullName?: string;
  email: string;
  password: string;
  phone?: string;
  city?: string;
  role?: UserRole;
  registrationNumber?: string;
  country?: string;
  companyName?: string;
  neighborhood?: string;
};

export type UpdateUserDto = Partial<CreateUserDto> & {
  isValidated?: boolean;
};

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createUserDto: CreateUserDto): Promise<User> {
    const { email, password, ...userData } = createUserDto;

    // Check if user already exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictException('Email already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await this.prisma.user.create({
      data: {
        ...userData,
        email,
        password: hashedPassword,
      },
    });

    // Remove password from response
    const { password: _, ...userWithoutPassword } = user;
    return userWithoutPassword as User;
  }

  async findAll(role?: UserRole): Promise<User[]> {
    const users = await this.prisma.user.findMany({
      where: role ? { role } : undefined,
      orderBy: { createdAt: 'desc' },
    });

    // Remove passwords from response
    return users.map(user => {
      const { password, ...userWithoutPassword } = user;
      return userWithoutPassword as User;
    });
  }

  async findOne(id: number): Promise<User> {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        roles: true,
        products: true,
        comments: true,
        orders: true,
      },
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    // Remove password from response
    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword as unknown as User;
  }

  async findByEmail(email: string): Promise<User | null> {
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      return null;
    }

    return user;
  }

  async update(id: number, updateUserDto: UpdateUserDto): Promise<User> {
    const { password, ...userData } = updateUserDto;

    // Prepare update data
    const updateData: any = { ...userData };

    // Hash password if provided
    if (password) {
      updateData.password = await bcrypt.hash(password, 10);
    }

    try {
      const user = await this.prisma.user.update({
        where: { id },
        data: updateData,
      });

      // Remove password from response
      const { password: _, ...userWithoutPassword } = user;
      return userWithoutPassword as User;
    } catch (error) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
  }

  async remove(id: number): Promise<void> {
    try {
      await this.prisma.user.delete({
        where: { id },
      });
    } catch (error) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
  }

  async validateUser(email: string, password: string): Promise<User | null> {
    const user = await this.findByEmail(email);
    
    if (user && await bcrypt.compare(password, user.password)) {
      // Remove password from response
      const { password: _, ...userWithoutPassword } = user;
      return userWithoutPassword as User;
    }

    return null;
  }

  async getSellers(): Promise<User[]> {
    return this.findAll(UserRole.seller);
  }

  async getCustomers(): Promise<User[]> {
    return this.findAll(UserRole.customer);
  }

  async getAdmins(): Promise<User[]> {
    return this.findAll(UserRole.admin);
  }

  async validateSeller(id: number): Promise<User> {
    return this.update(id, { isValidated: true });
  }

  async getUnvalidatedSellers(): Promise<User[]> {
    const users = await this.prisma.user.findMany({
      where: {
        role: UserRole.seller,
        isValidated: false,
      },
      orderBy: { createdAt: 'desc' },
    });

    // Remove passwords from response
    return users.map(user => {
      const { password, ...userWithoutPassword } = user;
      return userWithoutPassword as User;
    });
  }
}
