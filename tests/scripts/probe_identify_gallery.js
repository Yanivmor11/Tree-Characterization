// Probe: Identify -> gallery upload must open the report wizard with the
// picked photo attached (regression for discarded initialImage + GPS stall).
const { chromium } = require('@playwright/test');
const {
  loginWithEmail,
  grantGeolocation,
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

  await page.getByRole('button', { name: 'Identify' }).first().click();
  await page.getByRole('button', { name: 'Gallery' }).first().click();
  const addPhoto = page.getByRole('button', { name: 'Add photo' }).or(page.getByText('Add photo'));
  await addPhoto.first().waitFor({ timeout: 30_000 });

  const [chooser] = await Promise.all([
    page.waitForEvent('filechooser', { timeout: 20_000 }),
    addPhoto.first().click(),
  ]);
  await chooser.setFiles(MOCK_TREE_PHOTO);

  await page.getByText('Tree report').waitFor({ timeout: 60_000 });
  console.log('wizard opened');

  const removeButtons = await page
    .getByRole('button', { name: /remove photo/i })
    .count();
  console.log('attached photos on entry:', removeButtons);
  if (removeButtons < 1) {
    throw new Error('picked photo was not attached to the report draft');
  }
  console.log('PROBE PASSED');
  await browser.close();
})().catch((e) => {
  console.error('PROBE FAILED:', e.message);
  process.exit(1);
});
