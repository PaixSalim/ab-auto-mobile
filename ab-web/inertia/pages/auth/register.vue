<script setup lang="ts">
import { ref } from 'vue'
import { router, Link, Head } from '@inertiajs/vue3'
import InputComponent from '~/components/auth/form/InputComponent.vue'
import MessagePopup from '~/components/admin/product/MessagePopup.vue'
import AuthShell from '~/components/auth/AuthShell.vue'
import { PopupType } from '#utils/popup_type_utils'

const isLoading = ref(false)
const fullName = ref('')
const email = ref('')
const phone = ref('')
const city = ref('')
const password = ref('')
const confirmPassword = ref('')
const companyName = ref('')
const neighborhood = ref('')
const registrationNumber = ref('')
const showPopup = ref(false)
const popupType = ref<PopupType>(PopupType.SUCCESS)
const popupMessage = ref('')

const closePopup = () => {
  showPopup.value = false
}

function handleSubmit() {
  if (fullName.value.trim().length < 3) {
    showPopup.value = true
    popupType.value = PopupType.ERROR
    popupMessage.value = 'Le nom doit contenir au moins 3 caractères.'
    setTimeout(() => {
      showPopup.value = false
    }, 2800)
    return
  }

  if (password.value.length < 8) {
    showPopup.value = true
    popupType.value = PopupType.ERROR
    popupMessage.value = 'Le mot de passe doit contenir au moins 8 caractères.'
    setTimeout(() => {
      showPopup.value = false
    }, 2800)
    return
  }

  if (password.value !== confirmPassword.value) {
    showPopup.value = true
    popupType.value = PopupType.ERROR
    popupMessage.value = 'Les mots de passe ne correspondent pas.'
    setTimeout(() => {
      showPopup.value = false
    }, 2800)
    return
  }

  isLoading.value = true
  const form = new FormData()
  form.append('fullName', fullName.value.trim())
  form.append('email', email.value.toLowerCase().trim())
  form.append('phone', phone.value)
  form.append('city', city.value)
  form.append('password', password.value)
  form.append('confirmPassword', confirmPassword.value)
  form.append('companyName', companyName.value)
  form.append('neighborhood', neighborhood.value)
  form.append('registrationNumber', registrationNumber.value)

  router.post('/auth/register', form, {
    preserveScroll: false,
    onFinish: () => {
      isLoading.value = false
    },
    onSuccess: (page: { props?: { errors?: Record<string, string[]> } }) => {
      const err = page.props?.errors
      const emailErr = err?.email?.[0]
      if (emailErr) {
        showPopup.value = true
        popupType.value = PopupType.ERROR
        popupMessage.value = emailErr
        setTimeout(() => {
          showPopup.value = false
        }, 5000)
      }
    },
    onError: (errors) => {
      let msg = 'Impossible de créer le compte.'
      const e = errors?.email
      if (Array.isArray(e) && e[0]) msg = e[0]
      showPopup.value = true
      popupType.value = PopupType.ERROR
      popupMessage.value = msg
      setTimeout(() => {
        showPopup.value = false
      }, 4500)
    },
  })
}
</script>

<template>
  <Head title="Inscription" />

  <AuthShell
    wide
    show-close
    title="Créer un compte"
    subtitle="Renseignez les champs pro pour être enregistré comme vendeur ; sinon vous serez orienté vers un compte client."
  >
    <form class="space-y-4" @submit.prevent="handleSubmit">
      <div class="grid gap-4 sm:grid-cols-2">
        <div class="sm:col-span-2">
          <InputComponent
            id="fullName"
            type="text"
            placeholder="Nom et prénom"
            label="Nom complet"
            v-model="fullName"
          />
        </div>
        <InputComponent
          id="email"
          type="email"
          placeholder="vous@exemple.com"
          label="E-mail"
          v-model="email"
        />
        <InputComponent
          id="phone"
          type="text"
          placeholder="+226…"
          label="Téléphone"
          v-model="phone"
        />
        <InputComponent
          id="city"
          type="text"
          placeholder="Ville"
          label="Ville"
          v-model="city"
        />
        <InputComponent
          id="neighborhood"
          type="text"
          placeholder="Quartier"
          label="Quartier"
          v-model="neighborhood"
        />
        <InputComponent
          id="password"
          type="password"
          placeholder="8 caractères minimum"
          label="Mot de passe"
          v-model="password"
        />
        <InputComponent
          id="confirmPassword"
          type="password"
          placeholder="Répétez le mot de passe"
          label="Confirmation"
          v-model="confirmPassword"
        />
        <InputComponent
          id="companyName"
          type="text"
          placeholder="Optionnel"
          label="Entreprise"
          v-model="companyName"
        />
        <InputComponent
          id="registrationNumber"
          type="text"
          placeholder="Optionnel"
          label="N° d’enregistrement"
          v-model="registrationNumber"
        />
      </div>

      <button
        type="submit"
        :disabled="isLoading"
        class="mt-2 w-full flex items-center justify-center gap-2 rounded-2xl bg-[#BE1622] px-4 py-3.5 text-sm font-semibold text-white shadow-lg shadow-[#BE1622]/30 transition hover:bg-[#9d1220] disabled:cursor-not-allowed disabled:opacity-60 sm:text-base"
      >
        <span
          v-if="isLoading"
          class="i-line-md-loading-loop h-5 w-5 shrink-0 animate-spin"
        />
        {{ isLoading ? 'Création…' : 'S’inscrire' }}
      </button>
    </form>

    <div class="mt-8 border-t border-white/10 pt-6 text-center text-sm text-white/60">
      <p>
        Déjà inscrit ?
        <Link
          href="/auth/login"
          class="font-semibold text-[#BE1622] hover:text-red-400 transition-colors"
        >
          Se connecter
        </Link>
      </p>
      <p class="mt-2">
        <Link href="/" class="text-white/50 hover:text-white/80 transition-colors">
          ← Retour à l’accueil
        </Link>
      </p>
    </div>
  </AuthShell>

  <MessagePopup
    :show="showPopup"
    :type="popupType"
    :message="popupMessage"
    @close-callback="closePopup"
  />
</template>
