<template>
  <el-container class="app-container">
    <el-header>
      <el-menu mode="horizontal" router :default-active="$route.path">
        <el-menu-item index="/">首页 (注册)</el-menu-item>
        <el-menu-item index="/profile">个人资料</el-menu-item>
        <el-menu-item index="/admin">用户管理</el-menu-item>
        <el-menu-item index="/word-recitation">单词背诵</el-menu-item>
        <el-menu-item index="/ai-dictation">AI听写</el-menu-item>
      </el-menu>
    </el-header>
    <el-main>
      <router-view></router-view>
    </el-main>
  </el-container>
</template>

<script setup>
</script>

<style>
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}
.app-container {
  height: 100vh;
}
</style>
