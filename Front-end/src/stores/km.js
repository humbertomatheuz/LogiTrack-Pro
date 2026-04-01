import { defineStore } from 'pinia'
import api from '../services/api'

export const useKmStore = defineStore('km', {
  state: () => ({
    loading: false,
    filters: {
      veiculoId: '',
      tipo: '',
      dataInicio: '',
      dataFim: ''
    },
    veiculos: [],
    totalElementos: 0,
    paginaAtual: 1,
    itemsPorPagina: 10,
    kmTotalFrota: 0,
    kmFiltradoResult: 0
  }),
  getters: {
    kmFiltrado(state) {
      return state.kmFiltradoResult;
    }
  },
  actions: {
    async fetchResumo() {
      this.loading = true;
      try {
        const params = {
          veiculoId: this.filters.veiculoId || undefined,
          tipo: this.filters.tipo || undefined,
          dataInicio: this.filters.dataInicio || undefined,
          dataFim: this.filters.dataFim || undefined,
          page: this.paginaAtual - 1,
          size: this.itemsPorPagina,
          sortCol: 'kmTotal',
          sortDir: 'DESC'
        };

        const { data } = await api.get('/api/km-percorrido/resumo', { params });
        this.veiculos = data.grid.content || [];
        this.totalElementos = data.grid.totalElements || 0;
        this.kmTotalFrota = data.kmTotalFrota || 0;
        this.kmFiltradoResult = data.kmFiltrado || 0;
      } catch (err) {
        console.error('Erro ao processar resumo KM:', err);
      } finally {
        this.loading = false;
      }
    },
    async setPagina(pagina) {
      this.paginaAtual = pagina;
      await this.fetchResumo();
    },
    async aplicarFiltros() {
      this.paginaAtual = 1; // Reseta para a primeira página ao filtrar
      await this.fetchResumo();
    }
  }
})
