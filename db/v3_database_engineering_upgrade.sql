-- ==========================================================
-- 词汇大世界 (MathDataWork) - 数据库 V3.0 工程化精进脚本
-- 涵盖：AES 对称加密、数据变更审计触发器、冷热分离归档机制
-- ==========================================================

-- ----------------------------------------------------------
-- 1. 敏感数据安全：数据库层面 AES 对称加密存储
-- ----------------------------------------------------------
-- 针对用户的手机号、邮箱等隐私数据，使用 MySQL 原生 AES_ENCRYPT/AES_DECRYPT 
-- 避免明文存储，即使数据库被拖库也无法轻易获取用户联系方式。

-- 将原有明文字段修改为 VARBINARY，以便存储加密后的二进制数据
ALTER TABLE sys_user 
MODIFY COLUMN `phone` VARBINARY(255) COMMENT '手机号码(AES加密存储)',
MODIFY COLUMN `email` VARBINARY(255) COMMENT '邮箱(AES加密存储)';

-- 示例：注册时使用加密写入 (密钥可配置为环境变量或固定盐值，例如 'MathDataWorkKey')
-- INSERT INTO sys_user (username, password, phone, email) 
-- VALUES ('user1', 'hashed_pwd', AES_ENCRYPT('13800138000', 'MathDataWorkKey'), AES_ENCRYPT('user1@mathdata.com', 'MathDataWorkKey'));

-- 示例：登录或查询时进行解密
-- SELECT username, CAST(AES_DECRYPT(phone, 'MathDataWorkKey') AS CHAR) AS phone_decrypted FROM sys_user;


-- ----------------------------------------------------------
-- 2. 自动化合规：利用触发器 (Triggers) 实现用户信息变更全自动审计
-- ----------------------------------------------------------
-- 创建用户信息审计日志表
DROP TABLE IF EXISTS `sys_user_audit`;
CREATE TABLE `sys_user_audit` (
  `audit_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `action_type` VARCHAR(10) NOT NULL COMMENT '操作类型：UPDATE, DELETE',
  `old_phone` VARBINARY(255),
  `new_phone` VARBINARY(255),
  `old_email` VARBINARY(255),
  `new_email` VARBINARY(255),
  `action_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`audit_id`),
  INDEX idx_user_id (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户信息审计日志表';

-- 创建触发器：当用户信息发生更新时，自动记录修改前后的敏感数据状态
DELIMITER //
CREATE TRIGGER trg_sys_user_update_audit
AFTER UPDATE ON sys_user
FOR EACH ROW
BEGIN
    IF OLD.phone != NEW.phone OR OLD.email != NEW.email THEN
        INSERT INTO sys_user_audit (user_id, action_type, old_phone, new_phone, old_email, new_email)
        VALUES (OLD.id, 'UPDATE', OLD.phone, NEW.phone, OLD.email, NEW.email);
    END IF;
END //
DELIMITER ;


-- ----------------------------------------------------------
-- 3. 性能治理：历史数据归档机制 (冷热数据分离)
-- ----------------------------------------------------------
-- 当用户学习记录 (study_record) 随时间爆炸式增长，即使有分区表，主表体积依然庞大。
-- 设计历史归档机制，将超过 180 天的非活跃记录迁移至历史表。

-- 1. 创建历史归档表 (结构与主表一致)
CREATE TABLE `study_record_history` LIKE `study_record`;
ALTER TABLE `study_record_history` COMMENT = '学习记录历史归档表 (冷数据)';

-- 2. 创建定时任务 (Event) 自动归档 180 天前的数据
-- 注意：需要 MySQL 开启事件调度器 (SET GLOBAL event_scheduler = ON;)
DELIMITER //
CREATE EVENT IF NOT EXISTS evt_archive_study_record
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    -- 开启事务
    START TRANSACTION;
    
    -- 将 180 天前的数据插入历史表
    INSERT INTO study_record_history 
    SELECT * FROM study_record WHERE create_time < DATE_SUB(NOW(), INTERVAL 180 DAY);
    
    -- 删除主表中的过期数据
    DELETE FROM study_record WHERE create_time < DATE_SUB(NOW(), INTERVAL 180 DAY);
    
    COMMIT;
END //
DELIMITER ;
