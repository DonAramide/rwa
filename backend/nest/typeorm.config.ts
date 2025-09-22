import 'reflect-metadata';
import { DataSource } from 'typeorm';
import * as dotenv from 'dotenv';

dotenv.config();

const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL || 'postgresql://mac:@localhost:5432/rwa',
  entities: [
    'apps/api-gateway/src/modules/**/*.entity.{ts,js}',
  ],
  migrations: [
    'migrations/*.{ts,js}',
  ],
  synchronize: false,
  logging: true,
});

export default AppDataSource;














