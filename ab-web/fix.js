const fs = require('fs');
const file = 'src/app.controller.ts';
let code = fs.readFileSync(file, 'utf8');

// Strip all paginate except sellers
code = code.replace(/\{ products: this\.paginate\(products\)(, categories)? \}\)/g, '{ products, categories, brands })');
code = code.replace(/\{ orders: this\.paginate\(orders\) \}\)/g, '{ orders })');
code = code.replace(/\{ customers: this\.paginate\(customers\) \}\)/g, '{ customers })');
code = code.replace(/\{ brands: this\.paginate\(brands\)(.*?) \}\)/g, '{ brands$1 })');
code = code.replace(/\{ comments: this\.paginate\(comments\) \}\)/g, '{ comments })');
code = code.replace(/\{ promos: this\.paginate\(promotions\) \}\)/g, '{ promos: promotions })');
code = code.replace(/\{ promotions: this\.paginate\(promotions\) \}\)/g, '{ promos: promotions })');
code = code.replace(/\{ users: this\.paginate\(users\) \}\)/g, '{ users, roles })');
code = code.replace(/\{ roles: this\.paginate\(roles\) \}\)/g, '{ roles })');
code = code.replace(/\{ permissions: this\.paginate\(permissions\) \}\)/g, '{ permissions })');

// Fix adminProducts missing brands and categories
code = code.replace(
  /const products = await this\.prisma\.product\.findMany\(\{ include: \{ category: true, brand: true, seller: true \} \}\);/g,
  `const products = await this.prisma.product.findMany({ include: { category: true, brand: true, seller: true } });\n    const categories = await this.prisma.category.findMany();\n    const brands = await this.prisma.brand.findMany();`
);

// Fix sellerProducts missing brands
code = code.replace(
  /const products = await this\.prisma\.product\.findMany\(\{ include: \{ category: true, brand: true \} \}\);\n    const categories/g,
  `const products = await this.prisma.product.findMany({ include: { category: true, brand: true } });\n    const brands = await this.prisma.brand.findMany();\n    const categories`
);

// Fix adminUsers missing roles
code = code.replace(
  /const users = await this\.prisma\.user\.findMany\(\);/g,
  `const users = await this.prisma.user.findMany();\n    const roles = await this.prisma.role.findMany();`
);

fs.writeFileSync(file, code);
