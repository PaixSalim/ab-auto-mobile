<script setup lang="ts">

import { useCartStore } from '~/stores/cart_store'
import pinia from '~/stores/pinia'
import { onMounted } from 'vue'

const cartStore = useCartStore(pinia())
onMounted(() => {
  cartStore.initialize()
})

const addItem = (index: number) => {
  
}
</script>

<template>
  <div>
    <h2>Mon Panier</h2>
    <ul>
      <li v-for="item in 4" :key="item">
        {{ item }} - Test
        <button @click="addItem(item)">Ajouter</button>
      </li>
    </ul>

    <h1>Mon store maintenant</h1>
    <ul>
      <li v-for="item in cartStore.items" :key="item.id">
        {{ item.name }}€
        <button @click="cartStore.removeFromCart(item.id)">Retirer</button>
      </li>
    </ul>
  </div>
</template>
