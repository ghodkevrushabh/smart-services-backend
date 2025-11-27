export class CreateBookingDto {
  customer_id: number;
  provider_id: number;
  service_category: string;
  scheduled_date: string; // Send as "2025-10-15T10:00:00Z"
}