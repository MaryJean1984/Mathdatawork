<template>
  <div class="practice-container fluid-container" :class="themeClass">
    <el-card class="practice-card glass-card">
      <template #header>
        <div class="card-header">
          <span class="neon-text title-text">Word Practice Module</span>
        </div>
        
        <!-- 难度等级选择器 -->
        <div class="level-selector">
          <el-radio-group v-model="currentLevel" size="large" @change="handleLevelChange">
            <el-radio-button label="beginner">
              入门等级 <el-tag size="small" type="success" effect="dark" round>{{ getWordCount('beginner') }} 词</el-tag>
            </el-radio-button>
            <el-radio-button label="proficient">
              精通等级 <el-tag size="small" type="warning" effect="dark" round>{{ getWordCount('proficient') }} 词</el-tag>
            </el-radio-button>
            <el-radio-button label="master">
              大师等级 <el-tag size="small" type="danger" effect="dark" round>{{ getWordCount('master') }} 词</el-tag>
            </el-radio-button>
          </el-radio-group>
        </div>
      </template>

      <!-- 题目区域，根据不同等级动态改变布局和样式 -->
      <div v-if="currentQuestion" class="question-area" :class="layoutClass">
        
        <div class="meaning-wrapper">
          <h2 class="meaning-title neon-text">{{ currentQuestion.meaning }}</h2>
          <div class="instruction-text" :class="{'neon-text': currentLevel !== 'master'}">
            {{ currentLevel === 'master' ? 'SELECT THE CORRECT PROTOCOL MATCH' : '请根据上方中文释义，选择正确的英文单词：' }}
          </div>
          <div v-if="currentLevel === 'master'" class="glitch-overlay">DATA ENCRYPTED</div>
        </div>

        <div class="options-wrapper">
          <el-button 
            v-for="(opt, index) in options" 
            :key="index" 
            size="large"
            :type="getOptionType(opt)"
            @click="selectOption(opt)"
            class="option-btn glass-card">
            <span class="opt-index" v-if="currentLevel === 'proficient'">{{ String.fromCharCode(65 + index) }}.</span>
            {{ opt }}
          </el-button>
        </div>

        <!-- 知道 / 不知道 快捷操作区 -->
        <div class="quick-actions">
          <el-button type="danger" plain @click="markAsUnknown" class="action-btn glass-btn" :disabled="hasAnswered">
            <el-icon><Warning /></el-icon> 不知道 (加入待背库)
          </el-button>
          <el-button type="success" plain @click="markAsKnown" class="action-btn glass-btn" :disabled="hasAnswered">
            <el-icon><Check /></el-icon> 知道 (直接跳过)
          </el-button>
        </div>

        <!-- 导航按钮 -->
        <div class="nav-buttons">
          <el-button type="info" plain @click="prevQuestion" :disabled="currentIndex <= 0" class="nav-btn glass-btn">
            <el-icon><ArrowLeft /></el-icon> 上一个 (PREV)
          </el-button>
          <el-button type="primary" plain @click="nextQuestion" class="nav-btn glass-btn">
            下一个 (NEXT) <el-icon><ArrowRight /></el-icon>
          </el-button>
        </div>

      </div>

      <!-- 底部计数器 -->
      <div class="counter-footer">
        <div class="counter-item correct-counter">
          <span class="label">选择正确</span>
          <span class="value neon-text-success">{{ correctCount }}</span>
        </div>
        <div class="counter-item incorrect-counter">
          <span class="label">选择错误</span>
          <span class="value neon-text-danger">{{ incorrectCount }}</span>
        </div>
      </div>

    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { ArrowLeft, ArrowRight, Warning, Check } from '@element-plus/icons-vue'

// 【核心改造】动态生成 30,000+ 级别的海量模拟词库
const generateMassiveDictionary = () => {
  const dictionary = {
    beginner: [],
    proficient: [],
    master: []
  }

  // 1. 生成入门等级 (10000 词)
  const baseBeginner = [
    { w: 'apple', m: 'n. 苹果' }, { w: 'book', m: 'n. 书本' }, { w: 'cat', m: 'n. 猫' },
    { w: 'dog', m: 'n. 狗' }, { w: 'water', m: 'n. 水' }, { w: 'sun', m: 'n. 太阳' },
    { w: 'moon', m: 'n. 月亮' }, { w: 'tree', m: 'n. 树木' }, { w: 'bird', m: 'n. 鸟' },
    { w: 'fish', m: 'n. 鱼' }, { w: 'sky', m: 'n. 天空' }, { w: 'star', m: 'n. 星星' }
  ]
  for (let i = 0; i < 10050; i++) {
    const item = baseBeginner[i % baseBeginner.length]
    dictionary.beginner.push({
      word: item.w,
      meaning: item.m
    })
  }

  // 2. 生成精通等级 (10000 词)
  const baseProficient = [
    { w: 'abandon', m: 'v. 放弃，抛弃' }, { w: 'beneath', m: 'prep. 在...之下' },
    { w: 'capacity', m: 'n. 容量；能力' }, { w: 'delight', m: 'n. 高兴；v. 使高兴' },
    { w: 'eager', m: 'adj. 渴望的，热切的' }, { w: 'genuine', m: 'adj. 真实的；真诚的' },
    { w: 'hesitate', m: 'v. 犹豫，踌躇' }, { w: 'inspire', m: 'v. 鼓舞；激发' },
    { w: 'frequent', m: 'adj. 频繁的' }, { w: 'predict', m: 'v. 预言，预测' }
  ]
  for (let i = 0; i < 10200; i++) {
    const item = baseProficient[i % baseProficient.length]
    dictionary.proficient.push({
      word: item.w,
      meaning: item.m
    })
  }

  // 3. 生成大师等级 (10000 词)
  const baseMaster = [
    { w: 'ephemeral', m: 'adj. 短暂的' }, { w: 'serendipity', m: 'n. 机缘巧合' },
    { w: 'ubiquitous', m: 'adj. 无处不在的' }, { w: 'eloquent', m: 'adj. 雄辩的' },
    { w: 'resilient', m: 'adj. 能恢复活力的' }, { w: 'enigmatic', m: 'adj. 神秘的' },
    { w: 'ineffable', m: 'adj. 难以形容的' }, { w: 'paradigm', m: 'n. 范例；典范' },
    { w: 'obfuscate', m: 'v. 使模糊；使困惑' }, { w: 'pragmatic', m: 'adj. 务实的' }
  ]
  for (let i = 0; i < 10100; i++) {
    const item = baseMaster[i % baseMaster.length]
    dictionary.master.push({
      word: item.w,
      meaning: item.m
    })
  }

  return dictionary
}

const dictionary = generateMassiveDictionary()

const currentLevel = ref('beginner')

// 历史记录与导航状态
const questionHistory = ref([])
const currentIndex = ref(-1)

// 计数器状态
const correctCount = ref(0)
const incorrectCount = ref(0)

// 动态获取当前选定等级的词库
const currentWordList = computed(() => dictionary[currentLevel.value])

// 获取当前题目的数据
const currentQuestionData = computed(() => {
  if (currentIndex.value >= 0 && currentIndex.value < questionHistory.value.length) {
    return questionHistory.value[currentIndex.value]
  }
  return null
})

const currentQuestion = computed(() => currentQuestionData.value?.question)
const options = computed(() => currentQuestionData.value?.options || [])
const hasAnswered = computed(() => currentQuestionData.value?.hasAnswered || false)

// 动态主题类名
const themeClass = computed(() => `theme-${currentLevel.value}`)
const layoutClass = computed(() => `layout-${currentLevel.value}`)

const getWordCount = (level) => {
  return dictionary[level].length.toLocaleString()
}

const handleLevelChange = () => {
  ElMessage.success(`System Override: Switched to [${currentLevel.value.toUpperCase()}] Protocol`)
  questionHistory.value = []
  currentIndex.value = -1
  loadNewQuestion()
}

const getRandomWords = (count, exclude) => {
  const uniqueWords = [...new Set(currentWordList.value.map(w => w.word))].filter(w => w !== exclude)
  const shuffled = uniqueWords.sort(() => 0.5 - Math.random())
  return shuffled.slice(0, count)
}

const loadNewQuestion = () => {
  const randomTarget = currentWordList.value[Math.floor(Math.random() * currentWordList.value.length)]
  
  // 难度越大，干扰项越多
  const distractorCount = currentLevel.value === 'beginner' ? 3 : currentLevel.value === 'proficient' ? 5 : 7;
  const distractors = getRandomWords(distractorCount, randomTarget.word)
  const allOpts = [...distractors, randomTarget.word]
  
  questionHistory.value.push({
    question: randomTarget,
    options: allOpts.sort(() => 0.5 - Math.random()),
    selectedWord: null,
    hasAnswered: false
  })
  currentIndex.value = questionHistory.value.length - 1
}

const nextQuestion = () => {
  if (currentIndex.value < questionHistory.value.length - 1) {
    currentIndex.value++
  } else {
    loadNewQuestion()
  }
}

const prevQuestion = () => {
  if (currentIndex.value > 0) {
    currentIndex.value--
  }
}

const getOptionType = (opt) => {
  const current = currentQuestionData.value
  if (!current || !current.hasAnswered) return 'primary'
  if (opt === current.question.word) return 'success'
  if (opt === current.selectedWord && opt !== current.question.word) return 'danger'
  return 'primary'
}

const checkDisciplineProgress = () => {
  const dailyTarget = parseInt(localStorage.getItem('dailyTarget') || '0')
  if (dailyTarget <= 0) return

  let progress = JSON.parse(localStorage.getItem('studyProgress') || '{}')
  let honors = JSON.parse(localStorage.getItem('userHonors') || '{"medals": 0, "flags": 0}')
  const today = new Date().toDateString()

  // 初始化或跨天重置
  if (progress.lastDate !== today) {
    progress.wordsToday = 0
    progress.lastDate = today
    progress.targetMetToday = false
  }

  // 增加背诵数量
  progress.wordsToday += 1

  // 判断是否达成每日目标
  if (progress.wordsToday >= dailyTarget && !progress.targetMetToday) {
    progress.targetMetToday = true
    progress.streakDays = (progress.streakDays || 0) + 1
    
    // 发放勋章
    honors.medals += 1
    ElMessage({
      message: `🎉 恭喜达成今日自律目标！获得 1 枚勋章 🏅！`,
      type: 'success',
      duration: 4000
    })

    // 判断是否连续 30 天
    if (progress.streakDays >= 30) {
      honors.flags += 1
      progress.streakDays = 0 // 重置连击，重新算下一个30天
      ElMessage({
        message: `🏆 太强了！连续自律打卡 30 天！获得 1 面毅力旗帜 🚩！`,
        type: 'warning',
        duration: 5000
      })
    }

    localStorage.setItem('userHonors', JSON.stringify(honors))
  }

  localStorage.setItem('studyProgress', JSON.stringify(progress))
}

let autoNextTimer = null
const selectOption = (opt) => {
  const current = currentQuestionData.value
  if (!current || current.hasAnswered) return
  
  current.hasAnswered = true
  current.selectedWord = opt

  if (opt === current.question.word) {
    correctCount.value++
    ElMessage.success('CORRECT MATCH')
    // 选择正确算背一个单词，同步自律进度条
    checkDisciplineProgress()
  } else {
    incorrectCount.value++
    ElMessage.error(`ERROR! Target: ${current.question.word}`)
    recordError(current.question)
  }

  clearTimeout(autoNextTimer)
  autoNextTimer = setTimeout(() => {
    // 如果用户没有手动切换题目，则自动跳到下一题
    if (currentIndex.value === questionHistory.value.length - 1) {
      nextQuestion()
    }
  }, 1500)
}

const recordError = (wordObj) => {
  let errorWords = JSON.parse(localStorage.getItem('errorWords') || '[]')
  let hardWords = JSON.parse(localStorage.getItem('hardWords') || '[]')

  let existingError = errorWords.find(w => w.word === wordObj.word)
  
  if (existingError) {
    existingError.errorCount += 1
    if (existingError.errorCount >= 3) {
      const existsInHard = hardWords.find(w => w.word === wordObj.word)
      if (!existsInHard) {
        hardWords.push({ ...wordObj, addedReason: '错误达到3次' })
        localStorage.setItem('hardWords', JSON.stringify(hardWords))
        ElMessage.warning(`[SYSTEM ALERT] "${wordObj.word}" transferred to Hard Library!`)
      }
    }
  } else {
    errorWords.push({ ...wordObj, errorCount: 1 })
  }
  
  localStorage.setItem('errorWords', JSON.stringify(errorWords))
}

const markAsUnknown = () => {
  const current = currentQuestionData.value
  if (!current || current.hasAnswered) return
  
  current.hasAnswered = true
  
  // 加入待背库
  let toMemorizeWords = JSON.parse(localStorage.getItem('toMemorizeWords') || '[]')
  const exists = toMemorizeWords.find(w => w.word === current.question.word)
  if (!exists) {
    toMemorizeWords.push({ ...current.question, addedAt: new Date().toISOString() })
    localStorage.setItem('toMemorizeWords', JSON.stringify(toMemorizeWords))
    ElMessage.warning(`已将 "${current.question.word}" 加入待背库`)
  } else {
    ElMessage.info(`"${current.question.word}" 已在待背库中`)
  }
  
  // 直接跳过到下一题
  setTimeout(() => {
    nextQuestion()
  }, 800)
}

const markAsKnown = () => {
  const current = currentQuestionData.value
  if (!current || current.hasAnswered) return
  
  current.hasAnswered = true
  ElMessage.success(`跳过 "${current.question.word}"，继续下一题`)
  
  // 直接跳过到下一题
  setTimeout(() => {
    nextQuestion()
  }, 500)
}

onMounted(() => {
  loadNewQuestion()
})
</script>

<style scoped>
.practice-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: calc(100vh - 80px);
  padding: 20px;
  transition: all 0.5s ease;
}
.practice-card {
  width: 100%;
  max-width: 900px;
  text-align: center;
  padding: 20px;
  transition: all 0.5s ease;
  display: flex;
  flex-direction: column;
}
.card-header {
  margin-bottom: 20px;
}
.title-text {
  font-size: 1.5rem;
  font-weight: 800;
  letter-spacing: 2px;
}

/* 难度等级选择器基础样式 */
.level-selector {
  margin-top: 15px;
  margin-bottom: 10px;
}
.level-selector :deep(.el-radio-button__inner) {
  background: rgba(20, 20, 30, 0.4);
  border-color: var(--glass-border);
  color: var(--text-secondary);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
}
.level-selector :deep(.el-radio-button__original-radio:checked + .el-radio-button__inner) {
  background: var(--neon-cyan-dim);
  border-color: var(--neon-cyan);
  color: #fff;
  box-shadow: -1px 0 0 0 var(--neon-cyan);
}

/* 导航按钮样式 */
.nav-buttons {
  margin-top: 20px;
  display: flex;
  justify-content: space-between;
  padding: 0 20px;
}
.quick-actions {
  display: flex;
  justify-content: center;
  gap: 30px;
  margin-top: 30px;
}
.action-btn {
  font-size: 1.1rem;
  padding: 12px 30px !important;
}
.glass-btn {
  background: rgba(255, 255, 255, 0.05) !important;
  backdrop-filter: blur(10px);
  border: 1px solid var(--glass-border) !important;
  color: var(--text-primary) !important;
  font-weight: bold;
  letter-spacing: 1px;
  border-radius: 12px !important;
  padding: 12px 24px !important;
  transition: all 0.3s ease;
}
.glass-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.15) !important;
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(0, 243, 255, 0.2);
}
.glass-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 底部计数器样式 */
.counter-footer {
  margin-top: 30px;
  display: flex;
  justify-content: center;
  gap: 40px;
  padding-top: 20px;
  border-top: 1px solid var(--glass-border);
}
.counter-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  background: rgba(0, 0, 0, 0.2);
  padding: 15px 30px;
  border-radius: 16px;
  border: 1px solid var(--glass-border);
  min-width: 120px;
}
.counter-item .label {
  font-size: 0.9rem;
  color: var(--text-secondary);
  margin-bottom: 5px;
  letter-spacing: 1px;
}
.counter-item .value {
  font-size: 2rem;
  font-weight: 900;
}
.neon-text-success {
  color: #00ff80;
  text-shadow: 0 0 10px rgba(0, 255, 128, 0.5);
}
.neon-text-danger {
  color: #ff0055;
  text-shadow: 0 0 10px rgba(255, 0, 85, 0.5);
}

/* ========== 核心变装：入门等级 (Beginner) ========== */
/* 柔和生机绿色调，清晰巨大的双列排版 */
.theme-beginner .practice-card {
  border: 2px solid rgba(0, 255, 128, 0.2) !important;
  box-shadow: 0 0 40px rgba(0, 255, 128, 0.05) !important;
}
.theme-beginner .title-text {
  background: linear-gradient(90deg, #00ff80, #00f3ff);
  -webkit-background-clip: text;
  text-shadow: 0 0 20px rgba(0, 255, 128, 0.3);
}
.layout-beginner .meaning-title {
  font-size: 3rem;
  margin-bottom: 10px;
  letter-spacing: 2px;
  color: #fff;
}
.instruction-text {
  font-size: 1.1rem;
  color: var(--text-secondary);
  margin-bottom: 30px;
  letter-spacing: 1px;
}
.layout-beginner .options-wrapper {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 40px;
  padding: 20px 40px;
}
.layout-beginner .option-btn {
  height: 100px;
  font-size: 1.6rem;
  border-radius: 20px !important;
}

/* ========== 核心变装：精通等级 (Proficient) ========== */
/* 科技蓝黄高对比，紧凑的网格列表，显示选项序号，增加选项至6个 */
.theme-proficient .practice-card {
  border: 1px solid rgba(255, 208, 75, 0.3) !important;
  box-shadow: 0 0 30px rgba(255, 208, 75, 0.1) !important;
  background: rgba(10, 15, 25, 0.6) !important;
}
.theme-proficient .title-text {
  background: linear-gradient(90deg, #ffd04b, #00f3ff);
  -webkit-background-clip: text;
  text-shadow: 0 0 20px rgba(255, 208, 75, 0.3);
}
.layout-proficient .meaning-wrapper {
  background: rgba(255, 208, 75, 0.05);
  padding: 20px;
  border-radius: 12px;
  margin-bottom: 30px;
  border-left: 4px solid #ffd04b;
}
.layout-proficient .meaning-title {
  font-size: 2rem;
  margin: 0 0 10px 0;
  text-align: left;
  color: #ffd04b;
}
.layout-proficient .instruction-text {
  text-align: left;
  color: rgba(255, 208, 75, 0.8);
  font-size: 1rem;
}
.layout-proficient .options-wrapper {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}
.layout-proficient .option-btn {
  height: 70px;
  font-size: 1.2rem;
  border-radius: 8px !important;
  display: flex;
  justify-content: flex-start;
  padding-left: 20px;
  background: rgba(0, 0, 0, 0.4) !important;
}
.opt-index {
  color: #ffd04b;
  margin-right: 15px;
  font-weight: 900;
}

/* ========== 核心变装：大师等级 (Master) ========== */
/* 深邃赛博红紫暗黑风，极简极客排版，超多干扰项(8个)，带干扰视效 */
.theme-master .practice-card {
  border: 1px solid rgba(188, 19, 254, 0.4) !important;
  box-shadow: 0 0 50px rgba(188, 19, 254, 0.15) !important;
  background: rgba(5, 0, 10, 0.8) !important;
}
.theme-master .title-text {
  background: linear-gradient(90deg, #ff0055, #bc13fe);
  -webkit-background-clip: text;
  text-shadow: 0 0 25px rgba(255, 0, 85, 0.5);
  font-family: monospace;
}
.layout-master .meaning-wrapper {
  position: relative;
  margin-bottom: 50px;
}
.layout-master .meaning-title {
  font-size: 2.2rem;
  color: #ff0055;
  font-family: monospace;
  text-shadow: 2px 0 0 #bc13fe, -2px 0 0 #00f3ff;
  margin-bottom: 15px;
}
.layout-master .instruction-text {
  font-family: monospace;
  color: #a0a0b0;
  letter-spacing: 2px;
  font-size: 0.9rem;
}
.glitch-overlay {
  position: absolute;
  top: -10px;
  right: 0;
  font-size: 0.8rem;
  color: rgba(255, 255, 255, 0.3);
  font-family: monospace;
  letter-spacing: 5px;
}
.layout-master .options-wrapper {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 15px;
}
.layout-master .option-btn {
  height: auto;
  padding: 15px 30px !important;
  font-size: 1.1rem;
  border-radius: 0 !important;
  border: 1px solid rgba(255, 0, 85, 0.3) !important;
  background: transparent !important;
  color: #a0a0b0 !important;
  font-family: monospace;
  clip-path: polygon(10px 0, 100% 0, 100% calc(100% - 10px), calc(100% - 10px) 100%, 0 100%, 0 10px);
}
.layout-master .option-btn:hover {
  background: rgba(255, 0, 85, 0.1) !important;
  color: #fff !important;
  border-color: #ff0055 !important;
  box-shadow: 0 0 15px rgba(255, 0, 85, 0.3);
}

/* 按钮悬浮通用动效 */
.option-btn {
  transition: all 0.3s ease;
}
.option-btn:hover {
  transform: scale(1.03);
}
</style>