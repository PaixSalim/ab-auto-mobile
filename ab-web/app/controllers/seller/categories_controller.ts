import type { HttpContext } from '@adonisjs/core/http'
import Category from '#models/category'
import vine from '@vinejs/vine'
import { cuid } from '@adonisjs/core/helpers'
import drive from '@adonisjs/drive/services/main'
import env from '#start/env'
import { generateSlug } from '#utils/slug_utils'

export default class SellerCategoriesController {
  /**
   * Liste des catégories et sous-catégories
   */
  async index({ inertia }: HttpContext) {
    const categories = await Category.query()
      .whereNull('parent_id')
      .preload('subCategories')
      .orderBy('name', 'asc')

    // Formatter les URLs pour les images locales
    const formattedCategories = categories.map(category => ({
      ...category.toJSON(),
      url: this.formatImageUrl(category.url),
      subCategories: category.subCategories.map(sub => ({
        ...sub.toJSON(),
        url: this.formatImageUrl(sub.url)
      }))
    }))

    return inertia.render('seller/categories/index', { categories: formattedCategories })
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
   * Créer une catégorie ou sous-catégorie
   */
  async create({ request, response, session }: HttpContext) {
    const schema = vine.compile(
      vine.object({
        name: vine.string().trim().minLength(2),
        url: vine.string().trim().optional(),
        parentId: vine.number().optional(),
      })
    )

    try {
      const data = await request.validateUsing(schema)
      const file = request.file('image')

      let imageUrl = '/uploads/categories/default-category.jpg'

      // Traiter l'upload d'image si fourni
      if (file && file.tmpPath) {
        const fileName: string = `categories/${generateSlug(data.name)}-${cuid()}.${file.extname}`
        
        try {
          const disk = env.get('NODE_ENV') === 'production' ? 'r2' : 'local'
          await file.moveToDisk(fileName, disk)
          let uploadedUrl = await drive.use(disk).getUrl(fileName)
          
          if (disk === 'local' && !uploadedUrl.startsWith('/')) {
            uploadedUrl = '/uploads/' + uploadedUrl
          }
          
          imageUrl = uploadedUrl
        } catch (error) {
          console.error('Erreur lors de l\'upload de l\'image de catégorie:', error)
        }
      } else if (data.url) {
        // Utiliser l'URL fournie si pas d'image uploadée
        imageUrl = this.formatImageUrl(data.url)
      }

      await Category.create({
        name: data.name,
        url: imageUrl,
        parentId: data.parentId || null,
      })

      session.flash('notification', {
        type: 'success',
        message: 'Catégorie créée avec succès'
      })

      return response.redirect().back()
    } catch (error) {
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
  async edit({ request, response, session }: HttpContext) {
    const schema = vine.compile(
      vine.object({
        id: vine.number(),
        name: vine.string().trim().minLength(2),
        url: vine.string().trim().optional(),
        parentId: vine.number().optional(),
      })
    )

    try {
      const data = await request.validateUsing(schema)
      const category = await Category.findOrFail(data.id)
      const file = request.file('image')

      let imageUrl = category.url

      // Traiter l'upload d'image si fourni
      if (file && file.tmpPath) {
        const fileName: string = `categories/${generateSlug(data.name)}-${cuid()}.${file.extname}`
        
        try {
          const disk = env.get('NODE_ENV') === 'production' ? 'r2' : 'local'
          await file.moveToDisk(fileName, disk)
          let uploadedUrl = await drive.use(disk).getUrl(fileName)
          
          if (disk === 'local' && !uploadedUrl.startsWith('/')) {
            uploadedUrl = '/uploads/' + uploadedUrl
          }
          
          imageUrl = uploadedUrl
        } catch (error) {
          console.error('Erreur lors de l\'upload de l\'image de catégorie:', error)
        }
      } else if (data.url && data.url !== category.url) {
        // Utiliser la nouvelle URL si fournie et différente
        imageUrl = this.formatImageUrl(data.url)
      }

      category.name = data.name
      category.url = imageUrl
      category.parentId = data.parentId || null

      await category.save()

      session.flash('notification', {
        type: 'success',
        message: 'Catégorie modifiée avec succès'
      })

      return response.redirect().back()
    } catch (error) {
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
  async delete({ params, response, session }: HttpContext) {
    try {
      const category = await Category.findOrFail(params.id)
      await category.delete()

      session.flash('notification', {
        type: 'success',
        message: 'Catégorie supprimée avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la suppression de la catégorie'
      })
      return response.redirect().back()
    }
  }
}
