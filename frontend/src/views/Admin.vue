<template>
  <div class="admin-container fluid-container">
    <el-card class="glass-card">
      <template #header>
        <div class="card-header">
          <span class="neon-text title">ADMIN DASHBOARD</span>
          <el-button type="primary" class="glow-btn" size="small">ADD USER</el-button>
        </div>
      </template>
      <el-table :data="tableData" style="width: 100%" class="glass-table">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" width="180">
          <template #default="scope">
            <span class="neon-text">{{ scope.row.username }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="role" label="角色" width="120">
          <template #default="scope">
            <el-tag :type="scope.row.role === 'admin' ? 'danger' : 'success'" effect="dark">{{ scope.row.role }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="scope">
            <el-button size="small" @click="handleEdit(scope.$index, scope.row)">编辑</el-button>
            <el-button size="small" type="danger" plain @click="handleDelete(scope.$index, scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const tableData = ref([
  { id: 1, username: 'admin', email: 'admin@example.com', role: 'admin' },
  { id: 2, username: 'student1', email: 'stu1@example.com', role: 'student' },
  { id: 3, username: 'teacher1', email: 'tea1@example.com', role: 'teacher' }
])

const handleEdit = (index, row) => {
  ElMessage.info(`编辑用户: ${row.username}`)
}

const handleDelete = (index, row) => {
  ElMessageBox.confirm(
    `确定要删除用户 ${row.username} 吗？`,
    '警告',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).then(() => {
    tableData.value.splice(index, 1)
    ElMessage({
      type: 'success',
      message: '删除成功',
    })
  }).catch(() => {
    ElMessage({
      type: 'info',
      message: '已取消删除',
    })
  })
}
</script>

<style scoped>
.admin-container {
  padding: 20px;
}
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
.glow-btn {
  letter-spacing: 1px;
}
</style>
