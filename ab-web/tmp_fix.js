import * as fs from 'fs';

const filePath = 'src/app.controller.ts';
let content = fs.readFileSync(filePath, 'utf8');

// Replace this.paginate(X) with X, except for adminSellers
content = content.replace(
  /this\.paginate\((.*?)\)/g, 
  (match, variable) => {
    // Keep it for adminSellers if needed, actually let's keep it ONLY for sellers!
    return variable;
  }
);

// Specifically for adminSellers, we might need to restore it if it really needs pagination. But wait!
// What if we just do string replacement via regex, and manually fix adminSellers?
fs.writeFileSync(filePath, content);
