import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const permissions = [
  // Utilisateurs
  { group: 'Utilisateurs', name: 'Voir les utilisateurs', slug: 'view_users' },
  { group: 'Utilisateurs', name: 'Créer des utilisateurs', slug: 'create_users' },
  { group: 'Utilisateurs', name: 'Modifier des utilisateurs', slug: 'edit_users' },
  { group: 'Utilisateurs', name: 'Supprimer des utilisateurs', slug: 'delete_users' },
  { group: 'Utilisateurs', name: 'Gérer les statuts utilisateurs', slug: 'status_users' },

  // Rôles
  { group: 'Configuration', name: 'Voir les rôles', slug: 'view_roles' },
  { group: 'Configuration', name: 'Gérer les rôles', slug: 'manage_roles' },
  { group: 'Configuration', name: 'Assigner des permissions', slug: 'assign_permissions' },

  // Catégories
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
  { group: 'Bannières', name: 'Supprimer des bannières', slug: 'delete_banners' },
];

async function main() {
  console.log('🌱 Seeding permissions...');

  for (const permission of permissions) {
    await prisma.permission.upsert({
      where: { slug: permission.slug },
      update: permission,
      create: permission,
    });
    console.log(`  ✓ ${permission.name} (${permission.slug})`);
  }

  console.log('\n✅ Seeding completed successfully!');
  console.log('💡 Permissions disponibles sur: /dashboard/permissions');
}

main()
  .catch((e) => {
    console.error('❌ Error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
