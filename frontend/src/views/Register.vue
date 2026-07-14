<template>
  <div class="register-container fluid-container">
    <!-- 艺术体单词荧光花纹背景 -->
    <div class="art-word-pattern pattern-1">Vocabulary</div>
    <div class="art-word-pattern pattern-2">Epiphany</div>
    <div class="art-word-pattern pattern-3">Serendipity</div>
    <div class="art-word-pattern pattern-4">Eloquence</div>
    <div class="art-word-pattern pattern-5">Paradigm</div>

    <el-card class="box-card glass-card">
      <template #header>
        <div class="card-header">
          <span class="neon-text title">{{ isLogin ? 'SYSTEM LOGIN' : 'SYSTEM REGISTER' }}</span>
        </div>
      </template>
      <el-form :model="form" :rules="rules" ref="formRef" label-width="80px" class="glass-form" label-position="top">
        <el-form-item label="NICKNAME / 昵称" prop="username">
          <el-input v-model="form.username" placeholder="Enter your nickname"></el-input>
        </el-form-item>
        <el-form-item label="PASSWORD / 密码" prop="password">
          <el-input v-model="form.password" type="password" placeholder="Enter your password"></el-input>
        </el-form-item>
        
        <el-form-item class="action-group">
          <el-button type="primary" class="glow-btn" @click="submitForm">{{ isLogin ? 'ACCESS' : 'INITIALIZE' }}</el-button>
          <el-button @click="toggleMode" class="switch-btn">{{ isLogin ? 'Create Account' : 'Return to Login' }}</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'

const router = useRouter()
const isLogin = ref(true)
const formRef = ref(null)

const form = reactive({
  username: '',
  password: ''
})

const rules = reactive({
  username: [{ required: true, message: '请输入昵称', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
})

const toggleMode = () => {
  isLogin.value = !isLogin.value
  if (formRef.value) {
    formRef.value.resetFields()
  }
}

const submitForm = () => {
  if (!formRef.value) return
  formRef.value.validate((valid) => {
    if (valid) {
      if (isLogin.value) {
        ElMessage.success('登录成功！')
        localStorage.setItem('isLoggedIn', 'true')
        router.push('/recitation')
      } else {
        ElMessage.success('注册成功，请登录！')
        isLogin.value = true
      }
    } else {
      return false
    }
  })
}
</script>

<style scoped>
.register-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  position: relative;
  overflow: hidden;
}

/* 艺术体单词荧光花纹样式 */
.art-word-pattern {
  position: absolute;
  font-family: 'Comic Sans MS', cursive, 'Brush Script MT', 'Dancing Script', sans-serif;
  font-size: 6rem;
  font-weight: 900;
  opacity: 0.15;
  white-space: nowrap;
  pointer-events: none;
  z-index: 0;
  transform: rotate(-15deg);
  user-select: none;
}

.pattern-1 {
  top: 10%;
  left: -5%;
  color: var(--neon-cyan);
  text-shadow: 0 0 30px var(--neon-cyan);
}

.pattern-2 {
  bottom: 15%;
  right: -5%;
  color: var(--neon-purple);
  text-shadow: 0 0 30px var(--neon-purple);
  transform: rotate(10deg);
  font-size: 8rem;
}

.pattern-3 {
  top: 40%;
  right: -10%;
  color: #00ff80;
  text-shadow: 0 0 30px #00ff80;
  transform: rotate(-25deg);
  font-size: 5rem;
}

.pattern-4 {
  bottom: 5%;
  left: 10%;
  color: #ffd04b;
  text-shadow: 0 0 30px #ffd04b;
  transform: rotate(15deg);
  font-size: 4rem;
}

.pattern-5 {
  top: 5%;
  right: 20%;
  color: #ff0055;
  text-shadow: 0 0 30px #ff0055;
  transform: rotate(5deg);
  font-size: 3rem;
}

.box-card {
  width: 100%;
  max-width: 480px;
  padding: 20px;
  z-index: 10; /* 确保表单在花纹之上 */
}
.card-header {
  text-align: center;
}
.title {
  font-size: 1.8rem;
  font-weight: 800;
  letter-spacing: 2px;
}
.glass-form :deep(.el-form-item__label) {
  color: var(--text-secondary);
  font-size: 0.9rem;
  font-weight: bold;
  letter-spacing: 1px;
}
.action-group {
  margin-top: 40px;
}
.glow-btn {
  width: 100%;
  margin-bottom: 15px;
  font-weight: bold;
  letter-spacing: 2px;
}
.switch-btn {
  width: 100%;
  margin-left: 0 !important;
  border-color: transparent !important;
  background: transparent !important;
  color: var(--neon-cyan) !important;
}
.switch-btn:hover {
  text-shadow: 0 0 10px var(--neon-cyan-dim);
}
</style>
