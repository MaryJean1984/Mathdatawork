<template>
  <div class="profile-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>编辑个人资料</span>
        </div>
      </template>
      <el-form :model="profileForm" label-width="100px">
        <el-form-item label="昵称">
          <el-input v-model="profileForm.nickname"></el-input>
        </el-form-item>
        <el-form-item label="个人简介">
          <el-input type="textarea" v-model="profileForm.bio"></el-input>
        </el-form-item>
        <el-form-item label="年龄">
          <el-input-number v-model="profileForm.age" :min="1" :max="120"></el-input-number>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="saveProfile">保存修改</el-button>
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
  padding: 20px;
}
.box-card {
  max-width: 600px;
  margin: 0 auto;
}
</style>
