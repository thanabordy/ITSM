-- ============================================================
-- ITSM System — Database Schema (Structure Only)
-- Generated: 2026-02-13
-- Compatible with: MySQL 8.0+ / MariaDB 10.5+
-- ============================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------
-- 1. Users (IT Staff + General Users — Unified Table)
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
    `id`            VARCHAR(10)     NOT NULL,
    `code`          VARCHAR(20)     NOT NULL,
    `gender`        ENUM('Male','Female','Other') DEFAULT NULL,
    `name`          VARCHAR(100)    NOT NULL,
    `name_en`       VARCHAR(100)    DEFAULT NULL COMMENT 'English name',
    `email`         VARCHAR(150)    NOT NULL,
    `username`      VARCHAR(50)     DEFAULT NULL,
    `password`      VARCHAR(255)    DEFAULT NULL COMMENT 'Hashed password (IT staff only)',
    `department`    VARCHAR(100)    DEFAULT NULL,
    `position`      VARCHAR(100)    DEFAULT NULL,
    `role`          VARCHAR(50)     NOT NULL DEFAULT 'User' COMMENT 'IT Manager, Senior Support, Support Specialist, Junior Support, User',
    `level`         TINYINT         DEFAULT NULL COMMENT 'IT hierarchy level (1=Manager, 2=Senior, etc.)',
    `supervisor_id` VARCHAR(10)     DEFAULT NULL,
    `avatar`        VARCHAR(10)     DEFAULT NULL COMMENT 'First character of name for avatar display',
    `phone`         VARCHAR(30)     DEFAULT NULL,
    `location`      VARCHAR(100)    DEFAULT NULL,
    `created_at`    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`    DATETIME        DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_users_code` (`code`),
    UNIQUE KEY `uk_users_email` (`email`),
    KEY `idx_users_department` (`department`),
    KEY `idx_users_role` (`role`),
    CONSTRAINT `fk_users_supervisor` FOREIGN KEY (`supervisor_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 2. User Skills (Many-to-Many)
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `user_skills`;
CREATE TABLE `user_skills` (
    `user_id`   VARCHAR(10) NOT NULL,
    `skill`     VARCHAR(50) NOT NULL,
    PRIMARY KEY (`user_id`, `skill`),
    CONSTRAINT `fk_user_skills_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 3. User Permissions
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `user_permissions`;
CREATE TABLE `user_permissions` (
    `user_id`       VARCHAR(10) NOT NULL,
    `permission`    VARCHAR(50) NOT NULL,
    PRIMARY KEY (`user_id`, `permission`),
    CONSTRAINT `fk_user_permissions_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 4. Assets (IT Equipment)
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `assets`;
CREATE TABLE `assets` (
    `id`            VARCHAR(10)     NOT NULL,
    `name`          VARCHAR(150)    NOT NULL,
    `type`          VARCHAR(50)     NOT NULL COMMENT 'Computer, Laptop, Monitor, Printer, Network',
    `brand`         VARCHAR(50)     DEFAULT NULL,
    `model`         VARCHAR(100)    DEFAULT NULL,
    `serial`        VARCHAR(100)    DEFAULT NULL,
    `specs`         VARCHAR(255)    DEFAULT NULL,
    `location`      VARCHAR(100)    DEFAULT NULL,
    `status`        ENUM('Active','In Repair','Damaged','Retired') NOT NULL DEFAULT 'Active',
    `purchase_date` DATE            DEFAULT NULL,
    `warranty_end`  DATE            DEFAULT NULL,
    `assigned_to`   VARCHAR(10)     DEFAULT NULL,
    `created_at`    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`    DATETIME        DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_assets_serial` (`serial`),
    KEY `idx_assets_status` (`status`),
    KEY `idx_assets_type` (`type`),
    CONSTRAINT `fk_assets_assigned_to` FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 5. Tickets (Main)
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `tickets`;
CREATE TABLE `tickets` (
    `id`                VARCHAR(20)     NOT NULL COMMENT 'e.g. TK-2024-001',
    `title`             VARCHAR(255)    NOT NULL,
    `description`       TEXT            DEFAULT NULL,
    `status`            ENUM('Open','In Progress','Pending','Resolved','Closed','Rejected') NOT NULL DEFAULT 'Open',
    `priority`          VARCHAR(20)     NOT NULL DEFAULT 'Medium' COMMENT 'Low, Medium, High, Urgent',
    `type`              ENUM('Incident','Request') NOT NULL DEFAULT 'Incident',
    `category`          VARCHAR(50)     NOT NULL COMMENT 'Hardware, Software, Network, Security',
    `user_email`        VARCHAR(150)    NOT NULL COMMENT 'Requester email',
    `channel`           VARCHAR(30)     DEFAULT NULL COMMENT 'Phone, Email, Walk-in, Web Portal, Line',
    `asset_id`          VARCHAR(10)     DEFAULT NULL,
    `urgency`           VARCHAR(10)     DEFAULT 'Medium' COMMENT 'Low, Medium, High',
    `impact`            VARCHAR(10)     DEFAULT 'Medium' COMMENT 'Low, Medium, High',
    `internal_note`     TEXT            DEFAULT NULL COMMENT 'Internal staff notes',
    `pending_reason`    TEXT            DEFAULT NULL COMMENT 'Reason when status=Pending',
    `root_cause`        TEXT            DEFAULT NULL COMMENT 'Root cause when Resolved/Closed',
    `resolution_note`   TEXT            DEFAULT NULL COMMENT 'Resolution details when Resolved/Closed',
    `csat_score`        TINYINT         DEFAULT NULL COMMENT '1-5 rating',
    `csat_comment`      TEXT            DEFAULT NULL,
    `sla_response_due`  DATETIME        DEFAULT NULL,
    `sla_resolve_due`   DATETIME        DEFAULT NULL,
    `sla_response_met`  TINYINT(1)      DEFAULT NULL COMMENT '1=met, 0=breached, NULL=pending',
    `sla_resolve_met`   TINYINT(1)      DEFAULT NULL COMMENT '1=met, 0=breached, NULL=pending',
    `created_at`        DATETIME        NOT NULL,
    `updated_at`        DATETIME        DEFAULT NULL,
    `deleted_at`    DATETIME        DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_tickets_status` (`status`),
    KEY `idx_tickets_priority` (`priority`),
    KEY `idx_tickets_category` (`category`),
    KEY `idx_tickets_type` (`type`),
    KEY `idx_tickets_user_email` (`user_email`),
    KEY `idx_tickets_created_at` (`created_at`),
    CONSTRAINT `fk_tickets_asset` FOREIGN KEY (`asset_id`) REFERENCES `assets`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 6. Ticket Assignees (Multi-Assignee)
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `ticket_assignees`;
CREATE TABLE `ticket_assignees` (
    `ticket_id`     VARCHAR(20) NOT NULL,
    `user_id`       VARCHAR(10) NOT NULL,
    `assigned_at`   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ticket_id`, `user_id`),
    CONSTRAINT `fk_ticket_assignees_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_ticket_assignees_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 7. Ticket Timeline (Activity Log)
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `ticket_timeline`;
CREATE TABLE `ticket_timeline` (
    `id`            INT             AUTO_INCREMENT,
    `ticket_id`     VARCHAR(20)     NOT NULL,
    `action`        VARCHAR(100)    NOT NULL,
    `user_name`     VARCHAR(100)    NOT NULL,
    `detail`        TEXT            DEFAULT NULL,
    `created_at`    DATETIME        NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_timeline_ticket` (`ticket_id`),
    CONSTRAINT `fk_timeline_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 8. Ticket Attachments
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `ticket_attachments`;
CREATE TABLE `ticket_attachments` (
    `id`            INT             AUTO_INCREMENT,
    `ticket_id`     VARCHAR(20)     NOT NULL,
    `file_name`     VARCHAR(255)    NOT NULL,
    `file_type`     VARCHAR(100)    NOT NULL,
    `file_size`     INT             DEFAULT NULL COMMENT 'in bytes',
    `file_path`     VARCHAR(500)    NOT NULL COMMENT 'Storage path or URL',
    `uploaded_at`   TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_attachments_ticket` (`ticket_id`),
    CONSTRAINT `fk_attachments_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 9. Knowledge Base Articles
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `kb_articles`;
CREATE TABLE `kb_articles` (
    `id`            VARCHAR(10)     NOT NULL,
    `title`         VARCHAR(255)    NOT NULL,
    `category`      VARCHAR(50)     NOT NULL,
    `content`       TEXT            NOT NULL,
    `is_public`     TINYINT(1)      NOT NULL DEFAULT 1,
    `views`         INT             NOT NULL DEFAULT 0,
    `images`        JSON            DEFAULT NULL COMMENT 'Array of image objects [{name,type,data}]',
    `created_at`    DATE            NOT NULL,
    `updated_at`    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`    DATETIME        DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_kb_category` (`category`),
    KEY `idx_kb_public` (`is_public`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 10. Knowledge Base Tags
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `kb_tags`;
CREATE TABLE `kb_tags` (
    `article_id`    VARCHAR(10)     NOT NULL,
    `tag`           VARCHAR(50)     NOT NULL,
    PRIMARY KEY (`article_id`, `tag`),
    CONSTRAINT `fk_kb_tags_article` FOREIGN KEY (`article_id`) REFERENCES `kb_articles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 11. SLA Policies
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `sla_policies`;
CREATE TABLE `sla_policies` (
    `priority`          VARCHAR(20)     NOT NULL,
    `response_time`     INT             NOT NULL COMMENT 'in hours',
    `resolve_time`      INT             NOT NULL COMMENT 'in hours',
    `escalate_after`    INT             NOT NULL COMMENT 'in hours',
    `unit`              VARCHAR(10)     NOT NULL DEFAULT 'hours',
    PRIMARY KEY (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 12. Change Requests
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `change_requests`;
CREATE TABLE `change_requests` (
    `id`                VARCHAR(10)     NOT NULL,
    `title`             VARCHAR(255)    NOT NULL,
    `description`       TEXT            DEFAULT NULL,
    `type`              VARCHAR(20)     NOT NULL COMMENT 'Normal, Standard, Major, Emergency',
    `risk`              VARCHAR(20)     NOT NULL COMMENT 'Low, Medium, High, Critical',
    `status`            VARCHAR(30)     NOT NULL DEFAULT 'Pending' COMMENT 'Pending, Under Review, Approved, Rejected, Completed',
    `requested_by`      VARCHAR(10)     DEFAULT NULL,
    `scheduled_date`    DATE            DEFAULT NULL,
    `impact`            TEXT            DEFAULT NULL,
    `rollback_plan`     TEXT            DEFAULT NULL,
    `created_at`        TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_change_status` (`status`),
    CONSTRAINT `fk_change_requested_by` FOREIGN KEY (`requested_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 13. Problems
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `problems`;
CREATE TABLE `problems` (
    `id`            VARCHAR(10)     NOT NULL,
    `title`         VARCHAR(255)    NOT NULL,
    `description`   TEXT            DEFAULT NULL,
    `root_cause`    TEXT            DEFAULT NULL,
    `status`        VARCHAR(30)     NOT NULL DEFAULT 'Investigating' COMMENT 'Investigating, Identified, Resolved, Closed',
    `workaround`    TEXT            DEFAULT NULL,
    `created_at`    DATE            NOT NULL,
    `updated_at`    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_problem_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 14. Problem ↔ Ticket Relations
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `problem_related_tickets`;
CREATE TABLE `problem_related_tickets` (
    `problem_id`    VARCHAR(10) NOT NULL,
    `ticket_id`     VARCHAR(20) NOT NULL,
    PRIMARY KEY (`problem_id`, `ticket_id`),
    CONSTRAINT `fk_prt_problem` FOREIGN KEY (`problem_id`) REFERENCES `problems`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_prt_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 15. Notifications
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
    `id`            VARCHAR(10)     NOT NULL,
    `type`          VARCHAR(30)     NOT NULL COMMENT 'ticket_created, ticket_assigned, ticket_resolved, sla_warning, csat_request, escalation, change_request',
    `to_email`      VARCHAR(150)    NOT NULL,
    `subject`       VARCHAR(255)    NOT NULL,
    `status`        VARCHAR(20)     NOT NULL DEFAULT 'Sent',
    `sent_at`       DATETIME        NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_notifications_type` (`type`),
    KEY `idx_notifications_sent_at` (`sent_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 16. CSAT Responses
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `csat_responses`;
CREATE TABLE `csat_responses` (
    `id`            INT             AUTO_INCREMENT,
    `ticket_id`     VARCHAR(20)     NOT NULL,
    `score`         TINYINT         NOT NULL COMMENT '1-5',
    `comment`       TEXT            DEFAULT NULL,
    `response_date` DATETIME        NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_csat_ticket` (`ticket_id`),
    CONSTRAINT `fk_csat_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 17. Service Catalog — Categories
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `service_categories`;
CREATE TABLE `service_categories` (
    `id`            VARCHAR(20)     NOT NULL,
    `name`          VARCHAR(100)    NOT NULL,
    `icon`          VARCHAR(50)     DEFAULT NULL COMMENT 'FontAwesome class',
    `description`   VARCHAR(255)    DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------
-- 18. Service Catalog — Items
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `service_items`;
CREATE TABLE `service_items` (
    `id`            VARCHAR(20)     NOT NULL,
    `category_id`   VARCHAR(20)     NOT NULL,
    `name`          VARCHAR(150)    NOT NULL,
    `description`   VARCHAR(255)    DEFAULT NULL,
    `ticket_category` VARCHAR(50)   DEFAULT NULL COMMENT 'Maps to ticket category',
    `ticket_type`   ENUM('Incident','Request') NOT NULL DEFAULT 'Request',
    `icon`          VARCHAR(50)     DEFAULT NULL COMMENT 'FontAwesome class',
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_service_items_category` FOREIGN KEY (`category_id`) REFERENCES `service_categories`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
