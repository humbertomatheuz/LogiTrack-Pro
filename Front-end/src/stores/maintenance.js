import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '../services/api'

export const useMaintenanceStore = defineStore('maintenance', () => {
  const manutencoes = ref([])
  const veiculos = ref([])
  const loading = ref(false)
  const loadingVeiculos = ref(false)
  const error = ref(null)

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

  return {
    manutencoes,
    veiculos,
    loading,
    loadingVeiculos,
    error,
    fetchManutencoes,
    createManutencao,
    updateManutencao,
    deleteManutencao,
    fetchVeiculos,
  }
})
