#!/usr/bin/env node

/**
 * Script pour mettre à jour les permissions sans tout recréer
 * Ajoute les permissions manquantes (Bannières)
 */

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log('🔄 Mise à jour des permissions...');

  const bannerPermissions = [
    { group: 'Bannières', name: 'Voir les bannières', slug: 'view_banners' },
    { group: 'Bannières', name: 'Gérer les bannières', slug: 'manage_banners' },
    { group: 'Bannières', name: 'Créer des bannières', slug: 'create_banners' },
    { group: 'Bannières', name: 'Modifier des bannières', slug: 'edit_banners' },
    { group: 'Bannières', name: 'Supprimer des bannières', slug: 'delete_banners' },
  ];

  let created = 0;
  let updated = 0;

  for (const perm of bannerPermissions) {
    const result = await prisma.permission.upsert({
      where: { slug: perm.slug },
      update: perm,
      create: perm,
    });
    
    if (result) {
      console.log(`  ✓ ${perm.name} (${perm.slug})`);
      created++;
    }
  }

  console.log(`\n✅ ${created} permissions Bannières ajoutées/mises à jour !`);
  console.log('\n💡 Les permissions sont maintenant disponibles dans: /dashboard/permissions');
}

main()
  .catch((e) => {
    console.error('❌ Erreur:', e.message);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
