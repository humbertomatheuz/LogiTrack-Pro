import { defineStore } from 'pinia';
import api from '../services/api'

export const useProjecaoFinanceiraStore = defineStore('projecaoFinanceira', {
  state: () => ({
    filtros: {
      dataInicio: null,
      dataFim: null
    },
    dados: null,
    carregando: false,
    erro: null
  }),

  actions: {
    // Inicializa com datas do mês atual
    inicializarFiltrosMesAtual() {
      const agora = new Date();
      const mesAtual = agora.getMonth(); 
      const anoAtual = agora.getFullYear();
      
      // Primeiro dia do mês
      const primeiroDia = new Date(anoAtual, mesAtual, 1);
      // Último dia do mês
      const ultimoDia = new Date(anoAtual, mesAtual + 1, 0);
      
      this.filtros.dataInicio = this.formatarDataParaInput(primeiroDia);
      this.filtros.dataFim = this.formatarDataParaInput(ultimoDia);
    },

    formatarDataParaInput(data) {
      const ano = data.getFullYear();
      const mes = String(data.getMonth() + 1).padStart(2, '0');
      const dia = String(data.getDate()).padStart(2, '0');
      return `${ano}-${mes}-${dia}`;
    },

    async fetchProjecaoFinanceira(dataInicio, dataFim) {
      this.carregando = true;
      this.erro = null;
      
      try {
        const response = await api.get('/api/dashboard/projecao-financeira', {
          params: {
            dataInicio,
            dataFim
          }
        });

        this.dados = response.data;
      } catch (error) {
        this.erro = error.response?.data?.message || 'Erro ao carregar projeção financeira';
        this.dados = null;
      } finally {
        this.carregando = false;
      }
    },

    setFiltros(dataInicio, dataFim) {
      this.filtros.dataInicio = dataInicio;
      this.filtros.dataFim = dataFim;
    }
  },

  getters: {
    isDadosVazio: (state) => {
      return !state.dados || !state.dados.categorias || state.dados.categorias.length === 0;
    }
  }
});
