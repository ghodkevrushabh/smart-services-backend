import { PartialType } from '@nestjs/mapped-types';
import { CreateUserDto } from './create-user.dto';

export class UpdateUserDto extends PartialType(CreateUserDto) {
  full_name?: string;
  bio?: string;
  agency_name?: string;
  experience_years?: number;
  profile_pic?: string;
  city?: string;
  phone?: string;
}