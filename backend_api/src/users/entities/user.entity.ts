import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;

  @Column({ default: 'CUSTOMER' })
  role: string;

  @Column({ nullable: true })
  phone: string;

  // --- NEW PROFILE FIELDS (Make sure these have @Column!) ---
  
  @Column({ nullable: true })
  full_name: string;

  @Column({ nullable: true })
  bio: string;

  @Column({ nullable: true })
  agency_name: string;

  @Column({ nullable: true })
  experience_years: number;

  @Column({ nullable: true })
  profile_pic: string; // Stores the Base64 string

  @Column({ nullable: true })
  city: string;

  @Column({ nullable: true })
  fcm_token: string;

  // ----------------------------------------------------------

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}