

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hrm/app/route.dart';
import 'package:hrm/core/theme/app_theme/app_theme.dart';
import 'package:hrm/core/util/util.dart';

class App extends StatelessWidget {
  const App({super.key,});

  @override
  Widget build(BuildContext context) {
    // InitialBinding().dependencies();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      routerConfig:Routes().router ,
      builder: (context, child) {
        return Util(child: child);
      },
    );
  }
}
