<template>
  <div class="ai-assistant-wrapper" :class="{ 'is-open': isOpen }">
    <!-- 聊天气泡 -->
    <div class="chat-bubble glass-card" v-if="isOpen">
      <div class="chat-header">
        <span class="ai-name neon-text">小词 (Xiao Ci)</span>
        <el-icon class="close-btn" @click="toggleChat"><Close /></el-icon>
      </div>
      <div class="chat-content">
        <div class="message greeting">
          <p>{{ greetingMessage }}</p>
        </div>
        <div class="message target-reminder" v-if="targetMessage">
          <p>{{ targetMessage }}</p>
        </div>
        <div class="message encourage">
          <p>{{ encourageMessage }}</p>
        </div>
      </div>
    </div>

    <!-- AI 形象头像 (画眉鸟) -->
    <div class="avatar-container" @click="toggleChat">
      <div class="avatar-glow"></div>
      <img :src="avatarUrl" alt="小词 - 画眉鸟" class="bird-avatar" />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { Close } from '@element-plus/icons-vue'

const isOpen = ref(false)

// 使用 Trae 文档要求的图片生成规则生成卡通画眉鸟
const avatarUrl = ref('https://coresg-normal.trae.ai/api/ide/v1/text_to_image?prompt=cute%20cartoon%20laughingthrush%20bird%20vector%20art%20avatar%20cyberpunk%20style&image_size=square')

// 获取用户信息和学习进度
const getNickname = () => {
  const profile = JSON.parse(localStorage.getItem('userProfile') || '{}')
  return profile.nickname || '同学'
}

const getStudyProgress = () => {
  const target = parseInt(localStorage.getItem('dailyTarget') || '0')
  const progress = JSON.parse(localStorage.getItem('studyProgress') || '{}')
  const today = new Date().toDateString()
  let wordsToday = 0
  if (progress.lastDate === today) {
    wordsToday = progress.wordsToday || 0
  }
  return { target, wordsToday }
}

const toggleChat = () => {
  isOpen.value = !isOpen.value
}

// 动态生成消息
const greetingMessage = computed(() => {
  return `你好，${getNickname()}！我是小词，你的专属学习助手！🦆`
})

const targetMessage = computed(() => {
  const { target, wordsToday } = getStudyProgress()
  if (target > 0) {
    if (wordsToday >= target) {
      return `今日自律目标 ${target} 词已达成！你太棒了！🎉`
    } else {
      return `今天还要背 ${target - wordsToday} 个单词才能完成自律目标哦，冲鸭！🚀`
    }
  }
  return '你还没有设置每日自律目标哦，去【个人荣誉】里设置一下吧！'
})

const encourageMessage = computed(() => {
  const messages = [
    `加油，${getNickname()}！你一定能行！`,
    `每一个背下的单词，都是通往星辰大海的阶梯！`,
    `${getNickname()}太棒啦！每一步努力都算数！`,
    `相信自己，${getNickname()}的潜力是无限的！`
  ]
  // 这里用一个简单的随机，也可以固定
  return messages[Math.floor(Math.random() * messages.length)]
})

// 监听 localstorage 变化以更新昵称 (可选)
const handleStorageChange = () => {
  // 强制刷新计算属性，这里 Vue 响应式无法直接监听 localStorage
  // 实际项目中可使用 Pinia/Vuex，这里使用简易强制刷新
}

onMounted(() => {
  window.addEventListener('storage', handleStorageChange)
  // 首次进入默认打开打招呼
  setTimeout(() => {
    isOpen.value = true
  }, 1000)
})

onUnmounted(() => {
  window.removeEventListener('storage', handleStorageChange)
})

</script>

<style scoped>
.ai-assistant-wrapper {
  position: fixed;
  bottom: 40px;
  right: 40px;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.chat-bubble {
  width: 280px;
  margin-bottom: 20px;
  border-radius: 16px;
  border: 1px solid rgba(0, 243, 255, 0.3);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5), 0 0 20px rgba(0, 243, 255, 0.15);
  background: rgba(10, 15, 25, 0.85);
  backdrop-filter: blur(15px);
  transform-origin: bottom right;
  animation: popIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 15px;
  border-bottom: 1px dashed rgba(255, 255, 255, 0.1);
}

.ai-name {
  font-weight: 800;
  font-size: 1.1rem;
  color: #00f3ff;
}

.close-btn {
  cursor: pointer;
  color: var(--text-secondary);
  transition: all 0.3s ease;
}

.close-btn:hover {
  color: #ff4d4f;
  transform: rotate(90deg);
}

.chat-content {
  padding: 15px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.message {
  background: rgba(255, 255, 255, 0.05);
  padding: 10px 15px;
  border-radius: 12px;
  font-size: 0.95rem;
  line-height: 1.5;
  color: #e0e0e0;
  border-left: 3px solid transparent;
}

.greeting {
  border-left-color: #00f3ff;
}

.target-reminder {
  border-left-color: #ffd04b;
}

.encourage {
  border-left-color: #bc13fe;
  font-weight: bold;
}

.avatar-container {
  position: relative;
  width: 80px;
  height: 80px;
  cursor: pointer;
  border-radius: 50%;
  transition: all 0.3s ease;
}

.avatar-container:hover {
  transform: scale(1.1);
}

.bird-avatar {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #00f3ff;
  position: relative;
  z-index: 2;
}

.avatar-glow {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: #00f3ff;
  filter: blur(15px);
  opacity: 0.5;
  z-index: 1;
  animation: pulse 2s infinite alternate;
}

@keyframes popIn {
  from {
    opacity: 0;
    transform: scale(0.8) translateY(20px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

@keyframes pulse {
  0% {
    transform: scale(1);
    opacity: 0.4;
  }
  100% {
    transform: scale(1.2);
    opacity: 0.7;
  }
}
</style>