# Hata Akışları

## Genel İlke

- Her hata kullanıcıya anlamlı ve yargısız bir mesajla iletilir.
- Teknik hata mesajları kullanıcıya gösterilmez.
- Kritik hatalar Crashlytics'e loglanır.
- Recovery yolu her zaman sunulur.

---

## Hata Kategorileri

### 1. Ağ Hatası
**Tetikleyici:** İnternet bağlantısı yok veya timeout  
**UI:** "Bağlantı kurulamadı. Tekrar dene." + Retry butonu  
**Davranış:** Cache varsa cache'ten sun, yoksa empty state

### 2. Auth Hatası
**Tetikleyici:** Token süresi dolmuş veya geçersiz  
**UI:** Kullanıcı logout yapılır, login ekranına yönlendirilir  
**Log:** Crashlytics non-fatal

### 3. Meal Analiz Hatası
**Tetikleyici:** OpenAI API hatası veya tanımlama başarısız  
**UI:** "Şu an analiz yapamıyorum. Manuel giriş yapar mısın?"  
**Fallback:** Manual meal entry ekranına geçiş

### 4. Limit Aşımı
**Tetikleyici:** `LIMIT_EXCEEDED` hata kodu  
**UI:** Paywall ekranı, şefkatli mesajla  
**Recovery:** Trial teklifi veya premium yönlendirmesi

### 5. Koç Yanıt Hatası
**Tetikleyici:** Coach service hatası  
**UI:** Fallback copy metni gösterilir (AI yanıtı gibi görünür)  
**Log:** Silent fail, kullanıcı fark etmez

### 6. Sunucu Hatası (5xx)
**Tetikleyici:** Backend 500 döndürür  
**UI:** "Bir şeyler ters gitti. Az sonra tekrar dene."  
**Log:** Crashlytics fatal event

---

## Flutter Error Handling Deseni

```dart
// Repository katmanında
try {
  final result = await apiClient.fetchSomething();
  return Right(result);
} on NetworkException {
  return Left(AppError.network());
} on UnauthorizedException {
  return Left(AppError.auth());
} catch (e, stack) {
  FirebaseCrashlytics.instance.recordError(e, stack);
  return Left(AppError.unknown());
}
```

---

## Backend Error Handling Deseni

```python
# Route katmanında
@router.get("/endpoint")
async def endpoint(user=Depends(get_current_user)):
    try:
        result = await some_service.do_work(user.id)
        return {"data": result, "error": None}
    except LimitExceededException:
        raise HTTPException(status_code=429, detail={
            "code": "LIMIT_EXCEEDED",
            "message": "Günlük limitine ulaştın."
        })
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail={
            "code": "INTERNAL_ERROR",
            "message": "Bir şeyler ters gitti."
        })
```

---

## Empty State Kuralları

- Veri yoksa ekran boş bırakılmaz.
- Her empty state için: illüstrasyon/ikon + kısa metin + CTA.
- Metin yargısız ve davetkar olmalı.

| Ekran | Empty State Metni |
|-------|-------------------|
| Meal listesi | "Henüz öğün kaydın yok. İlk yemeği ekleyelim!" |
| Koç thread | "Koçuna bir şey sormak ister misin?" |
| İlerleme | "Birkaç gün kayıt yaptıktan sonra grafiğin burada belirir." |
