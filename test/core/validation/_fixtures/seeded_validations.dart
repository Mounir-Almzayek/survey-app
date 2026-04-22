// Hand-typed mirror of survey-system/prisma/seeders/validations.ts.
// Re-sync manually if the backend seed changes.

import 'package:king_abdulaziz_center_survey_app/core/enums/survey_enums.dart';
import 'package:king_abdulaziz_center_survey_app/core/models/survey/validation_model.dart';

Validation _v({
  required int id,
  required String regex,
  required String en,
  required String ar,
  required String enContent,
  required String arContent,
  bool needsValue = false,
  List<Map<String, dynamic>> valueFields = const [],
}) {
  return Validation(
    id: id,
    type: ValidationType.questions,
    validation: regex,
    enTitle: en,
    arTitle: ar,
    enContent: enContent,
    arContent: arContent,
    needsValue: needsValue,
    valueFields: valueFields,
    isActive: true,
  );
}

final Validation vNumber = _v(
  id: 1,
  regex: r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$',
  en: 'Number',
  ar: 'رقم',
  enContent: 'Value must be a number (integer or decimal); optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة رقماً (صحيحاً أو عشرياً)؛ يُسمح بعلامة + أو - في البداية',
);

final Validation vPositiveNumber = _v(
  id: 2,
  regex: r'^\+?[1-9١-٩][0-9٠-٩]*$',
  en: 'Positive Number',
  ar: 'رقم موجب',
  enContent: 'Value must be a positive number (greater than zero); optional leading + is allowed (e.g. +24)',
  arContent: 'يجب أن تكون القيمة رقماً موجباً (أكبر من الصفر)؛ يُسمح بعلامة + في البداية (مثل +24)',
);

final Validation vInteger = _v(
  id: 3,
  regex: r'^[-+]?[0-9٠-٩]+$',
  en: 'Integer (Positive or Negative)',
  ar: 'عدد صحيح (موجب أو سالب)',
  enContent: 'Value must be an integer; optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة عدداً صحيحاً؛ يُسمح بعلامة + أو - في البداية',
);

final Validation vDecimal = _v(
  id: 4,
  regex: r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$',
  en: 'Decimal Number',
  ar: 'رقم عشري',
  enContent: 'Value must be a decimal number; optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة رقماً عشرياً؛ يُسمح بعلامة + أو - في البداية',
);

final Validation vDecimal2 = _v(
  id: 5,
  regex: r'^[-+]?[0-9٠-٩]+\.[0-9٠-٩]{2}$',
  en: 'Decimal Number (2 Decimal Places)',
  ar: 'رقم عشري (منزلتان عشريتان)',
  enContent: 'Value must be a decimal number with exactly 2 decimal places; optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة رقماً عشرياً بمنزلتين عشريتين بالضبط؛ يُسمح بعلامة + أو - في البداية',
);

final Validation vMinLength = _v(
  id: 6,
  regex: r'^.{min,}$',
  en: 'Minimum Length',
  ar: 'الحد الأدنى للمحارف',
  enContent: 'Value must have a minimum number of characters',
  arContent: 'يجب أن تحتوي القيمة على الحد الأدنى من المحارف',
  needsValue: true,
  valueFields: const [{'field': 'min', 'type': 'positive_integer'}],
);

final Validation vMaxLength = _v(
  id: 7,
  regex: r'^.{0,max}$',
  en: 'Maximum Length',
  ar: 'الحد الأقصى للمحارف',
  enContent: 'Value must not exceed a maximum number of characters',
  arContent: 'يجب ألا تتجاوز القيمة الحد الأقصى من المحارف',
  needsValue: true,
  valueFields: const [{'field': 'max', 'type': 'positive_integer'}],
);

final Validation vLengthRange = _v(
  id: 8,
  regex: r'^.{min,max}$',
  en: 'Length Range',
  ar: 'نطاق الطول',
  enContent: 'Value must be between minimum and maximum number of characters',
  arContent: 'يجب أن تكون القيمة بين الحد الأدنى والأقصى من المحارف',
  needsValue: true,
  valueFields: const [
    {'field': 'min', 'type': 'positive_integer'},
    {'field': 'max', 'type': 'positive_integer'},
  ],
);

final Validation vMinLetters = _v(
  id: 9,
  regex: '^(?!.*[٠-٩])(?!.*[0-9])[؀-ٰٟ-ۿa-zA-Z]{min,}\$',
  en: 'Minimum Letters',
  ar: 'الحد الأدنى للأحرف',
  enContent: 'Value must have a minimum number of letters (alphabetic characters only)',
  arContent: 'يجب أن تحتوي القيمة على الحد الأدنى من الحروف (أحرف فقط)',
  needsValue: true,
  valueFields: const [{'field': 'min', 'type': 'positive_integer'}],
);

final Validation vMaxLetters = _v(
  id: 10,
  regex: '^(?!.*[٠-٩])(?!.*[0-9])[؀-ٰٟ-ۿa-zA-Z]{0,max}\$',
  en: 'Maximum Letters',
  ar: 'الحد الأقصى للأحرف',
  enContent: 'Value must not exceed a maximum number of letters (alphabetic characters only)',
  arContent: 'يجب ألا تتجاوز القيمة الحد الأقصى من الحروف (أحرف فقط)',
  needsValue: true,
  valueFields: const [{'field': 'max', 'type': 'positive_integer'}],
);

final Validation vLettersOnly = _v(
  id: 11,
  regex: '^(?!.*[٠-٩])[؀-ٰٟ-ۿa-zA-Z]+\$',
  en: 'Letters Only',
  ar: 'أحرف فقط',
  enContent: 'Value must contain only alphabetic characters (no numbers, special characters, or spaces)',
  arContent: 'يجب أن تكون بدون ارقام او رموز خاصة أو مسافات',
);

final Validation vLettersAndSpaces = _v(
  id: 12,
  regex: '^(?!.*[٠-٩])[؀-ٰٟ-ۿa-zA-Z ]+\$',
  en: 'Letters and Spaces Only',
  ar: 'أحرف ومسافات فقط',
  enContent: 'Value must contain only alphabetic characters and spaces',
  arContent: 'يجب أن تحتوي القيمة على أحرف ومسافات فقط',
);

final Validation vAlphanumeric = _v(
  id: 13,
  regex: '^[؀-ۿa-zA-Z0-9٠-٩]+\$',
  en: 'Alphanumeric',
  ar: 'أحرف وأرقام',
  enContent: 'Value must contain only letters and numbers (no spaces or special characters)',
  arContent: 'يجب أن تحتوي القيمة على أحرف وأرقام فقط (بدون مسافات أو رموز خاصة)',
);

final Validation vAlphanumericWithSpaces = _v(
  id: 14,
  regex: '^[؀-ۿa-zA-Z0-9٠-٩\\s]+\$',
  en: 'Alphanumeric with Spaces',
  ar: 'أحرف وأرقام مع مسافات',
  enContent: 'Value must contain only letters, numbers, and spaces',
  arContent: 'يجب أن تحتوي القيمة على أحرف وأرقام ومسافات فقط',
);

final Validation vEmail = _v(
  id: 15,
  regex: '^[a-zA-Z0-9٠-٩._%+-]+@[a-zA-Z0-9٠-٩.-]+\\.[a-zA-Z]{2,}\$',
  en: 'Email',
  ar: 'بريد إلكتروني',
  enContent: 'Value must be a valid email address',
  arContent: 'يجب أن تكون القيمة عنوان بريد إلكتروني صحيح',
);

final Validation vUrl = _v(
  id: 16,
  regex: r'^(https?://)?([\da-z٠-٩.-]+)\.([a-z.]{2,6})([/\w .-]*)*/?$',
  en: 'URL',
  ar: 'رابط',
  enContent: 'Value must be a valid URL',
  arContent: 'يجب أن تكون القيمة رابطاً صحيحاً',
);

final Validation vNoSpaces = _v(
  id: 17,
  regex: r'^\S+$',
  en: 'No Spaces',
  ar: 'بدون مسافات',
  enContent: 'Value must not contain any spaces',
  arContent: 'يجب ألا تحتوي القيمة على مسافات',
);

final Validation vNoSpecialChars = _v(
  id: 18,
  regex: '^[؀-ۿa-zA-Z0-9٠-٩\\s]+\$',
  en: 'No Special Characters',
  ar: 'بدون رموز خاصة',
  enContent: 'Value must not contain special characters (only letters, numbers, and spaces)',
  arContent: 'يجب ألا تحتوي القيمة على رموز خاصة (أحرف وأرقام ومسافات فقط)',
);

final Validation vMinValue = _v(
  id: 19,
  regex: r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$',
  en: 'Minimum Value',
  ar: 'الحد الأدنى للقيمة',
  enContent: 'Value must be a number greater than or equal to the specified minimum; optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة رقماً أكبر من أو يساوي الحد الأدنى المحدد؛ يُسمح بعلامة + أو - في البداية',
  needsValue: true,
  valueFields: const [{'field': 'min', 'type': 'number'}],
);

final Validation vMaxValue = _v(
  id: 20,
  regex: r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$',
  en: 'Maximum Value',
  ar: 'الحد الأقصى للقيمة',
  enContent: 'Value must be a number less than or equal to the specified maximum; optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة رقماً أقل من أو يساوي الحد الأقصى المحدد؛ يُسمح بعلامة + أو - في البداية',
  needsValue: true,
  valueFields: const [{'field': 'max', 'type': 'number'}],
);

final Validation vValueRange = _v(
  id: 21,
  regex: r'^[-+]?[0-9٠-٩]+(\.[0-9٠-٩]+)?$',
  en: 'Value Range',
  ar: 'نطاق القيمة',
  enContent: 'Value must be a number within the specified range (min to max); optional leading + or - is allowed',
  arContent: 'يجب أن تكون القيمة رقماً ضمن النطاق المحدد (من الحد الأدنى إلى الأقصى)؛ يُسمح بعلامة + أو - في البداية',
  needsValue: true,
  valueFields: const [
    {'field': 'min', 'type': 'number'},
    {'field': 'max', 'type': 'number'},
  ],
);

final Validation vArabicOnly = _v(
  id: 22,
  regex: '^(?=.*[؀-ۿ])[؀-ۿ٠-٩\\s‌‍\\x21-\\x2F\\x3A-\\x40\\x5B-\\x60\\x7B-\\x7E]+\$',
  en: 'Arabic Text Only',
  ar: 'نص عربي فقط',
  enContent: 'Value must be Arabic text with optional common punctuation and Arabic-Indic digits; Latin letters and Western digits are not allowed',
  arContent: 'يجب أن يكون النص عربياً مع السماح بعلامات الترقيم الشائعة والأرقام العربية (٠–٩)، دون الحروف أو الأرقام اللاتينية',
);

final Validation vEnglishOnly = _v(
  id: 23,
  regex: r'^[\x00-\x7F]+$',
  en: 'English Text Only',
  ar: 'نص إنجليزي فقط',
  enContent: 'Value must contain only English characters',
  arContent: 'يجب أن تحتوي القيمة على أحرف إنجليزية فقط',
);

final Validation vMinEight = _v(
  id: 24,
  regex: r'^.{8,}$',
  en: 'Minimum 8 Characters',
  ar: '8 محارف على الأقل',
  enContent: 'Value must be at least 8 characters long',
  arContent: 'يجب أن تكون القيمة 8 محارف على الأقل',
);

final Validation vStrongPassword = _v(
  id: 25,
  regex: r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9٠-٩])(?=.*[!@#$%^&*]).{8,}$',
  en: 'Strong Password',
  ar: 'كلمة مرور قوية',
  enContent: 'Value must be a strong password (at least 8 characters, including uppercase, lowercase, number, and special character)',
  arContent: 'يجب أن تكون القيمة كلمة مرور قوية (8 أحرف على الأقل، تتضمن حرف كبير وصغير ورقم ورمز خاص)',
);

/// All 25 seeded rules for iteration in lookup/fingerprint tests.
final List<Validation> allSeededValidations = [
  vNumber, vPositiveNumber, vInteger, vDecimal, vDecimal2,
  vMinLength, vMaxLength, vLengthRange,
  vMinLetters, vMaxLetters, vLettersOnly, vLettersAndSpaces,
  vAlphanumeric, vAlphanumericWithSpaces,
  vEmail, vUrl, vNoSpaces, vNoSpecialChars,
  vMinValue, vMaxValue, vValueRange,
  vArabicOnly, vEnglishOnly,
  vMinEight, vStrongPassword,
];
