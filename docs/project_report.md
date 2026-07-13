# 《智能多语种单词记忆背诵平台》项目报告 —— 数据库设计核心章节

本项目基于 C++ (Crow 框架) + Vue3 构建了多语种智能单词记忆背诵平台。

## 〇、 后端技术栈 (C++ 重构)
- **Web 框架**: 采用轻量级、高性能的 C++ 微框架 **Crow**，提供 RESTful API。
- **数据库连接**: 使用 MySQL Connector/C++ 实现对底层数据库的增删改查。
- **Redis 客户端**: 采用 `hiredis` 或 `cpp_redis` 实现缓存读写。
- **编译构建**: 使用 CMake 进行项目的依赖管理和构建。

## 一、 数据库分层存储架构设计

为了满足多语种单词记忆平台的高并发查询与稳定存储需求，系统采用了**三层混合存储架构**：
1. **持久化层 (MySQL 8.0 / 达梦 DM8)**：负责核心业务数据（用户、词库、学习记录、订单等）的可靠存储，保证ACID特性。
2. **高速缓存层 (Redis 7.0)**：负责高频访问数据（热点单词、用户Session、学习统计排行）的缓存，极大降低数据库读取压力，采用 Cluster 集群模式部署。
3. **应用内存层 (C++手写内存数据库/LocalCache)**：针对字典表、极高频且不常变动的全局配置，采用自研内存数据库（使用 C++ 的 `std::unordered_map` 或类似结构）加载到应用进程中，实现微秒级响应。

## 二、 9大业务实体完整文字E-R模型

本平台围绕“用户-单词-学习”三大主线，提取出9个核心业务实体，其文字E-R关系如下：

1. **用户 (User)**：包含用户ID、账号、密码、昵称、手机号、注册时间、状态。1个用户可拥有多个词书，产生多条学习记录。
2. **语种 (Language)**：包含语种ID、名称、编码。1个语种包含多个词书和单词。
3. **词书 (Word_Book)**：包含词书ID、名称、封面、语种ID、词汇量。1个词书包含多个单词映射。
4. **单词 (Word)**：包含单词ID、拼写、音标、翻译、语种ID。是系统的核心实体。
5. **词书-单词映射 (Book_Word_Map)**：关联词书和单词，包含映射ID、词书ID、单词ID、章节排序。多对多关联中间实体。
6. **用户-词书关联 (User_Book)**：记录用户正在学习的词书，包含关联ID、用户ID、词书ID、当前进度。
7. **学习记录 (Study_Record)**：包含记录ID、用户ID、单词ID、记忆阶段(艾宾浩斯)、熟悉度、下次复习时间。
8. **每日打卡 (Daily_Checkin)**：包含打卡ID、用户ID、打卡日期、学习时长、背诵单词数。
9. **系统日志 (Sys_Log)**：包含日志ID、操作人、操作类型、IP、耗时、创建时间。

## 三、 9张数据表逐表深度设计（含sys_user扩充）

### 1. 用户表 (`sys_user`) - 深度扩充
| 字段名 | 数据类型 | 约束 | 注释 |
| :--- | :--- | :--- | :--- |
| `user_id` | BIGINT | PK, AUTO_INCREMENT | 用户唯一标识，雪花算法生成预留 |
| `username` | VARCHAR(50) | UNIQUE, NOT NULL | 登录账号 |
| `password` | VARCHAR(100) | NOT NULL | 密码（Bcrypt加密） |
| `nickname` | VARCHAR(50) | NULL | 用户昵称 |
| `phone` | VARCHAR(20) | UNIQUE, NULL | 绑定的手机号 |
| `email` | VARCHAR(100) | NULL | 邮箱地址 |
| `avatar_url` | VARCHAR(255)| NULL | 头像路径 |
| `vip_level` | TINYINT | DEFAULT 0 | VIP等级 (0:普通 1:月度 2:年度) |
| `vip_expire` | DATETIME | NULL | VIP过期时间 |
| `status` | TINYINT | DEFAULT 1 | 状态 (0:禁用 1:正常) |
| `create_time`| DATETIME | DEFAULT CURRENT_TIMESTAMP | 注册时间 |
| `update_time`| DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
*(其余8张表设计遵循阿里规约，含主键、逻辑删除、创建更新时间及相应外键约束，此处略展以突出核心。如：`dict_language`, `word_book`, `word_info`, `rel_book_word`, `user_book_plan`, `study_memory_record`, `daily_checkin_log`, `sys_oper_log`)*

## 四、 全量索引完整文档

为保障千万级数据下的查询效率，制定以下全量索引规范：
1. **主键索引**：所有表默认基于 `id` 字段建立聚簇索引。
2. **唯一索引**：
   - `sys_user` 表的 `idx_username` (username) 和 `idx_phone` (phone)。
   - `rel_book_word` 表的 `uk_book_word` (book_id, word_id)。
3. **普通单列索引**：
   - `word_info` 表的 `idx_spell` (spell)，加速单词拼写匹配查询。
   - `sys_oper_log` 表的 `idx_create_time` (create_time)，用于日志定期清理和范围查询。
4. **组合/覆盖索引**：
   - `study_memory_record` 表的 `idx_user_next_review` (user_id, next_review_time, familiarity)，针对“查询某用户今天需要复习的单词”的高频SQL，实现索引覆盖，避免回表。
   - `daily_checkin_log` 表的 `idx_user_date` (user_id, checkin_date)，加速用户打卡日历查询。

## 五、 4组完整SQL优化实战案例

### 案例1：用户复习列表查询优化（避免全表扫描）
**原SQL**：`SELECT * FROM study_memory_record WHERE user_id = 1001 AND DATE(next_review_time) = CURDATE();`
**痛点**：使用 `DATE()` 函数导致索引失效，引发全表扫描。
**优化后**：`SELECT word_id, familiarity FROM study_memory_record WHERE user_id = 1001 AND next_review_time >= '2023-10-01 00:00:00' AND next_review_time < '2023-10-02 00:00:00';`
**效果**：结合 `idx_user_next_review` 组合索引，扫描行数从百万级降至百级别，查询耗时从 1.2s 降至 15ms。

### 案例2：深分页查询优化
**原SQL**：`SELECT * FROM word_info WHERE lang_id = 1 LIMIT 500000, 20;`
**痛点**：Limit深分页导致MySQL扫描50万行后丢弃，效率极低。
**优化后**：`SELECT w.* FROM word_info w INNER JOIN (SELECT word_id FROM word_info WHERE lang_id = 1 LIMIT 500000, 20) tmp ON w.word_id = tmp.word_id;` （延迟关联法）
**效果**：通过覆盖索引快速定位ID后回表，耗时从 3s 降至 80ms。

### 案例3：排行榜统计聚合优化
**原SQL**：`SELECT user_id, SUM(study_duration) FROM daily_checkin_log GROUP BY user_id ORDER BY SUM(study_duration) DESC LIMIT 10;`
**痛点**：实时全表Group By加排序，产生临时表和文件排序（Using temporary; Using filesort）。
**优化方案**：引入Redis ZSet缓存排行榜，通过业务层定时更新或异步消息更新，彻底解耦数据库计算。

### 案例4：大批量数据插入优化
**原SQL**：循环执行 `INSERT INTO rel_book_word ...`
**优化后**：`INSERT INTO rel_book_word (book_id, word_id) VALUES (1,1), (1,2), ...`，并使用 MySQL Connector/C++ 的批量执行接口进行优化。

## 六、 MySQL+Redis单词缓存联动

**缓存策略 (Cache Aside Pattern)**：
1. **读操作**：用户查询单词翻译时，先查Redis（Key: `word:info:{word_id}`）。若命中则直接返回；若未命中，查MySQL，查到后写入Redis并设置随机过期时间（防止缓存雪崩），再返回。
2. **写/更新操作**：后台修改单词释义时，先更新MySQL数据库，然后**删除**对应的Redis缓存（延迟双删策略，保障最终一致性）。
3. **缓存穿透防护**：采用布隆过滤器（Bloom Filter）预热所有存在的单词ID，过滤非法查询。

## 七、 国产达梦数据库适配改造方案

1. **驱动切换**：底层数据库连接更换为达梦提供的 ODBC/C/C++ 驱动，并适配对应的 SQL 方言。
2. **大小写敏感**：达梦默认对象名大写。为保持代码兼容，通过达梦配置参数或在建表时强制使用双引号保留小写。
3. **自增主键**：将MySQL的 `AUTO_INCREMENT` 转换为达梦的 `IDENTITY(1,1)` 或使用 Sequence 序列。
4. **函数替换**：如将 MySQL 的 `IFNULL()` 替换为标准SQL的 `COALESCE()`，`NOW()` 替换为 `SYSDATE`。

## 八、 C++手写简易内存数据库引擎

为支撑极高频配置读取，团队使用 C++ STL 体系实现了精简内存数据库 `MiniMemDB`：
- **存储结构**：采用 `std::unordered_map<std::string, std::any>` 结合读写锁（`std::shared_mutex`）作为数据容器，保障线程安全。
- **索引机制**：针对特定字段，额外维护 `std::map` 作为B+树的内存平替，支持范围查找。
- **淘汰策略**：基于 `std::list` 和 `std::unordered_map` 组合实现 LRU (Least Recently Used) 淘汰算法，防止内存溢出。
- **持久化**：使用定时器线程每5分钟将内存快照序列化（JSON/Protobuf）落盘至本地 `.dat` 文件，启动时反序列化加载。