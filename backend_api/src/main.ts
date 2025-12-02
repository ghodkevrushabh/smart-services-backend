import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';
import { json, urlencoded } from 'express'; // Import this

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 1. INCREASE PAYLOAD LIMIT (Critical for Base64 Images)
  app.use(json({ limit: '50mb' }));
  app.use(urlencoded({ extended: true, limit: '50mb' }));

  // 2. Enable CORS (Allow Mobile App access)
  app.enableCors();

  // 3. Global Validation (Protect against bad data)
  app.useGlobalPipes(new ValidationPipe({ transform: true }));

  // 4. Swagger Setup
  const config = new DocumentBuilder()
    .setTitle('Smart Services API')
    .setDescription('Enterprise Backend for Service Marketplace')
    .setVersion('2.0')
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);

  // 5. Start Server
  await app.listen(process.env.PORT || 3000);
  console.log(`🚀 Server running on port ${process.env.PORT || 3000}`);
}
bootstrap();