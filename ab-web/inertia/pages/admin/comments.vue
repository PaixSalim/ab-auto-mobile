<template>
  <Layout class="text-white">
    <CommentsManager/>
  </Layout>
</template>

<script setup lang="ts">
import Layout from '~/components/admin/Layout.vue'
import CommentsManager from '~/components/admin/comments/CommentsManager.vue'
import { CommentResponse } from '#dto/comments_interface'
import { usePoll } from '@inertiajs/vue3'

defineProps<{
  comments?: CommentResponse[]
  products?: any
}>()

usePoll(1000)

</script>
