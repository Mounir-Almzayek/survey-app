# هيكل الصفحات والعلاقات بينها (Pages Structure & Relationships)

بناءً على فهم مشروع الفرونت (Next.js) والبنية الحالية، هذا التصميم المقترح لكل صفحة.

---

## 📱 الصفحات الرئيسية (3 Tabs)

### 1. 🏠 Home (الصفحة الرئيسية)

#### **المحتوى:**

```
Home Screen
├── Header Section
│   ├── Welcome Message
│   └── Last Sync Status
│
├── Quick Stats (Metrics Cards)
│   ├── 📋 Assigned Surveys (عدد الاستطلاعات المعينة)
│   ├── ✅ Completed Responses (الاستجابات المكتملة)
│   ├── 📝 Draft Responses (المسودات)
│   ├── 🔄 Syncing Status (حالة المزامنة)
│   └── 📊 Completion Rate (نسبة الإنجاز)
│
├── Quick Actions (Floating Action Buttons)
│   ├── [➕ Start New Response] → Surveys List
│   ├── [📋 View All Surveys] → Surveys Tab
│   └── [📊 View Responses] → Responses List (من Home)
│
├── Assigned Surveys (قائمة مختصرة)
│   ├── Survey Card 1
│   │   ├── Title
│   │   ├── Status Badge
│   │   ├── Progress Bar
│   │   └── [Start] / [View] Button
│   └── Survey Card 2...
│
└── Recent Responses (آخر الاستجابات)
    ├── Response Card 1
    │   ├── Survey Name
    │   ├── Status (Synced/Syncing/Offline)
    │   ├── Date
    │   └── [View Details] → Response Details
    └── Response Card 2...
```

#### **الوظائف:**

1. **Dashboard Overview**

   - إحصائيات سريعة عن العمل
   - حالة المزامنة
   - آخر النشاطات

2. **Quick Access**

   - بدء استجابة جديدة بسرعة
   - الوصول للاستطلاعات
   - عرض الاستجابات

3. **Recent Activity**
   - آخر الاستجابات
   - آخر الاستطلاعات المفتوحة
   - حالة المزامنة

#### **Navigation (الوصول):**

```
Home Tab (Default)
    ↓
[Start New Response] → Surveys List → Survey Details → Start Response
    ↓
[View All Surveys] → Surveys Tab
    ↓
[View Responses] → Responses List (في Home نفسه أو Tab منفصل)
    ↓
[Survey Card] → Survey Details → Start Response
    ↓
[Response Card] → Response Details
```

---

### 2. 📋 Surveys (الاستطلاعات)

#### **المحتوى:**

```
Surveys Screen
├── Header Section
│   ├── Title: "Assigned Surveys"
│   ├── Search Bar
│   └── Filter Button
│
├── Filters Section
│   ├── Status Filter (All / Active / Completed)
│   ├── Date Filter
│   └── Sort Options
│
├── Surveys List
│   ├── Survey Card
│   │   ├── Survey Title
│   │   ├── Description (Preview)
│   │   ├── Status Badge
│   │   ├── Progress Info
│   │   │   ├── Responses Count
│   │   │   └── Completion Rate
│   │   ├── Due Date (if applicable)
│   │   └── Actions
│   │       ├── [View Details] → Survey Details
│   │       ├── [Start Response] → Survey Response
│   │       └── [Public Links] → Public Links (إذا متاح)
│   └── Survey Card 2...
│
└── Empty State (إذا لا توجد استطلاعات)
    └── Message + Illustration
```

#### **الوظائف:**

1. **Surveys Management**

   - عرض جميع الاستطلاعات المعينة
   - البحث والتصفية
   - ترتيب حسب التاريخ/الحالة

2. **Quick Actions**

   - بدء استجابة جديدة
   - عرض تفاصيل الاستطلاع
   - الوصول للروابط العامة

3. **Progress Tracking**
   - عدد الاستجابات لكل استطلاع
   - نسبة الإنجاز
   - آخر نشاط

#### **Navigation (الوصول):**

```
Surveys Tab
    ↓
[Survey Card] → Survey Details Screen
    │
    ├── [Start Response] → Survey Response Screen
    │   └── Fill Survey → Save → Sync
    │
    ├── [View Details] → Survey Details
    │   ├── Overview
    │   ├── Sections Preview
    │   └── [Start Response]
    │
    └── [Public Links] → Public Links Screen
        ├── List of Links
        ├── [Copy Link]
        ├── [Share QR]
        └── [View Stats]
```

---

### 3. 👤 Profile (البروفايل)

#### **المحتوى:**

```
Profile Screen
├── User Info Card
│   ├── Avatar
│   ├── Name
│   ├── Email
│   └── Role
│
├── Device Information Section
│   ├── Device Name
│   ├── Device Type
│   ├── Last Sync Time
│   ├── Sync Status
│   └── [Device Settings] → Device Settings
│
├── Settings Section
│   ├── Language
│   │   └── [Change Language] → Language Picker
│   ├── Notifications
│   │   └── [Notification Settings] → Notification Preferences
│   └── Security
│       └── [Security Settings] → Security Settings
│
└── Actions Section
    ├── [About] → About Screen
    ├── [Help & Support] → Help Screen
    └── [Logout] → Logout Dialog → Login Screen
```

#### **الوظائف:**

1. **User Profile**

   - عرض معلومات المستخدم
   - تحديث البروفايل (إذا متاح)

2. **Device Management**

   - معلومات الجهاز الحالي
   - حالة المزامنة
   - Device Settings

3. **App Settings**
   - اللغة
   - الإشعارات
   - الأمان

#### **Navigation (الوصول):**

```
Profile Tab
    ↓
[Device Settings] → Device Settings Screen
    ├── Device Info
    ├── Sync Settings
    └── [Transfer Device] → Device Transfer (في Login)
    ↓
[Language] → Language Picker Bottom Sheet
    ↓
[Notifications] → Notification Preferences Screen
    ↓
[Logout] → Logout Dialog → Login Screen
```

---

## 🔗 العلاقات بين الصفحات (Relationships)

### 1. Home ↔ Surveys

```
Home
    ├── [View All Surveys] → Surveys Tab
    ├── [Start New Response] → Surveys List → Start Response
    └── Survey Cards → Survey Details → Start Response
```

**العلاقة:**

- Home يعرض **مختصر** من الاستطلاعات
- Surveys يعرض **القائمة الكاملة** مع Filters
- كلاهما يصل لنفس الوجهات (Survey Details, Start Response)

---

### 2. Home ↔ Responses

```
Home
    ├── Recent Responses Section → Response Details
    └── [View All Responses] → Responses List (في Home أو Tab منفصل)
```

**العلاقة:**

- Home يعرض **آخر الاستجابات** (5-10)
- Responses List يعرض **جميع الاستجابات** مع Filters
- كلاهما يصل لـ Response Details

---

### 3. Surveys ↔ Survey Response

```
Surveys
    ├── [Start Response] → Survey Response Screen
    └── Survey Details → [Start Response] → Survey Response Screen
```

**العلاقة:**

- Surveys هو **نقطة البداية** لبدء استجابة جديدة
- Survey Response هو **شاشة ملء الاستطلاع**
- بعد الإكمال → يعود لـ Home أو Responses

---

### 4. Profile ↔ Device Management

```
Profile
    └── Device Info → Device Settings
        └── [Transfer Device] → Login Screen → Device Transfer
```

**العلاقة:**

- Profile يعرض **معلومات الجهاز**
- Device Transfer يحدث في **Login Screen** (كما اقترحنا)
- Profile → Login → Device Transfer

---

## 🗺️ خريطة التنقل الكاملة (Complete Navigation Map)

```
┌─────────────────────────────────────────────────────────┐
│                    Login Screen                          │
│  - Email/Password Login                                  │
│  - QR Scanner (Device Registration)                     │
│  - Device Transfer (Check-in/out)                       │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    Main Screen                           │
│  ┌──────────┬──────────┬──────────┐                    │
│  │   Home   │ Surveys  │ Profile  │                    │
│  └──────────┴──────────┴──────────┘                    │
└─────────────────────────────────────────────────────────┘
         ↓              ↓              ↓
    ┌─────────┐    ┌─────────┐    ┌─────────┐
    │  Home   │    │ Surveys │    │ Profile │
    └─────────┘    └─────────┘    └─────────┘
         │              │              │
         ├──────────────┼──────────────┤
         │              │              │
    ┌─────────┐    ┌─────────┐    ┌─────────┐
    │Survey   │    │Survey   │    │Device   │
    │Details  │    │Response │    │Settings │
    └─────────┘    └─────────┘    └─────────┘
         │              │              │
         │              │              │
    ┌─────────┐    ┌─────────┐    ┌─────────┐
    │Response │    │Public   │    │Transfer │
    │Details  │    │Links    │    │Device   │
    └─────────┘    └─────────┘    └─────────┘
```

---

## 📋 تفاصيل كل صفحة

### 🏠 Home Page - التفاصيل الكاملة

#### **1. Header Section**

```dart
- Welcome Message: "Welcome back, [Name]"
- Last Sync: "Last synced: 2 hours ago" / "Syncing..." / "Offline"
- Sync Button: [🔄 Sync Now] (إذا Offline)
```

#### **2. Quick Stats (4-6 Cards)**

```dart
Card 1: Assigned Surveys
  - Icon: 📋
  - Value: "12"
  - Label: "Assigned Surveys"
  - Action: Tap → Surveys Tab

Card 2: Completed Responses
  - Icon: ✅
  - Value: "45"
  - Label: "Completed"
  - Action: Tap → Responses List

Card 3: Draft Responses
  - Icon: 📝
  - Value: "3"
  - Label: "Drafts"
  - Action: Tap → Drafts List

Card 4: Sync Status
  - Icon: 🔄
  - Value: "100%" or "Syncing..."
  - Label: "Sync Status"
  - Action: Tap → Sync Details

Card 5: Completion Rate (Optional)
  - Icon: 📊
  - Value: "87%"
  - Label: "Completion Rate"

Card 6: Today's Responses (Optional)
  - Icon: 📅
  - Value: "8"
  - Label: "Today"
```

#### **3. Quick Actions**

```dart
Floating Action Button (FAB) - في Mobile
  - [➕ Start New Response]
  - Action: → Surveys List → Select Survey → Start Response

Quick Action Cards - في Web/Tablet
  - [Start New Response]
  - [View All Surveys]
  - [View Responses]
```

#### **4. Assigned Surveys (قائمة مختصرة - 3-5)**

```dart
Survey Card:
  - Survey Title
  - Status Badge (Active / Completed)
  - Progress: "5/10 responses"
  - Last Activity: "2 hours ago"
  - Actions:
    - [Start] → Start Response
    - [View] → Survey Details
```

#### **5. Recent Responses (آخر 5-10)**

```dart
Response Card:
  - Survey Name
  - Status Badge:
    - ✅ Synced (أخضر)
    - 🔄 Syncing (أزرق)
    - ⚠️ Offline (أصفر)
    - ❌ Error (أحمر)
  - Date: "2 hours ago"
  - Action: Tap → Response Details
```

---

### 📋 Surveys Page - التفاصيل الكاملة

#### **1. Header**

```dart
- Title: "Assigned Surveys"
- Search Bar: بحث في الاستطلاعات
- Filter Button: [🔽 Filters]
```

#### **2. Filters (Collapsible)**

```dart
- Status: [All] [Active] [Completed] [Draft]
- Sort: [Newest] [Oldest] [A-Z] [Z-A]
- Date Range: [Select Date Range]
```

#### **3. Surveys List**

```dart
Survey Card:
  ├── Header
  │   ├── Survey Title
  │   └── Status Badge
  ├── Description (Preview - 2 lines)
  ├── Progress Section
  │   ├── Progress Bar
  │   ├── "5/10 responses"
  │   └── "50% complete"
  ├── Metadata
  │   ├── Created: "2 days ago"
  │   ├── Due Date: "In 5 days" (إذا موجود)
  │   └── Last Activity: "2 hours ago"
  └── Actions
      ├── [View Details] → Survey Details
      ├── [Start Response] → Survey Response
      └── [Public Links] → Public Links (إذا متاح)
```

#### **4. Survey Details (عند الضغط على Survey)**

```dart
Survey Details Screen:
  ├── Overview
  │   ├── Title & Description
  │   ├── Status
  │   └── Dates
  ├── Sections Preview
  │   └── List of Sections
  ├── Statistics
  │   ├── Total Responses
  │   └── Completion Rate
  └── Actions
      ├── [Start Response]
      ├── [View Responses]
      └── [Public Links]
```

---

### 👤 Profile Page - التفاصيل الكاملة

#### **1. User Info Card**

```dart
User Card:
  ├── Avatar (Circular)
  ├── Name
  ├── Email
  ├── Role: "Researcher"
  └── [Edit Profile] (إذا متاح)
```

#### **2. Device Information**

```dart
Device Card:
  ├── Device Name
  ├── Device Type
  ├── Device ID
  ├── Last Sync
  │   ├── Time: "2 hours ago"
  │   └── Status: ✅ Synced / 🔄 Syncing / ⚠️ Offline
  └── [Device Settings] → Device Settings
```

#### **3. Settings Menu**

```dart
Settings List:
  ├── Language
  │   └── Current: "العربية" / "English"
  │   └── Action: → Language Picker
  ├── Notifications
  │   └── Action: → Notification Preferences
  ├── Security
  │   └── Action: → Security Settings
  ├── About
  │   └── App Version, Info
  └── Help & Support
      └── Contact, FAQ
```

#### **4. Actions**

```dart
- [Logout] → Logout Dialog → Login Screen
```

---

## 🔄 التدفقات الرئيسية (Main Flows)

### Flow 1: بدء استجابة جديدة

```
Home
    ↓ [Start New Response]
Surveys List
    ↓ [Select Survey]
Survey Details (Optional)
    ↓ [Start Response]
Survey Response Screen
    ↓ [Fill Survey]
    ↓ [Save] (Auto-save)
    ↓ [Submit]
Response Saved (Local)
    ↓ [Auto Sync] (إذا Online)
Response Synced
    ↓
Home (Updated)
```

### Flow 2: عرض الاستجابات

```
Home
    ↓ [View Responses] or [Response Card]
Responses List
    ↓ [Filter/Search]
    ↓ [Select Response]
Response Details
    ├── View Answers
    ├── View Metadata
    └── [Edit] (إذا Draft)
```

### Flow 3: استخدام Public Link

```
Surveys
    ↓ [Public Links]
Public Links Screen
    ↓ [Select Link]
    ↓ [Copy] or [Share QR]
    ↓
Link Shared
    ↓
External User Opens Link
    ↓
Public Survey Form (Web)
```

### Flow 4: Device Transfer

```
Profile
    ↓ [Device Settings]
Device Settings
    ↓ [Transfer Device]
Login Screen
    ↓ [Device Transfer Button]
Device Transfer Bottom Sheet
    ├── Check-out: Enter Email → Code Generated
    └── Check-in: Scan QR → Verify → Success
```

---

## 📊 البيانات المطلوبة لكل صفحة

### Home Page Data

```dart
{
  "stats": {
    "assignedSurveys": 12,
    "completedResponses": 45,
    "draftResponses": 3,
    "syncStatus": "synced" | "syncing" | "offline",
    "completionRate": 87.5
  },
  "recentSurveys": [
    {
      "id": 1,
      "title": "Survey Title",
      "status": "active",
      "progress": { "completed": 5, "total": 10 },
      "lastActivity": "2024-01-15T10:30:00Z"
    }
  ],
  "recentResponses": [
    {
      "id": 1,
      "surveyId": 1,
      "surveyTitle": "Survey Title",
      "status": "synced" | "syncing" | "offline",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### Surveys Page Data

```dart
{
  "surveys": [
    {
      "id": 1,
      "title": "Survey Title",
      "description": "Survey Description",
      "status": "active" | "completed" | "draft",
      "createdAt": "2024-01-10T10:00:00Z",
      "dueDate": "2024-01-20T10:00:00Z", // Optional
      "progress": {
        "completed": 5,
        "total": 10,
        "percentage": 50
      },
      "hasPublicLinks": true
    }
  ],
  "filters": {
    "status": "all" | "active" | "completed",
    "sort": "newest" | "oldest" | "a-z" | "z-a",
    "dateRange": { "start": null, "end": null }
  }
}
```

### Profile Page Data

```dart
{
  "user": {
    "id": 1,
    "name": "Researcher Name",
    "email": "researcher@example.com",
    "role": "Researcher",
    "avatar": "url" // Optional
  },
  "device": {
    "id": 1,
    "name": "Device Name",
    "type": "Tablet" | "Phone",
    "lastSync": "2024-01-15T10:30:00Z",
    "syncStatus": "synced" | "syncing" | "offline"
  },
  "settings": {
    "language": "ar" | "en",
    "notifications": {
      "enabled": true,
      "preferences": {}
    }
  }
}
```

---

## 🎯 APIs المطلوبة لكل صفحة

### Home Page APIs

```dart
GET /researcher/dashboard/stats
  → Returns: stats, recentSurveys, recentResponses

GET /researcher/assignments
  → Returns: list of assigned surveys

GET /researcher/responses?limit=10&sort=created_at:desc
  → Returns: recent responses
```

### Surveys Page APIs

```dart
GET /researcher/assignments
  → Returns: all assigned surveys

GET /researcher/survey/{id}
  → Returns: survey details

GET /researcher/survey/{id}/public-links
  → Returns: public links for survey
```

### Profile Page APIs

```dart
GET /auth/me
  → Returns: user info

GET /researcher/device/info
  → Returns: current device info

GET /auth/me/notification-preferences
  → Returns: notification settings
```

---

## 📱 Responsive Design

### Mobile (< 768px)

- **Home**: Cards في عمود واحد، FAB للـ Quick Actions
- **Surveys**: List view مع Cards
- **Profile**: Single column layout

### Tablet (768px - 1024px)

- **Home**: 2 columns للـ Cards
- **Surveys**: Grid view (2 columns)
- **Profile**: 2 columns (Info + Settings)

### Desktop (> 1024px)

- **Home**: 3-4 columns للـ Cards
- **Surveys**: Table view أو Grid (3 columns)
- **Profile**: Side-by-side layout

---

## ✅ Checklist للتنفيذ

### Home Page

- [ ] Header مع Welcome Message
- [ ] Quick Stats Cards (4-6)
- [ ] Quick Actions (FAB أو Cards)
- [ ] Assigned Surveys List (مختصر)
- [ ] Recent Responses List
- [ ] Sync Status Indicator
- [ ] Navigation إلى الصفحات الأخرى

### Surveys Page

- [ ] Header مع Search
- [ ] Filters Section
- [ ] Surveys List/Grid
- [ ] Survey Card Component
- [ ] Survey Details Screen
- [ ] Navigation إلى Survey Response

### Profile Page

- [ ] User Info Card
- [ ] Device Information Section
- [ ] Settings Menu
- [ ] Language Picker
- [ ] Notification Settings
- [ ] Logout Functionality

---

هذا التصميم يوفر:

- ✅ **وضوح في المحتوى** - كل صفحة لها هدف واضح
- ✅ **سهولة التنقل** - روابط منطقية بين الصفحات
- ✅ **تجربة مستخدم ممتازة** - كل شيء في مكانه الصحيح
- ✅ **كفاءة في الأداء** - تحميل البيانات حسب الحاجة
