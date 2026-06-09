// Full user journey: Identify -> Scan (camera fallback chooser on desktop)
// -> wizard with photo attached -> fill species -> leaves photo -> submit.
const { chromium } = require('@playwright/test');
const {
  loginWithEmail,
  grantGeolocation,
  uploadGalleryPhoto,
  wizardNext,
  wizardSubmit,
  MOCK_TREE_PHOTO,
  TARGET_LAT,
  TARGET_LON,
} = require('../helpers');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({
    colorScheme: 'light',
    viewport: { width: 390, height: 844 },
  });
  await grantGeolocation(page, { latitude: TARGET_LAT, longitude: TARGET_LON });
  await loginWithEmail(page, {
    email: `e2e${Date.now()}@example.com`,
    password: 'E2eTestPass123!',
    allowSignup: true,
  });

  // Scan path: the capture button opens a file chooser on GNSS-less desktops.
  await page.getByRole('button', { name: 'Identify' }).first().click();
  const [chooser] = await Promise.all([
    page.waitForEvent('filechooser', { timeout: 20_000 }),
    page.getByRole('button', { name: 'Scan' }).first().click(),
  ]);
  await chooser.setFiles(MOCK_TREE_PHOTO);

  await page.getByText('Tree report').waitFor({ timeout: 60_000 });
  const attached = await page.getByRole('button', { name: /remove photo/i }).count();
  console.log('scan -> wizard opened, attached photos:', attached);
  if (attached < 1) throw new Error('scanned photo missing from draft');

  await page.getByRole('textbox', { name: 'Species (common name)' }).click();
  await page.keyboard.type('Olive', { delay: 20 });
  await wizardNext(page);
  await wizardNext(page);
  await uploadGalleryPhoto(page);
  await wizardSubmit(page);

  await page
    .getByText('Report submitted')
    .or(page.getByText('Tree insights'))
    .first()
    .waitFor({ timeout: 60_000 });
  console.log('SUBMIT PASSED');
  await browser.close();
})().catch((e) => {
  console.error('PROBE FAILED:', e.message);
  process.exit(1);
});
