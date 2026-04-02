<script setup>
import { onMounted, onUnmounted } from 'vue'

const KEEP_ALIVE_INTERVAL = 5 * 60 * 1000 // 10 minutos
let intervalId = null

const keepAlive = async () => {
  try {
    const apiURL = import.meta.env.VITE_API_URL || ''
    await fetch(apiURL, { mode: 'no-cors' })
    console.debug('Keep-alive ping enviado com sucesso.')
  } catch (error) {
  }
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
