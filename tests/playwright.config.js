// @ts-check
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const baseURL = process.env.BASE_URL || 'http://localhost:8080';
const useExternalServer = Boolean(process.env.BASE_URL);

/** @type {import('@playwright/test').PlaywrightTestConfig} */
module.exports = {
  testDir: '.',
  testMatch: 'user_simulation.spec.js',
  timeout: 180_000,
  expect: { timeout: 20_000 },
  fullyParallel: false,
  workers: 1,
  retries: process.env.CI ? 1 : 0,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    viewport: { width: 390, height: 844 },
    locale: 'en-US',
    colorScheme: 'light',
    geolocation: { latitude: 32.0853, longitude: 34.7818 },
    permissions: ['geolocation'],
  },
  webServer: useExternalServer
    ? undefined
    : {
        command: 'bash scripts/start-e2e-server.sh',
        cwd: __dirname,
        url: baseURL,
        reuseExistingServer: !process.env.CI,
        timeout: 300_000,
        stdout: 'pipe',
        stderr: 'pipe',
      },
};
