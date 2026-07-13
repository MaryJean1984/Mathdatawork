-- ==========================================================
-- 词汇大世界 (MathDataWork) - 数据库 V2.0 高级架构演进脚本
-- 涵盖：JSON非结构化存储、表分区、延迟关联深度分页优化
-- ==========================================================

-- ----------------------------------------------------------
-- 1. JSON 原生类型应用：改造词库表，支持牛津/AI高维富文本数据
-- ----------------------------------------------------------
ALTER TABLE word_library 
ADD COLUMN `oxford_data` JSON COMMENT '存储牛津字典非结构化数据(同义词、搭配、例句)',
ADD COLUMN `ai_derivation` JSON COMMENT '存储大模型生成的思维导图、词根词缀扩展';

-- 示例：插入 JSON 数据
-- UPDATE word_library SET oxford_data = '{"level": "B2", "synonyms": ["capability", "volume"], "collocations": ["build capacity"]}' WHERE word_name = 'capacity';

-- 示例：使用 JSON_EXTRACT 进行原生 JSON 查询 (查询所有牛津等级为 B2 的单词)
-- SELECT word_name, oxford_data->>'$.level' as level FROM word_library WHERE oxford_data->>'$.level' = 'B2';


-- ----------------------------------------------------------
-- 2. 表分区 (Table Partitioning)：冷热数据分离方案
-- ----------------------------------------------------------
-- 针对海量增长的 study_record (学习记录表)，按月份进行 RANGE 分区
-- 注意：分区表要求分区键必须是主键/唯一键的一部分
ALTER TABLE study_record 
DROP PRIMARY KEY,
ADD PRIMARY KEY (`id`, `create_time`);

ALTER TABLE study_record 
PARTITION BY RANGE (MONTH(create_time)) (
    PARTITION p_q1 VALUES LESS THAN (4) COMMENT 'Q1冷数据',
    PARTITION p_q2 VALUES LESS THAN (7) COMMENT 'Q2冷数据',
    PARTITION p_q3 VALUES LESS THAN (10) COMMENT 'Q3温数据',
    PARTITION p_q4 VALUES LESS THAN (13) COMMENT 'Q4热数据',
    PARTITION p_max VALUES LESS THAN MAXVALUE
);

-- 优化器会自动触发 Partition Pruning (分区裁剪)，例如查询 10 月份的数据时，直接跳过 p_q1, p_q2


-- ----------------------------------------------------------
-- 3. 终极索引优化：覆盖索引 (Covering Index)
-- ----------------------------------------------------------
-- 针对后台管理系统的高频查询：根据学习语种、学习阶段筛选用户名
-- 创建联合索引，使得查询所需列全在索引树上，实现零回表 (Using index)
CREATE INDEX idx_lang_stage_name ON sys_user(language_type, study_stage, username);

-- 覆盖索引生效示例：
-- EXPLAIN SELECT username FROM sys_user WHERE language_type = 'English' AND study_stage = 'CET6';


-- ----------------------------------------------------------
-- 4. 千万级深分页终极优化：延迟关联 (Deferred Join)
-- ----------------------------------------------------------
-- 场景：当词库表突破 10 万级，前端跳页到非常靠后的位置时
-- 传统致命慢 SQL：
-- SELECT * FROM word_library ORDER BY id LIMIT 100000, 20;

-- 优化后 SQL (可直接用于项目后端的 Mapper/DAO 层)：
-- 通过子查询走主键索引快速定位，再 INNER JOIN 取出全量字段
/*
SELECT w.* 
FROM word_library w 
INNER JOIN (
    SELECT id FROM word_library 
    ORDER BY id 
    LIMIT 100000, 20
) AS tmp 
ON w.id = tmp.id;
*/