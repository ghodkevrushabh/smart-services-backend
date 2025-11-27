export class CreateUserDto {
  email: string;
  
  // No question mark! Password is REQUIRED.
  password: string; 
}