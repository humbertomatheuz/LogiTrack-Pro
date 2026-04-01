<template>
  <div class="layout-wrapper">

    <!-- ═══════════════ NAVBAR ═══════════════ -->
    <nav class="logi-navbar" role="navigation" aria-label="Navegação principal">
      <!-- Brand -->
      <div class="nav-brand">
        <span class="material-symbols-outlined brand-icon" aria-hidden="true">local_shipping</span>
        <span class="brand-text">LogiTrack<span class="brand-accent">Pro</span></span>
      </div>

      <!-- Nav Links -->
      <ul class="nav-links" role="list">
        <li>
          <router-link to="/gerenciamento" class="nav-link" active-class="nav-link--active">
            Gerenciamento
          </router-link>
        </li>
        <li v-if="authStore.isAdmin">
          <router-link to="/dashboard" class="nav-link" active-class="nav-link--active">
            Dashboard
          </router-link>
        </li>
      </ul>

      <!-- Right: user + logout -->
      <div class="nav-actions">
        <div class="nav-user-pill">
          <span class="material-symbols-outlined user-avatar-icon" aria-hidden="true">account_circle</span>
          <span class="user-name">{{ authStore.nome || 'Usuário' }}</span>
        </div>
        <button class="logout-btn" @click="authStore.logout()" aria-label="Encerrar sessão">
          <span class="material-symbols-outlined" aria-hidden="true">logout</span>
          Logout
        </button>
      </div>
    </nav>

    <!-- ═══════════════ PAGE CONTENT ═══════════════ -->
    <main class="layout-content">
      <RouterView />
    </main>

  </div>
</template>

<script setup>
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
</script>

<style scoped>
/* ══════════════════════════════════════════
   LAYOUT BASE
══════════════════════════════════════════ */
.layout-wrapper {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: #f0f2f8;
  font-family: 'Inter', 'Manrope', sans-serif;
}

.layout-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

/* ══════════════════════════════════════════
   NAVBAR
══════════════════════════════════════════ */
.logi-navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #ffffff;
  border-bottom: 1px solid rgba(0, 0, 0, 0.07);
  padding: 0 1.75rem;
  height: 58px;
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.06);
  position: sticky;
  top: 0;
  z-index: 100;
}

/* Brand */
.nav-brand {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 160px;
  text-decoration: none;
}
.brand-icon {
  color: #1A237E;
  font-size: 1.4rem;
  font-variation-settings: 'FILL' 1;
}
.brand-text {
  font-size: 1rem;
  font-weight: 800;
  color: #1a1a2e;
  letter-spacing: -0.01em;
  font-family: 'Manrope', sans-serif;
}
.brand-accent {
  color: #1A237E;
}

/* Nav links */
.nav-links {
  display: flex;
  gap: 0.25rem;
  list-style: none;
  margin: 0;
  padding: 0;
}
.nav-link {
  position: relative;
  display: inline-block;
  padding: 0.375rem 0.875rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: #555;
  text-decoration: none;
  border-radius: 8px;
  transition: color 0.2s, background 0.2s;
}
.nav-link:hover {
  color: #1A237E;
  background: rgba(26, 35, 126, 0.06);
}
.nav-link--active {
  color: #1A237E;
  font-weight: 700;
}
.nav-link--active::after {
  content: '';
  position: absolute;
  bottom: -10px;
  left: 0.875rem;
  right: 0.875rem;
  height: 3px;
  border-radius: 2px 2px 0 0;
  background: #1A237E;
}

/* Right actions */
.nav-actions {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  min-width: 180px;
  justify-content: flex-end;
}
.nav-user-pill {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.25rem 0.75rem;
  background: rgba(26, 35, 126, 0.06);
  border-radius: 999px;
  font-size: 0.8rem;
  font-weight: 600;
  color: #1A237E;
}
.user-avatar-icon {
  font-size: 1.2rem;
}
.user-name {
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.logout-btn {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  background: none;
  border: none;
  padding: 0.375rem 0.5rem;
  font-size: 0.8rem;
  font-weight: 500;
  color: #6b7280;
  cursor: pointer;
  border-radius: 6px;
  transition: color 0.2s, background 0.2s;
}
.logout-btn .material-symbols-outlined {
  font-size: 1rem;
}
.logout-btn:hover {
  color: #dc2626;
  background: rgba(220, 38, 38, 0.06);
}

/* ══════════════════════════════════════════
   PAGE TRANSITION
══════════════════════════════════════════ */
.page-enter-active,
.page-leave-active {
  transition: opacity 0.18s ease, transform 0.18s ease;
}
.page-enter-from {
  opacity: 0;
  transform: translateY(8px);
}
.page-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

/* ══════════════════════════════════════════
   RESPONSIVIDADE (MOBILE)
══════════════════════════════════════════ */
@media (max-width: 768px) {
  .logi-navbar {
    padding: 0 0.75rem;
    height: 52px;
  }
  
  .nav-brand {
    min-width: fit-content;
  }
  
  .brand-text {
    font-size: 0.9rem;
  }

  .nav-links {
    gap: 0;
  }
  
  .nav-link {
    padding: 0.25rem 0.6rem;
    font-size: 0.8rem;
  }
  
  .nav-actions {
    min-width: fit-content;
    gap: 0.5rem;
  }
  
  .nav-user-pill {
    padding: 0.25rem 0.5rem;
  }
  
  .user-name {
    display: none; /* Esconde nome no mobile */
  }
  
  .logout-btn {
    padding: 0.25rem;
    font-size: 0.75rem;
  }
  
  .logout-btn .material-symbols-outlined {
    font-size: 1.1rem;
  }
}

@media (max-width: 480px) {
  .brand-text {
    display: none; /* Esconde texto da marca em telas minúsculas */
  }
  
  .nav-links {
    flex: 1;
    justify-content: center;
  }
}
</style>
