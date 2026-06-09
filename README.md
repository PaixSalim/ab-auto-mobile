# AB Auto Mobile 🚗

Bienvenue sur le dépôt du projet mobile **AB Auto**. Cette application Flutter est conçue pour offrir une expérience premium et fluide aux utilisateurs cherchant à découvrir, parcourir et acheter des véhicules.

## 🎯 Architecture et Technologies

Ce projet suit les principes de la **Clean Architecture** et utilise **BLoC (Business Logic Component)** pour une gestion d'état robuste et prévisible.

* **Framework :** Flutter
* **State Management :** `flutter_bloc`
* **Navigation :** Gestion par `IndexedStack` (via `MainNavigation`) pour conserver l'état des onglets.
* **UI/UX :** Design moderne, aéré, "glassmorphism", ombres douces et typographie affirmée.

---

## 📱 Structure de l'application

L'application est divisée en plusieurs modules métiers (features) :
* **Auth :** Gestion de la connexion, de l'inscription et des sessions (ex: `AuthBottomSheet`).
* **Products :** Gestion du catalogue, de la recherche, et des détails des véhicules.
* **Promotions :** Affichage des offres spéciales et véhicules en promotion.
* **Banners :** Carrousel publicitaire dynamique.
* **Notifications :** Centre de notifications pour alerter l'utilisateur.

---

## 🌟 Zoom sur la Page d'Accueil (`HomePage`)

La page d'accueil (`lib/main.dart` -> `HomePage`) est le cœur de l'application. Elle a été récemment repensée pour être **très attractive, luxueuse et moderne**. 

Elle est structurée autour d'un `CustomScrollView` qui permet de faire défiler harmonieusement différents éléments variés (`Slivers`) de haut en bas :

### 1. Message d'accueil (Greeting)
Un message de bienvenue personnalisé (*"Bonjour 👋 Trouvez votre véhicule idéal aujourd'hui"*) accueille l'utilisateur. Cette section établit un ton humain et premium.

### 2. Carrousel Publicitaire (`CarouselWithIndicator`)
Un carrousel occupant 100% de la largeur de l'écran qui affiche les dernières nouveautés ou annonces majeures.

### 3. Filtres par Catégorie (`CategorySection`)
Une ligne de "chips" (bulles) défilables horizontalement permettant de filtrer rapidement les types de véhicules (SUV, Berline, etc.).

### 4. Promotions en cours (`PromotionsSection`)
Une section très élégante affichant les **4 meilleures promotions** du moment sous forme de carrousel horizontal. Un bouton "Voir plus" permet d'accéder à la page complète `AllPromotionsPage` qui contient l'intégralité des promotions avec une pagination 10 par 10.

### 5. Suggestions pour vous (`ProductGridCard`)
Une grille aérée (SliverGrid) avec des marges généreuses (16px) mettant en valeur les photos des véhicules avec leurs prix et descriptions. 
La liste est gérée par une pagination intelligente : un bouton **"Charger plus d'articles"** au design moderne (OutlinedButton avec des bords très arrondis) permet de révéler davantage de véhicules sans surcharger la mémoire.

---

## 🚀 Lancement Rapide

Pour lancer le projet en local :

1. Assurez-vous d'avoir Flutter installé (`flutter doctor`).
2. Installez les dépendances :
   ```bash
   flutter pub get
   ```
3. Lancez l'application sur un émulateur ou un appareil physique :
   ```bash
   flutter run
   ```

## 🎨 Lignes directrices de Design (Guidelines)
- **Couleurs :** Ne pas utiliser de couleurs "brutes" (comme du rouge pur). Privilégier des tons pastels, des gris clairs (`#F9FAFB`) pour le fond, et le vert WhatsApp (`#25D366`) pour les actions de contact.
- **Espacements :** Laissez l'interface respirer. Utilisez des `SizedBox` au lieu de lourds séparateurs (Dividers).
- **Textes :** Les titres doivent être marqués avec un `fontWeight` lourd (w800) et un espacement de lettres légèrement réduit (`letterSpacing: -0.5`).

---
*Maintenu par l'équipe de développement AB Auto.*
