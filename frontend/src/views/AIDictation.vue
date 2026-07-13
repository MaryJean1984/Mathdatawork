<template>
  <div class="ai-dictation-container">
    <h2>AI 听写练习</h2>
    <el-card class="box-card">
      <div class="audio-control">
        <el-button type="primary" size="large" @click="playAudio">
          <el-icon><Microphone /></el-icon> 播放 AI 读音
        </el-button>
      </div>
      <div class="input-area">
        <el-input
          v-model="userInput"
          type="textarea"
          :rows="4"
          placeholder="请在这里输入你听到的内容..."
        ></el-input>
      </div>
      <div class="submit-area">
        <el-button type="success" @click="checkAnswer">提交校对</el-button>
      </div>
      <div class="result-area" v-if="result">
        <el-alert
          :title="result.title"
          :type="result.type"
          :description="result.desc"
          show-icon
          :closable="false"
        >
        </el-alert>
        <p class="correct-answer" v-if="result.type !== 'success'">
          正确答案：{{ correctAnswer }}
        </p>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { Microphone } from '@element-plus/icons-vue'

const userInput = ref('')
const correctAnswer = ref('Artificial Intelligence is transforming education.')
const result = ref(null)

const playAudio = () => {
  ElMessage.info('AI 正在朗读... (模拟音频播放)')
}

const checkAnswer = () => {
  if (!userInput.value.trim()) {
    ElMessage.warning('请输入内容后再提交')
    return
  }
  
  if (userInput.value.trim().toLowerCase() === correctAnswer.value.toLowerCase()) {
    result.value = {
      title: '完全正确！',
      type: 'success',
      desc: '你的听写非常棒！'
    }
  } else {
    result.value = {
      title: '存在偏差',
      type: 'warning',
      desc: '你的拼写和标准答案不完全一致，请核令人对。'
    }
  }
}
</script>

<style scoped>
.ai-dictation-container {
  padding: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.box-card {
  width: 100%;
  max-width: 600px;
}
.audio-control {
  text-align: center;
  margin-bottom: 20px;
}
.input-area {
  margin-bottom: 20px;
}
.submit-area {
  text-align: right;
  margin-bottom: 20px;
}
.correct-answer {
  color: #f56c6c;
  font-weight: bold;
  margin-top: 10px;
}
</style>
