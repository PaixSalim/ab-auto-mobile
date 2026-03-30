export enum OrderStatus {
  PROCESSING = 'En cours',
  CANCELLED = 'Annulée',
  DELIVERED = 'Livrée',
}

export enum OrderAction {
  VERIFY = 'verify',
  CANCEL = 'cancel',
  DELETE = 'delete',
  DELIVERED = 'delivered',
  NONE = '/',
}

// Traductions pour chaque action
export const orderActionTranslations = {
  [OrderAction.VERIFY]: { fr: 'Vérifier', en: 'verify' },
  [OrderAction.CANCEL]: { fr: 'Annuler', en: 'cancel' },
  [OrderAction.DELETE]: { fr: 'Supprimer', en: 'delete' },
  [OrderAction.DELIVERED]: { fr: 'Livré', en: 'delivered' },
  [OrderAction.NONE]: { fr: '', en: '' },
}
// Fonction pour obtenir la traduction selon la langue
export const getActionTranslation = (action: OrderAction, lang: 'en' | 'fr'): string => {
  return orderActionTranslations[action][lang]
}

export enum PaymentStatus {
  COMPLETED = 'completed',
  FAILED = 'failed',
  PENDING = 'pending',
}
