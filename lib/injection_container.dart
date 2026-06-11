import 'package:auto/auth/data/datasource/auth_remote_datasource.dart';
import 'package:auto/auth/data/repository/auth_repository_impl.dart';
import 'package:auto/auth/domain/repository/auth_repository.dart';
import 'package:auto/auth/domain/usecases/auth_usecases.dart';
import 'package:auto/auth/presentation/bloc/auth_bloc.dart';
import 'package:auto/banners/data/data_source/local/banner_local_datasource_objectbox.dart';
import 'package:auto/banners/data/data_source/remote/banner_remote_datasource_dio.dart';
import 'package:auto/banners/data/repository/banner_repository_impl.dart';
import 'package:auto/banners/domain/repository/banner_repository.dart';
import 'package:auto/banners/domain/usecases/get_banners_usecase.dart';
import 'package:auto/banners/presentation/bloc/remote_banner_bloc.dart';
import 'package:auto/brands/data/data_source/local/brand_local_datasource_objectbox.dart';
import 'package:auto/brands/data/data_source/remote/brand_remote_datasource_dio.dart';
import 'package:auto/brands/domain/repository/brand_repository.dart';
import 'package:auto/brands/domain/usecases/get_brand_usecase.dart';
import 'package:auto/brands/presentation/bloc/remote/remote_brand_bloc.dart';
import 'package:auto/categories/data/data_source/remote/category_remote_datasource_dio.dart';
import 'package:auto/categories/data/repository/category_repository_impl.dart';
import 'package:auto/categories/domain/repository/category_repository.dart';
import 'package:auto/categories/domain/usecases/get_category_usecase.dart';
import 'package:auto/categories/presentation/bloc/remote/remote_category_bloc.dart';
import 'package:auto/chatbot/data/data_source/remote/chat_remote_datasource_dio.dart';
import 'package:auto/chatbot/data/data_source/remote/feedback_remote_datasource_dio.dart';
import 'package:auto/chatbot/data/repository/chat_repository_impl.dart';
import 'package:auto/chatbot/domain/repository/chat_repository.dart';
import 'package:auto/chatbot/domain/usecases/send_feedback_usecase.dart';
import 'package:auto/chatbot/domain/usecases/send_prompt_usecase.dart';
import 'package:auto/chatbot/presentation/bloc/remote/chat_bloc.dart';
import 'package:auto/comments/data/comment_repository_impl.dart';
import 'package:auto/comments/data/data_source/remote/comment_post_remote_datasource_dio.dart';
import 'package:auto/comments/data/data_source/remote/comment_remote_datasource_dio.dart';
import 'package:auto/comments/domain/repositories/comment_repository_impl.dart';
import 'package:auto/comments/domain/usecases/get_comments_use_case.dart';
import 'package:auto/comments/domain/usecases/post_comment_use_case.dart';
import 'package:auto/comments/presentation/bloc/comment_bloc.dart';
import 'package:auto/core/resources/network_info.dart';
import 'package:auto/core/constants/constants.dart';
import 'package:auto/core/resources/local_storage_service.dart';
import 'package:auto/products/data/data_source/local/product_local_data_source.dart';
import 'package:auto/products/data/data_source/remote/product_remote_datasource_dio.dart';
import 'package:auto/products/data/repository/product_repository_impl.dart';
import 'package:auto/products/domain/repository/product_repository.dart';
import 'package:auto/products/domain/usecases/get_product_usecase.dart';
import 'package:auto/products/domain/usecases/send_order_usecase.dart';
import 'package:auto/products/presentation/bloc/remote/order/remote_order_bloc.dart';
import 'package:auto/products/presentation/bloc/remote/remote_product_bloc.dart';
import 'package:auto/orders/data/datasource/my_order_remote_datasource.dart';
import 'package:auto/orders/data/repository/my_order_repository_impl.dart';
import 'package:auto/orders/domain/repository/my_order_repository.dart';
import 'package:auto/orders/domain/usecases/get_my_orders_usecase.dart';
import 'package:auto/orders/presentation/bloc/my_orders_bloc.dart';
import 'package:auto/promotions/data/data_source/remote/promotion_remote_datasource_dio.dart';
import 'package:auto/promotions/data/repository/promoted_product_repository.dart';
import 'package:auto/promotions/domain/repository/promoted_product_repository.dart';
import 'package:auto/promotions/domain/usecases/promoted_product_usecase.dart';
import 'package:auto/promotions/presentation/bloc/remote/remote_promoted_product_bloc.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'app_database.dart';
import 'brands/data/repository/brand_dio_impl.dart';
import 'categories/data/data_source/local/category_local_datasource_objectbox.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  await sl.reset();
  // ✅ Injecter ObjectBox d'abord
  sl.registerSingleton<ObjectBoxService>(ObjectBoxService());

  // 🗃️ Local DataSources
  sl.registerSingleton<ProductLocalDataSource>(
    ProductLocalDataSource(sl<ObjectBoxService>()),
  );
  sl.registerSingleton<CategoryLocalDataSource>(
    CategoryLocalDataSource(sl<ObjectBoxService>()),
  );
  sl.registerSingleton<BrandLocalDataSource>(
    BrandLocalDataSource(sl<ObjectBoxService>()),
  );
  sl.registerSingleton<BannerLocalDataSource>(
    BannerLocalDataSource(sl<ObjectBoxService>()),
  );

  // 🌐 Network
  sl.registerSingleton<InternetConnection>(InternetConnection());
  sl.registerSingleton<NetworkInfo>(NetworkInfo(sl()));

  // 🌍 Dio + API Services
  final appDir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    storage: FileStorage('${appDir.path}/.cookies/'),
  );
  final dio = Dio(BaseOptions(
    baseUrl: localAPIBaseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ));
  dio.interceptors.add(CookieManager(cookieJar));
  // Add authentication token to requests
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add token from local storage if available
        if (LocalStorageService.isLoggedIn && LocalStorageService.token != null) {
          options.headers['Authorization'] = 'Bearer ${LocalStorageService.token}';
        }
        return handler.next(options);
      },
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onResponse: (response, handler) {
                                                return handler.next(response);
      },
      onError: (DioException e, handler) async {
                                                        if (e.response?.statusCode == 401) {
          await LocalStorageService.clearAuth();
          await cookieJar.deleteAll();
          sl<AuthBloc>().add(const SessionExpired());
        }
        return handler.next(e);
      },
    ),
  );
  sl.registerSingleton<Dio>(dio);
  sl.registerSingleton<ProductRemoteDatasourceDio>(
    ProductRemoteDatasourceDio(sl()),
  );
  sl.registerSingleton<BrandRemoteDatasourceDio>(
    BrandRemoteDatasourceDio(sl()),
  );
  sl.registerSingleton<CategoryRemoteDataSourceDio>(
    CategoryRemoteDataSourceDio(sl()),
  );
  sl.registerSingleton<BannerRemoteDatasourceDio>(
    BannerRemoteDatasourceDio(sl()),
  );
  sl.registerSingleton<PromotionRemoteDatasourceDio>(
    PromotionRemoteDatasourceDio(sl()),
  );
  sl.registerSingleton<ChatRemoteDatasourceDio>(ChatRemoteDatasourceDio(sl()));
  sl.registerSingleton<FeedbackRemoteDatasourceDio>(
    FeedbackRemoteDatasourceDio(sl()),
  );
  sl.registerSingleton<CommentRemoteDatasourceDio>(
    CommentRemoteDatasourceDio(sl()),
  );
  sl.registerSingleton<CommentPostRemoteDatasourceDio>(
    CommentPostRemoteDatasourceDio(sl()),
  );
  sl.registerSingleton<AuthRemoteDatasource>(AuthRemoteDatasource(sl()));
  sl.registerSingleton<MyOrderRemoteDatasource>(MyOrderRemoteDatasource(sl()));

  // 📦 Repositories
  sl.registerSingleton<ProductRepository>(
    ProductRepositoryImpl(sl(), sl(), sl(), sl()),
  );
  sl.registerSingleton<CategoryRepository>(
    CategoryRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerSingleton<BrandRepository>(
    BrandRepositoryDioImpl(sl(), sl(), sl()),
  );
  sl.registerSingleton<BannerRepository>(
    BannerRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerSingleton<PromotedProductRepository>(
    PromotedProductRepositoryImpl(sl(), sl()),
  );
  sl.registerSingleton<ChatMessageRepository>(
    ChatMessageRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerSingleton<CommentRepository>(
    CommentRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl()));
  sl.registerSingleton<MyOrderRepository>(MyOrderRepositoryImpl(sl()));

  // 💼 UseCases
  sl.registerSingleton<GetProductUseCase>(GetProductUseCase(sl()));
  sl.registerSingleton<GetCategoryUseCase>(GetCategoryUseCase(sl()));
  sl.registerSingleton<GetBannerUseCase>(GetBannerUseCase(sl()));
  sl.registerSingleton<GetPromotedProductUseCase>(
    GetPromotedProductUseCase(sl()),
  );
  sl.registerSingleton<SendOrderUseCase>(SendOrderUseCase(sl()));
  sl.registerSingleton<GetBrandUseCase>(GetBrandUseCase(sl()));
  sl.registerSingleton<SendPromptUseCase>(SendPromptUseCase(sl()));
  sl.registerSingleton<SendFeedbackUseCase>(SendFeedbackUseCase(sl()));
  sl.registerSingleton<GetCommentUseCase>(GetCommentUseCase(sl()));
  sl.registerSingleton<PostCommentUseCase>(PostCommentUseCase(sl()));
  sl.registerSingleton<LoginUseCase>(LoginUseCase(sl()));
  sl.registerSingleton<RegisterUseCase>(RegisterUseCase(sl()));
  sl.registerSingleton<LogoutUseCase>(LogoutUseCase(sl()));
  sl.registerSingleton<GetMyOrdersUseCase>(GetMyOrdersUseCase(sl()));
  sl.registerSingleton<GetProductsPaginatedUseCase>(
    GetProductsPaginatedUseCase(sl()),
  );

  // 📦 BLoCs
  sl.registerFactory<RemoteProductsBloc>(
    () => RemoteProductsBloc(sl()),
  );
  sl.registerFactory<RemoteCategoryBloc>(() => RemoteCategoryBloc(sl()));
  sl.registerFactory<RemoteBannerBloc>(() => RemoteBannerBloc(sl()));
  sl.registerFactory<RemotePromotedProductBloc>(
    () => RemotePromotedProductBloc(sl()),
  );
  sl.registerFactory<RemoteOrderBloc>(() => RemoteOrderBloc(sl()));
  sl.registerFactory<RemoteBrandBloc>(() => RemoteBrandBloc(sl()));
  sl.registerFactory<ChatBloc>(() => ChatBloc(sl(), sl()));
  sl.registerFactory<CommentBloc>(() => CommentBloc(sl(), sl()));
  sl.registerSingleton<AuthBloc>(AuthBloc(sl(), sl(), sl()));
  sl.registerFactory<MyOrdersBloc>(() => MyOrdersBloc(sl()));
}
