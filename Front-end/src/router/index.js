import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import LoginView from '../views/LoginView.vue'

import MainLayout from '../layouts/MainLayout.vue'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: LoginView,
    meta: { requiresGuest: true }
  },
  {
    path: '/',
    component: MainLayout,
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        redirect: '/gerenciamento'
      },
      {
        path: 'dashboard',
        component: () => import('../views/DashboardView.vue'),
        meta: { requiresAdmin: true },
        children: [
          {
            path: '',
            redirect: '/dashboard/dados-frota'
          },
          {
            path: 'dados-frota',
            name: 'DashboardFrota',
            component: () => import('../views/dashboard/DadosFrota.vue')
          },
          {
            path: 'volume-categoria',
            name: 'DashboardVolumeCategoria',
            component: () => import('../views/dashboard/VolumeCategoria.vue')
          },
          {
            path: 'projecao-financeira',
            name: 'DashboardProjecaoFinanceira',
            component: () => import('../views/dashboard/ProjecaoFinanceira.vue')
          }
        ]
      },
      {
        path: 'gerenciamento',
        name: 'Gerenciamento',
        component: () => import('../views/GerenciamentoView.vue')
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Guard de rotas: verifica autenticação e expiração do token
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()

  if (to.meta.requiresAuth) {
      if (!authStore.isAuthenticated) {
        next({ name: 'Login' })
      } else if (to.matched.some(record => record.meta.requiresAdmin) && !authStore.isAdmin) {
        next({ name: 'Gerenciamento' })
      } else {
        next()
      }
  } else if (to.meta.requiresGuest) {
    if (authStore.isAuthenticated) {
      next({ name: 'Gerenciamento' })
    } else {
      next()
    }
  } else {
    next()
  }
})

export default router
