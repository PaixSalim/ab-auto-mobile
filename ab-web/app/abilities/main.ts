/*
|--------------------------------------------------------------------------
| Bouncer abilities
|--------------------------------------------------------------------------
|
| You may export multiple abilities from this file and pre-register them
| when creating the Bouncer instance.
|
| Pre-registered policies and abilities can be referenced as a string by their
| name. Also they are must if want to perform authorization inside Edge
| templates.
|
*/

import User from '#models/user'
import { Bouncer } from '@adonisjs/bouncer'

export const isAdmin = Bouncer.ability(async (user: User) => {
  return await user.isAdmin()
})

export const isSuperAdmin = Bouncer.ability(async (user: User) => {
  return await user.isSuperAdmin()
})

export const isSeller = Bouncer.ability(async (user: User) => {
  return (await user.isSeller()) || (await user.isAdmin())
})

/**
 * Capacité générique basée sur les permissions en base de données
 */
export const can = Bouncer.ability(async (user: User, permissionSlug: string) => {
  if (await user.isAdmin()) {
    return true
  }
  return await user.hasPermission(permissionSlug)
})

export const isOwner = Bouncer.ability(async (user: User, resource: { sellerId: number }) => {
  return user.id === resource.sellerId || (await user.isAdmin())
})

// Abilities pour les commentaires (admin et superadmin)
export const canViewComments = Bouncer.ability(async (user: User) => {
  return await user.isAdmin() // Inclut maintenant admin et superadmin
})

export const canManageComments = Bouncer.ability(async (user: User) => {
  return await user.isAdmin() // Inclut maintenant admin et superadmin
})

export const canDeleteComments = Bouncer.ability(async (user: User) => {
  return await user.isAdmin() // Inclut maintenant admin et superadmin
})