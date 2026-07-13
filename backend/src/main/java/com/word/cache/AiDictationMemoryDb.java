package com.word.cache;

import org.springframework.stereotype.Component;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * AI听写自定义内存数据库
 * 提供线程安全的缓存，并支持简单的过期清理机制（基于 TTL）
 */
@Component
public class AiDictationMemoryDb {

    // 使用 ConcurrentHashMap 保证线程安全
    private final Map<String, CacheItem> cache = new ConcurrentHashMap<>();
    
    // 定时任务执行器，用于清理过期数据
    private final ScheduledExecutorService cleaner = Executors.newSingleThreadScheduledExecutor();

    public AiDictationMemoryDb() {
        // 每分钟执行一次清理任务
        cleaner.scheduleAtFixedRate(this::cleanup, 1, 1, TimeUnit.MINUTES);
    }

    /**
     * 写入缓存数据
     * @param key 缓存键 (如 user_id_task_id)
     * @param value 缓存内容 (如 AI 听写识别结果)
     * @param ttl 过期时间 (毫秒)
     */
    public void put(String key, String value, long ttl) {
        long expireTime = System.currentTimeMillis() + ttl;
        cache.put(key, new CacheItem(value, expireTime));
    }

    /**
     * 读取缓存数据
     */
    public String get(String key) {
        CacheItem item = cache.get(key);
        if (item == null) {
            return null;
        }
        // 惰性删除
        if (System.currentTimeMillis() > item.expireTime) {
            cache.remove(key);
            return null;
        }
        return item.value;
    }

    /**
     * 删除缓存
     */
    public void remove(String key) {
        cache.remove(key);
    }

    /**
     * 定时清理过期缓存
     */
    private void cleanup() {
        long now = System.currentTimeMillis();
        cache.entrySet().removeIf(entry -> now > entry.getValue().expireTime);
    }

    /**
     * 缓存项内部类
     */
    private static class CacheItem {
        String value;
        long expireTime;

        CacheItem(String value, long expireTime) {
            this.value = value;
            this.expireTime = expireTime;
        }
    }
}
