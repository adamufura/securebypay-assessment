import { createNestExpressApp } from './create-app';
import { env } from './config/env';

async function bootstrap() {
  const app = await createNestExpressApp();
  app.listen(env.port, () => {
    console.log(`API listening on http://localhost:${env.port}/api`);
  });
}

void bootstrap();
