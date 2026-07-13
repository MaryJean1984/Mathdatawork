<template>
  <div class="recitation-container">
    <el-card class="word-card glass-card">
      <template #header>
        <div class="card-header">
          <span class="neon-text">Word Database <el-tag type="info" size="small" v-if="currentWord">{{ currentWord.oxfordLevel || 'B2' }}</el-tag></span>
          <el-button type="primary" plain size="small" @click="collectWord" :icon="Star">Add to Todo</el-button>
        </div>
      </template>
      <div class="word-content bento-grid" v-if="currentWord">
        
        <div class="bento-main">
          <h1 class="word-title neon-text">{{ currentWord.word }}</h1>
          <p class="phonetic">[{{ currentWord.phonetic }}]</p>
        </div>

        <div class="meaning-section bento-detail" v-if="showMeaning">
          <el-divider><span class="neon-text">Oxford Details</span></el-divider>
          <p class="meaning">{{ currentWord.meaning }}</p>
          
          <div v-if="currentWord.collocations && currentWord.collocations.length > 0" class="extra-info">
            <span class="info-label">Collocations:</span>
            <el-tag v-for="(col, idx) in currentWord.collocations" :key="idx" size="small" class="collocation-tag" effect="dark">
              {{ col }}
            </el-tag>
          </div>

          <div v-if="currentWord.synonyms && currentWord.synonyms.length > 0" class="extra-info">
            <span class="info-label">Synonyms:</span>
            <span class="synonym-text">{{ currentWord.synonyms.join(', ') }}</span>
          </div>

          <div class="example-box glass-card" v-if="currentWord.example">
            <span class="info-label">Example:</span>
            <p class="example-text">{{ currentWord.example }}</p>
            <p class="example-translation">{{ currentWord.exampleTranslation }}</p>
          </div>
        </div>
        
        <div class="meaning-mask glass-card" v-else @click="showMeaning = true">
          <span class="neon-text">TAP TO REVEAL DATA</span>
        </div>
      </div>
      
      <div class="action-buttons">
        <el-button type="success" size="large" @click="nextWord">KNOWN</el-button>
        <el-button type="danger" size="large" @click="markUnknow">UNKNOWN</el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Star } from '@element-plus/icons-vue'

const showMeaning = ref(false)

const wordList = [
  { 
    word: 'capacity', 
    phonetic: 'kəˈpæs.ə.ti', 
    meaning: 'n. 容量；能力；职位', 
    oxfordLevel: 'B2',
    collocations: ['have the capacity to do', 'build capacity', 'storage capacity'],
    synonyms: ['ability', 'capability', 'volume'],
    example: 'The stadium has a seating capacity of 50,000.',
    exampleTranslation: '这个体育场能容纳五万人。'
  },
  { 
    word: 'abandon', 
    phonetic: 'əˈbæn.dən', 
    meaning: 'v. 放弃，抛弃；中止', 
    oxfordLevel: 'B2',
    collocations: ['abandon a project', 'abandon hope', 'reckless abandon'],
    synonyms: ['desert', 'leave', 'give up'],
    example: 'They had to abandon the ship due to the severe storm.',
    exampleTranslation: '由于强风暴，他们不得不弃船。'
  },
  { 
    word: 'genuine', 
    phonetic: 'ˈdʒen.ju.ɪn', 
    meaning: 'adj. 真正的；真诚的', 
    oxfordLevel: 'C1',
    collocations: ['genuine interest', 'genuine leather', 'genuine smile'],
    synonyms: ['authentic', 'real', 'sincere'],
    example: 'She showed a genuine interest in our work.',
    exampleTranslation: '她对我们的工作表现出了真正的兴趣。'
  }
]

const currentIndex = ref(0)
const currentWord = ref(wordList[0])

const checkDisciplineProgress = () => {
  const dailyTarget = parseInt(localStorage.getItem('dailyTarget') || '0')
  if (dailyTarget <= 0) return

  let progress = JSON.parse(localStorage.getItem('studyProgress') || '{}')
  let honors = JSON.parse(localStorage.getItem('userHonors') || '{"medals": 0, "flags": 0}')
  const today = new Date().toDateString()

  // 初始化或跨天重置
  if (progress.lastDate !== today) {
    // 如果昨天完成了，连击+1，否则连击断掉（简单起见这里直接重新计算今天）
    // 实际项目中需要严格判断时间差
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

const nextWord = () => {
  showMeaning.value = false
  currentIndex.value = (currentIndex.value + 1) % wordList.length
  currentWord.value = wordList[currentIndex.value]
  checkDisciplineProgress()
}

const markUnknow = () => {
  showMeaning.value = true
  checkDisciplineProgress()
}

const collectWord = () => {
  const todoWords = JSON.parse(localStorage.getItem('todoWords') || '[]')
  const exists = todoWords.find(w => w.word === currentWord.value.word)
  if (!exists) {
    todoWords.push(currentWord.value)
    localStorage.setItem('todoWords', JSON.stringify(todoWords))
    ElMessage.success(`"${currentWord.value.word}" Added to Todo Library`)
  } else {
    ElMessage.info('Data already exists in library')
  }
}
</script>

<style scoped>
.recitation-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  padding: 20px;
}
.word-card {
  width: 100%;
  max-width: 800px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}
.word-content {
  margin-top: 20px;
}
.bento-main {
  grid-column: 1 / -1;
  text-align: center;
  padding: 40px 0;
  border-bottom: 1px solid var(--glass-border);
}
.word-title {
  font-size: 4rem;
  margin: 0;
  letter-spacing: 4px;
}
.phonetic {
  color: var(--text-secondary);
  font-size: 1.2rem;
  margin-top: 10px;
}
.bento-detail {
  grid-column: 1 / -1;
  padding: 20px;
}
.meaning {
  font-size: 1.4rem;
  color: var(--text-primary);
  font-weight: bold;
  margin-bottom: 20px;
}
.extra-info {
  margin: 15px 0;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
}
.info-label {
  color: var(--text-secondary);
  min-width: 100px;
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 1px;
}
.synonym-text {
  color: var(--neon-cyan);
  font-style: italic;
}
.example-box {
  margin-top: 20px;
  padding: 20px;
  border-left: 4px solid var(--neon-cyan) !important;
}
.example-text {
  color: var(--text-primary);
  font-size: 1.1rem;
  margin: 10px 0 5px 0;
}
.example-translation {
  color: var(--text-secondary);
  font-size: 0.95rem;
  margin: 0;
}
.meaning-mask {
  grid-column: 1 / -1;
  height: 150px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  margin-top: 20px;
  border-style: dashed !important;
}
.meaning-mask:hover {
  background: rgba(0, 243, 255, 0.05) !important;
}
.action-buttons {
  margin-top: 40px;
  display: flex;
  justify-content: space-around;
  padding: 0 20px 20px;
}
.action-buttons .el-button {
  width: 40%;
  height: 50px;
  font-size: 1.1rem;
  letter-spacing: 2px;
}
</style>