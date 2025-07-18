import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:techwiz/features/auth/data/auth_api_service.dart';
import 'package:techwiz/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:techwiz/features/auth/domain/usecases/login_user.dart';
import 'package:techwiz/features/auth/domain/usecases/register_user.dart';
import 'package:techwiz/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:techwiz/features/auth/presentation/cubits/auth_state.dart';
import 'package:techwiz/features/auth/presentation/screens/login_page.dart';
import 'package:techwiz/features/auth/presentation/screens/register_page.dart';
import 'package:techwiz/features/dashboard/data/dashboard_api_service.dart';
import 'package:techwiz/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:techwiz/features/problems/data/problems_api_service.dart';
import 'package:techwiz/features/problems/data/repositories/problems_repository_impl.dart';
import 'package:techwiz/features/categories/data/categories_api_service.dart';
import 'package:techwiz/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:techwiz/features/ai/data/ai_api_service.dart';
import 'package:techwiz/features/ai/data/ai_repository_impl.dart';
import 'package:techwiz/features/dashboard/domain/usecases/get_quick_actions_usecase.dart';
import 'package:techwiz/features/dashboard/domain/usecases/get_recent_guides_usecase.dart';
import 'package:techwiz/features/problems/domain/usecases/get_paginated_issues_usecase.dart';
import 'package:techwiz/features/problems/domain/usecases/get_issues_by_category_usecase.dart';
import 'package:techwiz/features/categories/domain/usecases/get_categories_detailed_usecase.dart';
import 'package:techwiz/features/ai/domain/usecases/match_problems_usecase.dart';
import 'package:techwiz/features/problems/presentation/cubits/paginated_issues_cubit.dart';
import 'package:techwiz/features/problems/presentation/cubits/category_issues_cubit.dart';
import 'package:techwiz/features/dashboard/presentation/cubits/dashboard_cubit.dart';
import 'package:techwiz/features/dashboard/presentation/cubits/dashboard_state.dart';
import 'package:techwiz/features/ai/presentation/cubits/ai_match_cubit.dart';
import 'package:techwiz/features/dashboard/presentation/screens/dashboard_page.dart';
import 'package:techwiz/features/ai/presentation/pages/ai_match_page.dart';
import 'package:techwiz/utils/colors.dart';
import 'package:techwiz/utils/theme_manager.dart';

Future<void> main() async {
  await dotenv.load();
  final httpClient = http.Client();

  final authApiService = AuthApiService(httpClient);
  final authRepository = AuthRepositoryImpl(authApiService);

  final dashboardApiService = DashboardApiService(httpClient);
  final dashboardRepository = DashboardRepositoryImpl(dashboardApiService);

  final problemsApiService = ProblemsApiService(httpClient);
  final problemsRepository = ProblemsRepositoryImpl(problemsApiService);

  final categoriesApiService = CategoriesApiService(httpClient);
  final categoriesRepository = CategoriesRepositoryImpl(categoriesApiService);

  final aiApiService = AiApiService(httpClient);
  final aiRepository = AiRepositoryImpl(aiApiService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(
            AuthInitial(),
            loginUser: LoginUser(authRepository),
            registerUser: RegisterUser(authRepository),
          ),
        ),
        BlocProvider(
          create: (_) => DashboardCubit(
            DashboardInitial(),
            getQuickActionsUseCase: GetQuickActionsUseCase(dashboardRepository),
            getRecentGuidesUseCase: GetRecentGuidesUseCase(dashboardRepository),
            getCategoriesDetailedUseCase: GetCategoriesDetailedUseCase(
              categoriesRepository,
            ),
          ),
        ),
        BlocProvider(
          create: (_) => PaginatedIssuesCubit(
            getPaginatedIssuesUseCase: GetPaginatedIssuesUseCase(
              problemsRepository,
            ),
          ),
        ),
        BlocProvider(
          create: (_) => CategoryIssuesCubit(
            getIssuesByCategoryUseCase: GetIssuesByCategoryUseCase(
              problemsRepository,
            ),
          ),
        ),
        BlocProvider(
          create: (_) => AiMatchCubit(MatchProblemsUseCase(aiRepository)),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      builder: (context, _) {
        final themeManager = Provider.of<ThemeManager>(context);
        return MaterialApp(
          title: 'TechWiz',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: AppColors.lightColorScheme,
            useMaterial3: true,
            fontFamily: 'System',
          ),
          darkTheme: ThemeData(
            colorScheme: AppColors.darkColorScheme,
            useMaterial3: true,
            fontFamily: 'System',
          ),
          themeMode: themeManager.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/home': (context) => const DashboardPage(),
            '/ai': (context) => const AiMatchPage(),
          },
        );
      },
    );
  }
}
