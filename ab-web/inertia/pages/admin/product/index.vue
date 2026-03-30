<template>
  <Layout>
    <div class="flex justify-between items-center mb-6">
      <h2 class="text-2xl font-semibold text-gray-900">Products</h2>
      <button
        @click="addProduct"
        class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
      >
        Ajouter un produit
      </button>
    </div>

    <div class="bg-white shadow-md rounded my-6">
      <table class="min-w-full leading-normal">
        <thead>
          <tr>
            <th
              class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
            >
              Name
            </th>
            <th
              class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
            >
              Category
            </th>
            <th
              class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
            >
              Price
            </th>
            <th
              class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
            >
              Statut
            </th>
            <th
              class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
            >
              Stock
            </th>
            <th
              class="px-5 py-3 border-b-2 border-gray-200 bg-gray-100 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
            >
              Actions
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="product in products" :key="product.id">
            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
              {{ product.name }}
            </td>
            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
              {{ product.category.name }}
            </td>
            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
              {{ product.price }}
            </td>
            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
              <span
                :class="[
                  'px-2 py-1 rounded text-xs font-medium',
                  product.validationStatus === 'approved' ? 'bg-green-100 text-green-800' :
                  product.validationStatus === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                  'bg-red-100 text-red-800'
                ]"
              >
                {{ product.validationStatus === 'approved' ? 'Approuvé' :
                   product.validationStatus === 'pending' ? 'En attente' :
                   'Rejeté' }}
              </span>
            </td>
            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
              {{ product.stock }}
            </td>
            <td class="px-5 py-5 border-b border-gray-200 bg-white text-sm">
              <a
                :href="router.route('admin.products.edit', product.id)"
                class="text-blue-600 hover:text-blue-900 mr-2"
                >Edit</a
              >
              <button @click="deleteProduct(product.id)" class="text-red-600 hover:text-red-900">
                Delete
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </Layout>
</template>

<script setup>
import { useForm, router } from '@inertiajs/vue3'
import Layout from '~/components/admin/Layout.vue'

const addProduct = () => {
  router.visit('admin/product/create')
}

const props = defineProps({
  products: Array,
})

const deleteProduct = (id) => {
  if (confirm('Are you sure you want to delete this product?')) {
    router.delete(router.route('admin.products.destroy', id))
  }
}
</script>
