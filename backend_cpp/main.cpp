#include "crow.h"
#include <iostream>
#include <thread>
#include <chrono>
#include <unordered_map>
#include <shared_mutex>

// ==========================================
// 核心亮点 3：C++ 手写内存数据库 (支持并发读写)
// ==========================================
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
    
    void remove(const std::string& key) {
        std::unique_lock<std::shared_mutex> lock(rw_mutex);
        store.erase(key);
    }
};

// 全局内存数据库实例
MemoryDB memDB;

// ==========================================
// 模拟的底层数据库执行组件
// ==========================================
void executeSQL(const std::string& sql) {
    // 实际项目中这里将调用 MySQL Connector/C++ 的 executeQuery/executeUpdate
    std::cout << "[DB Execution] " << sql << std::endl;
}

int main()
{
    crow::SimpleApp app;

    CROW_ROUTE(app, "/")([](){
        return "MathDataWork C++ Backend Running.";
    });

    // ==========================================
    // 核心亮点 1：千万级深分页终极优化 (延迟关联 Deferred Join)
    // ==========================================
    CROW_ROUTE(app, "/api/words/page")([](const crow::request& req){
        // 获取分页参数，模拟深分页 (如 page=5000, size=20)
        auto page = req.url_params.get("page") ? std::stoi(req.url_params.get("page")) : 5000;
        auto size = req.url_params.get("size") ? std::stoi(req.url_params.get("size")) : 20;
        int offset = (page - 1) * size;

        // 构造延迟关联的高性能 SQL
        std::string optimizedSQL = 
            "SELECT w.id, w.word_name, w.oxford_data "
            "FROM word_library w "
            "INNER JOIN ( "
            "    SELECT id FROM word_library ORDER BY id LIMIT " + std::to_string(offset) + ", " + std::to_string(size) + 
            ") AS tmp ON w.id = tmp.id;";

        executeSQL(optimizedSQL);

        crow::json::wvalue res;
        res["status"] = "success";
        res["message"] = "Used Deferred Join for deep pagination.";
        res["sql_executed"] = optimizedSQL;
        return res;
    });

    // ==========================================
    // 核心亮点 2：三层缓存架构下的“延迟双删”策略保障数据一致性
    // ==========================================
    CROW_ROUTE(app, "/api/user/update").methods(crow::HTTPMethod::POST)([](const crow::request& req){
        auto body = crow::json::load(req.body);
        if (!body) return crow::response(400, "Invalid JSON");

        std::string userId = body["userId"].s();
        std::string newBio = body["bio"].s();
        std::string cacheKey = "user_info_" + userId;

        // 步骤 1：第一次删除缓存 (Redis & MemoryDB)
        memDB.remove(cacheKey);
        std::cout << "[Cache] 1st Delete cache for key: " << cacheKey << std::endl;

        // 步骤 2：更新底层的 MySQL 数据库
        std::string updateSQL = "UPDATE sys_user SET bio = '" + newBio + "' WHERE id = " + userId + ";";
        executeSQL(updateSQL);

        // 步骤 3：异步执行延迟双删 (Delayed Double-Delete)
        std::thread([cacheKey]() {
            // 模拟休眠 500ms 等待数据库主从同步完成
            std::this_thread::sleep_for(std::chrono::milliseconds(500));
            // 第二次删除缓存，彻底防止脏数据
            memDB.remove(cacheKey);
            std::cout << "[Cache] 2nd (Delayed) Delete cache for key: " << cacheKey << std::endl;
        }).detach(); // 分离线程，不阻塞当前主请求

        crow::json::wvalue res;
        res["status"] = "success";
        res["message"] = "User updated with Delayed Double-Delete strategy.";
        return crow::response(res);
    });

    // ==========================================
    // 核心亮点 4：MySQL 8.0 JSON 字段的高效处理与更新
    // ==========================================
    CROW_ROUTE(app, "/api/words/ai_detail").methods(crow::HTTPMethod::POST)([](const crow::request& req){
        auto body = crow::json::load(req.body);
        if (!body) return crow::response(400, "Invalid JSON");

        std::string wordId = body["wordId"].s();
        // 模拟 AI 接口返回的复杂 JSON 结构：同义词、反义词、例句、语境
        // 注意：C++11 raw string literal 用于方便地编写 JSON 字符串
        std::string aiGeneratedJson = R"({"synonyms": ["excellent", "superb"], "antonyms": ["poor", "bad"], "sentences": [{"text": "This is an outstanding project.", "level": "advanced"}]})";

        // 利用 MySQL 8.0 的 JSON 函数进行局部更新 (JSON_MERGE_PATCH)
        // 避免读取整个 JSON 字段后再回写，大幅提升数据库性能
        std::string updateSQL = 
            "UPDATE word_library "
            "SET ai_expansion_data = JSON_MERGE_PATCH(COALESCE(ai_expansion_data, '{}'), '" + aiGeneratedJson + "') "
            "WHERE id = " + wordId + ";";

        executeSQL(updateSQL);

        crow::json::wvalue res;
        res["status"] = "success";
        res["message"] = "JSON data merged efficiently using MySQL JSON functions.";
        res["sql_executed"] = updateSQL;
        return crow::response(res);
    });

    app.port(8080).multithreaded().run();
}