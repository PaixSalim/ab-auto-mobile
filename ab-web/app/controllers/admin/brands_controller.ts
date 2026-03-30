import type { HttpContext } from '@adonisjs/core/http'
import Brand from '#models/brand'
import { cuid } from '@adonisjs/core/helpers'
import drive from '@adonisjs/drive/services/main'
import env from '#start/env'
import { generateSlug } from '#utils/slug_utils'

export default class AdminBrandsController {
  /**
   * Afficher la liste des marques
   */
  async index({ inertia }: HttpContext) {
    const brands = await Brand.query()
      .orderBy('name', 'asc')

    console.log('🔍 Raw brands from DB:', brands.map(b => ({
      id: b.id,
      name: b.name,
      url: b.url
    })))

    // Formatter les URLs pour les images locales
    const formattedBrands = brands.map(brand => {
      const brandJson = brand.toJSON()
      return {
        ...brandJson,
        url: this.formatImageUrl(brand.url)
      }
    })

    console.log('🔍 Formatted brands for frontend:', formattedBrands.map((b, index) => {
      const originalBrand = brands[index]
      return {
        id: (b as any).id,
        name: (b as any).name,
        originalUrl: originalBrand.url,
        formattedUrl: (b as any).url
      }
    }))

    return inertia.render('admin/brands/index', {
      brands: formattedBrands
    })
  }

  /**
   * Afficher le formulaire de création
   */
  async create({ inertia }: HttpContext) {
    return inertia.render('admin/brands/create')
  }

  /**
   * Créer une nouvelle marque
   */
  async store({ request, response, session }: HttpContext) {
    const { name, url } = request.only(['name', 'url'])
    const file = request.file('image')

    console.log('🔍 CREATE BRAND DEBUG:')
    console.log('- Request data:', { name, url })
    console.log('- File object:', file)
    console.log('- File exists?', !!file)
    console.log('- File has tmpPath?', file?.tmpPath)
    console.log('- File size:', file?.size)

    let imageUrl = '/uploads/brands/default-brand.jpg'

    // Traiter l'upload d'image si fourni
    if (file && file.tmpPath) {
      console.log('📁 Processing file upload...')
      const fileName: string = `brands/${generateSlug(name)}-${cuid()}.${file.extname}`
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
        console.error('❌ Erreur lors de l\'upload de l\'image de marque:', error)
      }
    } else {
      console.log('⚠️ No file provided or invalid file')
    }
    
    if (url) {
      // Utiliser l'URL fournie si pas d'image uploadée
      imageUrl = this.formatImageUrl(url)
      console.log('� Using provided URL:', imageUrl)
    } else if (!file?.tmpPath) {
      // Générer une URL par défaut si aucune URL fournie et pas d'image
      imageUrl = this.formatImageUrl(name.toLowerCase().replace(/\s+/g, '-'))
      console.log('🔄 Using generated URL:', imageUrl)
    }

    console.log('🎯 Final URL to save:', imageUrl)

    try {
      // Validation de base
      if (!name || name.trim() === '') {
        session.flash('errors', { name: 'Le nom de la marque est requis' })
        return response.redirect().back()
      }

      const brand = await Brand.create({
        name: name.trim(),
        url: imageUrl
      })

      console.log('🔍 Brand created - DEBUG INFO:')
      console.log('- Name:', name)
      console.log('- Image URL saved in DB:', imageUrl)
      console.log('- Brand ID:', brand.id)
      console.log('- Brand URL from DB:', brand.url)

      session.flash('notification', {
        type: 'success',
        message: 'Marque créée avec succès'
      })

      return response.redirect('/dashboard/brands')

    } catch (error) {
      console.error('❌ Error creating brand:', error)
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la création de la marque'
      })
      return response.redirect().back()
    }
  }

  /**
   * Afficher le formulaire d'édition
   */
  async edit({ params, inertia }: HttpContext) {
    const brand = await Brand.find(params.id)
    
    if (!brand) {
      return inertia.location('/dashboard/brands')
    }

    return inertia.render('admin/brands/edit', {
      brand: brand.toJSON()
    })
  }

  /**
   * Mettre à jour une marque
   */
  async update({ params, request, response, session }: HttpContext) {
    const { name, url } = request.only(['name', 'url'])
    const brand = await Brand.find(params.id)
    const file = request.file('image')

    if (!brand) {
      session.flash('notification', {
        type: 'error',
        message: 'Marque non trouvée'
      })
      return response.redirect().back()
    }

    let imageUrl = brand.url

    // Traiter l'upload d'image si fourni
    if (file && file.tmpPath) {
      console.log('📁 Processing file upload...')
      const fileName: string = `brands/${generateSlug(name)}-${cuid()}.${file.extname}`
      
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
        console.error('❌ Erreur lors de l\'upload de l\'image de marque:', error)
      }
    } else if (url && url !== brand.url) {
      // Utiliser la nouvelle URL si fournie et différente
      imageUrl = this.formatImageUrl(url)
    }

    try {
      // Validation de base
      if (!name || name.trim() === '') {
        session.flash('errors', { name: 'Le nom de la marque est requis' })
        return response.redirect().back()
      }

      await brand.merge({
        name: name.trim(),
        url: imageUrl
      }).save()

      session.flash('notification', {
        type: 'success',
        message: 'Marque modifiée avec succès'
      })

      return response.redirect('/dashboard/brands')

    } catch (error) {
      console.error('❌ Error updating brand:', error)
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
  async destroy({ params, response, session }: HttpContext) {
    try {
      const brand = await Brand.find(params.id)
      
      if (!brand) {
        session.flash('notification', {
          type: 'error',
          message: 'Marque non trouvée'
        })
        return response.redirect().back()
      }

      await brand.delete()
      
      session.flash('notification', {
        type: 'success',
        message: 'Marque supprimée avec succès'
      })
      return response.redirect('/dashboard/brands')

    } catch (error) {
      console.error('❌ Error deleting brand:', error)
      session.flash('notification', {
        type: 'error',
        message: 'Erreur lors de la suppression de la marque'
      })
      return response.redirect().back()
    }
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
}
