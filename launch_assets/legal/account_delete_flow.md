# 🗑️ Account Delete Flow — Apple Zorunlu

**Apple Guideline 5.1.1(v):** **Yeni hesap oluşturmaya izin veren her app, app içinden hesap silme yöntemi sunmak ZORUNDADIR.**

Bu kural **17 Haziran 2022'den beri** zorunlu. Eksiklik = anında reject.

**Google Play kuralı:** Mart 2024'ten beri benzer zorunluluk geldi.

---

## 📋 Apple'ın Net Gereksinimleri

✅ **App içinden başlatılabilmeli** (sadece web link YETERSİZ)
✅ **Settings/Profile sekmesinde belirgin yerleştirilmeli**
✅ **2-3 tap ile ulaşılabilmeli**
✅ **Verilerin silineceği açıkça belirtilmeli**
✅ **Onay adımı olmalı (kazara silmeyi önle)**
✅ **Aktif aboneliği iptal etme yönlendirmesi olmalı**
✅ **30 gün içinde verilerin silindiği belirtilmeli** (recommended)

---

## 🎨 UI/UX Flow

### Adım 1: Settings → Account
**Konum:** Settings → Account → "Delete Account" (kırmızı buton, en alt)

```
┌─────────────────────────────┐
│  ← Account                  │
│                             │
│  PROFILE                    │
│  Name: Ali Mirbağırzade    │
│  Email: ali@nuveli.app      │
│  [Edit Profile]             │
│                             │
│  SUBSCRIPTION               │
│  Premium Active             │
│  [Manage Subscription]      │
│                             │
│  DATA                       │
│  [Export My Data (CSV)]     │
│                             │
│  ───────────────────────    │
│                             │
│  DANGER ZONE                │
│  [Delete Account]  ⚠️       │  ← kırmızı buton
│                             │
└─────────────────────────────┘
```

### Adım 2: Delete Account Modal

Buton tıklandığında full-screen modal açılır:

```
┌─────────────────────────────────┐
│  ← Delete Account               │
│                                 │
│  ⚠️ This action is permanent    │
│                                 │
│  Deleting your account will:    │
│  • Remove all your meal logs    │
│  • Delete weight history        │
│  • Cancel any habits/streaks    │
│  • Erase your AI Coach insights │
│  • Remove all uploaded photos   │
│                                 │
│  ⏱️ This cannot be undone.      │
│  Data deletion completes        │
│  within 30 days.                │
│                                 │
│  💳 Subscription:               │
│  You still have an active       │
│  Premium subscription. We       │
│  cannot cancel it for you.      │
│  Please cancel it first via:    │
│  [Open App Store Subscriptions] │
│                                 │
│  ─────────────────────────      │
│                                 │
│  To confirm, type "DELETE":     │
│  ┌─────────────────────────┐    │
│  │                         │    │
│  └─────────────────────────┘    │
│                                 │
│  [Cancel]    [Delete Forever]   │  ← Delete disabled until "DELETE" yazılır
│                                 │
└─────────────────────────────────┘
```

### Adım 3: Final Confirmation

```
┌─────────────────────────────┐
│  ⚠️ Are you sure?           │
│                             │
│  This will permanently      │
│  delete your account and    │
│  all data. There is no      │
│  recovery.                  │
│                             │
│  [Cancel]  [Yes, Delete]    │
└─────────────────────────────┘
```

### Adım 4: Silme İşlemi

```
┌─────────────────────────────┐
│                             │
│       ⏳ Deleting...        │
│                             │
│   Removing your data...     │
│   This may take a moment    │
│                             │
└─────────────────────────────┘
```

### Adım 5: Confirmation Screen

```
┌─────────────────────────────┐
│                             │
│       ✅ Account Deleted    │
│                             │
│   Your account has been     │
│   marked for deletion.      │
│                             │
│   All data will be erased   │
│   within 30 days.           │
│                             │
│   We're sorry to see you    │
│   go. Thank you for trying  │
│   Nuveli.                   │
│                             │
│   [Close App]               │
│                             │
└─────────────────────────────┘
```

App otomatik logout olur ve splash screen'e döner.

---

## 💻 Flutter Implementation

### 1. Delete Account Screen

`lib/features/profile/screens/delete_account_screen.dart`:

```dart
class DeleteAccountScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmController = TextEditingController();
  bool _hasActiveSubscription = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
    _confirmController.addListener(() => setState(() {}));
  }

  Future<void> _checkSubscription() async {
    final customerInfo = await Purchases.getCustomerInfo();
    setState(() {
      _hasActiveSubscription = customerInfo.entitlements.active.isNotEmpty;
    });
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);
    try {
      // 1. Backend'e delete request gönder
      await ref.read(authRepoProvider).deleteAccount();
      
      // 2. Local data temizle (Hive cache)
      await Hive.deleteFromDisk();
      
      // 3. Notifications iptal
      await FlutterLocalNotificationsPlugin().cancelAll();
      
      // 4. Logout
      await Supabase.instance.client.auth.signOut();
      
      // 5. Success screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AccountDeletedScreen()),
        );
      }
    } catch (e) {
      setState(() => _isDeleting = false);
      showDialog(/* error dialog */);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConfirmed = _confirmController.text.trim().toUpperCase() == 'DELETE';
    
    return Scaffold(
      appBar: AppBar(title: Text('Delete Account')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'This action is permanent',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              Text('Deleting your account will:'),
              SizedBox(height: 8),
              _bullet('Remove all your meal logs'),
              _bullet('Delete weight history'),
              _bullet('Cancel any habits/streaks'),
              _bullet('Erase your AI Coach insights'),
              _bullet('Remove all uploaded photos'),
              SizedBox(height: 16),
              Text(
                '⏱️ This cannot be undone. Data deletion completes within 30 days.',
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 16),
              if (_hasActiveSubscription) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('💳 Subscription Active', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                        'You still have an active Premium subscription. We cannot cancel it for you. Please cancel it first.',
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          // iOS
                          launchUrl(Uri.parse('https://apps.apple.com/account/subscriptions'));
                          // Android: https://play.google.com/store/account/subscriptions
                        },
                        child: Text('Open App Store Subscriptions →'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
              Text('To confirm, type "DELETE" below:'),
              SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                decoration: InputDecoration(
                  hintText: 'Type DELETE',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: (isConfirmed && !_isDeleting) ? _deleteAccount : null,
                      child: _isDeleting 
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Delete Forever'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _bullet(String text) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text('• '),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
```

### 2. Backend Endpoint

`backend/app/routers/account.py`:

```python
from fastapi import APIRouter, Depends, HTTPException
from app.dependencies import get_current_user
from app.services.account_service import AccountService

router = APIRouter(prefix="/account", tags=["account"])

@router.delete("/me")
async def delete_my_account(
    current_user: dict = Depends(get_current_user),
    account_service: AccountService = Depends(),
):
    """
    Soft delete account. Hard delete happens after 30 days via cron job.
    """
    user_id = current_user["sub"]
    
    # 1. Mark account for deletion (soft delete)
    await account_service.mark_for_deletion(user_id)
    
    # 2. Delete sensitive data immediately (per GDPR Article 17)
    await account_service.delete_pii(user_id)  # email, name
    
    # 3. Trigger photo deletion (Supabase Storage)
    await account_service.delete_user_photos(user_id)
    
    # 4. Cancel any RevenueCat user attributes (subscription stays with Apple/Google)
    await account_service.anonymize_revenuecat(user_id)
    
    return {"status": "deleted", "permanent_deletion_at": "30 days"}
```

### 3. Account Service (Supabase)

`backend/app/services/account_service.py`:

```python
class AccountService:
    async def mark_for_deletion(self, user_id: str):
        # Update user_profiles
        await self.supabase.table("user_profiles").update({
            "deleted_at": "now()",
            "deletion_scheduled_for": "now() + interval '30 days'",
            "email": None,  # Anonymize immediately
            "name": "Deleted User",
        }).eq("user_id", user_id).execute()
        
        # Anonymize meals
        await self.supabase.table("meals").update({
            "photo_url": None,
            "user_id": None,  # Detach from user, keep for aggregate analytics
        }).eq("user_id", user_id).execute()
    
    async def delete_user_photos(self, user_id: str):
        # Supabase Storage bucket'tan kullanıcı fotolarını sil
        files = await self.supabase.storage.from_("meals").list(user_id)
        for file in files:
            await self.supabase.storage.from_("meals").remove([
                f"{user_id}/{file['name']}"
            ])
    
    async def delete_pii(self, user_id: str):
        # Auth tablosundan kullanıcıyı sil (Supabase auth.users)
        await self.supabase.auth.admin.delete_user(user_id)
```

### 4. 30-Day Cleanup Cron Job

`backend/app/cron/account_cleanup.py`:

```python
async def cleanup_deleted_accounts():
    """
    Run daily. Permanently delete accounts marked for deletion 30+ days ago.
    """
    deleted_users = await supabase.table("user_profiles").select("user_id").lt(
        "deletion_scheduled_for", "now()"
    ).execute()
    
    for user in deleted_users.data:
        # Hard delete all related rows
        await supabase.table("meals").delete().eq("user_id", user["user_id"]).execute()
        await supabase.table("water_logs").delete().eq("user_id", user["user_id"]).execute()
        await supabase.table("weight_logs").delete().eq("user_id", user["user_id"]).execute()
        await supabase.table("habits").delete().eq("user_id", user["user_id"]).execute()
        await supabase.table("habit_completions").delete().eq("user_id", user["user_id"]).execute()
        await supabase.table("meal_plans").delete().eq("user_id", user["user_id"]).execute()
        await supabase.table("ai_insights").delete().eq("user_id", user["user_id"]).execute()
        await supabase.table("user_profiles").delete().eq("user_id", user["user_id"]).execute()
        
        logger.info(f"Permanently deleted user {user['user_id']}")
```

---

## ⚠️ Subscription Handling

**Apple/Google rule:** Hesap silinse bile abonelik **otomatik iptal olmaz**. Kullanıcı abonelikten ayrıca çıkmalı.

**UX:** Yukarıdaki modal'da bunu açıkça belirt + Subscription Settings'e link ver.

**Refund:** Hesap silindiğinde kullanılmayan abonelik dönemi için refund verilmez (Apple/Google policy).

---

## ✅ Apple Reviewer Check

App Review sırasında Apple bunları test eder:

- [ ] Settings'te "Delete Account" linki var
- [ ] Tıklayınca delete confirmation flow başlar
- [ ] Confirmation adımları var (kazara silmeyi önler)
- [ ] Veriler gerçekten siliniyor (backend kontrolü)
- [ ] App içinde silme yapılabilir (sadece web link DEĞİL)
- [ ] Aktif abonelik bildirimi var
- [ ] Yardım email'i veya destek linki var

---

## 🚨 Yaygın Reject Sebepleri

| Hata | Apple Reject Code |
|---|---|
| "Delete Account" sadece web'de | 5.1.1(v) — App içi delete zorunlu |
| 5+ tap gerektiren süreç | 5.1.1(v) — "Easily discoverable" değil |
| Onay adımı yok (tek tıkla sileniyor) | 5.1.1(v) — User confirmation zorunlu |
| Subscription bilgisi yok | 3.1.2 — Subscription disclosure |
| Delete butonu hiç çalışmıyor | 2.1 — App crash on action |

---

## 📋 Submission Checklist

- [ ] `DeleteAccountScreen` Flutter'da implement edildi
- [ ] Settings → Account → Delete butonu var
- [ ] Backend `/account/me` DELETE endpoint çalışıyor
- [ ] Soft delete (mark for deletion) implement edildi
- [ ] Hard delete cron job (30 gün sonra) kurulu
- [ ] Test edildi: hesap silindikten sonra login dene → "Account not found"
- [ ] Supabase Storage'dan fotolar siliniyor
- [ ] App Store Reviewer notlarına eklenecek: "To test account deletion, login with reviewer@nuveli.app then Settings → Account → Delete Account"

---

**Önemli:** Test sırasında **gerçekten** delete olmalı. Sahte "delete" gösteren UI'lar reject olur. Reviewer hesabını gerçekten siliyor.
