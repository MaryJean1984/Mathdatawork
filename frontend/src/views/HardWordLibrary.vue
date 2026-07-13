<template>
  <div class="library-container fluid-container">
    <el-card class="glass-card">
      <template #header>
        <div class="card-header">
          <span class="neon-text title" style="color: #ff4d4f;">HARD MODE LIBRARY ({{ hardWords.length }})</span>
          <el-tag type="danger" effect="dark">这里是练习中错误达到 3 次以上的高频易错词</el-tag>
        </div>
      </template>
      <el-table :data="hardWords" style="width: 100%" empty-text="暂无难度词汇" class="glass-table">
        <el-table-column prop="word" label="单词" width="180">
          <template #default="scope">
            <span class="neon-text" style="color: #ff4d4f;">{{ scope.row.word }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="meaning" label="释义" />
        <el-table-column prop="addedReason" label="加入原因" width="180">
          <template #default="scope">
            <el-tag type="danger" effect="dark">{{ scope.row.addedReason }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="scope">
            <el-button size="small" type="success" plain @click="removeWord(scope.$index)">已攻克</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const hardWords = ref([])

const loadData = () => {
  hardWords.value = JSON.parse(localStorage.getItem('hardWords') || '[]')
}

const removeWord = (index) => {
  hardWords.value.splice(index, 1)
  localStorage.setItem('hardWords', JSON.stringify(hardWords.value))
  ElMessage.success('恭喜攻克该难度词汇！')
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