<template>
  <div class="dashboard-wrapper">
    <div class="welcome-card">
      <span class="material-symbols-outlined dashboard-icon">dashboard</span>
      <h1 class="welcome-title">Dashboard</h1>
      <p class="welcome-sub">Visão geral do sistema em breve. Utilize o menu de Gerenciamento para operações.</p>
    </div>
  </div>
</template>

<script setup>
</script>

<style scoped>
.dashboard-wrapper {
  padding: 2rem;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  min-height: calc(100vh - 58px);
}

.welcome-card {
  background: white;
  border-radius: 12px;
  padding: 2.5rem;
  text-align: center;
  box-shadow: 0 4px 16px rgba(0,0,0,0.05);
  max-width: 500px;
  width: 100%;
  margin-top: 2rem;
}

.dashboard-icon {
  font-size: 3rem;
  color: #1A237E;
  margin-bottom: 1rem;
}

.welcome-title {
  font-family: 'Manrope', sans-serif;
  color: #1a1a2e;
  font-weight: 800;
  margin: 0 0 0.5rem;
}

.welcome-sub {
  color: #6b7280;
  font-size: 0.95rem;
  line-height: 1.5;
  margin: 0;
}
</style>
