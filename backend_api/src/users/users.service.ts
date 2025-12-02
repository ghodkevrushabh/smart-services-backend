import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import * as bcrypt from 'bcrypt'; // Import the encryption tool

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  // NEW: Update the token in DB
  async updateToken(id: number, token: string) {
    return this.usersRepository.update(id, { fcm_token: token });
  }

  async create(createUserDto: CreateUserDto) {
    // 1. Generate a "Salt" (Random data to make encryption unique)
    const salt = await bcrypt.genSalt();

    // 2. Encrypt the password
    const hashedPassword = await bcrypt.hash(createUserDto.password, salt);

    // 3. Replace the plain password with the hashed one
    const secureUser = {
      ...createUserDto,
      password: hashedPassword,
    };

    // 4. Save the SECURE user to the database
    return this.usersRepository.save(secureUser);
  }

  findAll() {
    return this.usersRepository.find();
  }

  findOne(id: number) {
    return this.usersRepository.findOneBy({ id });
  }

  // MODIFIED: Find workers in a specific city
  findByRole(role: string, city?: string, category?: string) {
    const query: any = { role: role };
    
    if (city && city !== 'Unknown') {
      query.city = city;
    }
    
    // NEW: Filter by Service Category (e.g., "Maid")
    if (category) {
      query.service_category = category;
    }

    return this.usersRepository.find({ where: query });
  }
}