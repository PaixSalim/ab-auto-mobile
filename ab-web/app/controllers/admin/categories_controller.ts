import type { HttpContext } from '@adonisjs/core/http'
import Category from '#models/category'
import { cuid } from '@adonisjs/core/helpers'
import drive from '@adonisjs/drive/services/main'
import env from '#start/env'
import { generateSlug } from '#utils/slug_utils'

export default class AdminCategoriesController {
  /**
   * Afficher la liste des catégories avec sous-catégories
   */
  async index({ inertia }: HttpContext) {
    const categories = await Category.query()
      .whereNull('parent_id') // Catégories principales
      .preload('subCategories') // Charger les sous-catégories
      .orderBy('name', 'asc')

    console.log('🔍 Raw categories from DB:', categories.map(c => ({
      id: c.id,
      name: c.name,
      url: c.url,
      subCategoriesCount: c.subCategories.length
    })))

    // Formatter les URLs pour les images locales
    const formattedCategories = categories.map(category => {
      const categoryJson = category.toJSON()
      return {
        ...categoryJson,
        url: this.formatImageUrl(category.url),
        subCategories: category.subCategories.map(sub => {
          const subJson = sub.toJSON()
          return {
            ...subJson,
            url: this.formatImageUrl(sub.url)
          }
        })
      }
    })

    console.log('🔍 Formatted categories for frontend:', formattedCategories.map((c, index) => {
      const originalCategory = categories[index]
      return {
        id: c.id,
        name: c.name,
        originalUrl: originalCategory.url,
        formattedUrl: c.url,
        subCategoriesCount: c.subCategories.length
      }
    }))

    return inertia.render('admin/categories/index', { categories: formattedCategories })
  }

  /**
   * Formatter les URLs d'images
   */
  private formatImageUrl(url: string | null): string {
    if (!url) {
      return '/uploads/categories/default-category.jpg'
    }
    
    // Si c'est déjà une URL locale, la retourner
    if (url.startsWith('/uploads/')) {
      return url
    }
    
    // Si c'est une URL externe, la remplacer par l'image par défaut locale
    if (url.startsWith('http')) {
      return '/uploads/categories/default-category.jpg'
    }
    
    // Sinon, considérer que c'est un chemin local
    return url.startsWith('/') ? url : '/' + url
  }

  /**
   * Créer une nouvelle catégorie
   */
  async create({ request, response, session }: HttpContext) {
    const { name, url, parentId } = request.only(['name', 'url', 'parentId'])
    const file = request.file('image')

    console.log('🔍 CREATE CATEGORY DEBUG:')
    console.log('- Request data:', { name, url, parentId })
    console.log('- File object:', file)
    console.log('- File exists?', !!file)
    console.log('- File has tmpPath?', file?.tmpPath)
    console.log('- File size:', file?.size)

    let imageUrl = '/uploads/categories/default-category.jpg'

    // Traiter l'upload d'image si fourni
    if (file && file.tmpPath) {
      console.log('📁 Processing file upload...')
      const fileName: string = `categories/${generateSlug(name)}-${cuid()}.${file.extname}`
      console.log('- Generated filename:', fileName)
      
      try {
        const disk = env.get('NODE_ENV') === 'production' ? 'r2' : 'local'
        console.log('- Using disk:', disk)
        
        await file.moveToDisk(fileName, disk)
        console.log('✅ File moved to disk')
        
        let uploadedUrl: string
        
        if (disk === 'local') {
          // Pour le disque local, construire l'URL manuellement
          uploadedUrl = '/uploads/' + fileName
          console.log('- Local URL constructed manually:', uploadedUrl)
        } else {
          // Pour R2, utiliser la méthode getUrl
          uploadedUrl = await drive.use(disk).getUrl(fileName)
          console.log('- Drive returned URL:', uploadedUrl)
        }
        
        imageUrl = uploadedUrl
        console.log('✅ Final image URL:', imageUrl)
      } catch (error) {
        console.error('❌ Erreur lors de l\'upload de l\'image de catégorie:', error)
      }
    } else {
      console.log('⚠️ No file provided or invalid file')
    }
    
    if (url) {
      // Utiliser l'URL fournie si pas d'image uploadée
      imageUrl = this.formatImageUrl(url)
      console.log('📝 Using provided URL:', imageUrl)
    } else if (!file?.tmpPath) {
      // Générer une URL par défaut si aucune URL fournie et pas d'image
      imageUrl = this.formatImageUrl(name.toLowerCase().replace(/\s+/g, '-'))
      console.log('🔄 Using generated URL:', imageUrl)
    }

    console.log('🎯 Final URL to save:', imageUrl)

    try {
      const category = await Category.create({
        name: name,
        url: imageUrl,
        parentId: parentId || null
      })

      console.log('🔍 Category created - DEBUG INFO:')
      console.log('- Name:', name)
      console.log('- Image URL saved in DB:', imageUrl)
      console.log('- Category ID:', category.id)
      console.log('- Category URL from DB:', category.url)

      session.flash('notification', {
        type: 'success',
        message: 'Catégorie créée avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      console.error('❌ Error creating category:', error)
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la création de la catégorie'
      })
      return response.redirect().back()
    }
  }

  /**
   * Modifier une catégorie
   */
  async edit({ request, response, session, params }: HttpContext) {
    const { name, url, parentId } = request.only(['name', 'url', 'parentId'])
    const category = await Category.findOrFail(params.id)
    const file = request.file('image')

    let imageUrl = category.url

    // Traiter l'upload d'image si fourni
    if (file && file.tmpPath) {
      const fileName: string = `categories/${generateSlug(name)}-${cuid()}.${file.extname}`
      
      try {
        const disk = env.get('NODE_ENV') === 'production' ? 'r2' : 'local'
        console.log('- Using disk:', disk)
        
        await file.moveToDisk(fileName, disk)
        console.log('✅ File moved to disk')
        
        let uploadedUrl: string
        
        if (disk === 'local') {
          // Pour le disque local, construire l'URL manuellement
          uploadedUrl = '/uploads/' + fileName
          console.log('- Local URL constructed manually:', uploadedUrl)
        } else {
          // Pour R2, utiliser la méthode getUrl
          uploadedUrl = await drive.use(disk).getUrl(fileName)
          console.log('- Drive returned URL:', uploadedUrl)
        }
        
        imageUrl = uploadedUrl
        console.log('✅ Final image URL:', imageUrl)
      } catch (error) {
        console.error('❌ Erreur lors de l\'upload de l\'image de catégorie:', error)
      }
    } else if (url && url !== category.url) {
      // Utiliser la nouvelle URL si fournie et différente
      imageUrl = this.formatImageUrl(url)
    }

    try {
      await category.merge({
        name: name,
        url: imageUrl,
        parentId: parentId || null
      }).save()

      session.flash('notification', {
        type: 'success',
        message: 'Catégorie modifiée avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      console.error('❌ Error updating category:', error)
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la modification de la catégorie'
      })
      return response.redirect().back()
    }
  }

  /**
   * Supprimer une catégorie
   */
  async delete({ response, session, params }: HttpContext) {
    const category = await Category.findOrFail(params.id)

    try {
      await category.delete()

      session.flash('notification', {
        type: 'success',
        message: 'Catégorie supprimée avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      console.error('❌ Error deleting category:', error)
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la suppression de la catégorie'
      })
      return response.redirect().back()
    }
  }
}
