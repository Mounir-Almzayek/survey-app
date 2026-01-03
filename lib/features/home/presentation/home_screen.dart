import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/l10n/generated/l10n.dart';
import '../../../core/widgets/custom_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160.h),
        child: CustomAppBar(
          title: locale.home,
          big: false,
          showDrawerButton: true,
        ),
      ),
      body: Center(child: Text(locale.home)),
    );
  }
}
