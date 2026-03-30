/** Aligné avec `src/common/configs/upload-storage.ts` (IMAGE_MAX_FILE_SIZE) */
export const IMAGE_MAX_BYTES = 10 * 1024 * 1024

export const IMAGE_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'image/jpg',
  'image/gif',
  'image/webp',
] as const

export function isValidImageFile(file: File): boolean {
  if (file.size > IMAGE_MAX_BYTES) return false
  if (file.type && IMAGE_MIME_TYPES.includes(file.type as (typeof IMAGE_MIME_TYPES)[number]))
    return true
  return /\.(jpe?g|png|gif|webp)$/i.test(file.name)
}
