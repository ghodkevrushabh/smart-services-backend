import { Controller, Get, Post, Body, Patch, Param, Delete, Query } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get()
  findAll() {
    return this.usersService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(+id);
  }

 @Get('role/:role')
  findByRole(
    @Param('role') role: string, 
    @Query('lat') lat?: string,
    @Query('lng') lng?: string,
    @Query('category') category?: string
  ) {
    // Convert strings to numbers
    const latitude = lat ? parseFloat(lat) : undefined;
    const longitude = lng ? parseFloat(lng) : undefined;
    
    return this.usersService.findByRole(role, latitude, longitude, category);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(+id, updateUserDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.usersService.remove(+id);
  }
  // NEW: Save FCM Token
  @Patch(':id/token')
  updateToken(@Param('id') id: string, @Body('token') token: string) {
    return this.usersService.updateToken(+id, token);
  }
}