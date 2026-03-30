export const logJson = (data: any, context = 'INFO') => {
  const timestamp = new Date().toUTCString()
  const color =
    {
      INFO: '\x1b[34m', // Blue
      WARN: '\x1b[33m', // Yellow
      ERROR: '\x1b[31m', // Red
      DEBUG: '\x1b[36m', // Cyan
    }[context] || '\x1b[0m' // Default color

  const formattedJson = JSON.stringify(data, null, 2) // Beautify JSON with 2 spaces
  console.log(`${color}[${context}] [${timestamp}]:\x1b[0m\n${formattedJson}`)
}
