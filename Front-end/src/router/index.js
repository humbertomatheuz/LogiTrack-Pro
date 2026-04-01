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
        children: [
          {
            path: '',
            redirect: '/dashboard/km-percorrido'
          },
          {
            path: 'km-percorrido',
            name: 'DashboardKmPercorrido',
            component: () => import('../views/dashboard/KmPercorrido.vue')
          },
          {
            path: 'volume-categoria',
            name: 'DashboardVolumeCategoria',
            component: () => import('../views/dashboard/VolumeCategoria.vue')
          },
          {
            path: 'cronograma-manutencao',
            name: 'DashboardCronogramaManutencao',
            component: () => import('../views/dashboard/CronogramaManutencao.vue')
          },
          {
            path: 'ranking-utilizacao',
            name: 'DashboardRankingUtilizacao',
            component: () => import('../views/dashboard/RankingUtilizacao.vue')
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
      // Token expirado ou ausente: redireciona para login
      next({ name: 'Login' })
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
