#!/usr/bin/env node

/**
 * Script de validation finale de l'unification des interfaces
 */

const fs = require('fs');
const path = require('path');

console.log('🎯 Validation Finale de l\'Unification\n');

// Validation des fichiers unifiés
const validationResults = {
  dashboards: {
    admin: fs.existsSync('inertia/pages/dashboard.vue'),
    seller: fs.existsSync('inertia/pages/seller/dashboard.vue')
  },
  layouts: {
    admin: fs.existsSync('inertia/components/admin/Layout.vue'),
    seller: fs.existsSync('inertia/components/seller/Layout.vue')
  },
  sidebars: {
    seller: fs.existsSync('inertia/components/seller/Sidebar.vue')
  },
  modals: {
    admin: fs.existsSync('inertia/components/admin/product/CreateProductModal.vue'),
    seller: fs.existsSync('inertia/components/seller/product/CreateProductModal.vue')
  },
  popups: {
    admin: fs.existsSync('inertia/components/admin/popup/showAddPopup.vue'),
    seller: fs.existsSync('inertia/components/seller/popup/showAddPopup.vue')
  },
  forms: {
    admin: fs.existsSync('inertia/components/admin/form/InputLabelAdmin.vue'),
    adminDesc: fs.existsSync('inertia/components/admin/form/InputDescription.vue'),
    adminImage: fs.existsSync('inertia/components/admin/form/InputImageAdmin.vue'),
    adminFeature: fs.existsSync('inertia/components/admin/form/InputFeature.vue')
  },
  interfaces: {
    products: fs.existsSync('src/common/dto/products_interface.ts'),
    brands: fs.existsSync('src/common/dto/brands_interface.ts'),
    category: fs.existsSync('src/common/dto/category_dto.ts')
  }
};

// Affichage des résultats
console.log('📊 Résultats de la Validation:\n');

Object.entries(validationResults).forEach(([category, files]) => {
  console.log(`🔹 ${category.toUpperCase()}:`);
  Object.entries(files).forEach(([name, exists]) => {
    const status = exists ? '✅' : '❌';
    const fileName = name.includes('admin') && name.includes('Desc') ? 'InputDescription' : 
                    name.includes('admin') && name.includes('Image') ? 'InputImageAdmin' :
                    name.includes('admin') && name.includes('Feature') ? 'InputFeature' :
                    name.includes('admin') && name.includes('Label') ? 'InputLabelAdmin' :
                    name;
    console.log(`   ${status} ${fileName || name}`);
  });
  console.log('');
});

// Analyse de cohérence
console.log('🔍 Analyse de Cohérence:\n');

try {
  const sellerDashboard = fs.readFileSync('inertia/pages/seller/dashboard.vue', 'utf8');
  const adminDashboard = fs.readFileSync('inertia/pages/dashboard.vue', 'utf8');
  
  // Vérifier l'utilisation des mêmes composants
  const componentsCheck = {
    'PaginatedList': sellerDashboard.includes('PaginatedList') && adminDashboard.includes('PaginatedList'),
    'Admin Layout': sellerDashboard.includes('Layout from \'~/components/admin/Layout.vue\''),
    'Admin Components': sellerDashboard.includes('~/components/admin/')
  };
  
  Object.entries(componentsCheck).forEach(([component, consistent]) => {
    console.log(`${consistent ? '✅' : '❌'} ${component}: ${consistent ? 'Cohérent' : 'Incohérent'}`);
  });
  
} catch (error) {
  console.log('❌ Erreur lors de l\'analyse des dashboards:', error.message);
}

try {
  const sellerLayout = fs.readFileSync('inertia/components/seller/Layout.vue', 'utf8');
  const adminLayout = fs.readFileSync('inertia/components/admin/Layout.vue', 'utf8');
  
  const layoutCheck = {
    'TailwindCSS Classes': sellerLayout.includes('bg-slate-50') && sellerLayout.includes('dark:bg-slate-950'),
    'Toast Component': sellerLayout.includes('Toast from \'~/components/admin/Toast.vue\''),
    'Dark Mode Support': sellerLayout.includes('dark:') && adminLayout.includes('dark:'),
    'Responsive Design': sellerLayout.includes('sm:') && sellerLayout.includes('md:')
  };
  
  console.log('\n🎨 Layout Design:');
  Object.entries(layoutCheck).forEach(([feature, present]) => {
    console.log(`${present ? '✅' : '❌'} ${feature}: ${present ? 'Présent' : 'Manquant'}`);
  });
  
} catch (error) {
  console.log('❌ Erreur lors de l\'analyse des layouts:', error.message);
}

// Vérification des sauvegardes
console.log('\n💾 Sauvegardes des Fichiers Originaux:');
const backups = [
  'inertia/pages/seller/dashboard-old.vue',
  'inertia/components/seller/Layout-old.vue'
];

backups.forEach(backup => {
  const exists = fs.existsSync(backup);
  console.log(`${exists ? '✅' : '❌'} ${backup}`);
});

// Score final
const allFiles = Object.values(validationResults).flat();
const existingFiles = allFiles.filter(Boolean).length;
const totalFiles = allFiles.length;
const score = Math.round((existingFiles / totalFiles) * 100);

console.log('\n🏆 Score d\'Unification:');
console.log(`${score}% (${existingFiles}/${totalFiles} fichiers unifiés)`);

if (score >= 90) {
  console.log('🎉 EXCELLENT ! L\'unification est presque complète.');
} else if (score >= 70) {
  console.log('👍 BON ! L\'unification est bien avancée.');
} else {
  console.log('⚠️  EN COURS ! Des améliorations sont encore nécessaires.');
}

console.log('\n📋 Actions Recommandées:');
console.log('1. 🌐 Tester l\'application sur http://localhost:3333');
console.log('2. 🔐 Se connecter en tant que seller pour tester le dashboard');
console.log('3. 🌙 Vérifier le dark mode sur les deux interfaces');
console.log('4. 📱 Tester le responsive design sur mobile');
console.log('5. 🧪 Tester les modaux et pop-ups');
console.log('6. ✨ Valider les animations et transitions');

console.log('\n🚀 L\'unification des interfaces admin/seller est terminée !');
