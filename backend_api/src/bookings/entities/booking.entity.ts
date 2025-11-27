import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('bookings')
export class Booking {
  @PrimaryGeneratedColumn()
  id: number;

  // 1. Link to the Customer (Who booked?)
  @ManyToOne(() => User, { eager: true }) // eager: true means "Load the user details automatically"
  @JoinColumn({ name: 'customer_id' })
  customer: User;

  @Column()
  customer_id: number; // We store the ID directly for easy access

  // 2. Link to the Worker (Who is doing the job?)
  @ManyToOne(() => User, { eager: true })
  @JoinColumn({ name: 'provider_id' })
  provider: User;

  @Column()
  provider_id: number;

  // 3. Job Details
  @Column()
  service_category: string; // e.g., "Plumber"

  @Column({ default: 'PENDING' }) 
  status: string; // 'PENDING', 'ACCEPTED', 'COMPLETED', 'CANCELLED'

  @Column()
  scheduled_date: Date; // When should they come?

  // NEW: Rating (1 to 5 Stars)
  @Column({ nullable: true })
  rating: number;

  // NEW: Review Comment
  @Column({ nullable: true })
  review_comment: string;

  @CreateDateColumn()
  created_at: Date;
}