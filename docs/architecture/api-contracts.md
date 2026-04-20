# API Contracts

## Genel Kurallar

- Tüm endpointler `Authorization: Bearer <supabase_jwt>` gerektirir (health hariç).
- Response formatı standart:
```json
{
  "data": {},
  "error": null
}
```
- Hata durumunda:
```json
{
  "data": null,
  "error": {
    "code": "ERROR_CODE",
    "message": "Kullanıcıya gösterilebilir mesaj"
  }
}
```

---

## Endpoint Listesi (MVP)

### Health
```
GET /health
Response: { "status": "ok", "version": "1.0.0" }
```

---

### Profile & Onboarding
```
POST   /profile/onboarding
POST   /profile/coach-preferences
POST   /profile/notification-preferences
POST   /profile/complete-onboarding
GET    /profile
GET    /app/bootstrap
```

**GET /app/bootstrap** — Uygulama açılışında tek çağrı ile tüm state'i alır:
```json
{
  "profile": {},
  "coach_preferences": {},
  "premium_status": {},
  "onboarding_completed": true
}
```

---

### Meals
```
POST   /meals/analyze          # Fotoğraf/metin → AI analiz
POST   /meals/{id}/confirm     # AI sonucunu onayla
POST   /meals/{id}/edit        # Düzenle & kaydet
POST   /meals/manual           # Manuel giriş
GET    /meals?local_day=YYYY-MM-DD
DELETE /meals/{id}
```

---

### Home
```
GET    /home                   # Composite home payload
GET    /summary/daily?local_day=...
GET    /usage/today
```

---

### Water & Weight & Checkin
```
POST   /water
GET    /water?local_day=...
POST   /weight
GET    /weight/history
POST   /checkins
```

---

### Coach
```
POST   /coach/respond
GET    /coach/thread
POST   /coach/thread/message
```

---

### Premium
```
GET    /premium/status
GET    /premium/features
POST   /premium/trial-claim
```

---

### Summary
```
GET    /summary/weekly/current
GET    /summary/monthly/current
```

---

### Notifications & Devices
```
POST   /devices/push-token
GET    /notifications/preferences
PATCH  /notifications/preferences
```

---

### Safety
```
GET    /safety/status
GET    /safety/resources
POST   /safety/acknowledge
```

---

## Hata Kodları

| Kod | Anlam |
|-----|-------|
| `AUTH_REQUIRED` | Token yok veya geçersiz |
| `LIMIT_EXCEEDED` | Günlük kullanım limiti aşıldı |
| `ANALYSIS_FAILED` | AI analiz yapamadı |
| `NOT_FOUND` | Kayıt bulunamadı |
| `VALIDATION_ERROR` | İstek doğrulama hatası |
| `INTERNAL_ERROR` | Sunucu hatası |
