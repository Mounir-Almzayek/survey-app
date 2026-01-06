# Upload Feature - ميزة الرفع

## ✅ ما تم إنجازه

تم إنشاء ميزة Upload كاملة مع:
- ✅ Models (UploadFile, UploadProgress)
- ✅ Repository (Online & Local)
- ✅ Service (FilePickerService)
- ✅ Bloc (UploadBloc)
- ✅ Widgets (ImagePickerWidget, FilePickerWidget)
- ✅ الترجمات (عربي/إنجليزي)
- ✅ تصميم متوافق مع المشروع

## 📦 الترجمات المضافة

### الإنجليزية (intl_en.arb):
- `select_file`: "Select File"
- `upload_file`: "Upload File"
- `upload_files`: "Upload Files"
- `uploading`: "Uploading..."
- `uploaded`: "Uploaded"
- `upload_failed`: "Upload failed"
- `upload_success`: "File uploaded successfully"
- `file_selected`: "File selected"
- `remove_file`: "Remove File"
- `retry_upload`: "Retry Upload"
- `cancel_upload`: "Cancel Upload"

### العربية (intl_ar.arb):
- `select_file`: "اختر ملف"
- `upload_file`: "رفع ملف"
- `upload_files`: "رفع ملفات"
- `uploading`: "جاري الرفع..."
- `uploaded`: "تم الرفع"
- `upload_failed`: "فشل الرفع"
- `upload_success`: "تم رفع الملف بنجاح"
- `file_selected`: "تم اختيار الملف"
- `remove_file`: "إزالة الملف"
- `retry_upload`: "إعادة محاولة الرفع"
- `cancel_upload`: "إلغاء الرفع"

## 🎨 التصميم

الـ Widgets تستخدم:
- ✅ نفس الألوان من `AppColors`
- ✅ نفس Border Radius (14.r)
- ✅ نفس Box Shadows
- ✅ نفس الخطوط (GoogleFonts.cairo)
- ✅ تصميم متسق مع `CustomImagePicker` الموجود

## 📝 ملاحظة

إذا ظهرت أخطاء في الـ IDE حول الترجمات:
1. أعد تشغيل الـ IDE
2. أو قم بـ `flutter clean` ثم `flutter pub get`
3. الترجمات موجودة في `lib/core/l10n/generated/l10n.dart`

## 🚀 الاستخدام

```dart
// رفع صورة
ImagePickerWidget(
  title: 'Upload Image',
  autoUpload: true,
  onImageUploaded: (url) {
    print('Image URL: $url');
  },
)

// رفع ملف
FilePickerWidget(
  title: 'Upload File',
  autoUpload: true,
  allowedExtensions: ['pdf', 'doc'],
  onFileUploaded: (url) {
    print('File URL: $url');
  },
)
```

