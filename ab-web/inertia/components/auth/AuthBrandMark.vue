<template>
  <div class="flex flex-col items-center gap-3 select-none">
    <!-- Logo vectoriel local = affichage instantané (pas de CDN) -->
    <svg
      class="h-14 w-14 text-[#BE1622] drop-shadow-[0_0_24px_rgba(190,22,34,0.35)]"
      viewBox="0 0 64 64"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
    >
      <rect x="4" y="4" width="56" height="56" rx="14" class="fill-white/5 stroke-white/10" stroke-width="1" />
      <path
        d="M14 38h6l3-10h18l3 10h6M20 38v4M44 38v4M23 28h18"
        stroke="currentColor"
        stroke-width="2.2"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
      <circle cx="22" cy="42" r="3.5" class="fill-white/80" />
      <circle cx="42" cy="42" r="3.5" class="fill-white/80" />
    </svg>
    <div class="text-center">
      <p class="text-lg font-black tracking-tight text-white">AB AUTO</p>
      <p class="text-[11px] uppercase tracking-[0.25em] text-white/45 font-medium">
        Pièces &amp; accessoires
      </p>
    </div>
  </div>
</template>
