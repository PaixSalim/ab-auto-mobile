<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { router, Link } from '@inertiajs/vue3'
import {
  User,
  Store,
  ChevronRight,
  X,
  Home,
  Loader2,
} from 'lucide-vue-next'
import InputComponent from '~/components/auth/form/InputComponent.vue'
import MessagePopup from '~/components/admin/product/MessagePopup.vue'
import { PopupType } from '#utils/popup_type_utils'

const emit = defineEmits(['close'])

const step = ref(1) // 1: Select type, 2: Form
const userType = ref<'customer' | 'seller' | null>(null)
const isLoading = ref(false)

const form = ref({
  fullName: '',
  email: '',
  phone: '',
  city: '',
  password: '',
  confirmPassword: '',
  companyName: '',
  neighborhood: '',
})

const showPopup = ref(false)
const popupType = ref<PopupType>(PopupType.SUCCESS)
const popupMessage = ref('')

const closePopup = () => {
  showPopup.value = false
}

const handleSelectType = (type: 'customer' | 'seller') => {
  userType.value = type
  step.value = 2
}

const backToType = () => {
  step.value = 1
  userType.value = null
}

const close = () => {
  emit('close')
  // Reset state
  setTimeout(() => {
    step.value = 1
    userType.value = null
    form.value = {
      fullName: '',
      email: '',
      phone: '',
      city: '',
      password: '',
      confirmPassword: '',
      companyName: '',
      neighborhood: '',
    }
  }, 300)
}

/** Ferme la modale et renvoie vers l’accueil */
const quitToHome = () => {
  close()
  router.visit('/', { preserveScroll: false })
}

function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') {
    e.preventDefault()
    close()
  }
}

const bodyOverflowPrev = ref('')

onMounted(() => {
  bodyOverflowPrev.value = document.body.style.overflow
  document.body.style.overflow = 'hidden'
  document.addEventListener('keydown', onKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', onKeydown)
  document.body.style.overflow = bodyOverflowPrev.value
})

function handleSubmit() {
  if (form.value.fullName.length < 3) {
    showPopup.value = true
    popupType.value = PopupType.ERROR
    popupMessage.value = 'Le nom doit contenir au moins 3 caractères'
    return
  }

  if (form.value.password.length < 8) {
    showPopup.value = true
    popupType.value = PopupType.ERROR
    popupMessage.value = 'Le mot de passe doit contenir au moins 8 caractères'
    return
  }

  if (form.value.password !== form.value.confirmPassword) {
    showPopup.value = true
    popupType.value = PopupType.ERROR
    popupMessage.value = 'Les mots de passe ne correspondent pas'
    return
  }

  isLoading.value = true
  
  const payload = {
    ...form.value,
    isSeller: userType.value === 'seller'
  }

  router.post('/auth/register', payload, {
    preserveScroll: false,
    onFinish: () => {
      isLoading.value = false
    },
    onSuccess: () => {
      // Le serveur renvoie une redirection 303 (client / vendeur) : Inertia suit l’URL — ne pas forcer `/`.
      close()
    },
    onError: (errors) => {
      let msg = 'Impossible de créer le compte.'
      if (errors && typeof errors === 'object') {
        const first = Object.values(errors)[0] as unknown
        if (Array.isArray(first) && first[0]) msg = String(first[0])
        else if (typeof first === 'string') msg = first
      }
      showPopup.value = true
      popupType.value = PopupType.ERROR
      popupMessage.value = msg
    },
  })
}
</script>

<template>
  <Teleport to="body">
    <transition name="fade">
      <div
        class="register-popup-backdrop fixed inset-0 z-[6000] flex items-center justify-center p-4 sm:p-6 bg-[#0c0f14]/70 backdrop-blur-md"
        role="dialog"
        aria-modal="true"
        aria-labelledby="register-popup-title"
        @click.self="close"
      >
        <div
          class="bg-white rounded-[1.75rem] w-full max-w-lg overflow-hidden shadow-[0_25px_80px_-12px_rgba(0,0,0,0.35)] ring-1 ring-black/[0.06] relative z-[1] max-h-[min(92vh,720px)] flex flex-col pointer-events-auto"
          @click.stop
        >
        <div
          class="h-1.5 w-full bg-gradient-to-r from-[#BE1622] via-[#d42028] to-[#9d1220] shrink-0"
          aria-hidden="true"
        />

        <!-- Close -->
        <button
          type="button"
          @click="close"
          class="absolute top-4 right-4 z-20 flex h-10 w-10 items-center justify-center rounded-xl text-slate-400 transition hover:bg-slate-100 hover:text-slate-800"
          aria-label="Fermer la fenêtre"
        >
          <X class="h-5 w-5" aria-hidden="true" stroke-width="2" />
        </button>

        <div class="px-6 pt-7 pb-6 sm:px-8 sm:pt-8 sm:pb-7 overflow-y-auto flex-1 min-h-0">
          <div class="flex justify-center mb-5">
            <img
              class="h-14 sm:h-16 rounded-2xl shadow-md ring-1 ring-black/5"
              src="https://auto-cdn.uvatis.com/logo/logo.png"
              alt="Logo"
            />
          </div>

          <div class="flex justify-center mb-3">
            <span
              class="inline-flex items-center rounded-full border border-slate-200/90 bg-slate-50 px-3 py-1 text-[11px] font-semibold uppercase tracking-wider text-slate-600"
            >
              {{ step === 1 ? 'Étape 1 sur 2' : 'Étape 2 sur 2' }}
            </span>
          </div>

          <h2
            id="register-popup-title"
            class="text-xl sm:text-2xl font-bold tracking-tight text-slate-900 text-center mb-2"
          >
            {{ step === 1 ? 'Créer un compte' : (userType === 'seller' ? 'Devenir vendeur' : 'Inscription client') }}
          </h2>
          <p
            v-if="step === 1"
            class="text-slate-600 text-center text-sm sm:text-[15px] leading-relaxed max-w-[28rem] mx-auto mb-8"
          >
            Choisissez le type de compte qui vous correspond pour personnaliser votre inscription.
          </p>
          <p v-else class="text-slate-600 text-center text-sm sm:text-[15px] mb-8">
            Complétez les informations ci-dessous pour finaliser votre inscription.
          </p>

          <!-- Step 1: choix du type -->
          <div v-if="step === 1" class="space-y-3">
            <p class="text-[11px] font-semibold uppercase tracking-widest text-slate-400 text-center mb-4">
              Votre profil
            </p>
            <button
              type="button"
              @click="handleSelectType('customer')"
              class="group w-full flex items-center gap-4 p-4 sm:p-5 rounded-2xl border border-slate-200/90 bg-gradient-to-br from-white to-slate-50/90 text-left shadow-sm transition duration-200 hover:border-[#BE1622]/35 hover:shadow-md hover:-translate-y-px focus:outline-none focus-visible:ring-2 focus-visible:ring-[#BE1622]/40 focus-visible:ring-offset-2"
            >
              <div
                class="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-[#BE1622]/10 text-[#BE1622] ring-1 ring-[#BE1622]/15 transition group-hover:bg-[#BE1622]/15"
              >
                <User class="h-7 w-7" stroke-width="2" aria-hidden="true" />
              </div>
              <div class="min-w-0 flex-1">
                <h3 class="font-bold text-slate-900 text-base">Client</h3>
                <p class="text-xs sm:text-sm text-slate-600 mt-0.5 leading-snug">
                  Acheter sur la boutique et suivre vos commandes.
                </p>
              </div>
              <ChevronRight
                class="h-5 w-5 shrink-0 text-slate-300 transition group-hover:text-[#BE1622] group-hover:translate-x-0.5"
                aria-hidden="true"
              />
            </button>

            <button
              type="button"
              @click="handleSelectType('seller')"
              class="group w-full flex items-center gap-4 p-4 sm:p-5 rounded-2xl border border-slate-200/90 bg-gradient-to-br from-white to-slate-50/90 text-left shadow-sm transition duration-200 hover:border-[#BE1622]/35 hover:shadow-md hover:-translate-y-px focus:outline-none focus-visible:ring-2 focus-visible:ring-[#BE1622]/40 focus-visible:ring-offset-2"
            >
              <div
                class="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-slate-900/5 text-slate-800 ring-1 ring-slate-200/80 transition group-hover:bg-[#BE1622]/10 group-hover:text-[#BE1622] group-hover:ring-[#BE1622]/20"
              >
                <Store class="h-7 w-7" stroke-width="2" aria-hidden="true" />
              </div>
              <div class="min-w-0 flex-1">
                <h3 class="font-bold text-slate-900 text-base">Vendeur professionnel</h3>
                <p class="text-xs sm:text-sm text-slate-600 mt-0.5 leading-snug">
                  Publier et gérer vos véhicules et accessoires (validation admin).
                </p>
              </div>
              <ChevronRight
                class="h-5 w-5 shrink-0 text-slate-300 transition group-hover:text-[#BE1622] group-hover:translate-x-0.5"
                aria-hidden="true"
              />
            </button>

            <button
              type="button"
              @click="quitToHome"
              class="mt-6 w-full flex items-center justify-center gap-2 rounded-2xl border-2 border-slate-200 bg-white px-4 py-3.5 text-sm font-semibold text-slate-700 transition hover:border-slate-300 hover:bg-slate-50"
            >
              <Home class="h-4 w-4 shrink-0 text-slate-500" aria-hidden="true" />
              Quitter et retour à l’accueil
            </button>
          </div>

          <!-- Step 2: Form -->
          <form v-else @submit.prevent="handleSubmit" class="space-y-4 max-h-[60vh] overflow-y-auto px-1 custom-scrollbar">
            <InputComponent
              id="fullName"
              type="text"
              variant="light"
              :placeholder="userType === 'seller' ? 'Nom du contact' : 'Entrez votre nom complet'"
              :label="userType === 'seller' ? 'Nom complet du contact' : 'Nom complet'"
              v-model="form.fullName"
              required
            />

            <template v-if="userType === 'seller'">
              <InputComponent
                id="companyName"
                type="text"
                variant="light"
                placeholder="Nom de votre boutique"
                label="Nom de l'entreprise / Boutique"
                v-model="form.companyName"
                required
              />
            </template>

            <template v-if="userType === 'seller'">
              <InputComponent
                id="email"
                type="email"
                variant="light"
                placeholder="votre@email.com"
                label="Email"
                v-model="form.email"
                required
              />
            </template>

            <div class="grid gap-4" :class="userType === 'seller' ? 'grid-cols-2' : 'grid-cols-1'">
              <InputComponent
                id="phone"
                type="text"
                variant="light"
                placeholder="Numéro de téléphone"
                label="Téléphone"
                v-model="form.phone"
                required
              />
              <InputComponent
                v-if="userType === 'seller'"
                id="city"
                type="text"
                variant="light"
                placeholder="Votre ville"
                label="Ville"
                v-model="form.city"
                required
              />
            </div>

            <template v-if="userType === 'seller'">
              <InputComponent
                id="neighborhood"
                type="text"
                variant="light"
                placeholder="Votre quartier"
                label="Quartier"
                v-model="form.neighborhood"
                required
              />
            </template>

            <InputComponent
              v-if="userType === 'customer'"
              id="email"
              type="email"
              variant="light"
              placeholder="votre@email.com"
              label="Email"
              v-model="form.email"
              required
            />

            <InputComponent
              id="password"
              type="password"
              variant="light"
              placeholder="•••••••••"
              label="Mot de passe"
              v-model="form.password"
              required
            />

            <InputComponent
              id="confirmPassword"
              type="password"
              variant="light"
              placeholder="•••••••••"
              label="Confirmer le mot de passe"
              v-model="form.confirmPassword"
              required
            />

            <div class="flex flex-col gap-3 pt-4 sticky bottom-0 bg-white">
              <div class="flex gap-3">
                <button
                  type="button"
                  @click="backToType"
                  class="flex-1 px-4 py-3 rounded-xl border border-slate-200 font-semibold text-slate-700 hover:bg-slate-50 transition"
                >
                  Retour
                </button>
                <button
                  type="submit"
                  class="flex-[2] bg-[#BE1622] text-white px-4 py-3 rounded-xl font-bold shadow-lg shadow-[#BE1622]/25 hover:bg-[#9d1220] transition flex items-center justify-center gap-2 disabled:opacity-60"
                  :disabled="isLoading"
                >
                  <Loader2
                    v-if="isLoading"
                    class="h-5 w-5 shrink-0 animate-spin"
                    aria-hidden="true"
                  />
                  {{ isLoading ? 'Création...' : (userType === 'seller' ? 'Devenir vendeur' : 'S\'inscrire') }}
                </button>
              </div>
              <button
                type="button"
                @click="quitToHome"
                class="w-full flex items-center justify-center gap-2 rounded-xl border border-slate-200 py-2.5 text-sm font-medium text-slate-600 hover:bg-slate-50"
              >
                <Home class="h-4 w-4" aria-hidden="true" />
                Quitter et retour à l’accueil
              </button>
            </div>
          </form>

          <div v-if="step === 1" class="mt-6 text-center border-t border-slate-100 pt-6">
            <p class="text-slate-600 text-sm">
              Déjà inscrit ?
              <Link
                href="/auth/login"
                class="font-semibold text-[#BE1622] hover:text-[#9d1220] underline-offset-2 hover:underline ml-1"
              >
                Se connecter
              </Link>
            </p>
          </div>
        </div>
      </div>

      <MessagePopup
        :show="showPopup"
        :type="popupType"
        :message="popupMessage"
        @close-callback="closePopup"
      />
    </div>
    </transition>
  </Teleport>
</template>

<style scoped>
.register-popup-backdrop {
  animation: register-backdrop-in 0.25s ease-out;
}
@keyframes register-backdrop-in {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.25s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.custom-scrollbar::-webkit-scrollbar {
  width: 4px;
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: #e2e8f0;
  border-radius: 10px;
}
.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: #cbd5e1;
}
</style>
