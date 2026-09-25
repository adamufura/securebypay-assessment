# Myafrimall — SecureByPay Technical Assessment

Flutter Web frontend and NestJS API for sign up, login, and a shipments dashboard. Built to match the Myafrimall Figma designs.

## Live demo

- **App:** https://securebypay-assessment-frontend.vercel.app
- **API:** https://securebypay-assessment.vercel.app/api/health
- **Test login:** `demo@myafrimall.dev` / `Demo12345`

## Stack

- Flutter Web (Riverpod, go_router, fl_chart)
- NestJS + MongoDB Atlas
- Hosted on Vercel (API in `apps/api`, web in `apps/web`)

## Run locally

**API**

```bash
cd apps/api
cp ../../.env.example .env
# fill in MONGODB_URI and JWT_SECRET
npm install
npm run start:dev
```

**Web**

```bash
cd apps/web
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
```

## API endpoints

| Method | Path | Notes |
|--------|------|--------|
| GET | `/api/health` | Public |
| POST | `/api/auth/register` | Creates account + seed data |
| POST | `/api/auth/login` | Returns JWT |
| POST | `/api/auth/forgot` | Always returns success |
| GET | `/api/auth/me` | Auth required |
| GET | `/api/dashboard` | Auth required |
| GET | `/api/shipments` | Auth required |

## Author

Adamu Fura Suleiman  
[hi@adamspro.dev](mailto:hi@adamspro.dev) · [github.com/adamufura](https://github.com/adamufura) · [adamspro.dev](https://adamspro.dev)
