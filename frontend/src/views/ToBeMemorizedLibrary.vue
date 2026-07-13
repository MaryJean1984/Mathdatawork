<template>
  <div class="library-container fluid-container">
    <el-card class="glass-card">
      <template #header>
        <div class="card-header">
          <span class="neon-text title">TODO LIBRARY ({{ todoWords.length }})</span>
          <el-button type="danger" plain size="small" @click="clearAll">清空待背库</el-button>
        </div>
      </template>
      <el-table :data="todoWords" style="width: 100%" empty-text="暂无收藏的单词" class="glass-table">
        <el-table-column prop="word" label="单词" width="180">
          <template #default="scope">
            <span class="neon-text">{{ scope.row.word }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="phonetic" label="音标" width="150" />
        <el-table-column prop="meaning" label="释义" />
        <el-table-column label="操作" width="120">
          <template #default="scope">
            <el-button size="small" type="danger" @click="removeWord(scope.$index)">移除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const todoWords = ref([])

const loadData = () => {
  todoWords.value = JSON.parse(localStorage.getItem('todoWords') || '[]')
}

const removeWord = (index) => {
  todoWords.value.splice(index, 1)
  localStorage.setItem('todoWords', JSON.stringify(todoWords.value))
  ElMessage.success('已从待背库移除')
}

const clearAll = () => {
  todoWords.value = []
  localStorage.setItem('todoWords', '[]')
  ElMessage.success('待背库已清空')
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