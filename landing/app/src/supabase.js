/**
 * Supabase auth istemcisi — Nuveli web abonelik portalı için.
 * Tek singleton; her yerden import edilebilir.
 */
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.warn('[nuveli] Supabase env missing — check .env');
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
  },
});

/**
 * Mevcut kullanıcı — null dönerse logged out.
 */
export async function getCurrentUser() {
  const { data, error } = await supabase.auth.getUser();
  if (error || !data?.user) return null;
  return data.user;
}

/**
 * Magic link ile giriş — kullanıcıya e-posta gider.
 */
export async function signInWithEmail(email) {
  const { error } = await supabase.auth.signInWithOtp({
    email,
    options: {
      emailRedirectTo: window.location.origin + '/app/',
    },
  });
  if (error) throw error;
  return { sent: true };
}

/**
 * Çıkış.
 */
export async function signOut() {
  await supabase.auth.signOut();
}

/**
 * Auth state değişikliklerini dinle.
 */
export function onAuthChange(callback) {
  const { data } = supabase.auth.onAuthStateChange((event, session) => {
    callback(session?.user ?? null, event);
  });
  return () => data.subscription.unsubscribe();
}
