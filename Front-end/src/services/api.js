import axios from 'axios'

const api = axios.create({
  baseURL: 'http://localhost:8080',
  headers: {
    'Content-Type': 'application/json'
  }
})

// Interceptor de requisição: anexa o token JWT em todas as chamadas
api.interceptors.request.use(
  (config) => {
    // Importação dinâmica para evitar circular dependency
    const token = localStorage.getItem('logi_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Interceptor de resposta: monitora cabeçalho de novo token (sliding expiration)
api.interceptors.response.use(
  (response) => {
    const newToken = response.headers['x-new-token'] || response.headers['authorization']
    if (newToken) {
      const cleanToken = newToken.startsWith('Bearer ') ? newToken.substring(7) : newToken
      // Atualiza a store dinamicamente
      import('../stores/auth').then(({ useAuthStore }) => {
        const authStore = useAuthStore()
        authStore.refreshToken(cleanToken)
      })
    }
    return response
  },
  (error) => {
    if (error.response?.status === 401) {
      import('../stores/auth').then(({ useAuthStore }) => {
        const authStore = useAuthStore()
        authStore.logout()
      })
    }
    return Promise.reject(error)
  }
)

export default api
