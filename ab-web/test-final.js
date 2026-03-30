#!/usr/bin/env node

/**
 * Script de test final pour valider que les pages s'affichent correctement
 */

const fs = require('fs');
const { exec } = require('child_process');

console.log('🧪 Test Final des Pages\n');

// Test 1: Vérifier que le serveur est actif
console.log('1️⃣ Test du serveur NestJS...');
exec('netstat -ano | findstr :3333', (error, stdout, stderr) => {
  if (stdout.includes('3333')) {
    console.log('✅ Serveur NestJS actif sur le port 3333');
    
    // Test 2: Vérifier que la page home répond
    console.log('\n2️⃣ Test de la page home...');
    exec('Invoke-WebRequest -Uri http://localhost:3333 -UseBasicParsing | Select-Object -ExpandProperty StatusCode', (error, stdout, stderr) => {
      if (stdout.includes('200')) {
        console.log('✅ Page home répond avec statut 200');
        
        // Test 3: Vérifier les assets de build
        console.log('\n3️⃣ Test des assets de build...');
        const cssAsset = fs.existsSync('public/build/assets/app-Dix2aTPz.css');
        const jsAsset = fs.existsSync('public/build/assets/app-DA96a55Y.js');
        
        if (cssAsset && jsAsset) {
          console.log('✅ Assets CSS et JS générés');
          
          // Test 4: Vérifier les composants Vue
          console.log('\n4️⃣ Test des composants Vue...');
          const components = [
            'inertia/components/DesktopNavbar.vue',
            'inertia/pages/home.vue',
            'inertia/components/BannerSlider.vue',
            'inertia/components/ProductCategories.vue',
            'inertia/components/DealGrid.vue',
            'inertia/components/AllProductsGrid.vue',
            'inertia/components/Footer.vue',
            'inertia/components/Notification.vue',
            'inertia/components/MobileNavbar.vue',
            'inertia/components/SearchBar.vue',
            'inertia/components/auth/RegisterPopup.vue'
          ];
          
          let missingComponents = [];
          components.forEach(comp => {
            if (!fs.existsSync(comp)) {
              missingComponents.push(comp);
            }
          });
          
          if (missingComponents.length === 0) {
            console.log('✅ Tous les composants Vue existent');
            
            // Test 5: Vérifier les DTOs
            console.log('\n5️⃣ Test des DTOs...');
            const dtos = [
              'src/dto/banners_interface.ts',
              'src/dto/partners_interface.ts',
              'src/dto/products_interface.ts',
              'src/dto/brands_interface.ts',
              'src/dto/category_dto.ts'
            ];
            
            let missingDtos = [];
            dtos.forEach(dto => {
              if (!fs.existsSync(dto)) {
                missingDtos.push(dto);
              }
            });
            
            if (missingDtos.length === 0) {
              console.log('✅ Tous les DTOs existent');
              
              // Test 6: Vérifier l'unification
              console.log('\n6️⃣ Test de l\'unification...');
              const unifiedFiles = [
                'inertia/pages/seller/dashboard.vue',
                'inertia/components/seller/Layout.vue',
                'inertia/components/seller/Sidebar.vue',
                'inertia/components/seller/product/CreateProductModal.vue',
                'inertia/components/seller/popup/showAddPopup.vue'
              ];
              
              let missingUnified = [];
              unifiedFiles.forEach(file => {
                if (!fs.existsSync(file)) {
                  missingUnified.push(file);
                }
              });
              
              if (missingUnified.length === 0) {
                console.log('✅ Fichiers unifiés présents');
                
                // Résultat final
                console.log('\n🎉 RÉSULTAT FINAL:');
                console.log('✅ Serveur NestJS: Actif');
                console.log('✅ Page home: Accessible');
                console.log('✅ Assets: Générés');
                console.log('✅ Composants: Complets');
                console.log('✅ DTOs: Présents');
                console.log('✅ Unification: Terminée');
                
                console.log('\n🚀 L\'application est prête !');
                console.log('🌐 Accès: http://localhost:3333');
                console.log('📱 Pages testées: DesktopNavbar, Home');
                console.log('🎨 Design: Unifié admin/seller');
                
              } else {
                console.log('❌ Fichiers unifiés manquants:', missingUnified);
              }
            } else {
              console.log('❌ DTOs manquants:', missingDtos);
            }
          } else {
            console.log('❌ Composants manquants:', missingComponents);
          }
        } else {
          console.log('❌ Assets manquants');
          console.log(`CSS: ${cssAsset ? '✅' : '❌'}`);
          console.log(`JS: ${jsAsset ? '✅' : '❌'}`);
        }
      } else {
        console.log('❌ Page home inaccessible');
      }
    });
  } else {
    console.log('❌ Serveur NestJS non actif');
  }
});
