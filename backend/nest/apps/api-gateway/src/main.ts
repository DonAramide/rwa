import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './modules/app.module';
import { AuthService } from './modules/auth/auth.service';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS for Flutter web apps
  app.enableCors({
    origin: true, // Allow all origins for development
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    credentials: true,
  });
  
  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe({ 
    whitelist: true, 
    transform: true,
    forbidNonWhitelisted: true,
    transformOptions: {
      enableImplicitConversion: true,
    },
  }));
  
  // API prefix
  app.setGlobalPrefix('v1');
  
  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('RWA Platform API')
    .setDescription('Real World Assets tokenization platform API')
    .setVersion('1.0')
    .addBearerAuth()
    .addTag('Authentication', 'User authentication and authorization')
    .addTag('Admin Dashboard', 'Admin dashboard and management')
    .addTag('Assets', 'Asset management and tokenization')
    .addTag('Agents', 'Verification agents marketplace')
    .addTag('Revenue', 'Revenue distribution and payouts')
    .addTag('IoT', 'IoT device and telemetry management')
    .build();
    
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true,
    },
  });

  // Initialize default admin user
  try {
    const authService = app.get(AuthService);
    await authService.ensureAdminUser();
  } catch (error) {
    console.error('❌ Failed to create default admin user:', error.message);
  }

  const port = process.env.PORT ? parseInt(process.env.PORT) : 3000;
  await app.listen(port);
  
  console.log(`🚀 RWA Platform API running on: http://localhost:${port}`);
  console.log(`📚 API Documentation: http://localhost:${port}/api/docs`);
  console.log(`👤 Default Admin: admin@rwa-platform.com / admin123`);
}

bootstrap();








