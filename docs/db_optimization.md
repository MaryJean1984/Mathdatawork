# 数据库性能优化深度实战文档

本文档针对多语种单词记忆平台的数据库性能瓶颈，提供从索引、SQL语句到缓存架构的独立完整优化方案。

## 一、 索引优化板块

### 1. 索引设计原则
- **高选择性**：优先在区分度高的列（如 `user_id`、`phone`）上建立索引，状态列（如 `status` 性别、逻辑删除位）不建独立单列索引。
- **最左前缀匹配**：复合索引 `(a, b, c)` 的使用必须遵循最左前缀原则。查询 `a` 或 `a,b` 可走索引，仅查询 `b,c` 则失效。
- **覆盖索引**：尽量让查询的列包含在索引中，减少回表操作。如 `SELECT word_id, spell FROM word_info` 可建立 `(word_id, spell)` 的联合索引。

### 2. 索引失效排查清单 (Troubleshooting)
- 对索引列使用函数或运算：`WHERE YEAR(create_time) = 2023` -> 改为范围查询。
- 隐式类型转换：字符串字段未加引号 `WHERE phone = 13800000000` -> 必须写为 `WHERE phone = '13800000000'`。
- LIKE 左模糊查询：`WHERE spell LIKE '%apple'` 失效 -> 使用前缀匹配 `'apple%'` 或引入 Elasticsearch。
- OR 条件中存在无索引字段。

## 二、 SQL语句优化板块

### 1. 分页查询极致优化
在单词本浏览功能中，常遇深度分页问题：
```sql
-- 慢查询
SELECT * FROM word_info ORDER BY word_id LIMIT 100000, 20;
```
**优化方案1：延迟关联**
```sql
SELECT a.* FROM word_info a 
INNER JOIN (SELECT word_id FROM word_info ORDER BY word_id LIMIT 100000, 20) b 
ON a.word_id = b.word_id;
```
**优化方案2：游标分页 (Seek Method)**
前端记录上一页最后一条的ID：
```sql
SELECT * FROM word_info WHERE word_id > 100000 ORDER BY word_id LIMIT 20;
```

### 2. 批量操作优化
单词本导入功能需插入大量关联数据：
- 摒弃：在代码层 `for` 循环单条执行 `INSERT`。
- 推荐：使用批量插入 `INSERT INTO table (col1, col2) VALUES (v1, v2), (v3, v4)...`。
- 进阶：配置数据库连接池参数 `rewriteBatchedStatements=true` 并在 MyBatis 中使用 `BatchExecutor`。

### 3. EXISTS 与 IN 的选择
- 当外表大、内表小时，使用 `IN`。
- 当外表小、内表大且内表有索引时，使用 `EXISTS`。

## 三、 缓存优化板块

### 1. 缓存穿透 (Cache Penetration)
**现象**：黑客大量请求数据库中不存在的单词ID，导致请求穿透Redis直打MySQL。
**解决方案**：
- 接口层参数校验。
- 针对空结果也进行缓存，设置较短的过期时间（如 60s）。
- 引入 **布隆过滤器 (Bloom Filter)**，将所有真实存在的单词ID哈希映射到位图中，请求先过布隆过滤器。

### 2. 缓存击穿 (Cache Breakdown)
**现象**：某个极高频访问的热点单词（如 "hello"）缓存突然失效，瞬间大量并发请求打入数据库。
**解决方案**：
- 设置热点数据永不过期，或由后台定时任务主动刷新缓存。
- 使用 **互斥锁 (Mutex Lock / Redisson 分布式锁)**：发现缓存失效时，只有一个线程能去查库重建缓存，其他线程等待重试。

### 3. 缓存雪崩 (Cache Avalanche)
**现象**：大量单词缓存采用了相同的过期时间，导致在某一时刻同时失效，引发数据库宕机。
**解决方案**：
- 为缓存的过期时间增加一个随机扰动值：`expire_time = base_time + random(0, 3600)`。
- Redis 采用高可用集群架构（Cluster），防止单节点宕机引发雪崩。
- 熔断限流：在网关层（如 Sentinel）对查库请求进行限流降级。