import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '../services/api'

export const useMaintenanceStore = defineStore('maintenance', () => {
  const manutencoes = ref([])
  const veiculos = ref([])
  const loading = ref(false)
  const loadingVeiculos = ref(false)
  const error = ref(null)
  
  // ── Cronograma (HU06) - Manutenções pendentes com paginação ─────
  const cronograma = ref([])
  const cronogramaLoading = ref(false)
  const cronogramaError = ref(null)
  const cronogramaPaginaAtual = ref(0)
  const cronogramaItensPorPagina = ref(10)
  const cronogramaTotalElements = ref(0)
  const cronogramaTotalPages = ref(0)
  const cronogramaHasNext = ref(false)

  // ── Manutenções ──────────────────────────────────────────
  async function fetchManutencoes() {
    loading.value = true
    error.value = null
    try {
      const { data } = await api.get('/api/manutencoes')
      manutencoes.value = data
    } catch (err) {
      error.value = err.response?.data?.message || 'Erro ao carregar manutenções.'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function createManutencao(payload) {
    const { data } = await api.post('/api/manutencoes', payload)
    manutencoes.value.unshift(data)
    return data
  }

  async function updateManutencao(id, payload) {
    const { data } = await api.put(`/api/manutencoes/${id}`, payload)
    const idx = manutencoes.value.findIndex(m => m.id === id)
    if (idx !== -1) manutencoes.value[idx] = data
    return data
  }

  async function deleteManutencao(id) {
    await api.delete(`/api/manutencoes/${id}`)
    manutencoes.value = manutencoes.value.filter(m => m.id !== id)
  }

  // ── Veículos (para o select do formulário) ──────────────
  async function fetchVeiculos() {
    loadingVeiculos.value = true
    try {
      const { data } = await api.get('/api/veiculos')
      veiculos.value = data
    } catch {
      veiculos.value = []
    } finally {
      loadingVeiculos.value = false
    }
  }

  // ── Cronograma Paginado (HU06) - Usa endpoint /api/manutencoes/cronograma ──
  // HU06: Carrega primeiras 5 manutenções pendentes
  async function fetchCronograma() {
    cronogramaLoading.value = true
    cronogramaError.value = null
    cronogramaPaginaAtual.value = 0
    cronograma.value = []
    
    try {
      const response = await api.get('/api/manutencoes/cronograma', {
        params: {
          skip: 0, // Começa do item 0
          limit: 5 // Primeira carga com 5 itens
        }
      })
      
      // Response agora é CronogramaPaginadoDTO com structure:
      // { content: [...], totalElements, currentPage, pageSize, totalPages, hasNext }
      const paginatedData = response.data
      cronograma.value = paginatedData.content || []
      cronogramaTotalElements.value = paginatedData.totalElements || 0
      cronogramaTotalPages.value = paginatedData.totalPages || 0
      cronogramaHasNext.value = paginatedData.hasNext || false
      cronogramaPaginaAtual.value = paginatedData.currentPage || 0
    } catch (err) {
      cronogramaError.value = err.response?.data?.message || 'Erro ao carregar cronograma.'
      console.error('Erro fetchCronograma:', err)
    } finally {
      cronogramaLoading.value = false
    }
  }

  // HU06: Carrega mais 10 itens acumulativamente
  async function carregarMaisCronograma() {
    if (cronogramaLoading.value) return
    
    cronogramaLoading.value = true
    cronogramaError.value = null
    
    try {
      // skip = quantidade de itens já carregados (ponto de partida)
      const skip = cronograma.value.length
      const response = await api.get('/api/manutencoes/cronograma', {
        params: {
          skip: skip, // Pula até onde parou
          limit: 10 // Próximas cargas com 10 itens
        }
      })
      
      const paginatedData = response.data
      const novosDados = paginatedData.content || []
      
      // Adiciona apenas se houver dados
      if (Array.isArray(novosDados) && novosDados.length > 0) {
        cronograma.value = cronograma.value.concat(novosDados)
        cronogramaTotalElements.value = paginatedData.totalElements || 0
        cronogramaTotalPages.value = paginatedData.totalPages || 0
        cronogramaHasNext.value = paginatedData.hasNext || false
        cronogramaPaginaAtual.value = paginatedData.currentPage || 0
      }
    } catch (err) {
      cronogramaError.value = err.response?.data?.message || 'Erro ao carregar mais itens.'
      console.error('Erro carregarMaisCronograma:', err)
    } finally {
      cronogramaLoading.value = false
    }
  }

  return {
    manutencoes,
    veiculos,
    loading,
    loadingVeiculos,
    error,
    cronograma,
    cronogramaLoading,
    cronogramaError,
    cronogramaPaginaAtual,
    cronogramaItensPorPagina,
    cronogramaTotalElements,
    cronogramaTotalPages,
    cronogramaHasNext,
    fetchManutencoes,
    createManutencao,
    updateManutencao,
    deleteManutencao,
    fetchVeiculos,
    fetchCronograma,
    carregarMaisCronograma,
  }
})
