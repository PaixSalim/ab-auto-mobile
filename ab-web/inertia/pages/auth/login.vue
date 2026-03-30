<script setup lang="ts">
import { ref } from 'vue'
import { router, Link, Head } from '@inertiajs/vue3'
import InputComponent from '~/components/auth/form/InputComponent.vue'
import MessagePopup from '~/components/admin/product/MessagePopup.vue'
import AuthShell from '~/components/auth/AuthShell.vue'
import RegisterPopup from '~/components/auth/RegisterPopup.vue'
import { PopupType } from '#utils/popup_type_utils'

const isLoading = ref(false)
const uid = ref('')
const password = ref('')
const showPopup = ref(false)
const popupType = ref<PopupType>(PopupType.SUCCESS)
const popupMessage = ref('')
const showRegisterModal = ref(false)

const closePopup = () => {
  showPopup.value = false
}

const openRegisterModal = () => {
  showRegisterModal.value = true
}

function handleSubmit() {
  if (password.value.length < 6) {
    showPopup.value = true
    popupType.value = PopupType.ERROR
    popupMessage.value = 'Mot de passe : au moins 6 caractères.'
    setTimeout(() => {
      showPopup.value = false
    }, 2800)
    return
  }

  isLoading.value = true
  const form = new FormData()
  form.append('uid', uid.value.toString().toLowerCase().trim())
  form.append('password', password.value)

  router.post('/auth/login', form, {
    preserveScroll: false,
    onFinish: () => {
      isLoading.value = false
    },
    onSuccess: (page: { props?: { errors?: Record<string, string[]> } }) => {
      const err = page.props?.errors
      if (!err) return
      const uidErr = err.uid?.[0] || err.email?.[0]
      const first = uidErr ||
        (Object.values(err).find((v) => Array.isArray(v) && v[0]) as string[] | undefined)?.[0]
      if (first) {
        showPopup.value = true
        popupType.value = PopupType.ERROR
        popupMessage.value = first
        setTimeout(() => {
          showPopup.value = false
        }, 4500)
      }
    },
    onError: (errors) => {
      let errorMessage = 'Identifiants incorrects.'
      if (errors && typeof errors === 'object') {
        if (errors.uid && Array.isArray(errors.uid)) {
          errorMessage = errors.uid[0]
        } else if (errors.email && Array.isArray(errors.email)) {
          errorMessage = errors.email[0]
        } else {
          const first = Object.values(errors).find(
            (v) => Array.isArray(v) && v.length > 0,
          ) as string[] | undefined
          if (first?.[0]) errorMessage = first[0]
        }
      }
      showPopup.value = true
      popupType.value = PopupType.ERROR
      popupMessage.value = errorMessage
      setTimeout(() => {
        showPopup.value = false
      }, 4000)
    },
  })
}
</script>

<template>
  <Head title="Connexion" />

  <AuthShell
    show-close
    title="Connexion"
    subtitle="Accédez à votre espace !"
  >
    <form class="space-y-5" @submit.prevent="handleSubmit">
      <InputComponent
        id="uid"
        type="text"
        placeholder="E-mail ou téléphone"
        label="Identifiant"
        v-model="uid"
      />

      <InputComponent
        id="password"
        type="password"
        placeholder="Votre mot de passe"
        label="Mot de passe"
        v-model="password"
      />

      <button
        type="submit"
        :disabled="isLoading"
        class="w-full flex items-center justify-center gap-2 rounded-2xl bg-[#BE1622] px-4 py-3.5 text-sm font-semibold text-white shadow-lg shadow-[#BE1622]/30 transition hover:bg-[#9d1220] disabled:cursor-not-allowed disabled:opacity-60 sm:text-base"
      >
        <span
          v-if="isLoading"
          class="i-line-md-loading-loop h-5 w-5 shrink-0 animate-spin"
        />
        {{ isLoading ? 'Connexion…' : 'Se connecter' }}
      </button>
    </form>

    <div class="mt-8 space-y-3 border-t border-white/10 pt-6 text-center text-sm text-white/60">
      <p>
        Pas encore de compte ?
        <button
          @click="openRegisterModal"
          class="font-semibold text-[#BE1622] hover:text-red-400 transition-colors bg-transparent border-none cursor-pointer inline"
        >
          Créer un compte
        </button>
      </p>
      <p>
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

  <RegisterPopup v-if="showRegisterModal" @close="showRegisterModal = false" />
</template>
