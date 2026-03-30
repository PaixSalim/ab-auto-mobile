import env from '#start/env'
import { defineConfig, services } from '@adonisjs/drive'

const driveConfig = defineConfig({
  default: env.get('DRIVE_DISK'),

  /**
   * The services object can be used to configure multiple file system
   * services each using same or a different driver.
   */
  services: { 
    // Disque local pour le développement
    local: services.fs({
      location: './public/uploads',
      visibility: 'public',
    }),
    
    // Disque R2 pour la production
    r2: services.s3({
      credentials: {
        accessKeyId: env.get('R2_KEY'),
        secretAccessKey: env.get('R2_SECRET'),
      },
      region: 'auto',
      bucket: env.get('R2_BUCKET'),
      endpoint: env.get('R2_ENDPOINT'),
      visibility: 'public',
    }),
  },
})

export default driveConfig

declare module '@adonisjs/drive/types' {
  export interface DriveDisks extends InferDriveDisks<typeof driveConfig> {}
}