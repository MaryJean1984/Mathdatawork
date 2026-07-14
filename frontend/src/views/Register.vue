<template>
  <div class="register-container fluid-container">
    <el-card class="box-card glass-card">
      <template #header>
        <div class="card-header">
          <span class="neon-text title">{{ isLogin ? 'SYSTEM LOGIN' : 'SYSTEM REGISTER' }}</span>
        </div>
      </template>
      <el-form :model="form" :rules="rules" ref="formRef" label-width="80px" class="glass-form" label-position="top">
        <el-form-item label="PHONE / 电话" prop="phone">
          <el-input v-model="form.phone" placeholder="Enter your phone number"></el-input>
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
  phone: '',
  password: ''
})

const rules = reactive({
  phone: [
    { required: true, message: '请输入电话号码', trigger: 'blur' },
    { pattern: /^\d{11}$/, message: '请输入有效的11位电话号码', trigger: 'blur' }
  ],
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
}
.box-card {
  width: 100%;
  max-width: 480px;
  padding: 20px;
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
