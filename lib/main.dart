import 'package:auto/auth/presentation/bloc/auth_bloc.dart';
import 'package:auto/banners/presentation/bloc/remote_banner_bloc.dart';
import 'package:auto/banners/presentation/widgets/CarouselWithIndicator.dart';
import 'package:auto/brands/presentation/bloc/remote/remote_brand_bloc.dart';
import 'package:auto/categories/presentation/bloc/remote/remote_category_bloc.dart';
import 'package:auto/chatbot/presentation/bloc/remote/chat_bloc.dart';
import 'package:auto/chatbot/presentation/widgets/SupportAssistant.dart';
import 'package:auto/comments/presentation/bloc/comment_bloc.dart';
import 'package:auto/config/navigation/main_navigation.dart';
import 'package:auto/config/onboarding/introduction_screen.dart';
import 'package:auto/config/theme/app.theme.dart';
import 'package:auto/products/presentation/bloc/remote/order/remote_order_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_event.dart';
import 'package:auto/products/presentation/widgets/partners/PartnerSection.dart';
import 'package:auto/products/presentation/widgets/search.index.bar.dart';
import 'package:auto/promotions/presentation/bloc/remote/remote_promoted_product_bloc.dart';
import 'package:auto/promotions/presentation/widgets/PromotionsSection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_database.dart';
import 'categories/presentation/widgets/CategorySection.dart';
import 'core/resources/local_storage_service.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await ObjectBoxService.init();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final bool isFirstLaunch = LocalStorageService.isFirstLaunch;
    return MultiBlocProvider(
      providers: [
        BlocProvider<RemoteProductsBloc>(
          create: (context) => sl()..add(const GetProducts()),
        ),
        BlocProvider<RemoteCategoryBloc>(
          create: (context) => sl()..add(const GetCategories()),
        ),
        BlocProvider<RemotePromotedProductBloc>(
          create: (context) => sl()..add(const GetPromotedProduct()),
        ),
        BlocProvider<RemoteBannerBloc>(
          create: (context) => sl()..add(const GetBanner()),
        ),
        BlocProvider<RemoteOrderBloc>(create: (context) => sl()),
        BlocProvider<RemoteBrandBloc>(
          create: (context) => sl()..add(const GetBrandsEvent()),
        ),
        BlocProvider<ChatBloc>(create: (context) => sl()),
        BlocProvider<CommentBloc>(create: (context) => sl()),
        BlocProvider<AuthBloc>(create: (context) {
          final bloc = sl<AuthBloc>();
          bloc.add(const AppStarted());
          return bloc;
        }),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AB Auto',
        theme: theme(),
        home: isFirstLaunch ? OnBoardingPage() : MainNavigation(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(1),
          child: HomeSearchbar(),
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.account_circle),
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Text(
                        state.user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 18),
                          SizedBox(width: 8),
                          Text('Se déconnecter'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajouté pour éviter les conflits
              children: [
                CarouselWithIndicator(),
                CategorySection(),
                PromotionsSection(),
              ],
            ),
          ),
          const SupportAssistant(),
        ],
      ),
    );
  }
}
