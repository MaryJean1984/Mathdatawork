<template>
  <div class="library-container fluid-container">
    <el-card class="glass-card">
      <template #header>
        <div class="card-header">
          <span class="neon-text title">ERROR LIBRARY ({{ errorWords.length }})</span>
          <el-button type="danger" plain size="small" @click="clearAll">清空错题库</el-button>
        </div>
      </template>
      <el-table :data="errorWords" style="width: 100%" empty-text="太棒了，目前没有错题！" class="glass-table">
        <el-table-column prop="word" label="单词" width="180">
          <template #default="scope">
            <span class="neon-text">{{ scope.row.word }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="meaning" label="释义" />
        <el-table-column prop="errorCount" label="错误次数" width="120" align="center">
          <template #default="scope">
            <el-tag :type="scope.row.errorCount >= 3 ? 'danger' : 'warning'" effect="dark">
              {{ scope.row.errorCount }} 次
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="scope">
            <el-button size="small" type="success" plain @click="removeWord(scope.$index)">已掌握</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const errorWords = ref([])

const loadData = () => {
  errorWords.value = JSON.parse(localStorage.getItem('errorWords') || '[]')
}

const removeWord = (index) => {
  errorWords.value.splice(index, 1)
  localStorage.setItem('errorWords', JSON.stringify(errorWords.value))
  ElMessage.success('已移出错题库')
}

const clearAll = () => {
  errorWords.value = []
  localStorage.setItem('errorWords', '[]')
  ElMessage.success('错题库已清空')
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.title {
  font-size: 1.5rem;
  font-weight: bold;
  letter-spacing: 2px;
}
.glass-table {
  background: transparent !important;
}
</style>