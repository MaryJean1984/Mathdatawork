import { createRouter, createWebHistory } from 'vue-router'
import Register from '../views/Register.vue'

const routes = [
  {
    path: '/',
    name: 'Register',
    component: Register
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('../views/Profile.vue')
  },
  {
    path: '/admin',
    name: 'Admin',
    component: () => import('../views/Admin.vue')
  },
  {
    path: '/word-recitation',
    name: 'WordRecitation',
    component: () => import('../views/WordRecitation.vue')
  },
  {
    path: '/ai-dictation',
    name: 'AIDictation',
    component: () => import('../views/AIDictation.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
