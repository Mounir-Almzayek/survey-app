# APIs الخاصة بتطبيق الباحث (Researcher App APIs)

هذا الملف يوضح جميع APIs التي يحتاجها تطبيق الباحث ووظيفة كل واحد منها.

---

## 1. APIs المصادقة (Authentication APIs)

### 1.1 بدء تسجيل الدخول للباحث
- **Endpoint:** `POST /auth/researcher-login/initiate`
- **الوصف:** الخطوة الأولى في تسجيل الدخول - يرسل البريد الإلكتروني ويستقبل خيارات المصادقة (WebAuthn أو كلمة المرور)
- **الحالة:** ✅ مُنفذ في `lib/features/auth/repository/auth_online_repository.dart`

### 1.2 التحقق من تسجيل الدخول للباحث
- **Endpoint:** `POST /auth/researcher-login/verify-login`
- **الوصف:** الخطوة الثانية - يتحقق من بيانات المصادقة (WebAuthn credentials أو email/password) ويرجع access token
- **الحالة:** ✅ مُنفذ في `lib/features/auth/repository/auth_online_repository.dart`

### 1.3 الحصول على بيانات المستخدم
- **Endpoint:** `GET /auth/me`
- **الوصف:** يحصل على معلومات المستخدم الحالي (البروفايل)
- **الحالة:** ✅ مُنفذ في `lib/features/profile/repository/profile_online_repository.dart`

### 1.4 تسجيل الخروج
- **Endpoint:** `POST /auth/me/logout`
- **الوصف:** تسجيل الخروج من الجلسة الحالية
- **الحالة:** ✅ مُنفذ في `lib/features/profile/repository/profile_online_repository.dart`

### 1.5 تسجيل الخروج من جميع الأجهزة الأخرى
- **Endpoint:** `GET /auth/me/logout-from-all-other-devices`
- **الوصف:** تسجيل الخروج من جميع الجلسات على الأجهزة الأخرى
- **الحالة:** ❌ غير مُنفذ

### 1.6 تغيير اللغة
- **Endpoint:** `POST /auth/me/change-language`
- **الوصف:** تغيير لغة المستخدم
- **الحالة:** ❌ غير مُنفذ

### 1.7 حفظ Device Token
- **Endpoint:** `POST /auth/me/device-token/save-token`
- **الوصف:** حفظ device token للإشعارات (Push Notifications)
- **الحالة:** ❌ غير مُنفذ

### 1.8 الحصول على تفضيلات الإشعارات
- **Endpoint:** `GET /auth/me/notification-preferences`
- **الوصف:** الحصول على إعدادات الإشعارات للمستخدم
- **الحالة:** ❌ غير مُنفذ

### 1.9 تحديث تفضيلات الإشعارات
- **Endpoint:** `PUT /auth/me/notification-preferences/bulk`
- **الوصف:** تحديث إعدادات الإشعارات للمستخدم
- **الحالة:** ❌ غير مُنفذ

---

## 2. APIs الحضانة (Custody APIs)

### 2.1 الحصول على سجلات الحضانة
- **Endpoint:** `GET /researcher/custody`
- **الوصف:** الحصول على جميع سجلات الحضانة الخاصة بالباحث (الأجهزة التي تحت وصايته)
- **الحالة:** ❌ غير مُنفذ (يوجد صفحة `custody_page.dart` لكن بدون API)

### 2.2 إنشاء سجل حضانة جديد
- **Endpoint:** `POST /researcher/custody`
- **الوصف:** إنشاء سجل حضانة جديد (نقل جهاز من باحث لآخر)
- **الحالة:** ❌ غير مُنفذ

### 2.3 الحصول على سجل حضانة محدد
- **Endpoint:** `GET /researcher/custody/{id}`
- **الوصف:** الحصول على تفاصيل سجل حضانة محدد
- **الحالة:** ❌ غير مُنفذ

### 2.4 التحقق من سجل الحضانة
- **Endpoint:** `POST /researcher/custody/{id}/verify`
- **الوصف:** التحقق من كود التحقق عند استلام جهاز من باحث آخر
- **الحالة:** ❌ غير مُنفذ

### 2.5 إعادة إرسال كود التحقق
- **Endpoint:** `POST /researcher/custody/{id}/resend-code`
- **الوصف:** إعادة إرسال كود التحقق للحضانة
- **الحالة:** ❌ غير مُنفذ

---

## 3. APIs موقع الجهاز (Device Location APIs)

### 3.1 تحديث موقع الجهاز
- **Endpoint:** `POST /researcher/device-location/devices/{id}/location`
- **الوصف:** تحديث موقع الجهاز الفيزيائي (GPS coordinates)
- **الحالة:** ❌ غير مُنفذ

---

## 4. APIs الروابط العامة (Public Link APIs)

### 4.1 زيارة رابط عام
- **Endpoint:** `GET /public-link/{short_code}`
- **الوصف:** زيارة رابط عام والحصول على معلومات الاستطلاع
- **الحالة:** ❌ غير مُنفذ

### 4.2 بدء استجابة جديدة عبر رابط عام
- **Endpoint:** `POST /public-link/{short_code}/start`
- **الوصف:** بدء استجابة جديدة للاستطلاع عبر رابط عام
- **الحالة:** ❌ غير مُنفذ

### 4.3 حفظ إجابات قسم
- **Endpoint:** `POST /public-link/{short_code}/responses/{response_id}/sections/{section_id}`
- **الوصف:** حفظ إجابات قسم معين في الاستطلاع والمتابعة للقسم التالي
- **الحالة:** ❌ غير مُنفذ

### 4.4 التحقق من رابط عام (للباحث)
- **Endpoint:** `GET /researcher/public-link/{short_code}`
- **الوصف:** التحقق من صحة رابط عام والحصول على بيانات الاستطلاع (خاص بالباحث)
- **الحالة:** ❌ غير مُنفذ

---

## 5. APIs الاستجابات (Response APIs)

### 5.1 الحصول على تفاصيل الاستجابة
- **Endpoint:** `GET /researcher/response/{id}/details`
- **الوصف:** الحصول على تفاصيل شاملة للاستجابة (الإجابات، السجلات، المهمة، المستخدم، الجهاز)
- **الحالة:** ❌ غير مُنفذ

---

## 6. APIs الرفع (Upload APIs)

### 6.1 رفع صورة
- **Endpoint:** `POST /upload/image`
- **الوصف:** رفع صورة إلى الخادم
- **الحالة:** ❌ غير مُنفذ

### 6.2 رفع ملفات
- **Endpoint:** `POST /upload/files`
- **الوصف:** رفع ملفات إلى الخادم
- **الحالة:** ❌ غير مُنفذ

---

## 7. APIs تسجيل الجهاز (Device Registration APIs)

### 7.1 التحقق من Token التسجيل
- **Endpoint:** `GET /device-registration/validate-token/{token}`
- **الوصف:** التحقق من صحة token تسجيل الجهاز
- **الحالة:** ✅ مُنفذ في `lib/features/device_registration/`

### 7.2 تحدي WebAuthn للتسجيل
- **Endpoint:** `POST /device-registration/register/webauthn/challenge/{token}`
- **الوصف:** الحصول على challenge لـ WebAuthn عند تسجيل الجهاز
- **الحالة:** ✅ مُنفذ في `lib/features/device_registration/`

### 7.3 إكمال تسجيل WebAuthn
- **Endpoint:** `POST /device-registration/register/webauthn/complete/{token}`
- **الوصف:** إكمال تسجيل الجهاز باستخدام WebAuthn
- **الحالة:** ✅ مُنفذ في `lib/features/device_registration/`

### 7.4 إكمال تسجيل Cookie-based
- **Endpoint:** `POST /device-registration/register/cookie-based/complete/{token}`
- **الوصف:** إكمال تسجيل الجهاز باستخدام Cookie-based authentication
- **الحالة:** ✅ مُنفذ في `lib/features/device_registration/`

---

## 8. APIs أخرى (Other APIs)

### 8.1 Health Check
- **Endpoint:** `GET /health`
- **الوصف:** فحص حالة الخادم
- **الحالة:** ❌ غير مُنفذ

### 8.2 تسجيل أخطاء Frontend
- **Endpoint:** `POST /errors/frontend`
- **الوصف:** إرسال أخطاء من التطبيق إلى الخادم
- **الحالة:** ❌ غير مُنفذ

---

## ملخص الحالة

### ✅ مُنفذ (Implemented):
1. تسجيل الدخول للباحث (Initiate & Verify)
2. الحصول على البروفايل (`/auth/me`)
3. تسجيل الخروج (`/auth/me/logout`)
4. تسجيل الجهاز (جميع الطرق)

### ❌ غير مُنفذ (Not Implemented):
1. جميع APIs الحضانة (Custody)
2. تحديث موقع الجهاز
3. الروابط العامة (Public Links)
4. تفاصيل الاستجابات
5. رفع الملفات والصور
6. تفضيلات الإشعارات
7. تغيير اللغة
8. Health check
9. تسجيل الأخطاء

---

## ملاحظات مهمة

1. **APIs الحضانة:** مهمة جداً لإدارة نقل الأجهزة بين الباحثين
2. **Public Links:** ضرورية للباحثين لبدء الاستطلاعات وجمع البيانات
3. **Device Location:** قد تكون مهمة لتتبع مواقع الأجهزة
4. **Response Details:** مهمة لعرض تفاصيل الاستجابات المجمعة

