<script setup lang="ts">
withDefaults(
  defineProps<{
    label: string
    type: 'password' | 'email' | 'text'
    id: string
    placeholder: string
    /** `dark` = fond AuthShell sombre ; `light` = pop-in sur fond clair */
    variant?: 'dark' | 'light'
  }>(),
  { variant: 'dark' },
)

const model = defineModel()
</script>

<template>
  <div class="relative group">
    <label
      :for="id"
      :class="[
        'block text-xs font-bold uppercase tracking-widest mb-2 ml-1 transition-colors',
        variant === 'light'
          ? 'text-slate-600 group-focus-within:text-primary'
          : 'text-gray-400 group-focus-within:text-primary',
      ]"
    >
      {{ label }}
    </label>
    <div class="relative">
      <input
        :type="type"
        :name="id"
        :id="id"
        :class="[
          'w-full rounded-2xl px-4 py-3.5 focus:outline-none focus:ring-2 transition-all duration-300 shadow-inner',
          variant === 'light'
            ? 'bg-white border-2 border-slate-200 text-slate-900 placeholder:text-slate-400 focus:ring-primary/30 focus:border-primary/60 focus:bg-white'
            : 'bg-white/5 border border-white/10 text-white placeholder:text-white/20 focus:ring-primary/40 focus:border-primary/50 focus:bg-white/10',
        ]"
        :placeholder="placeholder"
        v-model="model"
        required
      />
      <div
        v-if="variant === 'dark'"
        class="absolute inset-0 rounded-2xl bg-primary/5 opacity-0 group-focus-within:opacity-100 pointer-events-none transition-opacity duration-500"
      />
    </div>
  </div>
</template>

<style scoped></style>
