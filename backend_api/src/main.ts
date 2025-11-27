import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 1. Enable CORS (Allows your Flutter App to talk to this Backend later)
  app.enableCors();

  // 2. Build the Swagger "Control Panel"
  const config = new DocumentBuilder()
    .setTitle('Smart Services API')
    .setDescription('The backend for our Global Service App')
    .setVersion('1.0')
    .build();
  
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document); // This creates the website at /api

  // 3. Start the Server
  await app.listen(process.env.PORT || 3000);
}
bootstrap();