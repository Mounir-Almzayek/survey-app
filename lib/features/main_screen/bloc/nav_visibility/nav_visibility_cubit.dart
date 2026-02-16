import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/repository/auth_local_repository.dart';
import '../../models/nav_visibility_context.dart';

class NavVisibilityCubit extends Cubit<NavVisibilityContext?> {
  NavVisibilityCubit() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final method = await AuthLocalRepository.getLoginMethod();
    emit(NavVisibilityContext(loginMethod: method));
  }
}
