import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Media from '#models/media'
import { MediaType } from '#dto/products_interface'

export default class extends BaseSeeder {
  async run() {
    let medias = []
    for (let i = 1; i < 18; i++) {
      medias.push({
        productId: i,
        url: 'https://media.autodoc.de/360_photos/14429902/preview.jpg',
        type: MediaType.IMAGE
      })
      medias.push({
        productId: i,
        url: 'https://cdn.autodoc.de/uploads/tyres/full/PKW/5420068624973_IM202.jpg',
        type: MediaType.IMAGE,
      })
      medias.push({
        productId: i,
        url: 'https://cdn.autodoc.de/uploads/tyres/full/PKW/5420068624973_IM202.jpg',
        type: MediaType.IMAGE
      })
    }
    await Media.createMany(medias)
  }
}
