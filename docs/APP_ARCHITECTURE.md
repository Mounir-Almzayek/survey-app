# التقسيم المثالي لتطبيق الباحث (Researcher App Architecture)

هذه الوثيقة توضح التقسيم والهيكلة المثالية لتطبيق الباحث بناءً على:

- User Stories من `survey-system/docs/user_story.md`
- APIs المتاحة من `RESEARCHER_APIS.md`
- البنية الحالية للتطبيق
- أفضل الممارسات في Flutter

---

## 📐 المبادئ الأساسية للتصميم

### 1. **Feature-First Architecture**

كل ميزة (Feature) تكون مستقلة تماماً مع:

- Models (نماذج البيانات)
- Repository (طبقة الوصول للبيانات)
- Bloc/Cubit (إدارة الحالة)
- Presentation (واجهة المستخدم)

### 2. **Clean Architecture Layers**

```
Presentation Layer (UI)
    ↓
Business Logic Layer (Bloc/Cubit)
    ↓
Data Layer (Repository)
    ↓
Network/Storage Layer (API/Local DB)
```

### 3. **Offline-First Approach**

جميع البيانات تُحفظ محلياً أولاً ثم تُزامن مع الخادم عند توفر الاتصال.

---

## 🗂️ التقسيم المقترح للميزات (Features)

### 📁 **1. Authentication (المصادقة)**

**المسار:** `lib/features/auth/`

#### البنية:

```
auth/
├── models/
│   ├── researcher_login_initiate_request.dart ✅
│   ├── researcher_login_initiate_response.dart ✅
│   ├── researcher_login_verify_request.dart ✅
│   ├── researcher_login_verify_response.dart ✅
│   └── user_session.dart (جديد - لحفظ بيانات الجلسة)
├── repository/
│   ├── auth_online_repository.dart ✅
│   ├── auth_local_repository.dart ✅
│   └── auth_repository.dart ✅
├── bloc/
│   └── login/
│       ├── login_bloc.dart ✅
│       ├── login_event.dart ✅
│       └── login_state.dart ✅
├── presentation/
│   ├── login_page.dart ✅
│   └── login_screen.dart ✅
└── widgets/
    └── qr_scanner_button.dart ✅
```

#### APIs المستخدمة:

- ✅ `POST /auth/researcher-login/initiate`
- ✅ `POST /auth/researcher-login/verify-login`
- ✅ `GET /auth/me`
- ✅ `POST /auth/me/logout`
- ❌ `GET /auth/me/logout-from-all-other-devices` (مستقبلي)
- ❌ `POST /auth/me/change-language` (مستقبلي)

---

### 📁 **2. Home/Dashboard (الصفحة الرئيسية)**

**المسار:** `lib/features/home/`

#### البنية:

```
home/
├── models/
│   ├── assignment.dart (جديد - المهام المعينة)
│   ├── survey_summary.dart (جديد - ملخص الاستطلاع)
│   └── dashboard_stats.dart (جديد - إحصائيات)
├── repository/
│   ├── home_online_repository.dart (جديد)
│   └── home_local_repository.dart (جديد)
├── bloc/
│   └── dashboard/
│       ├── dashboard_bloc.dart (جديد)
│       ├── dashboard_event.dart (جديد)
│       └── dashboard_state.dart (جديد)
└── presentation/
    ├── home_page.dart ✅
    ├── home_screen.dart ✅
    └── widgets/
        ├── assignment_card.dart (جديد)
        ├── survey_status_badge.dart (جديد)
        └── stats_summary.dart (جديد)
```

#### الوظيفة:

- عرض الاستبيانات المعينة للباحث
- عرض حالة كل استبيان (لم يبدأ، قيد التنفيذ، منتهي)
- عرض إحصائيات سريعة (عدد الاستجابات، المسودات)
- الوصول السريع لبدء استجابة جديدة

#### APIs المطلوبة:

- ❌ `GET /admin/assignment/survey/{survey_id}` (تحتاج endpoint للباحث)
- ❌ `GET /researcher/assignments` (مطلوب - قائمة المهام المعينة)

---

### 📁 **3. Surveys (الاستطلاعات)**

**المسار:** `lib/features/surveys/`

#### البنية:

```
surveys/
├── models/
│   ├── survey.dart (جديد - نموذج الاستطلاع الكامل)
│   ├── section.dart (جديد - قسم)
│   ├── question.dart (جديد - سؤال)
│   ├── question_option.dart (جديد - خيارات السؤال)
│   ├── assignment.dart (جديد - المهمة المعينة)
│   └── survey_status.dart (جديد - حالة الاستطلاع)
├── repository/
│   ├── surveys_online_repository.dart (جديد)
│   └── surveys_local_repository.dart (جديد)
├── bloc/
│   ├── assigned_surveys/
│   │   ├── assigned_surveys_bloc.dart (جديد)
│   │   ├── assigned_surveys_event.dart (جديد)
│   │   └── assigned_surveys_state.dart (جديد)
│   └── survey_details/
│       ├── survey_details_bloc.dart (جديد)
│       ├── survey_details_event.dart (جديد)
│       └── survey_details_state.dart (جديد)
└── presentation/
    ├── assigned_surveys_page.dart (جديد)
    ├── assigned_surveys_screen.dart (جديد)
    ├── survey_details_page.dart (جديد)
    └── widgets/
        ├── survey_card.dart (جديد)
        ├── survey_filter.dart (جديد)
        └── survey_search.dart (جديد)
```

#### الوظيفة:

- عرض قائمة الاستطلاعات المعينة
- تصفية وفرز الاستطلاعات
- عرض تفاصيل الاستطلاع
- الوصول لبدء استجابة جديدة

---

### 📁 **4. Responses (الاستجابات)**

**المسار:** `lib/features/responses/`

#### البنية:

```
responses/
├── models/
│   ├── response.dart (جديد - الاستجابة)
│   ├── response_answer.dart (جديد - إجابة سؤال)
│   ├── response_status.dart (جديد - حالة المزامنة)
│   ├── response_section.dart (جديد - قسم في الاستجابة)
│   └── response_details.dart (جديد - تفاصيل كاملة)
├── repository/
│   ├── responses_online_repository.dart (جديد)
│   ├── responses_local_repository.dart (جديد)
│   └── responses_sync_service.dart (جديد - خدمة المزامنة)
├── bloc/
│   ├── responses_list/
│   │   ├── responses_list_bloc.dart (جديد)
│   │   ├── responses_list_event.dart (جديد)
│   │   └── responses_list_state.dart (جديد)
│   ├── response_details/
│   │   ├── response_details_bloc.dart (جديد)
│   │   ├── response_details_event.dart (جديد)
│   │   └── response_details_state.dart (جديد)
│   └── sync/
│       ├── sync_bloc.dart (جديد - إدارة المزامنة)
│       ├── sync_event.dart (جديد)
│       └── sync_state.dart (جديد)
└── presentation/
    ├── responses_list_page.dart (جديد)
    ├── responses_list_screen.dart (جديد)
    ├── response_details_page.dart (جديد)
    └── widgets/
        ├── response_card.dart (جديد)
        ├── sync_status_badge.dart (جديد)
        └── response_filter.dart (جديد)
```

#### الوظيفة:

- عرض قائمة الاستجابات (المتزامنة، قيد المزامنة، غير متصلة)
- عرض تفاصيل الاستجابة
- إدارة المزامنة التلقائية
- إعادة محاولة المزامنة الفاشلة

#### APIs المستخدمة:

- ❌ `GET /researcher/response/{id}/details`
- ❌ `POST /public-link/{short_code}/start` (بدء استجابة)
- ❌ `POST /public-link/{short_code}/responses/{response_id}/sections/{section_id}` (حفظ إجابات)

---

### 📁 **5. Survey Response (ملء الاستطلاع)**

**المسار:** `lib/features/survey_response/`

#### البنية:

```
survey_response/
├── models/
│   ├── survey_response_session.dart (جديد - جلسة ملء الاستطلاع)
│   ├── section_progress.dart (جديد - تقدم الأقسام)
│   └── answer_input.dart (جديد - إدخال الإجابة)
├── repository/
│   ├── survey_response_online_repository.dart (جديد)
│   └── survey_response_local_repository.dart (جديد)
├── bloc/
│   ├── survey_response/
│   │   ├── survey_response_bloc.dart (جديد)
│   │   ├── survey_response_event.dart (جديد)
│   │   └── survey_response_state.dart (جديد)
│   └── auto_save/
│       ├── auto_save_bloc.dart (جديد - الحفظ التلقائي)
│       ├── auto_save_event.dart (جديد)
│       └── auto_save_state.dart (جديد)
└── presentation/
    ├── survey_response_page.dart (جديد)
    ├── survey_response_screen.dart (جديد)
    ├── widgets/
    │   ├── section_widget.dart (جديد - عرض قسم)
    │   ├── question_widget.dart (جديد - عرض سؤال)
    │   ├── question_input_widget.dart (جديد - إدخال الإجابة)
    │   ├── progress_indicator.dart (جديد - مؤشر التقدم)
    │   ├── gps_capture_button.dart (جديد - التقاط GPS)
    │   └── save_status_indicator.dart (جديد - حالة الحفظ)
    └── screens/
        ├── section_screen.dart (جديد)
        └── review_screen.dart (جديد - مراجعة قبل الإرسال)
```

#### الوظيفة:

- عرض الاستطلاع بشكل تفاعلي
- ملء الأسئلة مع التحقق من الصحة
- الحفظ التلقائي كل فترة
- التقاط GPS عند الحاجة
- المنطق الشرطي (إظهار/إخفاء الأسئلة)
- المراجعة قبل الإرسال

#### APIs المستخدمة:

- ❌ `GET /researcher/public-link/{short_code}` (التحقق من الرابط)
- ❌ `POST /public-link/{short_code}/start` (بدء الاستجابة)
- ❌ `POST /public-link/{short_code}/responses/{response_id}/sections/{section_id}` (حفظ قسم)

---

### 📁 **6. Custody (الحضانة)**

**المسار:** `lib/features/custody/`

#### البنية:

```
custody/
├── models/
│   ├── custody_record.dart (جديد - سجل الحضانة)
│   ├── custody_transfer.dart (جديد - نقل الحضانة)
│   └── custody_status.dart (جديد - حالة الحضانة)
├── repository/
│   ├── custody_online_repository.dart (جديد)
│   └── custody_local_repository.dart (جديد)
├── bloc/
│   ├── custody_list/
│   │   ├── custody_list_bloc.dart (جديد)
│   │   ├── custody_list_event.dart (جديد)
│   │   └── custody_list_state.dart (جديد)
│   ├── custody_transfer/
│   │   ├── custody_transfer_bloc.dart (جديد - نقل الحضانة)
│   │   ├── custody_transfer_event.dart (جديد)
│   │   └── custody_transfer_state.dart (جديد)
│   └── custody_verification/
│       ├── custody_verification_bloc.dart (جديد - التحقق)
│       ├── custody_verification_event.dart (جديد)
│       └── custody_verification_state.dart (جديد)
└── presentation/
    ├── custody_page.dart ✅ (يحتاج تحديث)
    ├── custody_list_screen.dart (جديد)
    ├── custody_transfer_screen.dart (جديد - نقل الجهاز)
    ├── custody_verification_screen.dart (جديد - التحقق من الكود)
    └── widgets/
        ├── register_device_card.dart ✅
        ├── custody_card.dart (جديد)
        ├── transfer_form.dart (جديد)
        └── verification_code_input.dart (جديد)
```

#### الوظيفة:

- عرض سجلات الحضانة
- بدء عملية نقل الجهاز (Check-out)
- التحقق من كود التحقق عند استلام الجهاز (Check-in)
- إعادة إرسال كود التحقق

#### APIs المستخدمة:

- ❌ `GET /researcher/custody`
- ❌ `POST /researcher/custody`
- ❌ `GET /researcher/custody/{id}`
- ❌ `POST /researcher/custody/{id}/verify`
- ❌ `POST /researcher/custody/{id}/resend-code`

---

### 📁 **7. Public Links (الروابط العامة)**

**المسار:** `lib/features/public_links/`

#### البنية:

```
public_links/
├── models/
│   ├── public_link.dart (جديد - رابط عام)
│   └── link_share_options.dart (جديد - خيارات المشاركة)
├── repository/
│   ├── public_links_online_repository.dart (جديد)
│   └── public_links_local_repository.dart (جديد)
├── bloc/
│   └── public_links/
│       ├── public_links_bloc.dart (جديد)
│       ├── public_links_event.dart (جديد)
│       └── public_links_state.dart (جديد)
└── presentation/
    ├── public_links_page.dart (جديد)
    ├── public_links_screen.dart (جديد)
    └── widgets/
        ├── public_link_card.dart (جديد)
        ├── share_button.dart (جديد - زر المشاركة)
        └── qr_code_generator.dart (جديد - توليد QR)
```

#### الوظيفة:

- عرض الروابط العامة للاستطلاعات المعينة
- نسخ الرابط
- مشاركة الرابط (QR Code، مشاركة عبر التطبيقات)
- عرض حالة الرابط (نشط، معطل، منتهي)

#### APIs المستخدمة:

- ❌ `GET /researcher/public-link/{short_code}` (للتحقق)
- ❌ `GET /admin/public-link` (قائمة الروابط - قد تحتاج endpoint للباحث)

---

### 📁 **8. Device Location (موقع الجهاز)**

**المسار:** `lib/features/device_location/`

#### البنية:

```
device_location/
├── models/
│   ├── device_location.dart (جديد - موقع الجهاز)
│   └── location_update_request.dart (جديد)
├── repository/
│   ├── device_location_online_repository.dart (جديد)
│   └── device_location_local_repository.dart (جديد)
├── service/
│   └── location_service.dart (جديد - خدمة GPS)
├── bloc/
│   └── device_location/
│       ├── device_location_bloc.dart (جديد)
│       ├── device_location_event.dart (جديد)
│       └── device_location_state.dart (جديد)
└── presentation/
    └── widgets/
        └── location_capture_widget.dart (جديد - التقاط الموقع)
```

#### الوظيفة:

- التقاط موقع GPS
- تحديث موقع الجهاز على الخادم
- استخدام الموقع في الاستجابات

#### APIs المستخدمة:

- ❌ `POST /researcher/device-location/devices/{id}/location`

---

### 📁 **9. Upload (الرفع)**

**المسار:** `lib/features/upload/`

#### البنية:

```
upload/
├── models/
│   ├── upload_file.dart (جديد - ملف للرفع)
│   └── upload_progress.dart (جديد - تقدم الرفع)
├── repository/
│   ├── upload_online_repository.dart (جديد)
│   └── upload_local_repository.dart (جديد)
├── service/
│   └── file_picker_service.dart (جديد - اختيار الملفات)
├── bloc/
│   └── upload/
│       ├── upload_bloc.dart (جديد)
│       ├── upload_event.dart (جديد)
│       └── upload_state.dart (جديد)
└── presentation/
    └── widgets/
        ├── image_picker_widget.dart (جديد)
        └── file_picker_widget.dart (جديد)
```

#### الوظيفة:

- رفع الصور
- رفع الملفات
- عرض تقدم الرفع
- إدارة الملفات المحلية

#### APIs المستخدمة:

- ❌ `POST /upload/image`
- ❌ `POST /upload/files`

---

### 📁 **10. Profile (البروفايل)**

**المسار:** `lib/features/profile/`

#### البنية:

```
profile/
├── models/
│   ├── user.dart ✅
│   └── notification_preferences.dart (جديد)
├── repository/
│   ├── profile_online_repository.dart ✅
│   ├── profile_local_repository.dart ✅
│   └── profile_repository.dart ✅
├── bloc/
│   └── profile/
│       ├── profile_bloc.dart ✅
│       ├── profile_event.dart ✅
│       └── profile_state.dart ✅
└── presentation/
    ├── profile_page.dart ✅
    ├── profile_screen.dart ✅
    └── widgets/
        ├── profile_logout_dialog.dart ✅
        ├── language_selector.dart (جديد)
        └── notification_settings.dart (جديد)
```

#### APIs المستخدمة:

- ✅ `GET /auth/me`
- ✅ `POST /auth/me/logout`
- ❌ `GET /auth/me/notification-preferences`
- ❌ `PUT /auth/me/notification-preferences/bulk`
- ❌ `POST /auth/me/change-language`

---

### 📁 **11. Device Registration (تسجيل الجهاز)**

**المسار:** `lib/features/device_registration/`

#### البنية:

```
device_registration/
├── models/ ✅ (موجود)
├── repository/ ✅ (موجود)
├── bloc/ ✅ (موجود)
└── presentation/ ✅ (موجود)
```

**الحالة:** ✅ مُنفذ بالكامل

---

## 🔧 المكونات المشتركة (Core)

### 📁 **Core Services**

**المسار:** `lib/core/services/`

```
services/
├── app_info_service.dart ✅
├── connectivity_service.dart (جديد - فحص الاتصال)
├── location_service.dart (جديد - GPS)
├── notification_service.dart (جديد - Push Notifications)
├── sync_service.dart (جديد - خدمة المزامنة العامة)
└── error_logging_service.dart (جديد - تسجيل الأخطاء)
```

### 📁 **Core Queue (نظام المزامنة)**

**المسار:** `lib/core/queue/`

```
queue/
├── sync_queue.dart ✅
├── sync_queue_item.dart ✅
└── sync_queue_manager.dart ✅
```

**الحالة:** ✅ موجود - يحتاج تكامل مع features جديدة

### 📁 **Core Utils**

**المسار:** `lib/core/utils/`

```
utils/
├── responsive_layout.dart ✅
├── validators.dart (جديد - التحقق من البيانات)
├── formatters.dart (جديد - تنسيق البيانات)
└── offline_helper.dart (جديد - مساعدات Offline)
```

---

## 📱 هيكل الشاشات الرئيسية

### 1. **Splash Screen** ✅

- فحص حالة المستخدم
- توجيه للصفحة المناسبة

### 2. **Login Screen** ✅

- تسجيل الدخول للباحث
- WebAuthn أو Password

### 3. **Main Screen** ✅

- Bottom Navigation Bar:
  - 🏠 Home (Dashboard)
  - 📋 Surveys (الاستطلاعات)
  - 👤 Profile (البروفايل)

### 4. **Home/Dashboard**

- قائمة الاستطلاعات المعينة
- إحصائيات سريعة
- الوصول السريع

### 5. **Assigned Surveys**

- قائمة الاستطلاعات
- تصفية وفرز
- تفاصيل الاستطلاع

### 6. **Survey Response**

- ملء الاستطلاع
- الأقسام والأسئلة
- الحفظ التلقائي
- المراجعة والإرسال

### 7. **Responses List**

- قائمة الاستجابات
- حالة المزامنة
- تفاصيل الاستجابة

### 8. **Custody**

- سجلات الحضانة
- نقل الجهاز
- التحقق من الكود

### 9. **Public Links**

- قائمة الروابط
- مشاركة الروابط

---

## 🔄 تدفق البيانات (Data Flow)

### 1. **Offline-First Flow**

```
User Action
    ↓
Local Repository (Save to Local DB)
    ↓
Sync Queue (Add to Queue)
    ↓
[When Online] Sync Service
    ↓
Online Repository (Send to Server)
    ↓
Update Local DB (Mark as Synced)
```

### 2. **Online Flow**

```
User Action
    ↓
Bloc Event
    ↓
Repository (Online)
    ↓
API Call
    ↓
Update State
    ↓
UI Update
```

---

## 📦 الاعتمادات المطلوبة (Dependencies)

### موجودة:

- ✅ `flutter_bloc` - إدارة الحالة
- ✅ `dio` - HTTP Client
- ✅ `flutter_secure_storage` - التخزين الآمن
- ✅ `device_info_plus` - معلومات الجهاز
- ✅ `local_auth` - المصادقة الحيوية

### مطلوبة:

- ❌ `sqflite` أو `hive` - قاعدة بيانات محلية
- ❌ `connectivity_plus` - فحص الاتصال
- ❌ `geolocator` - GPS
- ❌ `image_picker` - اختيار الصور
- ❌ `file_picker` - اختيار الملفات
- ❌ `qr_flutter` - توليد QR
- ❌ `share_plus` - مشاركة الملفات
- ❌ `workmanager` - مهام في الخلفية (للمزامنة)

---

## 🎯 أولويات التنفيذ

### المرحلة 1: الأساسيات (Priority 1)

1. ✅ Authentication (مُنفذ)
2. ✅ Device Registration (مُنفذ)
3. ❌ Home/Dashboard (عرض المهام المعينة)
4. ❌ Surveys List (قائمة الاستطلاعات)

### المرحلة 2: جمع البيانات (Priority 2)

5. ❌ Survey Response (ملء الاستطلاع)
6. ❌ Responses Management (إدارة الاستجابات)
7. ❌ Offline Sync (المزامنة)

### المرحلة 3: الميزات الإضافية (Priority 3)

8. ❌ Custody (الحضانة)
9. ❌ Public Links (الروابط العامة)
10. ❌ Device Location (موقع الجهاز)
11. ❌ Upload (الرفع)

### المرحلة 4: التحسينات (Priority 4)

12. ❌ Notification Preferences
13. ❌ Language Change
14. ❌ Error Logging
15. ❌ Analytics

---

## 📝 ملاحظات مهمة

### 1. **Offline Support**

- جميع البيانات تُحفظ محلياً أولاً
- نظام Queue للمزامنة
- مؤشرات واضحة لحالة المزامنة

### 2. **Error Handling**

- معالجة شاملة للأخطاء
- رسائل واضحة للمستخدم
- إعادة المحاولة التلقائية

### 3. **Performance**

- Lazy Loading للقوائم
- Caching للبيانات
- Optimistic Updates

### 4. **Security**

- تخزين آمن للـ Tokens
- تشفير البيانات الحساسة
- التحقق من الصلاحيات

### 5. **UX/UI**

- تصميم متجاوب (Mobile & Web)
- مؤشرات تحميل واضحة
- رسائل تأكيد للإجراءات المهمة
- دعم RTL (العربية)

---

## 🔍 نقاط التحسين المقترحة

1. **إضافة Unit Tests** لكل Bloc و Repository
2. **إضافة Integration Tests** للتدفقات الرئيسية
3. **تحسين Performance** باستخدام `flutter_bloc` بشكل أفضل
4. **إضافة Analytics** لتتبع استخدام التطبيق
5. **تحسين Error Messages** لتكون أكثر وضوحاً
6. **إضافة Accessibility** لدعم ذوي الاحتياجات الخاصة

---

هذا التقسيم يوفر:

- ✅ **Modularity** - كل ميزة مستقلة
- ✅ **Scalability** - سهل الإضافة والتعديل
- ✅ **Maintainability** - كود منظم وواضح
- ✅ **Testability** - سهل الاختبار
- ✅ **Reusability** - مكونات قابلة لإعادة الاستخدام

---

## Conditional follow-up: "option triggers a date/time question"

When a survey needs a DATETIME answer that is only required if the user picks
a specific choice (e.g. "Schedule a visit" → ask *when*), authors should NOT
introduce a new question type. Instead, compose:

1. A RADIO/DROPDOWN question with an option whose `value` is, for example,
   `"scheduled"`.
2. A separate DATETIME question in the same section.
3. A `ConditionalLogic` rule: `IF answer(Q1) == "scheduled" THEN SHOW Q2`.

`SurveyBehaviorManager` (see `lib/core/utils/survey_behavior_manager.dart`)
re-evaluates visibility and `is_required` on every answer change, so the
DATETIME question appears inline the moment the trigger option is selected.
This mirrors the web frontend and requires no app-side changes.
