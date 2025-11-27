import { Injectable } from '@nestjs/common';
import { CreateBookingDto } from './dto/create-booking.dto';
import { UpdateBookingDto } from './dto/update-booking.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Booking } from './entities/booking.entity';
import { UsersService } from '../users/users.service';
import * as admin from 'firebase-admin';
import * as path from 'path';
import * as fs from 'fs'; // NEW: To check file existence

@Injectable()
export class BookingsService {
  constructor(
    @InjectRepository(Booking)
    private bookingsRepository: Repository<Booking>,
    private usersService: UsersService,
  ) {
    // SMART INIT: Check Cloud Vault first, then Local
    try {
      if (!admin.apps.length) {
        // 1. Define paths
        const renderSecretPath = '/etc/secrets/firebase-admin.json';
        const localPath = path.join(process.cwd(), 'firebase-admin.json');
        
        // 2. Decide which one to use
        let finalPath = localPath;
        if (fs.existsSync(renderSecretPath)) {
          finalPath = renderSecretPath;
          console.log("☁️ Found Cloud Secret Key!");
        } else {
          console.log("💻 Using Local Secret Key.");
        }

        // 3. Initialize
        admin.initializeApp({
          credential: admin.credential.cert(finalPath),
        });
        console.log("🔥 Firebase Admin Initialized Successfully");
      }
    } catch (error) {
      console.warn("⚠️ Firebase Init Failed:", error.message);
    }
  }

  async create(createBookingDto: CreateBookingDto) {
    const booking = await this.bookingsRepository.save(createBookingDto);

    try {
      const provider = await this.usersService.findOne(createBookingDto.provider_id);
      if (provider && provider.fcm_token) {
        await admin.messaging().send({
          token: provider.fcm_token,
          notification: {
            title: 'New Job Alert! 🚨',
            body: `A customer needs a ${createBookingDto.service_category}. Check app now!`,
          },
          data: { bookingId: booking.id.toString() }
        });
        console.log(`🔔 Notification sent to ${provider.email}`);
      }
    } catch (error) {
      console.error("⚠️ Notification Failed:", error.message);
    }

    return booking;
  }

  findAll() {
    return this.bookingsRepository.find({ order: { created_at: 'DESC' } });
  }

  findOne(id: number) {
    return this.bookingsRepository.findOneBy({ id });
  }

  update(id: number, updateBookingDto: UpdateBookingDto) {
    return this.bookingsRepository.update(id, updateBookingDto);
  }

  remove(id: number) {
    return this.bookingsRepository.delete(id);
  }

  findByUser(userId: number) {
    return this.bookingsRepository.find({
      where: [
        { customer_id: userId },
        { provider_id: userId }
      ],
      order: { created_at: 'DESC' }
    });
  }
}