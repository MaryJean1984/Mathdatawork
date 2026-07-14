<template>
  <div class="ai-assistant-wrapper" :class="{ 'is-open': isOpen }">
    <!-- 聊天气泡 -->
    <div class="chat-bubble glass-card" v-if="isOpen">
      <div class="chat-header">
        <span class="ai-name neon-text">小词</span>
        <div class="header-actions">
          <el-icon class="close-btn" @click="toggleChat"><Close /></el-icon>
        </div>
      </div>
      
      <div class="chat-content" ref="chatContainer">
        <div 
          v-for="(msg, index) in messages" 
          :key="index" 
          class="message-row"
          :class="msg.role"
        >
          <div class="message-bubble" :class="msg.type || 'normal'">
            <p>{{ msg.text }}</p>
          </div>
        </div>
        
        <div v-if="isTyping" class="message-row assistant">
          <div class="message-bubble typing">
            <span class="dot"></span><span class="dot"></span><span class="dot"></span>
          </div>
        </div>
      </div>

      <div class="chat-input-area">
        <el-input 
          v-model="userInput" 
          placeholder="和小词聊聊英语..." 
          @keyup.enter="sendMessage"
          :disabled="isTyping"
        >
          <template #append>
            <el-button @click="sendMessage" :disabled="isTyping || !userInput.trim()">
              <el-icon><Position /></el-icon>
            </el-button>
          </template>
        </el-input>
      </div>
    </div>

    <!-- AI 形象头像 (画眉鸟) -->
    <div class="avatar-container" @click="toggleChat">
      <div class="avatar-glow"></div>
      <img :src="avatarImg" alt="小词 - 画眉鸟" class="bird-avatar" />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import { Close, Setting, Position } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import avatarImg from '../assets/ai_avatar.png'

const isOpen = ref(false)
const chatContainer = ref(null)
const userInput = ref('')
const isTyping = ref(false)
const messages = ref([])

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
  if (isOpen.value) {
    scrollToBottom()
  }
}

const scrollToBottom = async () => {
  await nextTick()
  if (chatContainer.value) {
    chatContainer.value.scrollTop = chatContainer.value.scrollHeight
  }
}

// 初始化欢迎语和进度提醒
const initMessages = () => {
  messages.value = []
  messages.value.push({
    role: 'assistant',
    type: 'greeting',
    text: `你好，${getNickname()}！我是小词，你的专属学习助手！`
  })

  const { target, wordsToday } = getStudyProgress()
  if (target > 0) {
    if (wordsToday >= target) {
      messages.value.push({
        role: 'assistant',
        type: 'target-reminder',
        text: `今日自律目标 ${target} 词已达成！你太棒了！`
      })
    } else {
      messages.value.push({
        role: 'assistant',
        type: 'target-reminder',
        text: `今天还要背 ${target - wordsToday} 个单词才能完成自律目标哦，冲鸭！`
      })
    }
  }
}

// Pollinations AI 免费聊天逻辑
const sendMessage = async () => {
  const text = userInput.value.trim()
  if (!text) return

  messages.value.push({ role: 'user', text })
  userInput.value = ''
  scrollToBottom()

  isTyping.value = true
  scrollToBottom()

  try {
    const systemContext = `你现在的身份是一个名叫“小词”的AI英语学习助手，你的形象是一只可爱的蓝色画眉鸟。用户的昵称是“${getNickname()}”。请用活泼、鼓励、简短的语气回答用户的英语学习问题，或者进行日常对话。不要输出过长的长篇大论。请注意：在所有的回复中，绝对不要使用任何Emoji表情符号。`
    
    // 使用 Pollinations AI 的 GET 接口，避免跨域或 Token 限制
    const url = `https://text.pollinations.ai/${encodeURIComponent(text)}?system=${encodeURIComponent(systemContext)}`

    const response = await fetch(url)

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const replyText = await response.text()

    messages.value.push({ role: 'assistant', text: replyText })
  } catch (error) {
    console.error(error)
    messages.value.push({ 
      role: 'assistant', 
      type: 'error',
      text: '抱歉，小词的接口开小差了，请稍后再试哦。' 
    })
  } finally {
    isTyping.value = false
    scrollToBottom()
  }
}

onMounted(() => {
  initMessages()
  setTimeout(() => {
    isOpen.value = true
  }, 1000)
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
  width: 320px;
  margin-bottom: 20px;
  border-radius: 16px;
  border: 1px solid rgba(0, 243, 255, 0.3);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5), 0 0 20px rgba(0, 243, 255, 0.15);
  background: rgba(10, 15, 25, 0.95);
  backdrop-filter: blur(15px);
  transform-origin: bottom right;
  animation: popIn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
  display: flex;
  flex-direction: column;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 15px;
  border-bottom: 1px dashed rgba(255, 255, 255, 0.1);
}

.header-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.ai-name {
  font-weight: 800;
  font-size: 1.1rem;
  color: #00f3ff;
}

.action-btn, .close-btn {
  cursor: pointer;
  color: var(--text-secondary);
  transition: all 0.3s ease;
  font-size: 1.1rem;
}

.action-btn:hover { color: #ffd04b; }
.close-btn:hover { color: #ff4d4f; transform: rotate(90deg); }

.chat-content {
  padding: 15px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-height: 300px;
  overflow-y: auto;
}
.chat-content::-webkit-scrollbar { width: 4px; }
.chat-content::-webkit-scrollbar-thumb { background: rgba(0, 243, 255, 0.3); border-radius: 4px; }

.message-row {
  display: flex;
  width: 100%;
}

.message-row.user {
  justify-content: flex-end;
}

.message-row.assistant {
  justify-content: flex-start;
}

.message-bubble {
  max-width: 85%;
  padding: 10px 14px;
  border-radius: 12px;
  font-size: 0.95rem;
  line-height: 1.5;
  word-wrap: break-word;
}

.message-row.user .message-bubble {
  background: rgba(0, 243, 255, 0.2);
  color: #fff;
  border-bottom-right-radius: 2px;
  border: 1px solid rgba(0, 243, 255, 0.4);
}

.message-row.assistant .message-bubble {
  background: rgba(255, 255, 255, 0.05);
  color: #e0e0e0;
  border-bottom-left-radius: 2px;
  border-left: 3px solid #00f3ff;
}

.message-bubble.greeting { border-left-color: #00f3ff; }
.message-bubble.target-reminder { border-left-color: #ffd04b; }
.message-bubble.error { border-left-color: #ff4d4f; color: #ff4d4f; }

.chat-input-area {
  padding: 10px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

.chat-input-area :deep(.el-input-group__append) {
  background-color: rgba(0, 243, 255, 0.1);
  border-color: rgba(0, 243, 255, 0.3);
  color: #00f3ff;
}

.chat-input-area :deep(.el-input__wrapper) {
  background-color: rgba(0, 0, 0, 0.3);
  box-shadow: 0 0 0 1px rgba(255, 255, 255, 0.1) inset;
}

.chat-input-area :deep(.el-input__inner) {
  color: #fff;
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
  background: var(--bg-dark);
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

/* 打字动画 */
.typing .dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  margin-right: 4px;
  border-radius: 50%;
  background-color: #00f3ff;
  animation: bounce 1.4s infinite ease-in-out both;
}
.typing .dot:nth-child(1) { animation-delay: -0.32s; }
.typing .dot:nth-child(2) { animation-delay: -0.16s; }

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}

@keyframes popIn {
  from { opacity: 0; transform: scale(0.8) translateY(20px); }
  to { opacity: 1; transform: scale(1) translateY(0); }
}

@keyframes pulse {
  0% { transform: scale(1); opacity: 0.4; }
  100% { transform: scale(1.2); opacity: 0.7; }
}
</style>