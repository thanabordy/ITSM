-- ============================================================
-- Migration: 02_system_settings
-- Description: Introduces System Settings, Dynamic Master Data, and RBAC
-- Created: 2026-02-14
-- Updated: Matches existing data in schema_with_demo_data.sql
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------
-- 1. System Configuration (Key-Value Store)
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE `system_settings` (
    `setup_key`     VARCHAR(50)     NOT NULL,
    `setup_value`   TEXT            DEFAULT NULL,
    `category`      VARCHAR(20)     NOT NULL DEFAULT 'general',
    `description`   VARCHAR(255)    DEFAULT NULL,
    `updated_at`    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`setup_key`),
    KEY `idx_settings_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 2. Master Data: Ticket Categories
-- Replaces hardcoded ENUMs/Strings
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `master_categories`;
CREATE TABLE `master_categories` (
    `id`            INT             AUTO_INCREMENT,
    `name`          VARCHAR(100)    NOT NULL,
    `type`          ENUM('Incident','Request','Problem','Change') NOT NULL DEFAULT 'Incident',
    `color`         VARCHAR(20)     DEFAULT '#6b7280' COMMENT 'Badge hex color',
    `is_active`     TINYINT(1)      NOT NULL DEFAULT 1,
    `created_at`    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_category_name` (`name`),
    KEY `idx_category_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 3. Master Data: Ticket Priorities & SLA
-- Replaces hardcoded strings & SLA logic
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `master_priorities`;
CREATE TABLE `master_priorities` (
    `id`            INT             AUTO_INCREMENT,
    `name`          VARCHAR(50)     NOT NULL,
    `level`         INT             NOT NULL COMMENT '1=Urgent, 4=Low',
    `color`         VARCHAR(20)     DEFAULT '#6b7280',
    `sla_response`  DECIMAL(5,2)    NOT NULL COMMENT 'Target hours for first response',
    `sla_resolve`   DECIMAL(5,2)    NOT NULL COMMENT 'Target hours for resolution',
    `is_active`     TINYINT(1)      NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_priority_name` (`name`),
    UNIQUE KEY `uk_priority_level` (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 4. Master Data: Departments
-- Replaces free-text department fields
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `master_departments`;
CREATE TABLE `master_departments` (
    `id`            INT             AUTO_INCREMENT,
    `name`          VARCHAR(100)    NOT NULL,
    `code`          VARCHAR(20)     DEFAULT NULL,
    `manager_id`    VARCHAR(10)     DEFAULT NULL,
    `is_active`     TINYINT(1)      NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_dept_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 5. Access Control: Roles
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
    `id`            INT             AUTO_INCREMENT,
    `name`          VARCHAR(50)     NOT NULL,
    `description`   VARCHAR(255)    DEFAULT NULL,
    `permissions`   JSON            DEFAULT NULL COMMENT 'JSON object of allowed actions',
    `is_system`     TINYINT(1)      NOT NULL DEFAULT 0 COMMENT 'Prevent deletion of system roles',
    `created_at`    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_role_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- DATA SEEDING (Matched with schema_with_demo_data.sql)
-- -----------------------------------------------------------

-- 1. System Settings
INSERT INTO `system_settings` (`setup_key`, `setup_value`, `category`, `description`) VALUES
('app_name', 'ITSM System', 'general', 'Application Title'),
('app_logo', '/logo.png', 'general', 'Logo URL'),
('maintenance_mode', 'false', 'general', 'System Maintenance Mode'),
('session_idle_timeout', '20', 'security', 'Frontend idle timeout in minutes'),
('session_token_expiry', '480', 'security', 'Backend JWT expiry in minutes'),
('ticket_prefix', 'TK-', 'service_desk', 'Prefix for Ticket IDs'),
('auto_close_days', '3', 'service_desk', 'Days to auto-close Resolved tickets'),
('smtp_host', '', 'email', 'SMTP Server Host'),
('smtp_port', '587', 'email', 'SMTP Server Port'),
('smtp_user', '', 'email', 'SMTP Username'),
('smtp_secure', 'tls', 'email', 'SMTP Security (tls/ssl)'),
('business_hours_start', '09:00', 'service_desk', 'Start of business day'),
('business_hours_end', '18:00', 'service_desk', 'End of business day');

-- 2. Departments (Includes both English & Thai as found in demo data)
INSERT INTO `master_departments` (`name`, `code`) VALUES
('IT', 'IT'),
('Human Resources', 'HR'),
('HR', 'HR_ALIAS'), -- Alias for mapping if needed, or unify
('Finance', 'FIN'),
('Sales', 'SALE'),
('Marketing', 'MKT'),
('Operations', 'OPS'),
('Management', 'MGT'),
('วิศวกรรม', 'ENG'),
('บัญชี', 'ACC'),
('ฝ่ายขาย', 'SAME_SALE'),
('การตลาด', 'SAME_MKT');

-- 3. Priorities (Matched EXACTLY with SLA Policies in demo data)
INSERT INTO `master_priorities` (`name`, `level`, `color`, `sla_response`, `sla_resolve`) VALUES
('Urgent', 1, '#dc2626', 1.00, 4.00),    -- Matches SLA Policy: 1h / 4h
('High', 2, '#ea580c', 2.00, 8.00),      -- Matches SLA Policy: 2h / 8h
('Medium', 3, '#3b82f6', 4.00, 24.00),   -- Matches SLA Policy: 4h / 24h
('Low', 4, '#64748b', 8.00, 72.00);      -- Matches SLA Policy: 8h / 72h (3 days)

-- 4. Ticket Categories (Matched with Tickets table demo data)
INSERT INTO `master_categories` (`name`, `type`, `color`) VALUES
('Hardware', 'Incident', '#ef4444'),
('Software', 'Incident', '#3b82f6'),
('Network', 'Incident', '#10b981'),
('Security', 'Incident', '#dc2626'),
('Access/Login', 'Request', '#f59e0b'), -- Kept as useful extra
('General Request', 'Request', '#8b5cf6');

-- 5. Roles (Matched with Users table demo data)
INSERT INTO `roles` (`name`, `description`, `is_system`, `permissions`) VALUES
('Admin', 'Super Administrator', 1, '{"admin": true, "settings": true, "reports": true, "ticket_delete": true, "user_manage": true}'),
('IT Manager', 'IT Management', 1, '{"admin": true, "settings": true, "reports": true, "ticket_delete": true, "user_manage": true}'),
('Senior Support', 'L2 Support', 0, '{"admin": false, "settings": false, "reports": true, "ticket_delete": false, "user_manage": true}'),
('Support Specialist', 'L1 Support', 0, '{"admin": false, "settings": false, "reports": false, "ticket_delete": false, "user_manage": false}'),
('Junior Support', 'Trainee', 0, '{"admin": false, "settings": false, "reports": false, "ticket_delete": false, "user_manage": false}'),
('User', 'Regular Employee', 1, '{"admin": false, "settings": false, "reports": false, "ticket_delete": false, "user_manage": false}');

SET FOREIGN_KEY_CHECKS = 1;
