import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import axios from 'axios'
import router from '../router'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('logi_token') || null)
  const nome = ref(localStorage.getItem('logi_nome') || null)
  const perfil = ref(localStorage.getItem('logi_perfil') || null)
  const expiresAt = ref(parseInt(localStorage.getItem('logi_expires_at')) || null)

  const isAuthenticated = computed(() => {
    if (!token.value || !expiresAt.value) return false
    return Date.now() < expiresAt.value
  })

  const isAdmin = computed(() => perfil.value === 'ADMIN')

  function setSession(data) {
    token.value = data.token
    nome.value = data.nome
    perfil.value = data.perfil
    expiresAt.value = Date.now() + 5 * 60 * 1000 // 5 minutos

    localStorage.setItem('logi_token', data.token)
    localStorage.setItem('logi_nome', data.nome)
    localStorage.setItem('logi_perfil', data.perfil)
    localStorage.setItem('logi_expires_at', expiresAt.value.toString())
  }

  function refreshToken(newToken) {
    token.value = newToken
    expiresAt.value = Date.now() + 5 * 60 * 1000
    localStorage.setItem('logi_token', newToken)
    localStorage.setItem('logi_expires_at', expiresAt.value.toString())
  }

  function logout() {
    token.value = null
    nome.value = null
    perfil.value = null
    expiresAt.value = null
    localStorage.removeItem('logi_token')
    localStorage.removeItem('logi_nome')
    localStorage.removeItem('logi_perfil')
    localStorage.removeItem('logi_expires_at')
    router.push('/login')
  }

  async function login(loginData) {
    const response = await axios.post('/api/auth/login', loginData)
    setSession(response.data)
    return response.data
  }

  return { token, nome, perfil, isAuthenticated, isAdmin, login, logout, refreshToken, setSession }
})
