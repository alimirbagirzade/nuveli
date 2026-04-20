/**
 * Nuveli — Abonelik portalı akış yöneticisi
 *
 * Akış:
 *   1. Sayfa yüklenince Supabase session kontrolü
 *   2. Session yok → sign-in state
 *   3. Session var → RC configure, customerInfo al
 *   4. nuveli_pro aktif → pro state (customer center)
 *   5. nuveli_pro yok → paywall state
 */

import {
  supabase,
  getCurrentUser,
  signInWithEmail,
  signOut,
  onAuthChange,
} from './supabase.js';

import {
  configureRevenueCat,
  getCustomerInfo,
  hasNuveliPro,
  getCurrentOffering,
  purchasePackage,
  presentPaywall,
} from './revenuecat.js';

// ───────────────────────────────────────────────
// DOM refs
// ───────────────────────────────────────────────
const $ = (id) => document.getElementById(id);

const states = {
  loading: $('state-loading'),
  signin: $('state-signin'),
  pro: $('state-pro'),
  purchase: $('state-purchase'),
};

function showState(name) {
  Object.values(states).forEach((el) => el.classList.remove('active'));
  states[name].classList.add('active');
}

// ───────────────────────────────────────────────
// Sign-in flow
// ───────────────────────────────────────────────
$('send-link-btn').addEventListener('click', async () => {
  const emailInput = $('email-input');
  const email = emailInput.value.trim();
  const successMsg = $('signin-success');
  const errorMsg = $('signin-error');
  const btn = $('send-link-btn');

  successMsg.classList.remove('visible');
  errorMsg.classList.remove('visible');

  if (!email || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
    errorMsg.textContent = 'Geçerli bir e-posta yaz.';
    errorMsg.classList.add('visible');
    return;
  }

  btn.disabled = true;
  btn.textContent = 'Gönderiliyor...';

  try {
    await signInWithEmail(email);
    successMsg.textContent = `Giriş linkini ${email} adresine gönderdik. Mail'ini kontrol et.`;
    successMsg.classList.add('visible');
    emailInput.value = '';
  } catch (err) {
    console.error(err);
    errorMsg.textContent = err?.message ?? 'Link gönderilemedi. Tekrar dener misin?';
    errorMsg.classList.add('visible');
  } finally {
    btn.disabled = false;
    btn.textContent = 'Giriş Linki Gönder';
  }
});

$('signout-btn').addEventListener('click', async () => {
  await signOut();
  // onAuthChange tetiklenecek
});

// ───────────────────────────────────────────────
// Pro state — Customer Center
// ───────────────────────────────────────────────
function renderCustomerCenter(customerInfo) {
  const grid = $('customer-center-grid');
  const entitlement = customerInfo?.entitlements?.active?.nuveli_pro;

  const rows = [];

  if (entitlement) {
    rows.push({
      label: 'Plan',
      value: formatProductId(entitlement.productIdentifier),
    });
    if (entitlement.expirationDate) {
      const d = new Date(entitlement.expirationDate);
      const isLifetime = entitlement.periodType === 'lifetime' ||
                         entitlement.productIdentifier?.includes('lifetime');
      rows.push({
        label: isLifetime ? 'Geçerlilik' : 'Yenileme',
        value: isLifetime ? 'Ömür boyu' : d.toLocaleDateString('tr-TR'),
      });
    }
    if (entitlement.willRenew === false && entitlement.expirationDate) {
      rows.push({
        label: 'Durum',
        value: 'İptal edilmiş (süre sonuna kadar aktif)',
      });
    } else if (entitlement.willRenew === true) {
      rows.push({ label: 'Durum', value: 'Otomatik yenilenecek' });
    }
    if (entitlement.store) {
      rows.push({ label: 'Kanal', value: formatStore(entitlement.store) });
    }
  }

  rows.push({
    label: 'E-posta',
    value: $('user-email').textContent,
  });

  grid.innerHTML = rows
    .map(
      (r) => `
    <div class="cc-item">
      <h4>${r.label}</h4>
      <div class="value">${r.value}</div>
    </div>`
    )
    .join('');
}

function formatProductId(id) {
  if (!id) return '—';
  if (id.includes('monthly')) return 'Aylık';
  if (id.includes('yearly') || id.includes('annual')) return 'Yıllık';
  if (id.includes('lifetime')) return 'Ömür Boyu';
  return id;
}

function formatStore(store) {
  const map = {
    APP_STORE: 'App Store',
    PLAY_STORE: 'Google Play',
    STRIPE: 'Web',
    RC_BILLING: 'Web',
    PROMOTIONAL: 'Hediye',
  };
  return map[store] ?? store;
}

$('refresh-btn').addEventListener('click', async () => {
  const btn = $('refresh-btn');
  btn.disabled = true;
  btn.innerHTML = '<span class="loading"></span> Yenileniyor';
  try {
    const info = await getCustomerInfo();
    renderCustomerCenter(info);
  } catch (err) {
    console.error(err);
  } finally {
    btn.disabled = false;
    btn.textContent = 'Yenile';
  }
});

// ───────────────────────────────────────────────
// Purchase state — Paywall + fallback plans
// ───────────────────────────────────────────────
async function renderPurchaseState() {
  showState('purchase');
  // Default: RC paywall'ı göstermek için butona tıklanmasını bekle
  // (Paywall otomatik açıldığında kullanıcı "hangi sayfadayım" şaşkınlığı yaşamasın)

  // Fallback manuel planları da yükle — paywall yoksa işe yarar
  await loadFallbackPlans();
}

async function loadFallbackPlans() {
  try {
    const offering = await getCurrentOffering();
    if (!offering) return;

    const list = $('plans-list');
    list.innerHTML = '';

    const packages = offering.availablePackages ?? [];
    const planOrder = ['$rc_annual', '$rc_monthly', '$rc_lifetime'];
    const sorted = [...packages].sort(
      (a, b) => planOrder.indexOf(a.identifier) - planOrder.indexOf(b.identifier)
    );

    sorted.forEach((pkg, i) => {
      const product = pkg.webBillingProduct ?? pkg.rcBillingProduct ?? pkg;
      const price = product.currentPrice?.formattedPrice
        ?? product.priceString
        ?? '—';
      const type = pkg.identifier;
      const title = formatPackageTitle(type);
      const period = formatPackagePeriod(type);
      const featured = type === '$rc_annual';

      const features = [
        'Sınırsız öğün analizi',
        'Gelişmiş AI koç + sesli yanıt',
        'Haftalık özet · aylık içgörü',
        'Tüm ilerleme grafikleri',
      ];

      const el = document.createElement('div');
      el.className = 'plan' + (featured ? ' featured' : '');
      el.innerHTML = `
        <div class="plan-tag">${title}</div>
        <div class="plan-price">${price}</div>
        <div class="plan-period">${period}</div>
        <ul class="plan-features">
          ${features.map((f) => `<li>${f}</li>`).join('')}
        </ul>
        <button class="btn btn-primary" data-pkg-index="${packages.indexOf(pkg)}">
          Seç
        </button>
      `;
      list.appendChild(el);
    });

    // Bind purchase handlers
    list.querySelectorAll('[data-pkg-index]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const idx = parseInt(btn.dataset.pkgIndex, 10);
        const pkg = packages[idx];
        await handlePurchase(pkg, btn);
      });
    });
  } catch (err) {
    console.error('[nuveli] fallback plans load failed:', err);
  }
}

function formatPackageTitle(id) {
  if (id === '$rc_monthly') return 'Aylık';
  if (id === '$rc_annual') return 'Yıllık · Popüler';
  if (id === '$rc_lifetime') return 'Ömür Boyu';
  return id;
}

function formatPackagePeriod(id) {
  if (id === '$rc_monthly') return 'her ay · istediğin zaman iptal';
  if (id === '$rc_annual') return 'her yıl · ayda ~₺ tasarruf';
  if (id === '$rc_lifetime') return 'tek sefer · ömür boyu erişim';
  return '';
}

async function handlePurchase(pkg, btn) {
  const errorMsg = $('purchase-error');
  errorMsg.classList.remove('visible');

  btn.disabled = true;
  btn.innerHTML = '<span class="loading"></span> Yönlendiriliyor';

  try {
    const user = await getCurrentUser();
    const result = await purchasePackage(pkg, {
      customerEmail: user?.email,
    });

    if (result.success && result.hasPro) {
      // Success → pro state
      showProState(result.customerInfo);
    } else if (result.cancelled) {
      // Sessiz, kullanıcı iptal etti
    } else if (result.error) {
      errorMsg.textContent = result.error;
      errorMsg.classList.add('visible');
    }
  } catch (err) {
    errorMsg.textContent = err?.message ?? 'Satın alma tamamlanamadı.';
    errorMsg.classList.add('visible');
  } finally {
    btn.disabled = false;
    btn.textContent = 'Seç';
  }
}

// Paywall göster — RC hosted UI
$('show-paywall-btn').addEventListener('click', async () => {
  const container = $('paywall-container');
  const manualPlans = $('manual-plans');
  const btn = $('show-paywall-btn');

  btn.disabled = true;
  btn.innerHTML = '<span class="loading"></span> Açılıyor';

  try {
    const result = await presentPaywall(container);
    if (result.success && result.hasPro) {
      showProState(result.customerInfo);
    } else if (result.cancelled) {
      // Fallback manuel planları göster
      manualPlans.style.display = 'block';
      btn.style.display = 'none';
    } else if (result.error) {
      manualPlans.style.display = 'block';
      const errorMsg = $('purchase-error');
      errorMsg.textContent = result.error;
      errorMsg.classList.add('visible');
    }
  } catch (err) {
    console.error(err);
    manualPlans.style.display = 'block';
  } finally {
    btn.disabled = false;
    btn.textContent = 'Paketleri Göster';
  }
});

async function showProState(customerInfo) {
  renderCustomerCenter(customerInfo);
  showState('pro');
}

// ───────────────────────────────────────────────
// Main bootstrap
// ───────────────────────────────────────────────
async function bootstrap() {
  showState('loading');

  try {
    const user = await getCurrentUser();

    if (!user) {
      showState('signin');
      return;
    }

    // User logged in → show chip + configure RC
    $('user-chip').style.display = 'flex';
    $('user-email').textContent = user.email ?? user.id;

    await configureRevenueCat(user.id);

    const isPro = await hasNuveliPro();

    if (isPro) {
      const info = await getCustomerInfo();
      showProState(info);
    } else {
      await renderPurchaseState();
    }
  } catch (err) {
    console.error('[nuveli] bootstrap error:', err);
    showState('signin');
    const errorMsg = $('signin-error');
    errorMsg.textContent = 'Bir şey ters gitti. Yenile ve tekrar dene.';
    errorMsg.classList.add('visible');
  }
}

// Auth değişirse otomatik yeniden bootstrap
onAuthChange(() => {
  bootstrap();
});

// İlk yükleme
bootstrap();
