part of 'language_bloc.dart';

abstract class LanguageEvent {
  const LanguageEvent();
}

class LoadLanguage extends LanguageEvent {
  const LoadLanguage();
}

class ChangeLanguage extends LanguageEvent {
  final AppLanguage language;
  const ChangeLanguage(this.language);
}

