import { createRouter, createWebHistory } from 'vue-router'
import Register from '../views/Register.vue'
import WordRecitation from '../views/WordRecitation.vue'
import WordPractice from '../views/WordPractice.vue'
import ToBeMemorizedLibrary from '../views/ToBeMemorizedLibrary.vue'
import ErrorLibrary from '../views/ErrorLibrary.vue'
import HardWordLibrary from '../views/HardWordLibrary.vue'
import Profile from '../views/Profile.vue'
import Honors from '../views/Honors.vue'

const routes = [
  { path: '/login', component: Register },
  { path: '/', redirect: '/recitation' },
  { path: '/recitation', component: WordRecitation },
  { path: '/practice', component: WordPractice },
  { path: '/todo', component: ToBeMemorizedLibrary },
  { path: '/errors', component: ErrorLibrary },
  { path: '/hard', component: HardWordLibrary },
  { path: '/profile', component: Profile },
  { path: '/honors', component: Honors }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 登录拦截逻辑
router.beforeEach((to, from, next) => {
  const isLoggedIn = localStorage.getItem('isLoggedIn')
  if (to.path !== '/login' && !isLoggedIn) {
    next('/login')
  } else if (to.path === '/login' && isLoggedIn) {
    next('/recitation') // 如果已经登录，不允许重复访问登录页
  } else {
    next()
  }
})

export default router
