import 'package:auto/auth/presentation/bloc/auth_bloc.dart';
import 'package:auto/banners/presentation/bloc/remote_banner_bloc.dart';
import 'package:auto/banners/presentation/widgets/CarouselWithIndicator.dart';
import 'package:auto/brands/presentation/bloc/remote/remote_brand_bloc.dart';
import 'package:auto/categories/presentation/bloc/remote/remote_category_bloc.dart';
import 'package:auto/chatbot/presentation/bloc/remote/chat_bloc.dart';
import 'package:auto/chatbot/presentation/widgets/SupportAssistant.dart';
import 'package:auto/comments/presentation/bloc/comment_bloc.dart';
import 'package:auto/config/navigation/main_navigation.dart';

import 'package:auto/config/theme/app.theme.dart';
import 'package:auto/products/presentation/bloc/remote/order/remote_order_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_event.dart';

import 'package:auto/promotions/presentation/bloc/remote/remote_promoted_product_bloc.dart';
import 'package:auto/promotions/presentation/widgets/PromotionsSection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_database.dart';
import 'categories/presentation/widgets/CategorySection.dart';
import 'package:auto/products/domain/entities/product_entity.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_state.dart';
import 'package:auto/products/presentation/widgets/ProductGridCard.dart';
import 'package:flutter/cupertino.dart';
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
        home: const MainNavigation(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CarouselWithIndicator(),
              CategorySection(),
              const PromotionsSection(),
              const Divider(thickness: 8, color: Color(0xFFEEEEEE)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Text(
                      "Suggestions pour vous",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              BlocBuilder<RemoteProductsBloc, RemoteProductState>(
                builder: (context, state) {
                  if (state is RemoteProductsDone) {
                    // Create a randomized list of products
                    final products = List<ProductEntity>.from(state.allProducts!);
                    products.shuffle();
                    
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ProductGridCard(product: products[index]);
                      },
                    );
                  }
                  if (state is RemoteProductsLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
        const SupportAssistant(),
      ],
    );
  }
}
