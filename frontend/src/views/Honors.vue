<template>
  <div class="honors-container fluid-container">
    <div class="header-section">
      <h1 class="neon-text title">HONORS & DISCIPLINE</h1>
      <p class="subtitle">自律模式与个人荣誉墙</p>
    </div>

    <div class="bento-grid">
      <!-- 自律模式目标设置 -->
      <el-card class="glass-card bento-item">
        <template #header>
          <div class="card-title neon-text">🎯 自律模式目标设置</div>
        </template>
        <div class="target-setting">
          <p class="desc-text">设置您每日的背诵词汇目标，完成后将获得勋章奖励！</p>
          <div class="input-group">
            <el-input-number 
              v-model="targetInput" 
              :min="0" 
              :max="1000" 
              :step="10" 
              class="target-input" />
            <el-button type="primary" @click="saveTarget">保存目标</el-button>
          </div>
          
          <div class="progress-section" v-if="dailyTarget > 0">
            <p class="desc-text">今日进度：{{ wordsToday }} / {{ dailyTarget }}</p>
            <el-progress 
              :percentage="progressPercentage" 
              :status="progressPercentage >= 100 ? 'success' : ''" 
              :stroke-width="15" 
              striped 
              striped-flow />
          </div>
          <div v-else class="progress-section">
            <el-tag type="warning" effect="dark">当前未开启自律模式，请设置目标单词数！</el-tag>
          </div>
        </div>
      </el-card>

      <!-- 学习数据统计 -->
      <el-card class="glass-card bento-item">
        <template #header>
          <div class="card-title neon-text">📊 自律数据统计</div>
        </template>
        <div class="stats-grid">
          <div class="stat-box">
            <div class="stat-value neon-text" style="color: #00f3ff;">{{ streakDays }}</div>
            <div class="stat-label">当前连续打卡(天)</div>
          </div>
          <div class="stat-box">
            <div class="stat-value neon-text" style="color: #ffd04b;">{{ honors.medals }}</div>
            <div class="stat-label">累计勋章(枚)</div>
          </div>
          <div class="stat-box">
            <div class="stat-value neon-text" style="color: #ff4d4f;">{{ honors.flags }}</div>
            <div class="stat-label">毅力旗帜(面)</div>
          </div>
        </div>
      </el-card>

      <!-- 个人荣誉墙 -->
      <el-card class="glass-card bento-item full-width">
        <template #header>
          <div class="card-title neon-text">🏆 个人荣誉墙</div>
        </template>
        
        <div class="honor-section">
          <h3 class="section-title">自律勋章 (完成每日目标获得)</h3>
          <div class="honor-display" v-if="honors.medals > 0">
            <span class="honor-icon medal-glow" v-for="i in honors.medals" :key="'medal-'+i">🏅</span>
          </div>
          <el-empty v-else description="暂无勋章，去完成今天的背诵目标吧！" :image-size="80" />
        </div>

        <el-divider border-style="dashed" />

        <div class="honor-section">
          <h3 class="section-title">毅力旗帜 (连续30天完成目标获得)</h3>
          <div class="honor-display" v-if="honors.flags > 0">
            <span class="honor-icon flag-glow" v-for="i in honors.flags" :key="'flag-'+i">🚩</span>
          </div>
          <el-empty v-else description="暂无旗帜，坚持连续打卡30天即可解锁！" :image-size="80" />
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'

const targetInput = ref(0)
const dailyTarget = ref(0)
const wordsToday = ref(0)
const streakDays = ref(0)
const honors = ref({ medals: 0, flags: 0 })

const progressPercentage = computed(() => {
  if (dailyTarget.value <= 0) return 0
  const pct = Math.floor((wordsToday.value / dailyTarget.value) * 100)
  return pct > 100 ? 100 : pct
})

const loadData = () => {
  dailyTarget.value = parseInt(localStorage.getItem('dailyTarget') || '0')
  targetInput.value = dailyTarget.value

  const progress = JSON.parse(localStorage.getItem('studyProgress') || '{}')
  const today = new Date().toDateString()
  if (progress.lastDate === today) {
    wordsToday.value = progress.wordsToday || 0
  } else {
    wordsToday.value = 0
  }
  streakDays.value = progress.streakDays || 0

  honors.value = JSON.parse(localStorage.getItem('userHonors') || '{"medals": 0, "flags": 0}')
}

const saveTarget = () => {
  if (targetInput.value < 0) return
  dailyTarget.value = targetInput.value
  localStorage.setItem('dailyTarget', dailyTarget.value.toString())
  
  if (dailyTarget.value > 0) {
    ElMessage.success(`自律模式已开启！今日目标：${dailyTarget.value} 词`)
  } else {
    ElMessage.warning('自律模式已关闭')
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.honors-container {
  padding-top: 20px;
}
.header-section {
  text-align: center;
  margin-bottom: 40px;
}
.title {
  font-size: 3rem;
  margin: 0;
  letter-spacing: 3px;
}
.subtitle {
  color: var(--text-secondary);
  font-size: 1.2rem;
  letter-spacing: 2px;
  margin-top: 10px;
}
.card-title {
  font-size: 1.4rem;
  font-weight: bold;
}
.bento-item {
  display: flex;
  flex-direction: column;
}
.full-width {
  grid-column: 1 / -1;
}
.target-setting {
  padding: 10px;
}
.desc-text {
  color: var(--text-secondary);
  font-size: 1.1rem;
  margin-bottom: 20px;
}
.input-group {
  display: flex;
  gap: 20px;
  align-items: center;
  margin-bottom: 30px;
}
.target-input {
  width: 200px;
}
.progress-section {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px dashed var(--glass-border);
}
.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  padding: 20px 0;
}
.stat-box {
  background: rgba(0, 0, 0, 0.3);
  border-radius: 16px;
  padding: 30px 10px;
  text-align: center;
  border: 1px solid var(--glass-border);
}
.stat-value {
  font-size: 3.5rem;
  font-weight: 900;
  margin-bottom: 10px;
}
.stat-label {
  color: var(--text-secondary);
  font-size: 1rem;
}
.honor-section {
  padding: 20px;
}
.section-title {
  color: var(--text-primary);
  margin-bottom: 20px;
  font-size: 1.2rem;
}
.honor-display {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  padding: 20px;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
  min-height: 100px;
}
.honor-icon {
  font-size: 3rem;
  transition: all 0.3s ease;
  cursor: pointer;
}
.honor-icon:hover {
  transform: scale(1.2) translateY(-5px);
}
.medal-glow {
  filter: drop-shadow(0 0 10px rgba(255, 208, 75, 0.5));
}
.flag-glow {
  filter: drop-shadow(0 0 10px rgba(255, 77, 79, 0.5));
}
</style>