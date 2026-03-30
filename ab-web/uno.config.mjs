import { defineConfig } from '@unocss/vite'
import presetIcons from '@unocss/preset-icons'
import presetUno from '@unocss/preset-uno'
import transformerDirectives from '@unocss/transformer-directives'
import transformerVariantGroup from '@unocss/transformer-variant-group'
import { icons as mdiIcons } from '@iconify-json/mdi'
import { icons as lineMdIcons } from '@iconify-json/line-md'

if (!mdiIcons?.icons || !lineMdIcons?.icons) {
  throw new Error(
    'UnoCSS: @iconify-json/mdi ou line-md introuvable (vérifiez les dépendances).',
  )
}

export default defineConfig({
  presets: [
    presetUno(),
    presetIcons({
      scale: 1.15,
      warn: false,
      // Les IconifyJSON doivent être passés en factory : sinon @iconify/utils les traite comme une map inline.
      collections: {
        mdi: () => mdiIcons,
        'line-md': () => lineMdIcons,
      },
    }),
  ],
  theme: {
    colors: {
      primary: {
        DEFAULT: '#BE1622',
        dark: '#8E1019',
        light: '#E31B2A',
      },
      background: {
        admin: '#020617', // slate-950
        secondary: '#0f172a', // slate-900
        tertiary: '#1e293b', // slate-800
      },
      title: '#f8fafc', // slate-50
      description: '#94a3b8', // slate-400
    },
    breakpoints: {
      sm: '640px',
      md: '768px',
      lg: '1024px',
      xl: '1280px',
    },
  },
  transformers: [
    transformerDirectives(),
    transformerVariantGroup(),
  ],
})
