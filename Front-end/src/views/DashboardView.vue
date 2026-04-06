<template>
  <div class="dashboard-wrapper container-fluid pt-4">
    <!-- Navegação em Abas (Nav Tabs do Bootstrap 5) -->
    <ul class="nav nav-tabs custom-nav-tabs" role="tablist">
      <li class="nav-item" v-for="tab in tabs" :key="tab.id" role="presentation">
        <router-link
          :to="{ name: tab.routeName }"
          class="nav-link"
          :class="{ active: dashboardStore.activeTab === tab.id }"
          @click="dashboardStore.setActiveTab(tab.id)"
        >
          <span class="material-symbols-outlined me-1 align-middle fs-6">{{ tab.icon }}</span>
          {{ tab.title }}
        </router-link>
      </li>
    </ul>

    <!-- Conteúdo das Abas (Child Routes) -->
    <div class="tab-content dashboard-content shadow-sm">
      <router-view></router-view>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useDashboardStore } from '../stores/dashboard';

const route = useRoute();
const dashboardStore = useDashboardStore();

const globalPeriod = ref(dashboardStore.globalFilters.period);

const tabs = [
  { id: 'dados-frota', title: 'Dados da Frota', routeName: 'DashboardFrota', icon: 'route' },
  { id: 'projecao-financeira', title: 'Dados Financeiros', routeName: 'DashboardProjecaoFinanceira', icon: 'payments' }
];

// Sincronizar store com a rota atual ao carregar ou navegar
const syncTabWithUrl = () => {
  const currentTab = tabs.find(t => route.name === t.routeName);
  if (currentTab) {
    dashboardStore.setActiveTab(currentTab.id);
  }
};

onMounted(syncTabWithUrl);
watch(() => route.name, syncTabWithUrl);

const updateGlobalFilter = () => {
  dashboardStore.setGlobalFilters({ period: globalPeriod.value });
};
</script>

<style scoped>
.dashboard-wrapper {
  padding: 1.5rem;
  max-width: 1400px;
  margin: 0 auto;
}

.dashboard-icon {
  font-size: 2.2rem;
  color: #1A237E;
}

.welcome-title {
  font-family: 'Manrope', sans-serif;
  color: #1a1a2e;
  font-weight: 800;
  font-size: 1.8rem;
}

/* Customização das Nav Tabs do Bootstrap */
.custom-nav-tabs {
  border-bottom: 2px solid #e2e8f0;
  display: flex !important;
  flex-direction: row !important;
  flex-wrap: wrap;
}

.custom-nav-tabs .nav-link {
  white-space: nowrap;
  color: #64748b;
  font-weight: 600;
  border: none;
  border-bottom: 2px solid transparent;
  padding: 0.75rem 1.25rem;
  margin-bottom: -2px;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
}

.custom-nav-tabs .nav-link:hover {
  color: #1A237E;
  border-bottom-color: #cbd5e1;
}

.custom-nav-tabs .nav-link.active {
  color: #1A237E;
  background-color: transparent;
  border-bottom-color: #1A237E;
}

.dashboard-content {
  background: white;
  border-radius: 0 0 12px 12px;
  min-height: 400px;
  border: 1px solid #e2e8f0;
  border-top: none;
}
</style>
