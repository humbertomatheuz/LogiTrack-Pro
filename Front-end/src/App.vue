<script setup>
import { onMounted, onUnmounted } from 'vue'

const KEEP_ALIVE_INTERVAL = 5 * 60 * 1000
let intervalId = null

const keepAlive = async () => {
  const now = new Date()
  const hour = now.getHours()

  if (hour < 7 || hour >= 22) return

  const apiURL = import.meta.env.VITE_API_URL || ''
  fetch(apiURL, { mode: 'no-cors' }).catch(() => {})
}

onMounted(() => {
  keepAlive()
  
  intervalId = setInterval(keepAlive, KEEP_ALIVE_INTERVAL)
})

onUnmounted(() => {
  if (intervalId) clearInterval(intervalId)
})
</script>

<template>
  <RouterView />
</template>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
</style>
