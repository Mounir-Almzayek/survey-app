import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/auth/session_invalidation_coordinator.dart';
import 'core/l10n/generated/l10n.dart';
import 'core/routes/app_pages.dart';
import 'core/services/hive_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/app_info_service.dart';
// import 'core/services/firebase_service.dart';
import 'core/queue/services/request_queue_manager.dart';
import 'core/queue/presentation/queue_status_listener.dart';
import 'core/styles/app_theme.dart';
import 'features/assignment/bloc/assignments_list/assignments_list_bloc.dart';
import 'features/device_location/bloc/device_location/device_location_bloc.dart';
import 'features/language/bloc/language/language_bloc.dart';
import 'features/profile/bloc/profile/profile_bloc.dart';
import 'features/device_location/presentation/location_permission_gate.dart';
import 'features/device_location/presentation/zone_violation_listener.dart';
import 'features/profile/services/profile_session_invalidation_policy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dotenv
  await dotenv.load();

  // Initialize services
  await StorageService.init();
  await HiveService.init();
  await AppInfoService.instance.initialize();
  // await FirebaseService.init();
  await RequestQueueManager().init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SessionInvalidationCoordinator.instance.configure(
        policy: const ProfileSessionInvalidationPolicy(),
        afterCleared: () {
          final ctx = Pages.navigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            ctx.read<ProfileBloc>().add(const SessionInvalidatedByServer());
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LanguageBloc()..add(const LoadLanguage())),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => DeviceLocationBloc()),
        BlocProvider(create: (_) => AssignmentsListBloc()),
      ],
      child: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (prev, curr) => curr is ProfileLogoutSuccess,
        listener: (context, state) {
          if (state is ProfileLogoutSuccess) {
            context.read<AssignmentsListBloc>().add(ClearAssignmentsList());
          }
        },
        child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          return ScreenUtilInit(
            designSize: const Size(360, 800),
            minTextAdapt: true,
            splitScreenMode: true,
            rebuildFactor: RebuildFactors.always,
            builder: (context, child) {
              return MaterialApp.router(
                title: 'Accreditation App',
                theme: appThemeData(context),
                debugShowCheckedModeBanner: false,
                locale: state.language.locale,
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
                routerConfig: appPages,
                builder: (context, child) {
                  final content = QueueStatusListener(
                    child: child ?? const SizedBox.shrink(),
                  );
                  return ZoneViolationListener(
                    child: LocationPermissionGate(child: content),
                  );
                },
              );
            },
          );
        },
        ),
      ),
    );
  }
}
