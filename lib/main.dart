import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'viewmodels/task_viewmodel.dart';
import 'views/task_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
      ],
      child: Consumer<TaskViewModel>(
        builder: (context, viewModel, _) {
          return MaterialApp(
            title: 'TaskFlow - Task Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: viewModel.themeMode,
            home: const TaskScreen(),
          );
        },
      ),
    );
  }
}
