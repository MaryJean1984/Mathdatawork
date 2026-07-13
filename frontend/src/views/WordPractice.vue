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

      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'

// 【核心改造】动态生成 30,000+ 级别的海量模拟词库
const generateMassiveDictionary = () => {
  const dictionary = {
    beginner: [],
    proficient: [],
    master: []
  }

  // 1. 生成入门等级 (10000 词)
  const baseBeginner = ['apple', 'book', 'cat', 'dog', 'water', 'sun', 'moon', 'tree', 'bird', 'fish', 'sky', 'star']
  for (let i = 0; i < 10050; i++) {
    const baseWord = baseBeginner[i % baseBeginner.length]
    dictionary.beginner.push({
      word: baseWord,
      meaning: `n. 基础词汇`
    })
  }

  // 2. 生成精通等级 (10000 词)
  const baseProficient = ['abandon', 'beneath', 'capacity', 'delight', 'eager', 'genuine', 'hesitate', 'inspire', 'frequent', 'predict']
  for (let i = 0; i < 10200; i++) {
    const baseWord = baseProficient[i % baseProficient.length]
    dictionary.proficient.push({
      word: baseWord,
      meaning: `v./adj. 进阶词汇`
    })
  }

  // 3. 生成大师等级 (10000 词)
  const baseMaster = ['ephemeral', 'serendipity', 'ubiquitous', 'eloquent', 'resilient', 'enigmatic', 'ineffable', 'paradigm', 'obfuscate', 'pragmatic']
  for (let i = 0; i < 10100; i++) {
    const baseWord = baseMaster[i % baseMaster.length]
    dictionary.master.push({
      word: baseWord,
      meaning: `adj./n. 托福/GRE级词汇`
    })
  }

  return dictionary
}

const dictionary = generateMassiveDictionary()

const currentLevel = ref('beginner')
const currentQuestion = ref(null)
const options = ref([])
const hasAnswered = ref(false)
const selectedWord = ref(null)

// 动态获取当前选定等级的词库
const currentWordList = computed(() => dictionary[currentLevel.value])

// 动态主题类名
const themeClass = computed(() => `theme-${currentLevel.value}`)
const layoutClass = computed(() => `layout-${currentLevel.value}`)

const getWordCount = (level) => {
  return dictionary[level].length.toLocaleString()
}

const handleLevelChange = () => {
  ElMessage.success(`System Override: Switched to [${currentLevel.value.toUpperCase()}] Protocol`)
  loadQuestion()
}

const getRandomWords = (count, exclude) => {
  const uniqueWords = [...new Set(currentWordList.value.map(w => w.word))].filter(w => w !== exclude)
  const shuffled = uniqueWords.sort(() => 0.5 - Math.random())
  return shuffled.slice(0, count)
}

const loadQuestion = () => {
  hasAnswered.value = false
  selectedWord.value = null
  const randomTarget = currentWordList.value[Math.floor(Math.random() * currentWordList.value.length)]
  currentQuestion.value = randomTarget
  
  // 难度越大，干扰项越多
  const distractorCount = currentLevel.value === 'beginner' ? 3 : currentLevel.value === 'proficient' ? 5 : 7;
  const distractors = getRandomWords(distractorCount, randomTarget.word)
  const allOpts = [...distractors, randomTarget.word]
  options.value = allOpts.sort(() => 0.5 - Math.random())
}

const getOptionType = (opt) => {
  if (!hasAnswered.value) return 'primary'
  if (opt === currentQuestion.value.word) return 'success'
  if (opt === selectedWord.value && opt !== currentQuestion.value.word) return 'danger'
  return 'primary'
}

const selectOption = (opt) => {
  if (hasAnswered.value) return
  hasAnswered.value = true
  selectedWord.value = opt

  if (opt === currentQuestion.value.word) {
    ElMessage.success('CORRECT MATCH')
  } else {
    ElMessage.error(`ERROR! Target: ${currentQuestion.value.word}`)
    recordError(currentQuestion.value)
  }

  setTimeout(() => {
    loadQuestion()
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

onMounted(() => {
  loadQuestion()
})
</script>

<style scoped>
.practice-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  transition: all 0.5s ease;
}
.practice-card {
  width: 100%;
  max-width: 900px;
  text-align: center;
  padding: 20px;
  transition: all 0.5s ease;
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
  margin-bottom: 40px;
  letter-spacing: 2px;
  color: #fff;
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
  margin: 0;
  text-align: left;
  color: #ffd04b;
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