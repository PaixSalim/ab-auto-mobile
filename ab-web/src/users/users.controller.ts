import { 
  Controller, 
  Get, 
  Post, 
  Body, 
  Patch, 
  Param, 
  Delete, 
  Query,
  UseGuards,
  HttpStatus,
  HttpCode
} from '@nestjs/common';
import { UsersService, CreateUserDto, UpdateUserDto } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { UserRole } from '@prisma/client';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.superadmin)
  async create(@Body() createUserDto: CreateUserDto) {
    const user = await this.usersService.create(createUserDto);
    return {
      statusCode: HttpStatus.CREATED,
      message: 'User created successfully',
      data: user
    };
  }

  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.superadmin)
  async findAll(@Query('role') role?: UserRole) {
    const users = await this.usersService.findAll(role);
    return {
      statusCode: HttpStatus.OK,
      data: users
    };
  }

  @Get('sellers')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.superadmin)
  async getSellers() {
    const sellers = await this.usersService.getSellers();
    return {
      statusCode: HttpStatus.OK,
      data: sellers
    };
  }

  @Get('sellers/unvalidated')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.superadmin)
  async getUnvalidatedSellers() {
    const sellers = await this.usersService.getUnvalidatedSellers();
    return {
      statusCode: HttpStatus.OK,
      data: sellers
    };
  }

  @Get('customers')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.superadmin)
  async getCustomers() {
    const customers = await this.usersService.getCustomers();
    return {
      statusCode: HttpStatus.OK,
      data: customers
    };
  }

  @Get('admins')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.superadmin)
  async getAdmins() {
    const admins = await this.usersService.getAdmins();
    return {
      statusCode: HttpStatus.OK,
      data: admins
    };
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.superadmin)
  async findOne(@Param('id') id: string) {
    const user = await this.usersService.findOne(+id);
    return {
      statusCode: HttpStatus.OK,
      data: user
    };
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.superadmin)
  async update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    const user = await this.usersService.update(+id, updateUserDto);
    return {
      statusCode: HttpStatus.OK,
      message: 'User updated successfully',
      data: user
    };
  }

  @Post(':id/validate-seller')
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.superadmin)
  async validateSeller(@Param('id') id: string) {
    const user = await this.usersService.validateSeller(+id);
    return {
      statusCode: HttpStatus.OK,
      message: 'Seller validated successfully',
      data: user
    };
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.admin, UserRole.superadmin)
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Param('id') id: string) {
    await this.usersService.remove(+id);
  }
}
