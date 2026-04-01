import { defineStore } from 'pinia';

export const useDashboardStore = defineStore('dashboard', {
  state: () => ({
    activeTab: 'km-percorrido',
    globalFilters: {
      period: 'last-7-days',
      // Outros filtros globais podem ser adicionados aqui
    }
  }),
  actions: {
    setActiveTab(tabName) {
      this.activeTab = tabName;
    },
    setGlobalFilters(filters) {
      this.globalFilters = { ...this.globalFilters, ...filters };
    }
  }
});
