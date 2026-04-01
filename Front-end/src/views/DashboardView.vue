<template>
  <div class="app-wrapper">
    <!-- ===== NAVBAR ===== -->
    <nav class="logi-navbar">
      <!-- Brand -->
      <div class="nav-brand">
        <span class="brand-text">LogiTrack Pro</span>
      </div>

      <!-- Nav Links -->
      <ul class="nav-links">
        <li>
          <router-link to="/gerenciamento" class="nav-link" active-class="nav-link--active">
            Gerenciamento
          </router-link>
        </li>
        <li>
          <router-link to="/dashboard" class="nav-link" active-class="nav-link--active">
            Dashboard
          </router-link>
        </li>
      </ul>

      <!-- Right side: user icon + logout -->
      <div class="nav-actions">
        <span class="material-symbols-outlined user-icon">account_circle</span>
        <button class="logout-btn" @click="authStore.logout()">
          Logout
        </button>
      </div>
    </nav>

    <!-- ===== PAGE CONTENT ===== -->
    <main class="dashboard-content">
      <div class="text-center">
        <span class="material-symbols-outlined" style="font-size: 4rem; color: #000666;">dashboard</span>
        <h1 class="mt-3" style="font-family: 'Manrope', sans-serif; color: #000666;">Dashboard</h1>
        <p class="text-muted">Bem-vindo, {{ authStore.nome }}!</p>
        <span class="badge" :class="authStore.isAdmin ? 'bg-primary' : 'bg-secondary'">
          {{ authStore.perfil }}
        </span>
      </div>
    </main>
  </div>
</template>

<script setup>
import { useAuthStore } from '../stores/auth'
const authStore = useAuthStore()
</script>

<style scoped>
/* ---------- Layout ---------- */
.app-wrapper {
  min-height: 100vh;
  background-color: #f5f5f5;
  font-family: 'Manrope', sans-serif;
}

/* ---------- Navbar ---------- */
.logi-navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: #ffffff;
  border-bottom: 1px solid #e0e0e0;
  padding: 0 1.5rem;
  height: 56px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

/* Brand */
.nav-brand {
  display: flex;
  align-items: center;
  min-width: 160px;
}

.brand-text {
  font-size: 1rem;
  font-weight: 700;
  color: #1a1a2e;
  letter-spacing: 0.02em;
}

/* Nav Links */
.nav-links {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  list-style: none;
  margin: 0;
  padding: 0;
}

.nav-link {
  position: relative;
  display: inline-block;
  padding: 0.25rem 0.75rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: #555;
  text-decoration: none;
  transition: color 0.2s;
}

.nav-link:hover {
  color: #000666;
}

/* Active underline — matches screenshot style */
.nav-link--active {
  color: #000666;
  font-weight: 700;
}

.nav-link--active::after {
  content: '';
  position: absolute;
  bottom: -6px;
  left: 0.75rem;
  right: 0.75rem;
  height: 3px;
  border-radius: 2px 2px 0 0;
  background-color: #000666;
}

/* Right Actions */
.nav-actions {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  min-width: 160px;
  justify-content: flex-end;
}

.user-icon {
  font-size: 1.6rem;
  color: #555;
  cursor: default;
}

.logout-btn {
  background: none;
  border: none;
  padding: 0;
  font-size: 0.875rem;
  font-weight: 500;
  color: #555;
  cursor: pointer;
  transition: color 0.2s;
}

.logout-btn:hover {
  color: #c0392b;
}

/* ---------- Content ---------- */
.dashboard-content {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 56px);
}

.text-center {
  text-align: center;
}

.mt-3 { margin-top: 1rem; }

.text-muted { color: #6c757d; }

.badge {
  display: inline-block;
  padding: 0.35em 0.65em;
  font-size: 0.75em;
  font-weight: 600;
  line-height: 1;
  border-radius: 0.35rem;
  color: #fff;
}

.bg-primary { background-color: #0d6efd; }
.bg-secondary { background-color: #6c757d; }
</style>
