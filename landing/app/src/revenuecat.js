/**
 * Nuveli — RevenueCat Web Billing entegrasyonu
 *
 * Bu modül `@revenuecat/purchases-js` üzerine thin wrapper sağlar:
 *  - Tek Purchases instance (singleton)
 *  - Supabase user ID ile identified customers (mobil + web entitlement birleşir)
 *  - Paywall display
 *  - Entitlement kontrolü (`nuveli_pro`)
 *  - Customer info retrieval + caching
 *  - Hata yönetimi
 *
 * Mimari notu:
 *  - Anonymous kullanıcılara izin yok; önce Supabase login zorunlu
 *  - Mobile uygulamadaki user ID ile aynı ID burada da kullanılır →
 *    aynı kişi web'de veya mobile'da abone olursa `nuveli_pro` her iki yerde aktif
 */

import { Purchases, ErrorCode, PurchasesError } from '@revenuecat/purchases-js';

const PUBLIC_API_KEY = import.meta.env.VITE_REVENUECAT_PUBLIC_KEY;
const ENTITLEMENT_ID = import.meta.env.VITE_RC_ENTITLEMENT_ID || 'nuveli_pro';

if (!PUBLIC_API_KEY) {
  console.warn('[nuveli] VITE_REVENUECAT_PUBLIC_KEY missing. Set it in .env');
}

/**
 * Purchases instance cache. configure() sadece bir kez çağrılır.
 */
let purchasesInstance = null;
let currentAppUserId = null;

/**
 * RC SDK'yı kullanıcı kimliğiyle yapılandırır.
 * @param {string} supabaseUserId - Supabase auth user id (uuid)
 * @returns {Promise<Purchases>}
 */
export async function configureRevenueCat(supabaseUserId) {
  if (!supabaseUserId) {
    throw new Error('configureRevenueCat: supabaseUserId required (no anonymous).');
  }

  if (purchasesInstance && currentAppUserId === supabaseUserId) {
    return purchasesInstance;
  }

  // Farklı user → önceki instance'ı kapat, yeniden configure et
  if (purchasesInstance && currentAppUserId !== supabaseUserId) {
    try {
      purchasesInstance.close?.();
    } catch (_) {
      // ignore
    }
    purchasesInstance = null;
  }

  purchasesInstance = Purchases.configure(PUBLIC_API_KEY, supabaseUserId);
  currentAppUserId = supabaseUserId;
  return purchasesInstance;
}

/**
 * Shared Purchases instance. configure() sonrası her yerden kullanılabilir.
 */
export function getPurchases() {
  if (!purchasesInstance) {
    throw new Error('RevenueCat not configured. Call configureRevenueCat(userId) first.');
  }
  return purchasesInstance;
}

// ───────────────────────────────────────────────
// Customer Info + Entitlements
// ───────────────────────────────────────────────

/**
 * En güncel CustomerInfo'yu RC backend'den getirir.
 * @returns {Promise<Object>} customerInfo
 */
export async function getCustomerInfo() {
  const purchases = getPurchases();
  try {
    return await purchases.getCustomerInfo();
  } catch (err) {
    console.error('[nuveli] getCustomerInfo failed:', err);
    throw mapError(err);
  }
}

/**
 * Kullanıcının Nuveli Pro entitlement'ı aktif mi?
 * @returns {Promise<boolean>}
 */
export async function hasNuveliPro() {
  const info = await getCustomerInfo();
  return ENTITLEMENT_ID in (info.entitlements?.active ?? {});
}

/**
 * Kullanıcının herhangi bir aktif entitlement'ı var mı?
 * @returns {Promise<boolean>}
 */
export async function hasAnyEntitlement() {
  const info = await getCustomerInfo();
  return Object.keys(info.entitlements?.active ?? {}).length > 0;
}

// ───────────────────────────────────────────────
// Offerings + Packages
// ───────────────────────────────────────────────

/**
 * RC dashboard'dan yapılandırılmış offering'i getirir.
 * `current` offering (default olarak işaretlenen) döner.
 * @returns {Promise<Object|null>}
 */
export async function getCurrentOffering() {
  const purchases = getPurchases();
  try {
    const offerings = await purchases.getOfferings();
    return offerings.current;
  } catch (err) {
    console.error('[nuveli] getOfferings failed:', err);
    throw mapError(err);
  }
}

/**
 * Belirli bir paket tipini getirir (lifetime / yearly / monthly).
 * Package identifier'ları RC dashboard'da yapılandırılmış olmalı.
 */
export async function getPackage(identifier) {
  const offering = await getCurrentOffering();
  if (!offering) return null;

  // RC standart package identifier'ları: $rc_monthly, $rc_annual, $rc_lifetime
  const map = {
    monthly: '$rc_monthly',
    yearly: '$rc_annual',
    lifetime: '$rc_lifetime',
  };
  const rcIdentifier = map[identifier] ?? identifier;

  return offering.availablePackages.find((p) => p.identifier === rcIdentifier) ?? null;
}

// ───────────────────────────────────────────────
// Purchase
// ───────────────────────────────────────────────

/**
 * Seçilen paketi satın alır. Stripe checkout akışı başlatır.
 * @param {Object} pkg - RC Package
 * @param {Object} [opts]
 * @param {string} [opts.customerEmail] - E-posta biliniyorsa otomatik doldurulur
 * @param {HTMLElement} [opts.htmlTarget] - Mount element; yoksa modal açılır
 * @returns {Promise<{success: boolean, hasPro: boolean, cancelled?: boolean, error?: string}>}
 */
export async function purchasePackage(pkg, opts = {}) {
  const purchases = getPurchases();

  try {
    const result = await purchases.purchase({
      rcPackage: pkg,
      customerEmail: opts.customerEmail,
      htmlTarget: opts.htmlTarget,
    });

    const customerInfo = result.customerInfo;
    const hasPro = ENTITLEMENT_ID in (customerInfo?.entitlements?.active ?? {});

    return { success: true, hasPro, customerInfo };
  } catch (err) {
    if (err instanceof PurchasesError) {
      if (err.errorCode === ErrorCode.UserCancelledError) {
        return { success: false, cancelled: true };
      }
      return { success: false, error: err.message };
    }
    console.error('[nuveli] purchase failed:', err);
    return { success: false, error: 'Satın alma tamamlanamadı. Tekrar dener misin?' };
  }
}

// ───────────────────────────────────────────────
// Paywall (RC hosted UI)
// ───────────────────────────────────────────────

/**
 * RC dashboard'da tasarlanmış paywall'ı gösterir.
 * Kullanıcı checkout'u bitirene veya iptal edene kadar Promise resolve olmaz.
 * @param {HTMLElement} container - Paywall'ın render edileceği element
 * @param {Object} [offering] - Belirli bir offering; omit edilirse current
 * @returns {Promise<{success: boolean, hasPro?: boolean, cancelled?: boolean, error?: string}>}
 */
export async function presentPaywall(container, offering = null) {
  const purchases = getPurchases();

  if (!container || !(container instanceof HTMLElement)) {
    throw new Error('presentPaywall: container must be a valid HTMLElement');
  }

  try {
    const result = await purchases.presentPaywall({
      htmlTarget: container,
      ...(offering && { offering }),
    });

    const customerInfo = result.customerInfo;
    const hasPro = ENTITLEMENT_ID in (customerInfo?.entitlements?.active ?? {});

    return { success: true, hasPro, customerInfo };
  } catch (err) {
    if (err instanceof PurchasesError && err.errorCode === ErrorCode.UserCancelledError) {
      return { success: false, cancelled: true };
    }
    console.error('[nuveli] presentPaywall failed:', err);
    return { success: false, error: 'Paywall açılamadı.' };
  }
}

// ───────────────────────────────────────────────
// User ID management
// ───────────────────────────────────────────────

/**
 * Kullanıcı hesabı değişti — RC için user id güncelle.
 * Logout'ta da çağrılmalı (yeni anonymous ID oluşturmak yerine
 * Supabase auth üzerinden yönetmek tercih edilir, login/signup zorunlu).
 */
export async function changeUser(supabaseUserId) {
  const purchases = getPurchases();
  try {
    return await purchases.changeUser(supabaseUserId);
  } catch (err) {
    console.error('[nuveli] changeUser failed:', err);
    throw mapError(err);
  }
}

// ───────────────────────────────────────────────
// Error mapping
// ───────────────────────────────────────────────

/**
 * RC hatalarını kullanıcı dostu Türkçe mesajlara çevirir.
 */
function mapError(err) {
  if (!(err instanceof PurchasesError)) {
    return new Error('Beklenmeyen bir hata oluştu. Tekrar dene.');
  }

  const messages = {
    [ErrorCode.NetworkError]: 'Bağlantı kurulamadı. İnternetini kontrol et.',
    [ErrorCode.UserCancelledError]: 'İşlem iptal edildi.',
    [ErrorCode.ProductNotAvailableForPurchaseError]: 'Bu paket şu an satın alınamıyor.',
    [ErrorCode.PurchaseInvalidError]: 'Ödeme onaylanamadı. Kartını kontrol et.',
    [ErrorCode.PaymentPendingError]: 'Ödeme bekliyor. Biraz sonra tekrar dene.',
    [ErrorCode.InvalidCredentialsError]: 'Kimlik bilgileri geçersiz.',
    [ErrorCode.UnknownError]: 'Bilinmeyen bir hata. Tekrar dener misin?',
  };

  const userMessage = messages[err.errorCode] ?? err.message ?? 'Bir sorun oluştu.';
  const wrapped = new Error(userMessage);
  wrapped.code = err.errorCode;
  wrapped.original = err;
  return wrapped;
}
