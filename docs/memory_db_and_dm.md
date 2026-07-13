# 核心技术演进方案：手写内存数据库与达梦国产化适配

## 一、 基于Java的独立升级版手写内存数据库方案

为了摆脱对外部中间件的强依赖，降低小型私有化部署的成本，系统研发了纯Java实现的内存数据库 `JMemoryDB`，用于替代部分 Redis 功能，承载全局配置与字典表的高速访问。

### 1. 核心架构设计
- **数据结构层**：基于 JDK 的 `ConcurrentHashMap` 实现键值对存储，保证并发读写安全。
- **过期淘汰机制**：
  - 惰性删除：Get操作时检查时间戳，若过期则删除并返回 null。
  - 定期删除：利用 `ScheduledThreadPoolExecutor` 守护线程，每秒随机抽取键进行过期检查。
  - 内存淘汰算法：实现类 `LinkedHashMap` 的 `accessOrder=true` 机制，当内存容量达到阈值（如 10万条）时，触发 LRU（最近最少使用）淘汰。

### 2. 核心代码结构示例
```java
public class JMemoryDB {
    // 核心数据容器，Value封装了数据内容与过期时间戳
    private final Map<String, CacheNode> cacheMap = new ConcurrentHashMap<>();
    private final int capacity;
    
    // LRU淘汰队列
    private final Deque<String> lruQueue = new ConcurrentLinkedDeque<>();

    public void put(String key, Object value, long ttlMillis) {
        // 容量控制与LRU淘汰逻辑...
        CacheNode node = new CacheNode(value, System.currentTimeMillis() + ttlMillis);
        cacheMap.put(key, node);
        lruQueue.remove(key);
        lruQueue.addFirst(key);
    }

    public Object get(String key) {
        CacheNode node = cacheMap.get(key);
        if (node == null) return null;
        if (node.isExpired()) {
            cacheMap.remove(key);
            lruQueue.remove(key);
            return null;
        }
        // 刷新LRU
        lruQueue.remove(key);
        lruQueue.addFirst(key);
        return node.getValue();
    }
}
```

### 3. 数据持久化策略 (AOF + RDB 简化版)
- **快照持久化 (RDB)**：每隔10分钟，将 `cacheMap` 序列化为 JSON 写入磁盘 `snapshot.data`。
- **恢复机制**：应用重启时，通过实现 Spring 的 `ApplicationRunner` 接口，自动读取文件并反序列化加载到内存。

---

## 二、 现有MySQL项目向达梦(DM8)数据库适配改造方案

响应国家信创号召，本平台全面支持从 MySQL 8.0 平滑迁移至国产达梦数据库 DM8。

### 1. 驱动与依赖替换
在 `pom.xml` 中移除 `mysql-connector-java`，引入达梦官方驱动：
```xml
<dependency>
    <groupId>com.dameng</groupId>
    <artifactId>DmJdbcDriver18</artifactId>
    <version>8.1.2.141</version>
</dependency>
```

### 2. 数据库连接池配置 (application.yml)
```yaml
spring:
  datasource:
    driver-class-name: dm.jdbc.driver.DmDriver
    url: jdbc:dm://127.0.0.1:5236/SCHEMA_NAME?zeroDateTimeBehavior=convertToNull&useUnicode=true&characterEncoding=utf-8
    username: dm_user
    password: dm_password
```

### 3. ORM框架方言适配 (MyBatis-Plus)
配置 MyBatis-Plus 的分页插件拦截器，将数据库方言显式指定为达梦：
```java
@Bean
public MybatisPlusInterceptor mybatisPlusInterceptor() {
    MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
    // 达梦数据库的分页语法与Oracle类似
    interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.DM));
    return interceptor;
}
```

### 4. DDL与DML语法差异性改造
- **自增主键**：MySQL 的 `AUTO_INCREMENT` 需修改为达梦的 `IDENTITY(1,1)`，代码中 `@TableId(type = IdType.AUTO)` 保持不变，底层驱动会进行兼容。
- **关键字冲突**：达梦对关键字（如 `domain`, `type`, `date`）极其敏感。若表字段冲突，需在 Mapper XML 中使用双引号 `""` 将字段包裹，而非 MySQL 的反引号 ` `` `。
- **大小写敏感**：达梦默认对象名大写敏感。建议在达梦初始化实例时，设置 `COMPATIBLE_MODE=4`（兼容MySQL模式），并在连接串中控制大小写敏感属性。
- **日期时间函数**：将代码中手写的 MySQL 特定函数如 `DATE_FORMAT()` 替换为达梦支持的 `TO_CHAR()`，或统一在 Java 业务层进行时间格式化。

### 5. 数据迁移方案
使用达梦官方提供的 **DTS (数据迁移工具)**，创建 MySQL 到 DM8 的迁移任务，自动完成表结构映射、数据全量同步及完整性校验。