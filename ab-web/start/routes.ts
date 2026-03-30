/*
|--------------------------------------------------------------------------
| Routes file
|--------------------------------------------------------------------------
|
| The routes file is used for defining the HTTP routes.
|
*/

import router from '@adonisjs/core/services/router'
import { middleware } from '#start/kernel'
const CommentController = () => import('#controllers/admin/comment_controller')
const PromotionController = () => import('#controllers/admin/promotion_controller')
const ChatbotsController = () => import('#controllers/admin/chatbots_controller')
const ApiController = () => import('#controllers/api_controller')
const StoreController = () => import('#controllers/store_controller')
const LoginController = () => import('#controllers/admin/login_controller')
const OrdersController = () => import('#controllers/admin/orders_controller')
const UsersController = () => import('#controllers/admin/users_controller')
const RolesController = () => import('#controllers/admin/roles_controller')
const AdminController = () => import('#controllers/admin/admin_controller')
const RegisterController = () => import('#controllers/register_controller')
const SellersController = () => import('#controllers/admin/sellers_controller')
const CustomersController = () => import('#controllers/admin/customers_controller')
const SellerCategoriesController = () => import('#controllers/seller/categories_controller')
const SellerProductsController = () => import('#controllers/seller/products_controller')
const SellerBrandsController = () => import('#controllers/seller/brands_controller')
const CustomerController = () => import('#controllers/customer_controller')
const DashboardController = () => import('#controllers/dashboard_controller')
const AdminCategoriesController = () => import('#controllers/admin/categories_controller')
const AdminBrandsController = () => import('#controllers/admin/brands_controller')
const ProductValidationController = () => import('#controllers/admin/product_validation_controller')
const PermissionsController = () => import('#controllers/admin/permissions_controller')
const CheckDbStatusesController = () => import('#controllers/check_db_statuses_controller')

router.get('/health', async ({ response }) => {
  try {
    return response.ok({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      memory: process.memoryUsage(),
    })
  } catch (error) {
    return response.serviceUnavailable({
      status: 'unhealthy',
      error: error.message,
    })
  }
})
router.get('/', [StoreController, 'index']).as('index')
router.get('/catalogue', [StoreController, 'catalogue'])
router.get('/catalogue/product/:slug', [StoreController, 'view'])

router.get('/auth/login', [LoginController, 'render'])
router.post('/auth/login', [LoginController, 'execute'])
router.get('/auth/register', [RegisterController, 'render'])
router.post('/auth/register', [RegisterController, 'execute'])
// Logout pour NestJS - Supprime le cookie JWT
router.post('/auth/logout', async ({ response, logger }) => {
  logger.info('Tentative de logout')
  
  try {
    // Supprimer le cookie d'authentification
    response.clearCookie('access_token')
    logger.info('Utilisateur déconnecté avec succès')
  } catch (error) {
    logger.error('Erreur lors du logout: %s', error.message)
  }
  
  // Redirection avec code 303 pour Inertia
  return response.redirect(303, '/')
})

// Routes client (protégées)
router
  .group(() => {
    router.get('/orders', [CustomerController, 'renderOrders']).as('customer.orders')
    router.get('/comments', [CustomerController, 'renderComments']).as('customer.comments')
  })
  .use(middleware.auth())

router
  .group(() => {
    router.get('/', [DashboardController, 'index']).as('index')
    router.get('products', [AdminController, 'products']).as('products')
    router.get('orders', [OrdersController, 'index']).as('orders')

    // Route de test pour diagnostiquer (sans middleware)
    router.post('test-sellers', [SellersController, 'store']).as('test.sellers.store')

// Gestion des vendeurs
    router
      .group(() => {
        router.get('/', [SellersController, 'index']).as('index')
        router.get('create', [SellersController, 'create']).as('create')
        router.post('/', [SellersController, 'store']).as('store')
        router.put('edit', [SellersController, 'edit']).as('edit')
        router.put('toggle-validation/:id', [SellersController, 'toggleValidation']).as('toggle')
        router.delete('delete/:id', [SellersController, 'delete']).as('delete')
      })
      .prefix('sellers')
      .as('sellers')

    // Route de test pour diagnostiquer
    router.post('test-sellers', [SellersController, 'store']).as('test.sellers.store')

    // Gestion des clients
    router
      .group(() => {
        router.get('/', [CustomersController, 'index']).as('index')
        router.post('create', [CustomersController, 'create']).as('create')
        router.put('edit', [CustomersController, 'edit']).as('edit')
        router.delete('delete/:id', [CustomersController, 'delete']).as('delete')
      })
      .prefix('customers')
      .as('customers')

    // Gestion des catégories
    router
      .group(() => {
        router.get('/', [AdminCategoriesController, 'index']).as('index')
        router.post('create', [AdminCategoriesController, 'create']).as('create')
        router.post('edit/:id', [AdminCategoriesController, 'edit']).as('edit')
        router.delete('delete/:id', [AdminCategoriesController, 'delete']).as('delete')
      })
      .prefix('categories')
      .as('categories')

    // Gestion des marques
    router
      .group(() => {
        router.get('/', [AdminBrandsController, 'index']).as('index')
        router.post('create', [AdminBrandsController, 'store']).as('create')
        router.post('edit/:id', [AdminBrandsController, 'update']).as('edit')
        router.delete('delete/:id', [AdminBrandsController, 'destroy']).as('delete')
      })
      .prefix('brands')
      .as('brands')

    router
      .group(() => {
        router.get('/', [CommentController, 'index']).as('index')
        router.put('/toggle-status', [CommentController, 'toggleCommentStatus']).as('toggle')
        router.put('/update', [CommentController, 'updateComment']).as('update')
        router.delete('/delete/:id', [CommentController, 'deleteComment']).as('delete')
      })
      .prefix('comments')
      .as('comments')

    // Promotions
    router
      .group(() => {
        router.get('/', [PromotionController, 'index']).as('index')
        router.post('create', [PromotionController, 'create']).as('create')
        router.put('edit', [PromotionController, 'edit']).as('edit')
        router.delete('delete/:id', [PromotionController, 'delete']).as('delete')
      })
      .prefix('promotions')
      .as('promotions')

    // Pour la gestion des produits
    router
      .group(() => {
        router.post('cancel', [OrdersController, 'cancel']).as('cancel')
        router.post('delete', [OrdersController, 'delete']).as('delete')
        router.post('delivered', [OrdersController, 'delivered']).as('delivered')
      })
      .prefix('order')
      .as('order')

    router
      .group(() => {
        router.post('create', [AdminController, 'create']).as('create')
        router.put('edit', [AdminController, 'edit']).as('edit')
        router.delete('delete/:id', [AdminController, 'delete']).as('delete')
      })
      .prefix('product')
      .as('product')

    // Validation des produits
    router
      .group(() => {
        router.get('/', [ProductValidationController, 'index']).as('index')
        router.get('all', [ProductValidationController, 'all']).as('all')
        router.post('approve', [ProductValidationController, 'approve']).as('approve')
        router.post('reject', [ProductValidationController, 'reject']).as('reject')
      })
      .prefix('validation')
      .as('validation')
    router.resource('users', UsersController).as('users')
    router.resource('roles', RolesController).as('roles')

    // Gestion des permissions
    router.get('permissions', [PermissionsController, 'index']).as('permissions.index')
    router.get('permissions/role/:id', [PermissionsController, 'getRolePermissions']).as('permissions.role')
    router.post('permissions/sync', [PermissionsController, 'sync']).as('permissions.sync')

  })
  .prefix('dashboard')
  .use(middleware.auth())
  .use(middleware.admin())
  .as('admin_dashboard')

// Routes vendeurs
router
  .group(() => {
    router.get('/', [SellerProductsController, 'dashboard']).as('index')
    router.get('products', [SellerProductsController, 'index']).as('products')
    router.get('comments', [SellerProductsController, 'comments']).as('comments')
    router.get('orders', [SellerProductsController, 'orders']).as('orders')
    router.post('comments/reply', [SellerProductsController, 'replyComment']).as('comments.reply')
    router.put('comments/toggle', [SellerProductsController, 'toggleCommentStatus']).as('comments.toggle')

    // Gestion des commandes par le vendeur
    router
      .group(() => {
        router.post('cancel', [SellerProductsController, 'cancelOrder']).as('order.cancel')
        router.post('delivered', [SellerProductsController, 'deliveredOrder']).as('order.delivered')
      })
      .prefix('order')
      .as('order')

    // Gestion des catégories
    router
      .group(() => {
        router.get('/', [SellerCategoriesController, 'index']).as('index')
        router.post('create', [SellerCategoriesController, 'create']).as('create')
        router.put('edit', [SellerCategoriesController, 'edit']).as('edit')
        router.delete('delete/:id', [SellerCategoriesController, 'delete']).as('delete')
      })
      .prefix('categories')
      .as('categories')

    // Gestion des marques
    router
      .group(() => {
        router.get('/', [SellerBrandsController, 'index']).as('index')
        router.post('create', [SellerBrandsController, 'create']).as('create')
        router.put('edit', [SellerBrandsController, 'edit']).as('edit')
        router.delete('delete/:id', [SellerBrandsController, 'delete']).as('delete')
      })
      .prefix('brands')
      .as('brands')

    // Gestion des produits
    router
      .group(() => {
        router.post('create', [SellerProductsController, 'create']).as('create')
        router.put('edit', [SellerProductsController, 'edit']).as('edit')
        router.delete('delete/:id', [SellerProductsController, 'delete']).as('delete')
      })
      .prefix('product')
      .as('product')
  })
  .prefix('seller')
  .use(middleware.auth())
  .use(middleware.seller())
  .as('seller')

// Routes API Auth (mobile)
router
  .group(() => {
    router.post('login', async ({ request, response, auth }) => {
      const { email, password } = request.only(['email', 'password'])
      try {
        const { default: User } = await import('#models/user')
        const user = await User.verifyCredentials(email, password)
        await auth.use('web').login(user)
        return response.ok({
          user: { id: user.id, fullName: user.fullName, email: user.email, role: user.role },
        })
      } catch {
        return response.unauthorized({ message: 'Identifiants invalides' })
      }
    })
    router.post('register', async ({ request, response, auth }) => {
      const { fullName, email, password } = request.only(['fullName', 'email', 'password'])
      try {
        const { default: User } = await import('#models/user')
        const { UserStatus } = await import('#dto/user_types')
        const user = await User.create({ fullName, email, password, role: UserStatus.CUSTOMER })
        await auth.use('web').login(user)
        return response.created({
          user: { id: user.id, fullName: user.fullName, email: user.email, role: user.role },
        })
      } catch {
        return response.badRequest({ message: 'Email déjà utilisé ou données invalides' })
      }
    })
    router
      .get('me', async ({ auth, response }) => {
        const user = auth.user!
        return response.ok({
          user: { id: user.id, fullName: user.fullName, email: user.email, role: user.role },
        })
      })
      .use(middleware.auth())
    router.post('logout', async ({ auth, response }) => {
      await auth.use('web').logout()
      return response.ok({ message: 'Déconnecté' })
    }).use(middleware.auth())
  })
  .prefix('api/v1/auth')

router
  .group(() => {
    router.get('products', [ApiController, 'getProducts'])
    router.get('products-web', [ApiController, 'getProductsWeb'])
    router.post('order', [ApiController, 'postOrder']).use(middleware.auth())
    router.get('product/:id', [ApiController, 'getOneProduct'])
    router.get('categories', [ApiController, 'getCategories'])
    router.get('promotions', [ApiController, 'getPromotedProducts'])
    router.get('banners', [ApiController, 'getBanners'])
    router.get('brands', [ApiController, 'getBrands'])
    router.get('brand/spec', [ApiController, 'getBrandsByCategory'])
    router.get('brands/partners', [ApiController, 'getPartnersBrands'])

    router.post('comment', [ApiController, 'postComment']).use(middleware.auth())
    router.get('comments', [ApiController, 'getCommentsByProduct'])

    // Commandes client (authentifié)
    router
      .get('my-orders', async ({ auth, response }) => {
        const { default: Order } = await import('#models/order')
        const user = auth.user!
        const orders = await Order.query()
          .where('userId', user.id)
          .preload('product', (q) => q.preload('medias'))
          .orderBy('createdAt', 'desc')
        return response.ok(orders)
      })
      .use(middleware.auth())

    // Chatbot
    router
      .group(() => {
        router
          .post('description', [ChatbotsController, 'description'])
          .as('description')
          .use(middleware.auth())
        router
          .post('features', [ChatbotsController, 'features'])
          .as('features')
          .use(middleware.auth())
        router.post('chat', [ChatbotsController, 'chat']).as('chat')
        router.post('feedback', [ChatbotsController, 'feedback']).as('feedback')
      })
      .prefix('generate')
      .as('generate')
  })
  .prefix('api/v1')

router.get('/privacy', ({ inertia }) => {
  return inertia.render('privacy')
})

router.get('/*', ({ inertia }) => {
  return inertia.render('errors/not_found')
})

// Routes de test
router.get('/test/validation', async ({ response }) => {
  const Product = (await import('#models/product')).default
  const { ValidationStatus } = await import('#dto/products_interface')
  const { ProductState } = await import('#dto/products_interface')
  
  try {
    const testProduct = await Product.create({
      name: 'Produit Test Validation',
      description: 'Description du produit test',
      price: 1000,
      categoryId: 1,
      brandId: 1,
      state: ProductState.NEW,
      warranty: '1 mois',
      features: [],
      sellerId: 1,
      slug: 'produit-test-validation',
      discount: 0,
      validationStatus: ValidationStatus.PENDING,
    })

    return response.json({
      message: 'Produit test créé',
      product: {
        id: testProduct.id,
        name: testProduct.name,
        validationStatus: testProduct.validationStatus,
      }
    })
  } catch (error) {
    return response.json({
      error: 'Erreur lors de la création: ' + error.message
    })
  }
})

router.get('/test/status', async ({ response }) => {
  const Product = (await import('#models/product')).default
  
  try {
    const products = await Product.query().select('id', 'name', 'validationStatus').limit(5)
    
    return response.json({
      products: products.map(p => ({
        id: p.id,
        name: p.name,
        validationStatus: p.validationStatus,
      }))
    })
  } catch (error) {
    return response.json({
      error: 'Erreur: ' + error.message
    })
  }
})

router.get('/test/db-status', [CheckDbStatusesController, 'index'])
router.get('/debug/users', async ({ response }) => {
  const { default: DebugUsersController } = await import('#controllers/debug_users_controller')
  return new DebugUsersController().index({ response } as any)
})
