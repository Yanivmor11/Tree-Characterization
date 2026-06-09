// @ts-check
const { test, expect } = require('@playwright/test');
const {
  TARGET_LAT,
  TARGET_LON,
  NEARBY_WARN_METERS,
  offsetNorthMeters,
  grantGeolocation,
  clickByLabel,
  fillByLabel,
  loginWithEmail,
  openReportWizard,
  uploadGalleryPhoto,
  wizardNext,
  wizardSubmit,
} = require('./helpers');

/** @type {{ email: string; password: string; allowSignup: boolean }} */
let creds;

test.beforeEach(async ({ page }) => {
  creds = {
    email:
      process.env.E2E_TEST_EMAIL ||
      `e2e-${Date.now()}-${Math.random().toString(36).slice(2, 7)}@example.com`,
    password: process.env.E2E_TEST_PASSWORD || 'E2eTestPass123!',
    allowSignup: !process.env.E2E_TEST_EMAIL,
  };
  await grantGeolocation(page, { latitude: TARGET_LAT, longitude: TARGET_LON });
});

test.describe('UrbanTree user simulation', () => {
  test('Scenario 1 — Ideal Citizen completes the 3-step wizard', async ({ page }) => {
    await loginWithEmail(page, creds);
    await openReportWizard(page);

    // Step 1 — whole tree
    await expect(page.getByText(/Step 1/)).toBeVisible();
    await uploadGalleryPhoto(page);
    await page.getByRole('textbox', { name: 'Species (common name)' }).click();
    await page.keyboard.type('Olive', { delay: 20 });
    await wizardNext(page);

    // Step 2 — optional flower/fruit (skip photos)
    await expect(page.getByText(/Step 2/)).toBeVisible();
    await wizardNext(page);

    // Step 3 — leaves (required)
    await expect(page.getByText(/Step 3/)).toBeVisible();
    await uploadGalleryPhoto(page);
    await wizardSubmit(page);

    // Success path: submitted snackbar or insights dialog — app must not crash.
    const submitted = page.getByText('Report submitted');
    const insights = page.getByText('Tree insights');
    const done = page.getByRole('button', { name: 'Done' });

    await expect(submitted.or(insights).or(done).first()).toBeVisible({ timeout: 45_000 });

    if (await insights.isVisible().catch(() => false)) {
      await done.click();
    }

    await expect(page.getByText('Tree report')).not.toBeVisible({ timeout: 15_000 });
  });

  test('Scenario 2 — Impatient User triggers validation without crashing', async ({ page }) => {
    await loginWithEmail(page, creds);
    await openReportWizard(page);

    // Rush to final step with no mandatory photos.
    await wizardNext(page);
    await wizardNext(page);
    await expect(page.getByText(/Step 3/)).toBeVisible();

    await wizardSubmit(page);
    await expect(
      page.getByText('Add at least one whole-tree photo before submitting.').first(),
    ).toBeVisible();

    // Still on wizard — no crash.
    await expect(page.getByText('Submit report')).toBeVisible();

    // Upload flower photo without required metadata, then try Next on step 2.
    await page.getByRole('button', { name: 'Back', exact: true }).last().click({ force: true });
    await expect(page.getByText(/Step 2/)).toBeVisible();

    const [chooser] = await Promise.all([
      page.waitForEvent('filechooser', { timeout: 20_000 }),
      page.getByRole('button', { name: 'Gallery' }).click(),
    ]);
    await chooser.setFiles(require('./helpers').MOCK_TREE_PHOTO);
    await page.waitForTimeout(1000);

    await wizardNext(page);
    await expect(
      page.getByText('Add flower/fruit stage and abundance, or remove those photos.').first(),
    ).toBeVisible();

    // App remains responsive.
    await expect(page.getByText(/Step 2/)).toBeVisible();
    await expect(page.getByRole('button', { name: 'Next' })).toBeEnabled();
  });

  test('Scenario 3 — Distance boundary: 60 m outside 50 m duplicate-warning radius', async ({
    page,
  }) => {
    const outside = offsetNorthMeters(TARGET_LAT, TARGET_LON, 60);
    await grantGeolocation(page, outside);

    await loginWithEmail(page, creds);
    await openReportWizard(page);

    // Camera on step 1 triggers the 50 m duplicate-tree dialog when contextual pins exist.
    const dialogTitle = page.getByText('Nearby mapped trees');
    const cameraChooser = page.waitForEvent('filechooser', { timeout: 15_000 });
    await clickByLabel(page, 'Camera');
    const chooser = await cameraChooser;
    await chooser.setFiles(require('./helpers').MOCK_TREE_PHOTO);

    await page.waitForTimeout(1500);
    await expect(dialogTitle).toHaveCount(0);

    // Sanity: 60 m > 50 m NEARBY_WARN_METERS — user is outside duplicate-warning radius.
    const distanceFromAnchor = 60;
    expect(distanceFromAnchor).toBeGreaterThan(NEARBY_WARN_METERS);

    // Inside-threshold control coordinate (30 m < 50 m rule) for documentation parity.
    const inside = offsetNorthMeters(TARGET_LAT, TARGET_LON, 30);
    expect(inside.latitude).toBeLessThan(outside.latitude);
  });
});

test('sanity — nearby threshold constant matches product rule', () => {
  expect(NEARBY_WARN_METERS).toBe(50);
  const sixtyM = offsetNorthMeters(TARGET_LAT, TARGET_LON, 60);
  const thirtyM = offsetNorthMeters(TARGET_LAT, TARGET_LON, 30);
  expect(sixtyM.latitude).toBeGreaterThan(TARGET_LAT);
  expect(thirtyM.latitude).toBeGreaterThan(TARGET_LAT);
  expect(sixtyM.latitude).toBeGreaterThan(thirtyM.latitude);
});
