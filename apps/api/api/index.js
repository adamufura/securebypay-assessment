let cached;

/**
 * Vercel serverless entry for NestJS.
 * Build step runs `nest build` first; this loads `dist/`.
 */
module.exports = async function handler(req, res) {
  if (!cached) {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const { createNestExpressApp } = require('../dist/create-app');
    cached = await createNestExpressApp();
  }
  return cached(req, res);
};
