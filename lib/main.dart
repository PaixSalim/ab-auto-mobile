import 'package:auto/auth/presentation/bloc/auth_bloc.dart';
import 'package:auto/banners/presentation/bloc/remote_banner_bloc.dart';
import 'package:auto/banners/presentation/widgets/CarouselWithIndicator.dart';
import 'package:auto/brands/presentation/bloc/remote/remote_brand_bloc.dart';
import 'package:auto/categories/presentation/bloc/remote/remote_category_bloc.dart';
import 'package:auto/chatbot/presentation/bloc/remote/chat_bloc.dart';
import 'package:auto/chatbot/presentation/widgets/SupportAssistant.dart';
import 'package:auto/comments/presentation/bloc/comment_bloc.dart';
import 'package:auto/config/navigation/main_navigation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'package:auto/config/theme/app.theme.dart';
import 'package:auto/products/presentation/bloc/remote/order/remote_order_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_event.dart';

import 'package:auto/promotions/presentation/bloc/remote/remote_promoted_product_bloc.dart';
import 'package:auto/promotions/presentation/widgets/PromotionsSection.dart';
import 'package:auto/notifications/data/notification_service.dart';
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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Demander les permissions de notification
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Autoriser spécifiquement l'affichage pour iOS (et certaines surcouches Android) au premier plan
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
    
    // Souscrire au topic de promotions et au topic global
    await messaging.subscribeToTopic('promotions_topic');
    await messaging.subscribeToTopic('all_users');
    print("Inscrit avec succès aux topics des promotions et all_users");

    // Initialiser les notifications locales
    await NotificationService.init();

    // Écoute locale pour afficher la notif en mode premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔥 INFO: Notif reçue en mode ouvert: ${message.notification?.title}');
      NotificationService.showNotification(message);
    });
    
  } catch (e) {
    print("Erreur d'initialisation Firebase (vérifiez google-services.json): $e");
  }

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _displayedProductsCount = 8; // Initial number of products to display
  static const int _incrementCount = 8; // Number of products to load each time
  List<ProductEntity>? _cachedShuffledProducts; // Cached to prevent reshuffling

  void _loadMoreProducts() {
    setState(() {
      _displayedProductsCount += _incrementCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteProductsBloc, RemoteProductState>(
      builder: (context, state) {
        bool isLoading = state is RemoteProductsLoading;
        List<ProductEntity> displayList = [];
        bool hasMoreProducts = false;

        if (state is RemoteProductsDone && state.allProducts != null) {
          // Verify cache or regenerate if the source list changes
          if (_cachedShuffledProducts == null || _cachedShuffledProducts!.length != state.allProducts!.length) {
            _cachedShuffledProducts = List<ProductEntity>.from(state.allProducts!);
            _cachedShuffledProducts!.shuffle();
          }
          
          displayList = _cachedShuffledProducts!.take(_displayedProductsCount).toList();
          hasMoreProducts = _displayedProductsCount < _cachedShuffledProducts!.length;
        }

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: CarouselWithIndicator()),
                SliverToBoxAdapter(child: CategorySection()),
                const SliverToBoxAdapter(child: PromotionsSection()),
                const SliverToBoxAdapter(child: Divider(thickness: 8, color: Color(0xFFEEEEEE))),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [ 
                        Text(
                          "Suggestions pour vous",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CupertinoActivityIndicator()),
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.65,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProductGridCard(
                            product: displayList[index],
                            index: index, // Passes index for unique Hero tag
                          );
                        },
                        childCount: displayList.length,
                      ),
                    ),
                  ),
                  
                  // Load More Button
                  if (hasMoreProducts)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: _loadMoreProducts,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "Charger plus d'articles",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                  // End message if all products are displayed
                  if (!hasMoreProducts && displayList.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            "Tous les articles sont affichés",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
            
            // const SupportAssistant(),
          ],
        );
      },
    );
  }
}
