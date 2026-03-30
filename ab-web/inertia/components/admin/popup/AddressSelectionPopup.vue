<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50"
  >
    <div class="bg-background-admin rounded-lg p-6 w-full max-w-md">
      <h2 class="text-2xl font-bold mb-4">
        {{ addresses.length > 0 ? 'Choisir ' : 'Ajouter' }} une adresse de livraison
      </h2>

      <div v-if="addresses.length > 0">
        <h3 class="text-lg font-semibold mb-2">Adresses existantes</h3>
        <div v-for="address in addresses" :key="address.id" class="mb-2">
          <label class="flex items-center space-x-2 cursor-pointer">
            <input
              type="radio"
              :value="address.id"
              v-model="selectedAddressId"
              class="form-radio text-primary"
            />
            <span class=" ">{{ address.type }} : {{ formatAddress(address) }}</span>
          </label>
        </div>
      </div>

      <div class="mt-4">
        <button v-if="addresses.length <= 3" @click="$emit('add-address')" class="text-lg underline mb-2 text-primary">
          {{ addresses.length > 0 ? 'Ajouter une nouvelle adresse' : 'Créer une adresse' }}
        </button>
      </div>

      <div class="mt-6 flex justify-end space-x-3">
        <button
          @click="close"
          class="px-4 py-2 bg-gray-300 text-gray-800 rounded-md hover:bg-gray-400 transition duration-300"
        >
          Annuler
        </button>
        <button
          @click="confirmSelection"
          :disabled="addresses.length < 0 || selectedAddressId === null"
          class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary-dark transition duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Confirmer
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import type Address from '#models/address'

defineProps<{
  isOpen: boolean
  addresses: Address[]
}>()

const emit = defineEmits(['close', 'select-address', 'add-address'])

const selectedAddressId = ref<string | null>(null)

const formatAddress = (address: Address) => {
  return `${address.addressLine}, ${address.city}, ${address.country}`
}

const close = () => {
  emit('close')
}

const confirmSelection = () => {
  if (selectedAddressId.value) {
    emit('select-address', selectedAddressId.value)
  }
  close()
}
</script>
