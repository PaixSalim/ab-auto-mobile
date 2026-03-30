export function generateSlug(name: string): string {
  // Convertir le texte en minuscules
  let slug = name.toLowerCase()

  // Remplacer les espaces par des tirets
  slug = slug.replace(/\s+/g, '-')

  // Supprimer les caractères spéciaux et les accentuations
  slug = slug.normalize('NFD').replace(/[\u0300-\u036f]/g, '') // Normaliser et supprimer les accents
  slug = slug.replace(/[^a-z0-9\-]/g, '') // Garder uniquement les lettres, les chiffres et les tirets

  // Enlever les tirets en début et fin de chaîne
  slug = slug.replace(/^-+/, '').replace(/-+$/, '')

  // Générer un suffixe aléatoire (ex: CA25, XZ89)
  const randomSuffix = Math.random().toString(36).substring(2, 6).toUpperCase()

  return `${slug}-${randomSuffix}`
}
