import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app/theme.dart';
import 'core/localization/app_localizations.dart';
import 'data/repositories/catering_repository.dart';
import 'viewmodels/auth_company_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/functions_viewmodel.dart';
import 'viewmodels/recipes_viewmodel.dart';
import 'viewmodels/inventory_viewmodel.dart';
import 'viewmodels/staff_viewmodel.dart';
import 'viewmodels/costing_viewmodel.dart';
import 'views/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = CateringRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthCompanyViewModel(repository)),
        ChangeNotifierProvider(create: (_) => DashboardViewModel(repository)),
        ChangeNotifierProvider(create: (_) => FunctionsViewModel(repository)),
        ChangeNotifierProvider(create: (_) => RecipesViewModel(repository)),
        ChangeNotifierProvider(create: (_) => InventoryViewModel(repository)),
        ChangeNotifierProvider(create: (_) => StaffViewModel(repository)),
        ChangeNotifierProvider(create: (_) => CostingViewModel(repository)),
      ],
      child: const CateringErpApp(),
    ),
  );
}

class CateringErpApp extends StatelessWidget {
  const CateringErpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthCompanyViewModel>();
    final currentLang = authVM.currentLanguage;

    return MaterialApp(
      title: 'RasoiPro Catering ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: Locale(currentLang),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
        Locale('mr', 'IN'),
        Locale('gu', 'IN'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
