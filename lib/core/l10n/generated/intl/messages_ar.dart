// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  static String m0(count) => "${count} روابط نشطة";

  static String m1(start, end) => "فترة الإتاحة: ${start} / ${end}";

  static String m2(code) => "الكود: ${code}";

  static String m3(id) =>
      "هل أنت متأكد من رغبتك في حذف هذا الرد (ID: ${id})؟ لا يمكن التراجع عن هذا الإجراء.";

  static String m4(date) => "أنشئ في: ${date}";

  static String m5(count) => "${count} مسودات متاحة";

  static String m6(email) => "أدخل الرمز المرسل إلى ${email}";

  static String m7(message) => "خطأ: ${message}";

  static String m8(date) => "آخر تحديث: ${date}";

  static String m9(date) => "آخر تحديث: ${date}";

  static String m10(count) => "الردود المحلية (${count})";

  static String m11(date) => "موعد النشر: ${date}";

  static String m12(id) => "رد رقم: ${id}";

  static String m13(count) => "${count} أقسام";

  static String m14(title) => "رابط الاستطلاع: ${title}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "activate": MessageLookupByLibrary.simpleMessage("تفعيل"),
        "activate_account":
            MessageLookupByLibrary.simpleMessage("تفعيل الحساب"),
        "active_links_count": m0,
        "active_responses":
            MessageLookupByLibrary.simpleMessage("الاستجابات النشطة"),
        "active_tasks": MessageLookupByLibrary.simpleMessage("المهام النشطة"),
        "allow_location_access":
            MessageLookupByLibrary.simpleMessage("السماح بالوصول إلى الموقع"),
        "arabic": MessageLookupByLibrary.simpleMessage("العربية"),
        "assignments": MessageLookupByLibrary.simpleMessage("المهام"),
        "availability_period": m1,
        "available_surveys":
            MessageLookupByLibrary.simpleMessage("الاستبيانات المتاحة"),
        "avg": MessageLookupByLibrary.simpleMessage("المعدل"),
        "browser": MessageLookupByLibrary.simpleMessage("المتصفح"),
        "camera": MessageLookupByLibrary.simpleMessage("الكاميرا"),
        "camera_permission_required": MessageLookupByLibrary.simpleMessage(
            "إذن الكاميرا مطلوب لمسح رموز QR"),
        "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
        "cancel_download":
            MessageLookupByLibrary.simpleMessage("إلغاء التحميل"),
        "cancel_upload": MessageLookupByLibrary.simpleMessage("إلغاء الرفع"),
        "close": MessageLookupByLibrary.simpleMessage("إغلاق"),
        "code": MessageLookupByLibrary.simpleMessage("الكود"),
        "code_colon": m2,
        "company": MessageLookupByLibrary.simpleMessage("الشركة"),
        "complete_device_registration": MessageLookupByLibrary.simpleMessage(
            "إكمال عملية تسجيل الجهاز في النظام"),
        "complete_registration_tap_notice": MessageLookupByLibrary.simpleMessage(
            "بالضغط على \'ربط الجهاز\'، سيصبح هذا الجهاز مخصصاً لملفك التعريفي كباحث."),
        "completed": MessageLookupByLibrary.simpleMessage("المكتملة"),
        "completion_rate": MessageLookupByLibrary.simpleMessage("نسبة الإنجاز"),
        "confirm": MessageLookupByLibrary.simpleMessage("تأكيد"),
        "confirm_delete_message": m3,
        "confirm_delete_title":
            MessageLookupByLibrary.simpleMessage("تأكيد الحذف"),
        "cookie_based_method_description": MessageLookupByLibrary.simpleMessage(
            "سيتم استخدام طريقة قائمة على الكوكيز لتسجيل الجهاز"),
        "copy_link": MessageLookupByLibrary.simpleMessage("نسخ الرابط"),
        "created_at_colon": m4,
        "custody": MessageLookupByLibrary.simpleMessage("العهدة"),
        "custody_status_cancelled":
            MessageLookupByLibrary.simpleMessage("ملغي"),
        "custody_status_pending":
            MessageLookupByLibrary.simpleMessage("قيد الانتظار"),
        "custody_status_verified":
            MessageLookupByLibrary.simpleMessage("تم التحقق"),
        "custody_verified_successfully":
            MessageLookupByLibrary.simpleMessage("تم التحقق من العهدة بنجاح"),
        "delete": MessageLookupByLibrary.simpleMessage("حذف"),
        "delete_draft_message": MessageLookupByLibrary.simpleMessage(
            "هل أنت متأكد من رغبتك في حذف مسودة الاستطلاع هذه؟"),
        "delete_draft_title":
            MessageLookupByLibrary.simpleMessage("حذف المسودة"),
        "device_already_registered":
            MessageLookupByLibrary.simpleMessage("هذا الجهاز مسجل مسبقاً"),
        "device_already_registered_desc": MessageLookupByLibrary.simpleMessage(
            "معرف هذا الجهاز مرتبط بالفعل بملف تعريف آخر أو سبق ربطه مسبقاً."),
        "device_information": MessageLookupByLibrary.simpleMessage(
            "المعلومات المستخرجة من الجهاز"),
        "device_name": MessageLookupByLibrary.simpleMessage("اسم الجهاز"),
        "device_registered_success":
            MessageLookupByLibrary.simpleMessage("تم ربط الجهاز بحسابك بنجاح"),
        "device_registered_successfully":
            MessageLookupByLibrary.simpleMessage("تم تسجيل الجهاز بنجاح"),
        "device_type": MessageLookupByLibrary.simpleMessage("نوع الجهاز"),
        "download_file": MessageLookupByLibrary.simpleMessage("تحميل الملف"),
        "downloading": MessageLookupByLibrary.simpleMessage("جاري التحميل..."),
        "drafts_available": m5,
        "edit": MessageLookupByLibrary.simpleMessage("تعديل"),
        "email": MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
        "email_verified_success": MessageLookupByLibrary.simpleMessage(
            "تم التحقق من البريد الإلكتروني بنجاح"),
        "english": MessageLookupByLibrary.simpleMessage("الإنجليزية"),
        "enter_code": MessageLookupByLibrary.simpleMessage("أدخل الرمز"),
        "enter_code_sent": m6,
        "enter_details": MessageLookupByLibrary.simpleMessage(
            "أدخل بيانات تسجيل الدخول الخاصة بك"),
        "enter_email": MessageLookupByLibrary.simpleMessage(
            "أدخل عنوان البريد الإلكتروني"),
        "enter_email_reset": MessageLookupByLibrary.simpleMessage(
            "أدخل بريدك الإلكتروني لاستلام رمز إعادة التعيين"),
        "enter_notes_optional":
            MessageLookupByLibrary.simpleMessage("أدخل ملاحظات (اختياري)"),
        "enter_survey_code":
            MessageLookupByLibrary.simpleMessage("أدخل رمز الاستطلاع"),
        "enter_verification_code":
            MessageLookupByLibrary.simpleMessage("أدخل رمز التحقق"),
        "enter_verification_code_instruction":
            MessageLookupByLibrary.simpleMessage(
                "أدخل رمز التحقق المرسل إلى بريدك الإلكتروني"),
        "entity": MessageLookupByLibrary.simpleMessage("الجهة"),
        "error_occurred": MessageLookupByLibrary.simpleMessage("حدث خطأ ما"),
        "error_with_message": m7,
        "expires_at": MessageLookupByLibrary.simpleMessage("تاريخ الانتهاء"),
        "failed_pick_image": MessageLookupByLibrary.simpleMessage(
            "فشل في اختيار الصورة، يرجى المحاولة لاحقاً!"),
        "failed_to_save_image":
            MessageLookupByLibrary.simpleMessage("فشل في حفظ الصورة"),
        "file_downloaded_colon":
            MessageLookupByLibrary.simpleMessage("تم تحميل الملف في:"),
        "file_downloaded_successfully":
            MessageLookupByLibrary.simpleMessage("تم تحميل الملف بنجاح"),
        "file_ready": MessageLookupByLibrary.simpleMessage("الملف جاهز"),
        "file_selected":
            MessageLookupByLibrary.simpleMessage("تم اختيار الملف"),
        "forgot_password":
            MessageLookupByLibrary.simpleMessage("نسيت كلمة المرور؟"),
        "gallery": MessageLookupByLibrary.simpleMessage("المعرض"),
        "gb": MessageLookupByLibrary.simpleMessage("جيجابايت"),
        "get_started": MessageLookupByLibrary.simpleMessage("ابدأ الآن"),
        "grant_permission": MessageLookupByLibrary.simpleMessage("منح الإذن"),
        "hide_details": MessageLookupByLibrary.simpleMessage("إخفاء التفاصيل"),
        "home": MessageLookupByLibrary.simpleMessage("الرئيسية"),
        "home_survey_status_subtitle": MessageLookupByLibrary.simpleMessage(
            "إليك ما يحدث في استطلاعاتك اليوم."),
        "id_number": MessageLookupByLibrary.simpleMessage("رقم الهوية"),
        "image_saved_successfully": MessageLookupByLibrary.simpleMessage(
            "تم حفظ الصورة بنجاح في المعرض"),
        "in_progress_surveys":
            MessageLookupByLibrary.simpleMessage("استبيانات قيد التنفيذ"),
        "invalid_email": MessageLookupByLibrary.simpleMessage(
            "عنوان بريد إلكتروني غير صحيح"),
        "invalid_qr_code": MessageLookupByLibrary.simpleMessage(
            "رمز QR غير صالح. يرجى المحاولة مرة أخرى."),
        "language": MessageLookupByLibrary.simpleMessage("اللغة"),
        "language_dialog_cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
        "language_dialog_confirm":
            MessageLookupByLibrary.simpleMessage("تأكيد"),
        "language_dialog_title":
            MessageLookupByLibrary.simpleMessage("اختر اللغة"),
        "last_update": m8,
        "last_updated_at": m9,
        "link_copied":
            MessageLookupByLibrary.simpleMessage("تم نسخ الرابط إلى الحافظة"),
        "link_device": MessageLookupByLibrary.simpleMessage("ربط الجهاز"),
        "local_responses_count": m10,
        "location_permission_denied":
            MessageLookupByLibrary.simpleMessage("تم رفض إذن الموقع"),
        "location_permission_required_message":
            MessageLookupByLibrary.simpleMessage(
                "لاستخدام هذا التطبيق، يجب السماح بالوصول إلى موقع جهازك."),
        "location_permission_required_title":
            MessageLookupByLibrary.simpleMessage("إذن الموقع مطلوب"),
        "location_required":
            MessageLookupByLibrary.simpleMessage("الموقع مطلوب"),
        "location_tracking_started":
            MessageLookupByLibrary.simpleMessage("تم بدء تتبع الموقع"),
        "location_tracking_stopped":
            MessageLookupByLibrary.simpleMessage("تم إيقاف تتبع الموقع"),
        "location_update_failed":
            MessageLookupByLibrary.simpleMessage("فشل تحديث الموقع"),
        "location_updated":
            MessageLookupByLibrary.simpleMessage("تم تحديث الموقع"),
        "location_warning_logout": MessageLookupByLibrary.simpleMessage(
            "تحذير: أنت خارج المنطقة المسموح بها. جاري تسجيل الخروج..."),
        "log_out": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
        "login": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
        "login_as_admin": MessageLookupByLibrary.simpleMessage("الدخول كمسؤول"),
        "login_message":
            MessageLookupByLibrary.simpleMessage("يرجى تسجيل الدخول"),
        "login_success":
            MessageLookupByLibrary.simpleMessage("تم تسجيل الدخول بنجاح"),
        "logout_message": MessageLookupByLibrary.simpleMessage(
            "هل أنت متأكد من رغبتك في تسجيل الخروج؟"),
        "logout_title": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
        "main_menu": MessageLookupByLibrary.simpleMessage("القائمة الرئيسية"),
        "max_responses":
            MessageLookupByLibrary.simpleMessage("أقصى عدد للاستجابات"),
        "max_touch_points":
            MessageLookupByLibrary.simpleMessage("نقاط اللمس القصوى"),
        "nationality": MessageLookupByLibrary.simpleMessage("الجنسية"),
        "new_password":
            MessageLookupByLibrary.simpleMessage("كلمة المرور الجديدة"),
        "new_response": MessageLookupByLibrary.simpleMessage("رد جديد"),
        "new_response_success":
            MessageLookupByLibrary.simpleMessage("تم بدء رد جديد بنجاح"),
        "no_active_account":
            MessageLookupByLibrary.simpleMessage("ليس لديك حساب مفعل؟"),
        "no_active_responses":
            MessageLookupByLibrary.simpleMessage("لا توجد استجابات نشطة"),
        "no_custody_records":
            MessageLookupByLibrary.simpleMessage("لا توجد سجلات عهدة"),
        "no_custody_records_description":
            MessageLookupByLibrary.simpleMessage("ليس لديك أي سجلات عهدة بعد"),
        "no_data": MessageLookupByLibrary.simpleMessage("لا توجد بيانات"),
        "no_password":
            MessageLookupByLibrary.simpleMessage("يرجى إدخال كلمة المرور"),
        "no_public_links":
            MessageLookupByLibrary.simpleMessage("لا توجد روابط عامة"),
        "no_public_links_description": MessageLookupByLibrary.simpleMessage(
            "ليس لديك أي روابط عامة معينة بعد"),
        "no_responses_found":
            MessageLookupByLibrary.simpleMessage("لا توجد استجابات"),
        "no_surveys_available": MessageLookupByLibrary.simpleMessage(
            "لا توجد استبيانات متاحة حالياً"),
        "no_user_data": MessageLookupByLibrary.simpleMessage(
            "لم يتم العثور على بيانات المستخدم"),
        "no_user_name": MessageLookupByLibrary.simpleMessage(
            "يرجى إدخال البريد الإلكتروني"),
        "not_available": MessageLookupByLibrary.simpleMessage("غير متاح"),
        "notes": MessageLookupByLibrary.simpleMessage("ملاحظات"),
        "notifications": MessageLookupByLibrary.simpleMessage("التنبيهات"),
        "offline_drafts":
            MessageLookupByLibrary.simpleMessage("المسودات المحلية"),
        "offline_mode": MessageLookupByLibrary.simpleMessage(
            "عرض البيانات المحفوظة (أوفلاين)"),
        "ok": MessageLookupByLibrary.simpleMessage("موافق"),
        "operating_system":
            MessageLookupByLibrary.simpleMessage("نظام التشغيل"),
        "or": MessageLookupByLibrary.simpleMessage("أو"),
        "password": MessageLookupByLibrary.simpleMessage("كلمة المرور"),
        "password_reset_success": MessageLookupByLibrary.simpleMessage(
            "تمت إعادة تعيين كلمة المرور بنجاح"),
        "password_too_short":
            MessageLookupByLibrary.simpleMessage("كلمة المرور قصيرة جداً"),
        "phone": MessageLookupByLibrary.simpleMessage("رقم الهاتف"),
        "place_qr_code":
            MessageLookupByLibrary.simpleMessage("ضع رمز QR داخل الإطار للمسح"),
        "please_enter_code":
            MessageLookupByLibrary.simpleMessage("يرجى إدخال الرمز"),
        "please_enter_email": MessageLookupByLibrary.simpleMessage(
            "يرجى إدخال عنوان البريد الإلكتروني"),
        "please_enter_verification_code": MessageLookupByLibrary.simpleMessage(
            "يرجى إدخال رمز التحقق المكون من 6 أرقام"),
        "please_select": MessageLookupByLibrary.simpleMessage("يرجى الاختيار"),
        "point_camera_at_qr_code":
            MessageLookupByLibrary.simpleMessage("وجّه الكاميرا نحو رمز QR"),
        "position": MessageLookupByLibrary.simpleMessage("المنصب"),
        "processing": MessageLookupByLibrary.simpleMessage("جاري المعالجة..."),
        "processor_cores":
            MessageLookupByLibrary.simpleMessage("أنوية المعالج"),
        "profile": MessageLookupByLibrary.simpleMessage("الملف الشخصي"),
        "public_link_not_found":
            MessageLookupByLibrary.simpleMessage("الرابط العام غير موجود"),
        "public_links": MessageLookupByLibrary.simpleMessage("الروابط العامة"),
        "publish_date": m11,
        "qr_code": MessageLookupByLibrary.simpleMessage("رمز QR"),
        "qr_scanner": MessageLookupByLibrary.simpleMessage("قارئ رمز QR"),
        "queue_detail_body":
            MessageLookupByLibrary.simpleMessage("البيانات المرسلة"),
        "queue_detail_error": MessageLookupByLibrary.simpleMessage("الخطأ"),
        "queue_status_completed":
            MessageLookupByLibrary.simpleMessage("تم الإرسال"),
        "queue_status_failed":
            MessageLookupByLibrary.simpleMessage("فشل الإرسال"),
        "queue_status_processing":
            MessageLookupByLibrary.simpleMessage("جاري المعالجة"),
        "queue_summary_title":
            MessageLookupByLibrary.simpleMessage("الطلبات المعلقة"),
        "ram": MessageLookupByLibrary.simpleMessage("الذاكرة العشوائية"),
        "read_more": MessageLookupByLibrary.simpleMessage("قراءة المزيد"),
        "receive_custody":
            MessageLookupByLibrary.simpleMessage("استلام العهدة"),
        "register_device": MessageLookupByLibrary.simpleMessage("تسجيل الجهاز"),
        "registration_method_cookie_based_description":
            MessageLookupByLibrary.simpleMessage(
                "استخدام كوكيز آمنة مخزنة في خدمة التخزين الآمن في التطبيق لهذا الجهاز"),
        "registration_method_cookie_based_title":
            MessageLookupByLibrary.simpleMessage(
                "تسجيل قياسي (معتمد على الكوكيز)"),
        "registration_method_device_bound_key_description":
            MessageLookupByLibrary.simpleMessage(
                "استخدام مفتاح تشفير خاص بالجهاز يتم تخزينه بشكل آمن على هذا الجهاز فقط"),
        "registration_method_device_bound_key_title":
            MessageLookupByLibrary.simpleMessage(
                "تسجيل آمن (مفتاح مرتبط بالجهاز)"),
        "remember_me": MessageLookupByLibrary.simpleMessage("تذكرني"),
        "remove_file": MessageLookupByLibrary.simpleMessage("إزالة الملف"),
        "request_location_permission":
            MessageLookupByLibrary.simpleMessage("طلب إذن الموقع"),
        "researcher_login":
            MessageLookupByLibrary.simpleMessage("دخول الباحثين"),
        "resend_code":
            MessageLookupByLibrary.simpleMessage("إعادة إرسال الرمز"),
        "reset_password":
            MessageLookupByLibrary.simpleMessage("إعادة تعيين كلمة المرور"),
        "response_details_title":
            MessageLookupByLibrary.simpleMessage("تفاصيل الاستجابة"),
        "response_number": m12,
        "response_status_flagged":
            MessageLookupByLibrary.simpleMessage("معلَّمة"),
        "response_status_pending":
            MessageLookupByLibrary.simpleMessage("قيد الانتظار"),
        "response_status_rejected":
            MessageLookupByLibrary.simpleMessage("مرفوضة"),
        "response_status_synced":
            MessageLookupByLibrary.simpleMessage("متزامنة"),
        "responses_title": MessageLookupByLibrary.simpleMessage("الاستجابات"),
        "resume_survey": MessageLookupByLibrary.simpleMessage("استكمال"),
        "retry": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
        "retry_upload":
            MessageLookupByLibrary.simpleMessage("إعادة محاولة الرفع"),
        "scan_qr": MessageLookupByLibrary.simpleMessage("مسح رمز QR"),
        "scan_qr_code": MessageLookupByLibrary.simpleMessage("مسح رمز QR"),
        "scan_qr_code_instruction":
            MessageLookupByLibrary.simpleMessage("ضع رمز QR داخل الإطار للمسح"),
        "screen_resolution": MessageLookupByLibrary.simpleMessage("دقة الشاشة"),
        "search": MessageLookupByLibrary.simpleMessage("بحث"),
        "sections_count": m13,
        "select_date": MessageLookupByLibrary.simpleMessage("اختر التاريخ"),
        "select_file": MessageLookupByLibrary.simpleMessage("اختر ملف"),
        "select_language": MessageLookupByLibrary.simpleMessage("اختر اللغة"),
        "send_code": MessageLookupByLibrary.simpleMessage("إرسال الرمز"),
        "settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
        "share_link": MessageLookupByLibrary.simpleMessage("مشاركة"),
        "share_link_subject": m14,
        "show_less": MessageLookupByLibrary.simpleMessage("عرض أقل"),
        "show_qr_code": MessageLookupByLibrary.simpleMessage("عرض رمز QR"),
        "start_location_tracking":
            MessageLookupByLibrary.simpleMessage("بدء تتبع الموقع"),
        "start_transfer": MessageLookupByLibrary.simpleMessage("بدء النقل"),
        "statistics": MessageLookupByLibrary.simpleMessage("الإحصائيات"),
        "stop_location_tracking":
            MessageLookupByLibrary.simpleMessage("إيقاف تتبع الموقع"),
        "storage_permission_denied":
            MessageLookupByLibrary.simpleMessage("تم رفض إذن التخزين"),
        "submit": MessageLookupByLibrary.simpleMessage("إرسال"),
        "survey_code_placeholder":
            MessageLookupByLibrary.simpleMessage("مثال: ABC-123"),
        "survey_link": MessageLookupByLibrary.simpleMessage("رابط الاستطلاع"),
        "survey_overview":
            MessageLookupByLibrary.simpleMessage("نظرة عامة على الاستبيانات"),
        "surveys": MessageLookupByLibrary.simpleMessage("الاستطلاعات"),
        "sync": MessageLookupByLibrary.simpleMessage("مزامنة"),
        "tap_to_view": MessageLookupByLibrary.simpleMessage("اضغط للعرض"),
        "to_user_email": MessageLookupByLibrary.simpleMessage(
            "البريد الإلكتروني للمستخدم المستقبل"),
        "total": MessageLookupByLibrary.simpleMessage("الإجمالي"),
        "total_sections_touched":
            MessageLookupByLibrary.simpleMessage("إجمالي الأقسام المفتوحة"),
        "transfer_info_message": MessageLookupByLibrary.simpleMessage(
            "أدخل البريد الإلكتروني للباحث الذي سيستلم الجهاز. سيتم إرسال رمز التحقق لكلا المستخدمين."),
        "transfer_initiated_successfully":
            MessageLookupByLibrary.simpleMessage("تم بدء عملية النقل بنجاح"),
        "upload_failed": MessageLookupByLibrary.simpleMessage("فشل الرفع"),
        "upload_file": MessageLookupByLibrary.simpleMessage("رفع ملف"),
        "upload_files": MessageLookupByLibrary.simpleMessage("رفع ملفات"),
        "upload_image": MessageLookupByLibrary.simpleMessage("رفع صورة"),
        "upload_success":
            MessageLookupByLibrary.simpleMessage("تم رفع الملف بنجاح"),
        "uploaded": MessageLookupByLibrary.simpleMessage("تم الرفع"),
        "uploading": MessageLookupByLibrary.simpleMessage("جاري الرفع..."),
        "verification_code": MessageLookupByLibrary.simpleMessage("رمز التحقق"),
        "verification_code_resent": MessageLookupByLibrary.simpleMessage(
            "تم إعادة إرسال رمز التحقق بنجاح"),
        "verification_info_message": MessageLookupByLibrary.simpleMessage(
            "أدخل رمز التحقق المرسل إلى بريدك الإلكتروني لإكمال عملية نقل العهدة."),
        "verify": MessageLookupByLibrary.simpleMessage("تحقق"),
        "verify_custody":
            MessageLookupByLibrary.simpleMessage("التحقق من العهدة"),
        "verifying_device_key": MessageLookupByLibrary.simpleMessage(
            "جارٍ التحقق من مفتاح الجهاز..."),
        "view_details": MessageLookupByLibrary.simpleMessage("عرض التفاصيل"),
        "view_survey_drafts":
            MessageLookupByLibrary.simpleMessage("عرض مسودات الاستطلاع"),
        "welcome": MessageLookupByLibrary.simpleMessage(
            "مرحباً بكم في منصة الاستطلاعات"),
        "welcome_back_researcher": MessageLookupByLibrary.simpleMessage(
            "مرحباً بك مجدداً، أيها الباحث"),
        "welcome_subtitle": MessageLookupByLibrary.simpleMessage(
            "صوتك يهمنا.. شاركنا رأيك للمساهمة في التطوير والتحسين المستمر"),
        "zone": MessageLookupByLibrary.simpleMessage("المنطقة"),
        "zone_violation_message": MessageLookupByLibrary.simpleMessage(
            "لقد انتقلت خارج النطاق الجغرافي المصرح به للعمل. سيتم إنهاء جلستك فوراً لضمان أمن البيانات."),
        "zone_violation_title":
            MessageLookupByLibrary.simpleMessage("خرق المنطقة الأمنية")
      };
}
