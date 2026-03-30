import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient({
  log: ['error', 'warn'],
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
});

async function main() {
  console.log('🌱 Seeding database...');

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. Roles
  // ─────────────────────────────────────────────────────────────────────────────
  console.log('  → Roles...');
  const rolesData = [
    { name: 'Super Administrateur', slug: 'superadmin' },
    { name: 'Administrateur', slug: 'admin' },
    { name: 'Vendeur', slug: 'seller' },
    { name: 'Client', slug: 'customer' },
  ];
  for (const role of rolesData) {
    await prisma.role.upsert({
      where: { slug: role.slug },
      update: { name: role.name },
      create: role,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. Permissions
  // ─────────────────────────────────────────────────────────────────────────────
  console.log('  → Permissions...');
  const permissions = [
    // Utilisateurs
    { group: 'Utilisateurs', name: 'Voir les utilisateurs', slug: 'view_users' },
    { group: 'Utilisateurs', name: 'Créer des utilisateurs', slug: 'create_users' },
    { group: 'Utilisateurs', name: 'Modifier des utilisateurs', slug: 'edit_users' },
    { group: 'Utilisateurs', name: 'Supprimer des utilisateurs', slug: 'delete_users' },
    { group: 'Utilisateurs', name: 'Gérer les statuts utilisateurs', slug: 'status_users' },
    // Configuration
    { group: 'Configuration', name: 'Voir les rôles', slug: 'view_roles' },
    { group: 'Configuration', name: 'Gérer les rôles', slug: 'manage_roles' },
    { group: 'Configuration', name: 'Assigner des permissions', slug: 'assign_permissions' },
    // Catalogue
    { group: 'Catalogue', name: 'Voir les catégories', slug: 'view_categories' },
    { group: 'Catalogue', name: 'Gérer les catégories', slug: 'manage_categories' },
    // Produits
    { group: 'Produits', name: 'Voir tous les produits', slug: 'view_all_products' },
    { group: 'Produits', name: 'Gérer tous les produits', slug: 'manage_all_products' },
    { group: 'Produits', name: 'Valider les produits', slug: 'validate_products' },
    { group: 'Produits', name: 'Gérer ses propres produits', slug: 'manage_own_products' },
    // Vendeurs
    { group: 'Vendeurs', name: 'Voir les vendeurs', slug: 'view_sellers' },
    { group: 'Vendeurs', name: 'Gérer les vendeurs', slug: 'manage_sellers' },
    { group: 'Vendeurs', name: 'Valider les vendeurs', slug: 'validate_sellers' },
    // Clients
    { group: 'Clients', name: 'Voir les clients', slug: 'view_customers' },
    { group: 'Clients', name: 'Gérer les clients', slug: 'manage_customers' },
    // Commandes
    { group: 'Commandes', name: 'Voir toutes les commandes', slug: 'view_all_orders' },
    { group: 'Commandes', name: 'Gérer toutes les commandes', slug: 'manage_all_orders' },
    { group: 'Commandes', name: 'Gérer ses propres commandes', slug: 'manage_own_orders' },
    // Commentaires
    { group: 'Commentaires', name: 'Voir les commentaires', slug: 'view_comments' },
    { group: 'Commentaires', name: 'Gérer les commentaires', slug: 'manage_comments' },
    { group: 'Commentaires', name: 'Approuver les commentaires', slug: 'approve_comments' },
    { group: 'Commentaires', name: 'Supprimer les commentaires', slug: 'delete_comments' },
    // Promotions
    { group: 'Promotions', name: 'Voir les promotions', slug: 'view_promotions' },
    { group: 'Promotions', name: 'Gérer les promotions', slug: 'manage_promotions' },
    { group: 'Promotions', name: 'Créer des promotions', slug: 'create_promotions' },
    { group: 'Promotions', name: 'Modifier des promotions', slug: 'edit_promotions' },
    { group: 'Promotions', name: 'Supprimer des promotions', slug: 'delete_promotions' },
    // Marques
    { group: 'Marques', name: 'Voir les marques', slug: 'view_brands' },
    { group: 'Marques', name: 'Gérer les marques', slug: 'manage_brands' },
    { group: 'Marques', name: 'Créer des marques', slug: 'create_brands' },
    { group: 'Marques', name: 'Modifier des marques', slug: 'edit_brands' },
    { group: 'Marques', name: 'Supprimer des marques', slug: 'delete_brands' },
    // Bannières
    { group: 'Bannières', name: 'Voir les bannières', slug: 'view_banners' },
    { group: 'Bannières', name: 'Gérer les bannières', slug: 'manage_banners' },
    { group: 'Bannières', name: 'Créer des bannières', slug: 'create_banners' },
    { group: 'Bannières', name: 'Modifier des bannières', slug: 'edit_banners' },
    { group: 'Bannières', name: 'Supprimer les bannières', slug: 'delete_banners' },
  ];
  for (const perm of permissions) {
    await prisma.permission.upsert({
      where: { slug: perm.slug },
      update: { name: perm.name, group: perm.group },
      create: perm,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. Superadmin user
  // ─────────────────────────────────────────────────────────────────────────────
  console.log('  → Superadmin user...');
  const hashedPassword = await bcrypt.hash('superpassword123', 10);
  const superadmin = await prisma.user.upsert({
    where: { email: 'superadmin@ab-auto.com' },
    update: {},
    create: {
      fullName: 'Super Administrateur',
      email: 'superadmin@ab-auto.com',
      password: hashedPassword,
      phone: '691112233',
      role: 'superadmin',
      isValidated: true,
    },
  });

  const superadminRole = await prisma.role.findUnique({ where: { slug: 'superadmin' } });
  if (superadminRole) {
    await prisma.user.update({
      where: { id: superadmin.id },
      data: { roles: { connect: { id: superadminRole.id } } },
    });

    // Assigner toutes les permissions au superadmin
    const allPermissions = await prisma.permission.findMany();
    await prisma.role.update({
      where: { id: superadminRole.id },
      data: {
        permissions: {
          connect: allPermissions.map(p => ({ id: p.id }))
        }
      }
    });
    console.log(`  → Assigned ${allPermissions.length} permissions to superadmin role`);
  }

  const adminRole = await prisma.role.findUnique({ where: { slug: 'admin' } });
  if (adminRole) {
    const allPermissions = await prisma.permission.findMany();
    await prisma.role.update({
      where: { id: adminRole.id },
      data: {
        permissions: {
          set: allPermissions.map((p) => ({ id: p.id })),
        },
      },
    });
    console.log(`  → Assigned ${allPermissions.length} permissions to admin role`);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. Categories
  // ─────────────────────────────────────────────────────────────────────────────
  console.log('  → Categories...');
  const base = 'https://auto-cdn.uvatis.com/cat/';
  const categoriesData = [
    { name: 'Pièces auto', url: `${base}auto.jpg` },
    { name: 'Pièces électriques', url: `${base}piece_electrique.jpg` },
    { name: 'Accessoires auto', url: `${base}accessoires.png` },
    { name: 'Appareils de diagnostic automobile', url: `${base}appareill_de_diagnostique.jpg` },
    { name: 'Automobile', url: `${base}auto.png` },
    { name: 'Outillage', url: `${base}outillage_.png` },
    { name: 'Groupe électrogène', url: `${base}groupe.png` },
    { name: 'Vêtements', url: `${base}vetement.png` },
    { name: 'Transitaire', url: `${base}transitaire.jpeg` },
    { name: 'Casque moto', url: `${base}casque_de_moto.jpg` },
    { name: 'Formation auto', url: `${base}formation_auto.jpg` },
  ];
  const createdCategories: Record<string, number> = {};
  for (const cat of categoriesData) {
    const existing = await prisma.category.findFirst({ where: { name: cat.name } });
    if (!existing) {
      const created = await prisma.category.create({ data: cat });
      createdCategories[cat.name] = created.id;
    } else {
      createdCategories[cat.name] = existing.id;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. Brands (attached to "Pièces auto" category as default)
  // ─────────────────────────────────────────────────────────────────────────────
  console.log('  → Brands...');
  const urlBase = 'https://auto-cdn.uvatis.com/brands/';
  const catUrlBase = 'https://auto-cdn.uvatis.com/cat/';
  const defaultCatId = createdCategories['Pièces auto'];

  const brandsData = [
    { name: 'Tout', url: `${urlBase}tous-logo.png` },
    { name: 'Audi', url: `${urlBase}audi.png` },
    { name: 'BMW', url: `${urlBase}bmw.png` },
    { name: 'Chevrolet', url: `${urlBase}chevrolet.png` },
    { name: 'Dodge', url: `${urlBase}dodge.png` },
    { name: 'Ferrari', url: `${urlBase}ferrari.png` },
    { name: 'Ford', url: `${urlBase}ford.png` },
    { name: 'Honda', url: `${urlBase}honda.png` },
    { name: 'Hyundai', url: `${urlBase}hyundai.png` },
    { name: 'Jaguar', url: `${urlBase}jaguar.png` },
    { name: 'Jeep', url: `${urlBase}jeep.png` },
    { name: 'Kia', url: `${urlBase}kia.png` },
    { name: 'Lexus', url: `${urlBase}lexus.png` },
    { name: 'Mazda', url: `${urlBase}mazda.png` },
    { name: 'Mercedes', url: `${urlBase}mercedes.png` },
    { name: 'Nissan', url: `${urlBase}nissan.png` },
    { name: 'Peugeot', url: `${urlBase}peugeot.png` },
    { name: 'Porsche', url: `${urlBase}porsche.png` },
    { name: 'Subaru', url: `${urlBase}subaru.png` },
    { name: 'Tesla', url: `${urlBase}tesla.png` },
    { name: 'Toyota', url: `${urlBase}toyota.png` },
    { name: 'Outillage', url: `${urlBase}outillage.png` },
    { name: 'BYD', url: `${urlBase}byd.png` },
    { name: 'Changan', url: `${urlBase}changan.png` },
    { name: 'Chery', url: `${urlBase}chery.png` },
    { name: 'Geely', url: `${urlBase}geely.png` },
    { name: 'GMC', url: `${urlBase}gmc.png` },
    { name: 'Haval', url: `${urlBase}haval.png` },
    { name: 'Itaoua', url: `${urlBase}itaoua.png` },
    { name: 'Jac-motors', url: `${urlBase}jac-motors.png` },
    { name: 'Jetour', url: `${urlBase}jetour.png` },
    { name: 'JMC', url: `${urlBase}jmc.png` },
    { name: 'Mitsubishi', url: `${urlBase}mitsubishi.png` },
    { name: 'Scion', url: `${urlBase}scion.png` },
    { name: 'Casque moto', url: `${catUrlBase}casque_de_moto.jpg`, catName: 'Casque moto' },
    { name: 'Formation auto', url: `${catUrlBase}formation_auto.jpg`, catName: 'Formation auto' },
    { name: 'Transitaire', url: `${catUrlBase}transitaire.jpeg`, catName: 'Transitaire' },
    { name: 'Groupe électrogène', url: `${catUrlBase}groupe.png`, catName: 'Groupe électrogène' },
  ];

  for (const brand of brandsData) {
    const catId = brand.catName ? (createdCategories[brand.catName] ?? defaultCatId) : defaultCatId;
    const existing = await prisma.brand.findFirst({ where: { name: brand.name } });
    if (!existing) {
      await prisma.brand.create({
        data: { name: brand.name, url: brand.url, categoryId: catId },
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 6. Banners
  // ─────────────────────────────────────────────────────────────────────────────
  console.log('  → Banners...');
  const bannerBase = 'https://auto-cdn.uvatis.com/banners/';
  const bannersData = [
    { title: 'Promotion sur les pneus', description: "Jusqu'à -30% sur une sélection de pneus Michelin et Continental", link: 'Découvrir', image: `${bannerBase}banner_ab_auto_1.png` },
    { title: 'Nouveaux produits Bosch', description: 'Découvrez notre nouvelle gamme de batteries et alternateurs', link: 'Voir les produits', image: `${bannerBase}banner_ab_auto_2.png` },
    { title: "Préparez votre voiture pour l'hiver", description: "Tout l'équipement nécessaire pour affronter la saison froide", link: 'Se préparer', image: `${bannerBase}banner_ab_auto_3.png` },
    { title: "Préparez votre voiture pour l'hiver", description: "Tout l'équipement nécessaire pour affronter la saison froide", link: 'Se préparer', image: `${bannerBase}banner_ab_auto_4.png` },
    { title: "Préparez votre voiture pour l'hiver", description: "Tout l'équipement nécessaire pour affronter la saison froide", link: 'Se préparer', image: `${bannerBase}banner_ab_auto_5.png` },
  ];
  const bannerCount = await prisma.banner.count();
  if (bannerCount === 0) {
    await prisma.banner.createMany({ data: bannersData });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 7. Partners
  // ─────────────────────────────────────────────────────────────────────────────
  console.log('  → Partners...');
  const partnersData = [
    { image: `${urlBase}itaoua.png`, label: 'ITAOUA' },
    { image: `${urlBase}jetour.png`, label: 'Jetour' },
    { image: `${urlBase}changan.png`, label: 'Changan' },
    { image: `${urlBase}geely.png`, label: 'Geely' },
    { image: `${urlBase}cfao.png`, label: 'CFAO' },
  ];
  const partnerCount = await prisma.partner.count();
  if (partnerCount === 0) {
    await prisma.partner.createMany({ data: partnersData });
  }

  console.log('✅ Seeding complete!');
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    console.error('\n💡 Make sure DATABASE_URL is set correctly in your .env file');
    console.error('   Check if MySQL server is running and accessible\n');
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
