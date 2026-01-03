import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/app_language.dart';
import '../../../splash/repositories/settings_local_repository.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc()
    : super(
        LanguageInitial(
          language: AppLanguage.fromCode(
            SettingsLocalRepository.loadLanguage().languageCode,
          ),
        ),
      ) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  void _onLoadLanguage(LoadLanguage event, Emitter<LanguageState> emit) {
    final locale = SettingsLocalRepository.loadLanguage();
    emit(LanguageInitial(language: AppLanguage.fromCode(locale.languageCode)));
  }

  void _onChangeLanguage(ChangeLanguage event, Emitter<LanguageState> emit) {
    SettingsLocalRepository.storeLanguage(event.language.locale);
    emit(LanguageInitial(language: event.language));
  }
}

