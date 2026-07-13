<template>
  <div class="app-wrapper">
    <el-header class="sticky-header" v-if="isLoggedIn">
      <el-menu 
        mode="horizontal" 
        class="glass-nav"
        :default-active="$route.path"
        router>
        <div class="brand neon-text">词汇大世界</div>
        <el-menu-item index="/recitation">背单词</el-menu-item>
        <el-menu-item index="/practice">单词练习</el-menu-item>
        <el-menu-item index="/todo">待背库</el-menu-item>
        <el-menu-item index="/errors">错题库</el-menu-item>
        <el-menu-item index="/hard">难度词汇库</el-menu-item>
        <el-menu-item index="/honors">个人荣誉</el-menu-item>
        <el-menu-item index="/profile">个人资料</el-menu-item>
        <div style="flex-grow: 1;"></div>
        <el-menu-item @click="logout" class="logout-btn">退出登录</el-menu-item>
      </el-menu>
    </el-header>
    
    <main class="main-content fluid-container">
      <router-view></router-view>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()

// 根据当前路由判断是否显示导航栏
const isLoggedIn = computed(() => route.path !== '/login')

const logout = () => {
  localStorage.removeItem('isLoggedIn')
  router.push('/login')
}
</script>

<style scoped>
.app-wrapper {
  height: 100vh;
  overflow-y: auto;
  scroll-snap-type: y proximity;
}

.sticky-header {
  position: sticky;
  top: 0;
  z-index: 1000;
  padding: 0;
  height: auto;
}

.glass-nav {
  background: rgba(10, 10, 15, 0.6) !important;
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.05) !important;
  box-shadow: 0 4px 30px rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  padding: 0 20px;
}

.brand {
  font-size: 2.2rem;
  font-weight: 900;
  margin-right: 40px;
  letter-spacing: 3px;
}

.el-menu--horizontal > .el-menu-item {
  color: var(--text-secondary) !important;
  font-weight: 600;
  font-size: 1.25rem;
  border-bottom: 2px solid transparent;
  transition: all 0.3s ease;
  padding: 0 25px;
}

.el-menu--horizontal > .el-menu-item:hover,
.el-menu--horizontal > .el-menu-item.is-active {
  color: #fff !important;
  background-color: transparent !important;
  border-bottom: 2px solid var(--neon-cyan) !important;
  text-shadow: 0 0 10px var(--neon-cyan-dim);
}

.logout-btn {
  color: #ff4d4f !important;
}
.logout-btn:hover {
  border-bottom-color: #ff4d4f !important;
  text-shadow: 0 0 10px rgba(255, 77, 79, 0.4);
}

.main-content {
  scroll-snap-align: start;
  min-height: calc(100vh - 60px);
  display: flex;
  flex-direction: column;
}
</style>

<style>
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}
.app-container {
  height: 100vh;
}
</style>
