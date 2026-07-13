/*
 Navicat Premium Data Transfer
 Target Server Type    : MySQL
 Target Server Version : 80000
 File Encoding         : 65001
 
 需求:
 1. 创建数据库，utf8mb4.
 2. 9张核心表CREATE TABLE，sys_user增加全套用户信息.
 3. 全部索引CREATE INDEX.
 4. 每张表插入30条以上测试数据，sys_user填充完整信息.
 5. 单表CRUD示例，含用户录入/修改/查询/删除.
 6. 多表联查优化SQL.
 7. 4组慢SQL优化对比脚本.
 8. 聚合统计SQL.
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 创建数据库，utf8mb4
-- ----------------------------
CREATE DATABASE IF NOT EXISTS `mathdatawork` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `mathdatawork`;

-- ----------------------------
-- 2. 9张核心表CREATE TABLE，sys_user增加全套用户信息
-- ----------------------------

-- 表1：sys_dept (部门表)
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '部门ID',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父部门ID',
  `dept_name` VARCHAR(50) NOT NULL COMMENT '部门名称',
  `order_num` INT DEFAULT 0 COMMENT '显示顺序',
  `leader` VARCHAR(20) DEFAULT NULL COMMENT '负责人',
  `phone` VARCHAR(11) DEFAULT NULL COMMENT '联系电话',
  `email` VARCHAR(50) DEFAULT NULL COMMENT '邮箱',
  `status` TINYINT DEFAULT 1 COMMENT '部门状态（1正常 0停用）',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='部门表';

-- 表2：sys_user (用户信息表)
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` BIGINT DEFAULT NULL COMMENT '部门ID',
  `username` VARCHAR(30) NOT NULL COMMENT '用户名',
  `password` VARCHAR(100) NOT NULL COMMENT '密码',
  `real_name` VARCHAR(30) DEFAULT NULL COMMENT '真实姓名',
  `gender` TINYINT DEFAULT 0 COMMENT '性别（0未知 1男 2女）',
  `email` VARCHAR(50) DEFAULT NULL COMMENT '邮箱',
  `phone` VARCHAR(11) DEFAULT NULL COMMENT '手机号码',
  `avatar` VARCHAR(255) DEFAULT NULL COMMENT '头像路径',
  `status` TINYINT DEFAULT 1 COMMENT '帐号状态（1正常 0停用）',
  `login_ip` VARCHAR(128) DEFAULT NULL COMMENT '最后登录IP',
  `login_date` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户信息表';

-- 表3：sys_role (角色信息表)
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` VARCHAR(30) NOT NULL COMMENT '角色名称',
  `role_key` VARCHAR(100) NOT NULL COMMENT '角色权限字符串',
  `role_sort` INT NOT NULL COMMENT '显示顺序',
  `status` TINYINT DEFAULT 1 COMMENT '角色状态（1正常 0停用）',
  `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色信息表';

-- 表4：sys_user_role (用户和角色关联表)
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户和角色关联表';

-- 表5：sys_menu (菜单权限表)
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` VARCHAR(50) NOT NULL COMMENT '菜单名称',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父菜单ID',
  `order_num` INT DEFAULT 0 COMMENT '显示顺序',
  `path` VARCHAR(200) DEFAULT '' COMMENT '路由地址',
  `component` VARCHAR(255) DEFAULT NULL COMMENT '组件路径',
  `is_frame` TINYINT DEFAULT 0 COMMENT '是否为外链（1是 0否）',
  `menu_type` CHAR(1) DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `perms` VARCHAR(100) DEFAULT NULL COMMENT '权限标识',
  `icon` VARCHAR(100) DEFAULT '#' COMMENT '菜单图标',
  `status` TINYINT DEFAULT 1 COMMENT '菜单状态（1正常 0停用）',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜单权限表';

-- 表6：sys_role_menu (角色和菜单关联表)
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu` (
  `role_id` BIGINT NOT NULL COMMENT '角色ID',
  `menu_id` BIGINT NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色和菜单关联表';

-- 表7：biz_project (业务项目表)
DROP TABLE IF EXISTS `biz_project`;
CREATE TABLE `biz_project` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `project_name` VARCHAR(100) NOT NULL COMMENT '项目名称',
  `description` TEXT COMMENT '项目描述',
  `manager_id` BIGINT NOT NULL COMMENT '负责人ID',
  `status` TINYINT DEFAULT 1 COMMENT '状态（1进行中 2已完成 3延期 0取消）',
  `start_date` DATE DEFAULT NULL COMMENT '开始日期',
  `end_date` DATE DEFAULT NULL COMMENT '结束日期',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='业务项目表';

-- 表8：biz_task (业务任务表)
DROP TABLE IF EXISTS `biz_task`;
CREATE TABLE `biz_task` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `project_id` BIGINT NOT NULL COMMENT '所属项目ID',
  `task_name` VARCHAR(100) NOT NULL COMMENT '任务名称',
  `assignee_id` BIGINT DEFAULT NULL COMMENT '执行人ID',
  `priority` TINYINT DEFAULT 2 COMMENT '优先级（1高 2中 3低）',
  `status` TINYINT DEFAULT 1 COMMENT '状态（1待办 2进行中 3已完成）',
  `due_date` DATETIME DEFAULT NULL COMMENT '截止日期',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='业务任务表';

-- 表9：sys_log (操作日志记录)
DROP TABLE IF EXISTS `sys_log`;
CREATE TABLE `sys_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `title` VARCHAR(50) DEFAULT '' COMMENT '模块标题',
  `business_type` TINYINT DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` VARCHAR(100) DEFAULT '' COMMENT '方法名称',
  `request_method` VARCHAR(10) DEFAULT '' COMMENT '请求方式',
  `operator_type` TINYINT DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` VARCHAR(50) DEFAULT '' COMMENT '操作人员',
  `dept_name` VARCHAR(50) DEFAULT '' COMMENT '部门名称',
  `oper_url` VARCHAR(255) DEFAULT '' COMMENT '请求URL',
  `oper_ip` VARCHAR(128) DEFAULT '' COMMENT '主机地址',
  `oper_param` VARCHAR(2000) DEFAULT '' COMMENT '请求参数',
  `json_result` VARCHAR(2000) DEFAULT '' COMMENT '返回参数',
  `status` TINYINT DEFAULT 1 COMMENT '操作状态（1正常 0异常）',
  `error_msg` VARCHAR(2000) DEFAULT '' COMMENT '错误消息',
  `oper_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志记录';


-- ----------------------------
-- 3. 全部索引CREATE INDEX
-- ----------------------------
CREATE INDEX idx_sys_user_username ON sys_user(username);
CREATE INDEX idx_sys_user_phone ON sys_user(phone);
CREATE INDEX idx_sys_user_dept_id ON sys_user(dept_id);

CREATE INDEX idx_sys_dept_parent_id ON sys_dept(parent_id);

CREATE INDEX idx_sys_role_role_key ON sys_role(role_key);

CREATE INDEX idx_sys_menu_parent_id ON sys_menu(parent_id);

CREATE INDEX idx_biz_project_manager_id ON biz_project(manager_id);
CREATE INDEX idx_biz_project_status ON biz_project(status);

CREATE INDEX idx_biz_task_project_id ON biz_task(project_id);
CREATE INDEX idx_biz_task_assignee_id ON biz_task(assignee_id);
CREATE INDEX idx_biz_task_status ON biz_task(status);

CREATE INDEX idx_sys_log_oper_time ON sys_log(oper_time);
CREATE INDEX idx_sys_log_oper_name ON sys_log(oper_name);


-- ----------------------------
-- 4. 每张表插入30条以上测试数据 (使用 MySQL 8.0 CTE 递归生成)
-- ----------------------------

-- 插入31条部门数据
INSERT INTO `sys_dept` (`parent_id`, `dept_name`, `order_num`, `leader`, `phone`, `email`)
WITH RECURSIVE seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 31)
SELECT 
  IF(n=1, 0, 1), CONCAT('研发部门', n), n, CONCAT('主管', n), 
  CONCAT('1380000', LPAD(n, 4, '0')), CONCAT('dept', n, '@mathdata.com') 
FROM seq;

-- 插入31条用户数据
INSERT INTO `sys_user` (`dept_id`, `username`, `password`, `real_name`, `gender`, `email`, `phone`, `status`, `remark`)
WITH RECURSIVE seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 31)
SELECT 
  (n % 10) + 1, CONCAT('user', n), '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', 
  CONCAT('员工', n), IF(n % 2 = 0, 1, 2), CONCAT('user', n, '@mathdata.com'), 
  CONCAT('1390000', LPAD(n, 4, '0')), IF(n % 15 = 0, 0, 1), CONCAT('这是第', n, '个用户的备注')
FROM seq;

-- 插入31条角色数据
INSERT INTO `sys_role` (`role_name`, `role_key`, `role_sort`, `remark`)
WITH RECURSIVE seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 31)
SELECT 
  CONCAT('角色', n), CONCAT('role_', n), n, CONCAT('角色描述', n)
FROM seq;

-- 插入31条用户角色关联数据
INSERT INTO `sys_user_role` (`user_id`, `role_id`)
WITH RECURSIVE seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 31)
SELECT n, (n % 5) + 1 FROM seq;

-- 插入31条菜单数据
INSERT INTO `sys_menu` (`menu_name`, `parent_id`, `order_num`, `path`, `menu_type`, `perms`)
WITH RECURSIVE seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 31)
SELECT 
  CONCAT('菜单', n), IF(n <= 5, 0, (n % 5) + 1), n, CONCAT('/path', n), 
  IF(n <= 5, 'M', 'C'), CONCAT('sys:menu:', n)
FROM seq;

-- 插入31条角色菜单关联数据
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
WITH RECURSIVE seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 31)
SELECT (n % 10) + 1, n FROM seq;

-- 插入31条项目数据
INSERT INTO `biz_project` (`project_name`, `description`, `manager_id`, `status`, `start_date`, `end_date`)
WITH RECURSIVE seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 31)
SELECT 
  CONCAT('数据项目', n), CONCAT('项目描述', n), (n % 20) + 1, 
  (n % 3) + 1, DATE_ADD('2023-01-01', INTERVAL n DAY), DATE_ADD('2023-12-01', INTERVAL n DAY)
FROM seq;

-- 插入31条任务数据
INSERT INTO `biz_task` (`project_id`, `task_name`, `assignee_id`, `priority`, `status`, `due_date`)
WITH RECURSIVE seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 31)
SELECT 
  (n % 10) + 1, CONCAT('数据处理任务', n), (n % 30) + 1, 
  (n % 3) + 1, (n % 3) + 1, DATE_ADD('2023-05-01', INTERVAL n DAY)
FROM seq;

-- 插入31条操作日志数据
INSERT INTO `sys_log` (`title`, `business_type`, `method`, `request_method`, `oper_name`, `oper_ip`, `status`, `oper_time`)
WITH RECURSIVE seq AS (SELECT 1 AS n UNION ALL SELECT n + 1 FROM seq WHERE n < 31)
SELECT 
  CONCAT('模块', n), (n % 4), CONCAT('com.mathdatawork.Method', n), 
  IF(n % 2 = 0, 'GET', 'POST'), CONCAT('user', (n % 30) + 1), 
  CONCAT('192.168.1.', n), IF(n % 10 = 0, 0, 1), DATE_SUB(NOW(), INTERVAL n HOUR)
FROM seq;


-- ----------------------------
-- 5. 单表CRUD示例，含用户录入/修改/查询/删除
-- ----------------------------
-- 录入（新增用户）
INSERT INTO `sys_user` (`username`, `password`, `real_name`, `gender`, `email`, `phone`, `dept_id`) 
VALUES ('new_admin', 'e10adc3949ba59abbe56e057f20f883e', '新管理员', 1, 'admin@mathdata.com', '13888888888', 1);

-- 查询（根据用户名精准查询可用用户）
SELECT `id`, `username`, `real_name`, `email`, `phone`, `status` 
FROM `sys_user` 
WHERE `username` = 'new_admin' AND `status` = 1;

-- 修改（更新邮箱和手机号）
UPDATE `sys_user` 
SET `email` = 'update@mathdata.com', `phone` = '13999999999'
WHERE `username` = 'new_admin';

-- 删除（逻辑删除或物理删除，此处为物理删除）
DELETE FROM `sys_user` WHERE `username` = 'new_admin';


-- ----------------------------
-- 6. 多表联查优化SQL
-- ----------------------------
-- 需求：查询进行中项目下所有待办任务的详细信息，包含项目名称、任务名、执行人姓名及所在部门
-- 优化点：使用 INNER JOIN 代替 WHERE 隐式连接，利用索引字段过滤 (status, project_id)
SELECT 
    t.id AS task_id,
    t.task_name,
    p.project_name,
    a.real_name AS assignee_name,
    d.dept_name AS assignee_dept
FROM biz_task t
INNER JOIN biz_project p ON t.project_id = p.id
LEFT JOIN sys_user a ON t.assignee_id = a.id
LEFT JOIN sys_dept d ON a.dept_id = d.id
WHERE t.status = 1 AND p.status = 1;


-- ----------------------------
-- 7. 4组慢SQL优化对比脚本
-- ----------------------------
-- 【第1组：隐式类型转换导致索引失效】
-- 优化前（phone是VARCHAR，传入INT导致全表扫描）：
EXPLAIN SELECT * FROM sys_user WHERE phone = 13900000010;
-- 优化后（类型匹配，走 idx_sys_user_phone 索引）：
EXPLAIN SELECT * FROM sys_user WHERE phone = '13900000010';

-- 【第2组：左模糊查询导致索引失效】
-- 优化前（LIKE '%...' 导致全表扫描）：
EXPLAIN SELECT * FROM sys_user WHERE username LIKE '%user1%';
-- 优化后（右模糊，走 idx_sys_user_username 索引）：
EXPLAIN SELECT * FROM sys_user WHERE username LIKE 'user1%';

-- 【第3组：OR条件中存在无索引字段导致索引失效】
-- 优化前（remark无索引，OR会导致username索引也失效，全表扫描）：
EXPLAIN SELECT * FROM sys_user WHERE username = 'user1' OR remark = '测试';
-- 优化后（使用 UNION ALL 分离查询，前半部分可走索引）：
EXPLAIN 
SELECT * FROM sys_user WHERE username = 'user1'
UNION ALL
SELECT * FROM sys_user WHERE remark = '测试';

-- 【第4组：深度分页优化（Limit 偏移量过大）】
-- 优化前（LIMIT越往后越慢，扫描大量无用行）：
EXPLAIN SELECT * FROM sys_log ORDER BY oper_time DESC LIMIT 10000, 20;
-- 优化后（通过子查询先走索引查出主键，再JOIN回表查全字段）：
EXPLAIN 
SELECT l.* FROM sys_log l
INNER JOIN (
    SELECT id FROM sys_log ORDER BY oper_time DESC LIMIT 10000, 20
) tmp ON l.id = tmp.id;


-- ----------------------------
-- 8. 聚合统计SQL
-- ----------------------------
-- 需求：统计每个部门的用户总数、男性用户数、女性用户数
SELECT 
    d.dept_name,
    COUNT(u.id) AS total_users,
    SUM(CASE WHEN u.gender = 1 THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN u.gender = 2 THEN 1 ELSE 0 END) AS female_count
FROM sys_dept d
LEFT JOIN sys_user u ON d.id = u.dept_id
GROUP BY d.id, d.dept_name
ORDER BY total_users DESC;

SET FOREIGN_KEY_CHECKS = 1;
