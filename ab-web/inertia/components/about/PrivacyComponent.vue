<script setup lang="ts">
import { ref } from 'vue'
import { router } from '@inertiajs/vue3'

const policyContent = ref({
  title: "Politique de Confidentialité",
  introduction:
    "Bienvenue dans la politique de confidentialité d'Auto-Pro. Nous respectons votre vie privée et nous nous engageons à protéger les informations que vous nous fournissez lorsque vous utilisez notre application pour rechercher des pièces ou services automobiles.",
  sections: [
    {
      title: "Collecte des Informations",
      content: "Auto-Pro ne collecte aucune donnée personnelle lors de la simple navigation sur l'application. Les seules informations que nous recueillons sont fournies volontairement par l'utilisateur au moment de passer une commande :",
      list: [
        "Nom (ou pseudonyme)",
        "Numéro WhatsApp pour la communication"
      ]
    },
    {
      title: "Utilisation des Informations",
      content: "Les informations collectées sont utilisées uniquement dans les cas suivants :",
      list: [
        "Traiter votre commande de pièces ou services",
        "Vous contacter via WhatsApp pour le suivi ou des précisions",
        "Améliorer notre service client et répondre à vos besoins"
      ]
    },
    {
      title: "Partage des Informations",
      content: "Nous ne partageons vos informations personnelles avec aucun tiers, sauf dans les cas suivants :",
      list: [
        "Si vous donnez votre accord explicite pour être mis en relation avec un fournisseur ou un garage partenaire",
        "Si la loi l’exige (obligations légales ou procédures judiciaires)"
      ]
    },
    {
      title: "Protection des Informations",
      content: "Nous mettons en œuvre des mesures raisonnables pour protéger les données que vous nous fournissez. Ces informations ne sont jamais publiées ni revendues. L'accès est limité uniquement aux membres autorisés de notre équipe."
    },
    {
      title: "Durée de Conservation",
      content: "Nous conservons vos données (nom et numéro WhatsApp) uniquement le temps nécessaire pour assurer le suivi de votre commande. Elles peuvent être supprimées sur simple demande."
    },
    {
      title: "Vos Droits",
      content: "Conformément aux lois applicables, vous disposez des droits suivants concernant vos données personnelles :",
      list: [
        "Demander l'accès aux informations que nous détenons sur vous",
        "Demander la suppression de vos données après la commande",
        "Retirer votre consentement à tout moment"
      ]
    },
    {
      title: "Modifications de la Politique",
      content: "Nous pouvons mettre à jour cette politique de confidentialité. Toute modification sera affichée directement dans l'application avec la date de mise à jour. Nous vous encourageons à la consulter régulièrement."
    },
    {
      title: "Nous Contacter",
      content: "Pour toute question concernant cette politique de confidentialité ou vos données personnelles, vous pouvez nous contacter via :",
      list: [
        "Email : auto-pro@uvatis.com"
      ]
    }
  ]
});
</script>


<template>
  <div class="min-h-screen bg-gray-100 mt-10 py-8 px-4 sm:px-6 lg:(px-8 mt-15)">
    <div class="max-w-3xl mx-auto bg-white shadow-md rounded-lg overflow-hidden">
      <div class="p-6 sm:p-8">
        <h1 class="text-3xl text-center font-bold text-primary mb-6">{{ policyContent.title }}</h1>

        <div class="space-y-6 md:(text-xl) text-gray-700">
          <p class="italic text-gray-5">Dernière modification : 11 Avril 2025</p>
          <p>{{ policyContent.introduction }}</p>

          <div v-for="(section, index) in policyContent.sections" :key="index" class="space-y-2">
            <h2 class="text-xl md:(text-2xl) font-semibold text-primary">{{ index + 1 }}. {{ section.title }}</h2>
            <p>{{ section.content }}</p>
            <ul v-if="section.list" class="list-disc pl-6">
              <li v-for="(item, itemIndex) in section.list" :key="itemIndex">
                {{ item }}
              </li>
            </ul>
          </div>

          <div class="flex justify-center">
            <button @click="router.get('/')" class="px-4 py-2 bg-primary rounded-lg text-white">
              Accueil
            </button>
          </div>

        </div>
      </div>
    </div>
  </div>
</template>
