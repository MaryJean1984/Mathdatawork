<template>
  <div class="profile-container fluid-container">
    <el-card class="box-card glass-card">
      <template #header>
        <div class="card-header">
          <span class="neon-text title">USER PROFILE</span>
        </div>
      </template>
      <el-form :model="profileForm" label-width="120px" class="glass-form" label-position="top">
        <el-form-item label="NICKNAME / 昵称">
          <el-input v-model="profileForm.nickname"></el-input>
        </el-form-item>
        <el-form-item label="AGE / 年龄">
          <el-input-number v-model="profileForm.age" :min="1" :max="120"></el-input-number>
        </el-form-item>
        <el-form-item label="BIO / 个人简介">
          <el-input v-model="profileForm.bio" type="textarea" rows="4"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" class="glow-btn" @click="saveProfile">SAVE CHANGES</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { reactive } from 'vue'
import { ElMessage } from 'element-plus'

const profileForm = reactive({
  nickname: 'TestUser',
  bio: '我爱学习，学习使我快乐。',
  age: 18
})

const saveProfile = () => {
  ElMessage.success('个人资料已保存！')
  console.log('保存的数据：', profileForm)
}
</script>

<style scoped>
.profile-container {
  display: flex;
  justify-content: center;
  padding: 40px 20px;
}
.box-card {
  width: 100%;
  max-width: 600px;
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
  font-weight: bold;
  letter-spacing: 1px;
}
.glow-btn {
  width: 100%;
  margin-top: 20px;
  letter-spacing: 2px;
}
</style>
