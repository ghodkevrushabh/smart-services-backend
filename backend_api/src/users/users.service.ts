import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import * as bcrypt from 'bcrypt'; // Import Bcrypt

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  // 1. Create User (WITH ENCRYPTION)
  async create(createUserDto: CreateUserDto) {
    // A. Generate Salt
    const salt = await bcrypt.genSalt();
    
    // B. Hash the Password
    const hashedPassword = await bcrypt.hash(createUserDto.password, salt);

    // C. Save Securely
    const secureUser = {
      ...createUserDto,
      password: hashedPassword,
    };

    return this.usersRepository.save(secureUser);
  }

  // 2. Find All Users
  findAll() {
    return this.usersRepository.find();
  }

  // 3. Find One User by ID
  findOne(id: number) {
    return this.usersRepository.findOneBy({ id });
  }

  // 4. Find by Role (With City & Category Filters)
  findByRole(role: string, city?: string, category?: string) {
    const query: any = { role: role };
    
    if (city && city !== 'Unknown') {
      query.city = city;
    }
    
    if (category) {
      query.service_category = category;
    }

    return this.usersRepository.find({ where: query });
  }

  // 5. Update User
  update(id: number, updateUserDto: UpdateUserDto) {
    return this.usersRepository.update(id, updateUserDto);
  }

  // 6. Remove User
  remove(id: number) {
    return this.usersRepository.delete(id);
  }

  // 7. Update FCM Token (For Notifications)
  async updateToken(id: number, token: string) {
    return this.usersRepository.update(id, { fcm_token: token });
  }
}