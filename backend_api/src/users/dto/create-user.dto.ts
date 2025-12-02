export class CreateUserDto {
  email: string;
  password: string;
  role?: string; // 'CUSTOMER' or 'WORKER'
  service_category?: string; // NEW: 'Plumber', 'Maid', etc.
}