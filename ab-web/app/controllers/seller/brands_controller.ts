import type { HttpContext } from '@adonisjs/core/http'
import Brand from '#models/brand'
import vine from '@vinejs/vine'
import { cuid } from '@adonisjs/core/helpers'
import drive from '@adonisjs/drive/services/main'
import env from '#start/env'
import { generateSlug } from '#utils/slug_utils'

export default class SellerBrandsController {
  /**
   * Liste des marques
   */
  async index({ inertia }: HttpContext) {
    const brands = await Brand.query()
      .orderBy('name', 'asc')

    // Formatter les URLs pour les images locales
    const formattedBrands = brands.map(brand => ({
      ...brand.toJSON(),
      url: this.formatImageUrl(brand.url)
    }))

    return inertia.render('seller/brands/index', { brands: formattedBrands })
  }

  /**
   * Formatter les URLs d'images
   */
  private formatImageUrl(url: string | null): string {
    if (!url) {
      return '/uploads/brands/default-brand.jpg'
    }
    
    // Si c'est déjà une URL locale, la retourner
    if (url.startsWith('/uploads/')) {
      return url
    }
    
    // Si c'est une URL externe, la remplacer par l'image par défaut locale
    if (url.startsWith('http')) {
      return '/uploads/brands/default-brand.jpg'
    }
    
    // Sinon, considérer que c'est un chemin local
    return url.startsWith('/') ? url : '/' + url
  }

  /**
   * Créer une marque
   */
  async create({ request, response, session }: HttpContext) {
    const schema = vine.compile(
      vine.object({
        name: vine.string().trim().minLength(2),
        url: vine.string().trim().optional(),
      })
    )

    try {
      const data = await request.validateUsing(schema)
      const file = request.file('image')

      let imageUrl = '/uploads/brands/default-brand.jpg'

      // Traiter l'upload d'image si fourni
      if (file && file.tmpPath) {
        const fileName: string = `brands/${generateSlug(data.name)}-${cuid()}.${file.extname}`
        
        try {
          const disk = env.get('NODE_ENV') === 'production' ? 'r2' : 'local'
          await file.moveToDisk(fileName, disk)
          let uploadedUrl = await drive.use(disk).getUrl(fileName)
          
          if (disk === 'local' && !uploadedUrl.startsWith('/')) {
            uploadedUrl = '/uploads/' + uploadedUrl
          }
          
          imageUrl = uploadedUrl
        } catch (error) {
          console.error('Erreur lors de l\'upload de l\'image de marque:', error)
        }
      } else if (data.url) {
        // Utiliser l'URL fournie si pas d'image uploadée
        imageUrl = this.formatImageUrl(data.url)
      }

      await Brand.create({
        name: data.name,
        url: imageUrl,
      })

      session.flash('notification', {
        type: 'success',
        message: 'Marque créée avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la création de la marque'
      })
      return response.redirect().back()
    }
  }

  /**
   * Modifier une marque
   */
  async edit({ request, response, session }: HttpContext) {
    const schema = vine.compile(
      vine.object({
        id: vine.number(),
        name: vine.string().trim().minLength(2),
        url: vine.string().trim().optional(),
      })
    )

    try {
      const data = await request.validateUsing(schema)
      const brand = await Brand.findOrFail(data.id)
      const file = request.file('image')

      let imageUrl = brand.url

      // Traiter l'upload d'image si fourni
      if (file && file.tmpPath) {
        const fileName: string = `brands/${generateSlug(data.name)}-${cuid()}.${file.extname}`
        
        try {
          const disk = env.get('NODE_ENV') === 'production' ? 'r2' : 'local'
          await file.moveToDisk(fileName, disk)
          let uploadedUrl = await drive.use(disk).getUrl(fileName)
          
          if (disk === 'local' && !uploadedUrl.startsWith('/')) {
            uploadedUrl = '/uploads/' + uploadedUrl
          }
          
          imageUrl = uploadedUrl
        } catch (error) {
          console.error('Erreur lors de l\'upload de l\'image de marque:', error)
        }
      } else if (data.url && data.url !== brand.url) {
        // Utiliser la nouvelle URL si fournie et différente
        imageUrl = this.formatImageUrl(data.url)
      }

      brand.name = data.name
      brand.url = imageUrl

      await brand.save()

      session.flash('notification', {
        type: 'success',
        message: 'Marque modifiée avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la modification de la marque'
      })
      return response.redirect().back()
    }
  }

  /**
   * Supprimer une marque
   */
  async delete({ params, response, session }: HttpContext) {
    try {
      const brand = await Brand.findOrFail(params.id)
      await brand.delete()

      session.flash('notification', {
        type: 'success',
        message: 'Marque supprimée avec succès'
      })

      return response.redirect().back()
    } catch (error) {
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la suppression de la marque'
      })
      return response.redirect().back()
    }
  }
}
