<template>
  <div class="profile-container fluid-container">
    <el-card class="box-card glass-card">
      <template #header>
        <div class="card-header">
          <span class="neon-text title">USER PROFILE</span>
        </div>
      </template>
      <el-form :model="profileForm" label-width="120px" class="glass-form" label-position="top">
        <div class="bento-grid-form">
          <el-form-item label="ACCOUNT / 账号">
            <el-input v-model="profileForm.account" disabled></el-input>
          </el-form-item>
          <el-form-item label="NICKNAME / 昵称">
            <el-input v-model="profileForm.nickname"></el-input>
          </el-form-item>
          <el-form-item label="REAL NAME / 姓名">
            <el-input v-model="profileForm.realName"></el-input>
          </el-form-item>
          <el-form-item label="PHONE / 手机号">
            <el-input v-model="profileForm.phone"></el-input>
          </el-form-item>
          <el-form-item label="EMAIL / 邮箱">
            <el-input v-model="profileForm.email"></el-input>
          </el-form-item>
          <el-form-item label="GENDER / 性别">
            <el-select v-model="profileForm.gender" placeholder="Select Gender" class="full-width">
              <el-option label="Male / 男" value="male"></el-option>
              <el-option label="Female / 女" value="female"></el-option>
              <el-option label="Other / 其他" value="other"></el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="AGE / 年龄">
            <el-input-number v-model="profileForm.age" :min="1" :max="120" class="full-width"></el-input-number>
          </el-form-item>
          <el-form-item label="PREFERRED LANG / 擅长语种">
            <el-select v-model="profileForm.preferredLanguage" placeholder="Select Language" class="full-width">
              <el-option label="English / 英语" value="en"></el-option>
              <el-option label="French / 法语" value="fr"></el-option>
              <el-option label="German / 德语" value="de"></el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="STUDY STAGE / 学习阶段">
            <el-select v-model="profileForm.studyStage" placeholder="Select Stage" class="full-width">
              <el-option label="Beginner / 入门" value="beginner"></el-option>
              <el-option label="Intermediate / 进阶" value="intermediate"></el-option>
              <el-option label="Advanced / 高级" value="advanced"></el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="STUDY GOAL / 学习目标">
            <el-input v-model="profileForm.studyGoal" placeholder="e.g. CET-6, IELTS"></el-input>
          </el-form-item>
        </div>
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
  account: 'user_001',
  nickname: 'CyberStudent',
  realName: '张三',
  phone: '13800138000',
  email: 'cyber@example.com',
  gender: 'male',
  age: 18,
  preferredLanguage: 'en',
  studyStage: 'beginner',
  studyGoal: 'CET-4',
  bio: '我爱学习，学习使我快乐。'
})

const saveProfile = async () => {
  // Simulate API call to backend
  try {
    // 假设调用后端更新接口
    // await fetch('/api/user/update', { method: 'POST', body: JSON.stringify({ userId: '1', ...profileForm }) })
    ElMessage.success('个人资料已成功更新并同步至数据库！')
    console.log('保存的数据：', profileForm)
  } catch (e) {
    ElMessage.error('更新失败')
  }
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
  max-width: 900px;
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
.bento-grid-form {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}
.full-width {
  width: 100%;
}
.glow-btn {
  width: 100%;
  margin-top: 20px;
  letter-spacing: 2px;
}
/* Deep selectors to ensure inner inputs are transparent and match theme */
:deep(.el-select .el-input__wrapper) {
  background: rgba(0, 0, 0, 0.3) !important;
  box-shadow: 0 0 0 1px var(--glass-border) inset !important;
}
:deep(.el-select .el-input__inner) {
  color: var(--text-primary) !important;
}
:deep(.el-input.is-disabled .el-input__wrapper) {
  background: rgba(0, 0, 0, 0.5) !important;
}
:deep(.el-input.is-disabled .el-input__inner) {
  color: var(--text-secondary) !important;
}
</style>
