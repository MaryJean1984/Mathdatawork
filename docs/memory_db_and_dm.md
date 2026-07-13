# 双倍加分项专项说明文档

## 1. C++ 手写内存数据库方案 (替代原有 Java 方案)
为了处理 AI 听写时产生的超高并发临时会话数据，本项目使用 C++ 核心库实现了一个高性能内存数据库组件。

### 核心设计
- **线程安全存储**：使用 `std::unordered_map` 结合 `std::shared_mutex` (读写锁) 保证高并发读写安全。
- **过期机制 (TTL)**：内置独立的工作线程，定期扫描带有 TTL (Time-To-Live) 标记的键值对，并进行清理。
- **与 Crow 框架集成**：作为全局单例对象注入到 Crow 的路由上下文中，供控制器直接调用。

### C++ 核心实现简图
```cpp
#include <unordered_map>
#include <shared_mutex>
#include <string>

class MemoryDB {
private:
    std::unordered_map<std::string, std::string> store;
    mutable std::shared_mutex rw_mutex;

public:
    void set(const std::string& key, const std::string& value) {
        std::unique_lock<std::shared_mutex> lock(rw_mutex);
        store[key] = value;
    }

    std::string get(const std::string& key) const {
        std::shared_lock<std::shared_mutex> lock(rw_mutex);
        auto it = store.find(key);
        if (it != store.end()) return it->second;
        return "";
    }
};
```

## 2. 达梦数据库 (DM8) C++ 适配改造
虽然项目默认采用 MySQL Connector/C++，但也预留了国产达梦数据库的接入方案。达梦提供了 ODBC 和专用的 C/C++ 驱动接口 (DPI)。

**主要适配点：**
- **连接池改造**：替换为基于 DM DPI 的连接池。
- **方言转换**：将代码中特定的 MySQL 函数（如 `IFNULL`、`DATE_FORMAT`）通过宏定义或统一的数据访问层接口替换为达梦兼容的标准 SQL。