import { computed } from 'vue'
import { usePage } from '@inertiajs/vue3'

interface User {
  id: number
  fullName: string
  email: string
  phone?: string
  role: string
}

export function useAuth() {
  const page = usePage()
  
  const user = computed(() => {
    const authUser = (page.props as any).auth?.user
    if (!authUser) return undefined
    
    return {
      id: authUser.id,
      fullName: authUser.fullName || authUser.fullname,
      email: authUser.email,
      phone: authUser.phone,
      role: authUser.role,
    } as User
  })
  
  const isAuthenticated = computed(() => !!user.value)
  
  const userRole = computed(() => user.value?.role)
  
  const isAdmin = computed(() => userRole.value === 'admin')
  
  const isSeller = computed(() => userRole.value === 'seller')
  
  const isCustomer = computed(() => !userRole.value || userRole.value === 'customer')
  
  return {
    user,
    isAuthenticated,
    userRole,
    isAdmin,
    isSeller,
    isCustomer,
  }
}
