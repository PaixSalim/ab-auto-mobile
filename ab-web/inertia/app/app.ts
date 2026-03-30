import '../css/app.css'
import 'virtual:uno.css'
import { createApp, h } from 'vue'
import { createInertiaApp } from '@inertiajs/vue3'
import { createPinia } from 'pinia'
import GlobalFlashToaster from '../components/GlobalFlashToaster.vue'

const appName = 'AB-AUTO'

const root: any = document.getElementById('app')
let initialPage = null

/** Base64 → chaîne UTF-8 (atob seul casse les accents dans le JSON Inertia). */
function decodeBase64Utf8(b64: string): string {
  const binary = atob(b64)
  const bytes = new Uint8Array(binary.length)
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i)
  }
  return new TextDecoder('utf-8').decode(bytes)
}

try {
  const base64Page = root?.dataset.page
  if (base64Page) {
    initialPage = JSON.parse(decodeBase64Utf8(base64Page))
  }
} catch (e) {
}

createInertiaApp({
  page: initialPage,
  progress: { color: '#BE1622' },
  title: (title) => `${title} - ${appName}`,
  resolve: (name) => {
    const pages = import.meta.glob('../pages/**/*.vue', { eager: true })
    const page: any = pages[`../pages/${name}.vue`]
    if (!page) console.error('Component not found:', name)
    return page?.default ?? page
  },
  setup({ el, App, props, plugin }: any) {
    createApp({
      render: () =>
        h('div', { class: 'min-h-screen' }, [h(App, props)]),
    })
      .use(plugin)
      .use(createPinia())
      .mount(el!)
  },
})
