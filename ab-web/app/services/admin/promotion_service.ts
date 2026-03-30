import { CreatePromotionDto, EditPromotionDto } from '#dto/promoted_products_dto'
import { generateSlug } from '#utils/slug_utils'
import { cuid } from '@adonisjs/core/helpers'
import drive from '@adonisjs/drive/services/main'
import env from '#start/env'
import Promotion from '#models/promotion'
import { DateTime } from 'luxon'

export class PromotionService {
  async create(payload: CreatePromotionDto, file?: any) {
    let imageUrl = '/uploads/products/default-product.jpg' // Image par défaut LOCALE
    
    console.log('🚀 CREATE PROMOTION - START')
    console.log('Payload:', payload)
    console.log('File object:', file)
    console.log('File exists?', !!file)
    console.log('File has tmpPath?', file?.tmpPath)
    
    if (file && file.tmpPath) {
      console.log('📁 File upload detected')
      const fileName: string = `promotions/${generateSlug(payload.promoLabel)}-${cuid()}.${file.extname}`
      console.log('📝 Generated filename:', fileName)
      
      try {
        const disk = env.get('NODE_ENV') === 'production' ? 'r2' : 'local'
        console.log('💾 Using disk:', disk)
        
        await file.moveToDisk(fileName, disk)
        console.log('✅ File moved to disk')
        
        let uploadedUrl: string
        
        if (disk === 'local') {
          // Pour le disque local, construire l'URL manuellement
          uploadedUrl = '/uploads/' + fileName
          console.log('� Local URL constructed manually:', uploadedUrl)
        } else {
          // Pour R2, utiliser la méthode getUrl
          uploadedUrl = await drive.use(disk).getUrl(fileName)
          console.log('� Drive returned URL:', uploadedUrl)
        }
        
        imageUrl = uploadedUrl
        console.log('🎯 FINAL IMAGE URL:', imageUrl)
        
      } catch (error) {
        console.error('❌ UPLOAD ERROR:', error)
        console.log('⚠️ Will use default image')
      }
    } else {
      console.log('⚠️ NO FILE - Using default image')
    }

    console.log('� Saving to database with URL:', imageUrl)

    const promotion = await Promotion.create({
      productId: payload.productId,
      promoLabel: payload.promoLabel,
      discountPercent: Number(payload.discountPercent),
      promoStartDate: DateTime.fromISO(payload.promoStartDate),
      promoEndDate: DateTime.fromISO(payload.promoEndDate),
      url: imageUrl,
    })
    
    console.log('✅ Promotion created - ID:', promotion.id)
    console.log('✅ Final URL in DB:', imageUrl)
    
    return promotion
  }

  async edit(payload: EditPromotionDto, file?: any) {
    console.log('Editing promotion with payload:', payload)
    console.log('File received for edit:', file)
    
    const promo = await Promotion.findOrFail(payload.id)
    console.log('Found promotion:', promo.id, 'current URL:', promo.url)
    
    let imageUrl = promo.url // Conserver l'URL existante par défaut
    
    // Si une nouvelle image est fournie, la traiter
    if (file && file.tmpPath) {
      console.log('Processing new file upload for edit...')
      const fileName: string = `promotions/${generateSlug(payload.promoLabel)}-${cuid()}.${file.extname}`
      console.log('Generated filename for edit:', fileName)
      
      try {
        // Utiliser le disque approprié selon l'environnement
        const disk = env.get('NODE_ENV') === 'production' ? 'r2' : 'local'
        await file.moveToDisk(fileName, disk)
        
        let uploadedUrl: string
        
        if (disk === 'local') {
          // Pour le disque local, construire l'URL manuellement
          uploadedUrl = '/uploads/' + fileName
          console.log('Local disk URL constructed manually for edit:', uploadedUrl)
        } else {
          // Pour R2, utiliser la méthode getUrl
          uploadedUrl = await drive.use(disk).getUrl(fileName)
        }
        
        imageUrl = uploadedUrl
        
        console.log('Image uploaded successfully for edit to', disk, ':', imageUrl)
      } catch (error) {
        console.error('Erreur lors de l\'enregistrement du fichier :', error)
        // Continue avec l'URL existante en cas d'erreur
      }
    } else {
      console.log('No new file provided for edit, keeping existing image')
    }
    
    await promo
      .merge({
        productId: payload.productId,
        promoLabel: payload.promoLabel,
        discountPercent: payload.discountPercent,
        promoStartDate: DateTime.fromISO(payload.promoStartDate),
        promoEndDate: DateTime.fromISO(payload.promoEndDate),
        url: imageUrl, // Mettre à jour l'URL si nouvelle image
      })
      .save()
      
    console.log('Promotion modified with URL:', imageUrl)
  }

  async delete(id: number) {
    const promo = await Promotion.find(id)
    if (promo) {
      await promo.delete()
    }
  }
}
