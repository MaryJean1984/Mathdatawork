<template>
  <div class="word-recitation-container">
    <h2>单词背诵</h2>
    <el-card class="word-card" v-if="currentWord">
      <div class="word-content">
        <h1 class="word-title">{{ currentWord.word }}</h1>
        <div class="phonetic">[{{ currentWord.phonetic }}]</div>
        <el-button type="primary" plain @click="showMeaning = !showMeaning">
          {{ showMeaning ? '隐藏释义' : '显示释义' }}
        </el-button>
        <div class="meaning" v-show="showMeaning">
          <p>{{ currentWord.meaning }}</p>
          <p class="example">例句：{{ currentWord.example }}</p>
        </div>
      </div>
      <div class="actions">
        <el-button type="success" @click="nextWord">认识</el-button>
        <el-button type="warning" @click="nextWord">不认识</el-button>
      </div>
    </el-card>
    <el-empty v-else description="今天的单词已经背完啦！"></el-empty>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const showMeaning = ref(false)
const words = ref([
  { word: 'Algorithm', phonetic: 'ˈælɡərɪðəm', meaning: 'n. 算法', example: 'We need a better algorithm to sort the data.' },
  { word: 'Database', phonetic: 'ˈdeɪtəbeɪs', meaning: 'n. 数据库', example: 'The user information is stored in the database.' },
  { word: 'Frontend', phonetic: 'frʌntˈɛnd', meaning: 'n. 前端', example: 'She is a talented frontend developer.' }
])

const currentIndex = ref(0)
const currentWord = ref(words.value[0])

const nextWord = () => {
  showMeaning.value = false
  if (currentIndex.value < words.value.length - 1) {
    currentIndex.value++
    currentWord.value = words.value[currentIndex.value]
  } else {
    currentWord.value = null
  }
}
</script>

<style scoped>
.word-recitation-container {
  padding: 20px;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.word-card {
  width: 100%;
  max-width: 600px;
  text-align: center;
}
.word-title {
  font-size: 3em;
  margin-bottom: 10px;
}
.phonetic {
  color: #666;
  margin-bottom: 20px;
}
.meaning {
  margin-top: 20px;
  font-size: 1.2em;
}
.example {
  color: #888;
  font-style: italic;
  font-size: 0.9em;
}
.actions {
  margin-top: 30px;
  display: flex;
  justify-content: space-around;
}
</style>
