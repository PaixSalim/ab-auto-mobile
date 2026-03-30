<template>
  <Layout class="text-white">
    <OrdersView :orders="orders" @view="view" @action="handleAction" />

    <ShowOrderDetails
      v-if="showOrderDetailModal"
      :order="orderItemsForModal!"
      @close="closeOrderDetailModal"
    />

    <ConfirmAction
      v-if="confirm.show"
      :message="confirm.message"
      :action="getActionTranslation(confirm.action, 'fr')"
      @close="closeConfirmPopup"
      @action="action"
    />

    <MessagePopup
      :show="alertModal"
      :type="modalType!"
      :message="modalMessage"
      @close-callback="closeAlertModal"
    />
  </Layout>
</template>

<script setup lang="ts">
import Layout from '~/components/admin/Layout.vue'
import OrdersView from '~/components/admin/Orders/OrdersView.vue'
import ShowOrderDetails from '~/components/admin/popup/ShowOrderDetails.vue'
import { ref } from 'vue'
import { router } from '@inertiajs/vue3'
import MessagePopup from '~/components/admin/product/MessagePopup.vue'
import ConfirmAction from '~/components/admin/popup/ConfirmAction.vue'
import { PopupType } from '#utils/popup_type_utils'
import { getActionTranslation, OrderAction } from '#utils/enum'
import { OrderType } from '#dto/order_dto'

defineProps<{
  orders: OrderType[]
}>()

const showOrderDetailModal = ref(false)
const alertModal = ref(false)
const orderItemsForModal = ref<OrderType>()
const closeOrderDetailModal = () => {
  showOrderDetailModal.value = false
}
const modalType = ref<PopupType>(PopupType.SUCCESS)
const modalMessage = ref<string>('')
const closeAlertModal = () => {
  alertModal.value = false
}
const view = (order: OrderType) => {
  orderItemsForModal.value = order
  showOrderDetailModal.value = true
}

const handleAction = (data: { action: OrderAction; message: string; orderId: number }) => {
  confirm.value.show = true
  confirm.value.id = data.orderId
  confirm.value.message = data.message
  confirm.value.action = data.action
}
const action = async () => {
  router.post(
    `/dashboard/order/${confirm.value.action}`,
    {
      orderId: confirm.value.id,
    },
    {
      preserveScroll: true,
      onSuccess: () => {
        confirm.value.show = false
        alertModal.value = true
        modalMessage.value = `Action sur la commande ${confirm.value.id} effectuée avec succès`
        modalType.value = PopupType.SUCCESS
        setTimeout(() => {
          alertModal.value = false
        }, 1400)
      },
      onError: () => {
        alertModal.value = true
        modalMessage.value = 'Une erreur est survenue, veuillez réessayer'
        modalType.value = PopupType.ERROR

        setTimeout(() => {
          alertModal.value = false
        }, 1400)
      },
      onFinish: () => {
        confirm.value.action = OrderAction.NONE
      },
    }
  )
}

/*
Modal logic
 */

const confirm = ref<{
  id: number
  message: string
  action: OrderAction
  show: boolean
}>({
  id: 0,
  message: '',
  action: OrderAction.CANCEL,
  show: false,
})

const closeConfirmPopup = () => {
  confirm.value.show = false
}

// End ------------------
</script>
