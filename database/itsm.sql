-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 14, 2026 at 08:23 AM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `itsm`
--

-- --------------------------------------------------------

--
-- Table structure for table `assets`
--

CREATE TABLE `assets` (
  `id` varchar(10) NOT NULL,
  `name` varchar(150) NOT NULL,
  `type` varchar(50) NOT NULL COMMENT 'Computer, Laptop, Monitor, Printer, Network',
  `brand` varchar(50) DEFAULT NULL,
  `model` varchar(100) DEFAULT NULL,
  `serial` varchar(100) DEFAULT NULL,
  `specs` varchar(255) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `status` enum('Active','In Repair','Damaged','Retired') NOT NULL DEFAULT 'Active',
  `purchase_date` date DEFAULT NULL,
  `warranty_end` date DEFAULT NULL,
  `assigned_to` varchar(10) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `assets`
--

INSERT INTO `assets` (`id`, `name`, `type`, `brand`, `model`, `serial`, `specs`, `location`, `status`, `purchase_date`, `warranty_end`, `assigned_to`, `created_at`, `updated_at`, `deleted_at`) VALUES
('A001', 'Desktop PC - การเงิน', 'Computer', 'Dell', 'OptiPlex 7090', 'DEL-7090-001', 'i7-11700 / 16GB / SSD 512GB', 'ชั้น 3 - ฝ่ายการเงิน', 'Active', '2023-03-15', '2026-03-15', 'U001', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('A002', 'Laptop - HR', 'Laptop', 'Lenovo', 'ThinkPad T14', 'LEN-T14-002', 'i5-1235U / 8GB / SSD 256GB', 'ชั้น 4 - HR', 'Active', '2023-06-01', '2026-06-01', 'U002', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('A003', 'Monitor 27\" - HR', 'Monitor', 'Samsung', 'S27A700NW', 'SAM-27-003', NULL, 'ชั้น 4 - HR', 'In Repair', NULL, NULL, 'U002', '2026-02-13 14:25:48', '2026-02-14 06:38:31', NULL),
('A004', 'Desktop PC - บัญชี', 'Computer', 'HP', 'ProDesk 400 G9', 'HP-400-004', 'i5-12500 / 16GB / SSD 512GB', 'ชั้น 3 - ฝ่ายบัญชี', 'Active', '2023-01-15', '2026-01-15', 'U004', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('A005', 'Printer ชั้น 3', 'Printer', 'HP', 'LaserJet Pro M404dn', 'HP-LJ-005', 'Mono / Duplex / Network', 'ชั้น 3 - แผนกรวม', 'In Repair', '2022-08-01', '2025-08-01', NULL, '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('A006', 'Switch ชั้น 5', 'Network', 'Cisco', 'Catalyst 2960X', 'CIS-2960-006', '48-port GigE PoE+', 'ชั้น 5 - Server Room', 'Active', '2022-06-01', '2025-06-01', NULL, '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('A007', 'Access Point ชั้น 5', 'Network', 'Ubiquiti', 'UniFi 6 Pro', 'UBI-U6-007', 'WiFi 6 / 5.3 Gbps', 'ชั้น 5 - ห้องประชุม', 'Active', '2023-09-01', '2025-09-01', NULL, '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('A008', 'Laptop - การตลาด', 'Laptop', 'Apple', 'MacBook Pro 14\"', 'APL-MBP-008', 'M2 Pro / 16GB / 512GB', 'ชั้น 4 - ฝ่ายการตลาด', 'Active', '2023-11-01', '2025-11-01', 'U003', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('A009', 'Laptop - วิศวกรรม', 'Laptop', 'Dell', 'Precision 5570', 'DEL-5570-009', 'i7-12800H / 32GB / SSD 1TB', 'ชั้น 2 - วิศวกรรม', 'Active', '2023-04-01', '2026-04-01', 'U005', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('A010', 'Firewall', 'Network', 'Fortinet', 'FortiGate 100F', 'FGT-100F-010', '20 Gbps / UTM', 'ชั้น 5 - Server Room', 'Active', '2023-01-01', '2026-01-01', NULL, '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `change_requests`
--

CREATE TABLE `change_requests` (
  `id` varchar(10) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `type` varchar(20) NOT NULL COMMENT 'Normal, Standard, Major, Emergency',
  `risk` varchar(20) NOT NULL COMMENT 'Low, Medium, High, Critical',
  `status` varchar(30) NOT NULL DEFAULT 'Pending' COMMENT 'Pending, Under Review, Approved, Rejected, Completed',
  `requested_by` varchar(10) DEFAULT NULL,
  `scheduled_date` date DEFAULT NULL,
  `impact` text DEFAULT NULL,
  `rollback_plan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `change_requests`
--

INSERT INTO `change_requests` (`id`, `title`, `description`, `type`, `risk`, `status`, `requested_by`, `scheduled_date`, `impact`, `rollback_plan`, `created_at`, `updated_at`) VALUES
('CR001', 'อัพเกรด Firewall Rules', 'ปรับ Firewall rules ใหม่เพื่อ Block ช่องโหว่ CVE-2024-XXXX', 'Normal', 'High', 'Approved', 'ST001', '2024-01-20', 'Internet อาจ Downtime 30 นาที ระหว่าง 22:00-22:30', 'Restore Firewall config เดิมจาก Backup', '2026-02-13 14:25:48', '2026-02-13 14:25:48'),
('CR002', 'เพิ่ม Memory Server', 'เพิ่ม RAM จาก 32GB เป็น 64GB สำหรับ ERP Server', 'Standard', 'Medium', 'Pending', 'ST002', '2024-01-25', 'ERP Downtime 1 ชั่วโมง', 'ถอด RAM ใหม่ออก ใส่ RAM เดิมกลับ', '2026-02-13 14:25:48', '2026-02-13 14:25:48'),
('CR003', 'ย้าย Email Server ไป Cloud', 'Migrate Exchange On-premise ไปใช้ Microsoft 365', 'Major', 'Critical', 'Under Review', 'ST001', '2024-02-15', 'Email อาจใช้งานไม่ได้ 4-8 ชั่วโมง ระหว่าง Migration', 'Rollback DNS MX Record กลับ On-premise', '2026-02-13 14:25:48', '2026-02-13 14:25:48');

-- --------------------------------------------------------

--
-- Table structure for table `csat_responses`
--

CREATE TABLE `csat_responses` (
  `id` int(11) NOT NULL,
  `ticket_id` varchar(20) NOT NULL,
  `score` tinyint(4) NOT NULL COMMENT '1-5',
  `comment` text DEFAULT NULL,
  `response_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `csat_responses`
--

INSERT INTO `csat_responses` (`id`, `ticket_id`, `score`, `comment`, `response_date`) VALUES
(1, 'TK-2024-003', 5, 'แก้ไขเร็วมาก ขอบคุณครับ', '2024-01-13 14:30:00'),
(2, 'TK-2024-007', 4, 'ขอบคุณครับ แต่ใช้เวลานิดนึง', '2024-01-12 16:00:00'),
(3, 'TK-2024-009', 4, 'เปลี่ยนจอใหม่ให้ ขอบคุณค่ะ', '2024-01-14 11:00:00'),
(4, 'TK-2024-011', 5, 'รวดเร็วมากครับ', '2024-01-11 17:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `kb_articles`
--

CREATE TABLE `kb_articles` (
  `id` varchar(10) NOT NULL,
  `title` varchar(255) NOT NULL,
  `category` varchar(50) NOT NULL,
  `content` text NOT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 1,
  `views` int(11) NOT NULL DEFAULT 0,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Array of image objects [{name,type,data}]' CHECK (json_valid(`images`)),
  `created_at` date NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `kb_articles`
--

INSERT INTO `kb_articles` (`id`, `title`, `category`, `content`, `is_public`, `views`, `images`, `created_at`, `updated_at`, `deleted_at`) VALUES
('KB001', 'วิธีเชื่อมต่อ WiFi ออฟฟิศ', 'Network', '# วิธีเชื่อมต่อ WiFi\n\n1. เปิด WiFi Settings\n2. เลือก SSID: **Company-WiFi-5GHz**\n3. ใส่ Password ที่ได้รับจาก IT\n4. รอสักครู่จนเชื่อมต่อสำเร็จ\n\n> หากไม่สามารถเชื่อมต่อได้ ให้ลอง Forget Network แล้วเชื่อมต่อใหม่', 1, 245, NULL, '2024-01-01', '2026-02-13 14:25:48', NULL),
('KB002', 'การแก้ปัญหา Outlook เชื่อมต่อไม่ได้', 'Software', '# แก้ปัญหา Outlook\n\n1. ตรวจสอบการเชื่อมต่อ Internet\n2. ไปที่ File > Account Settings ตรวจสอบ Server Settings\n3. ลอง Repair Outlook Profile\n4. Clear Outlook Cache\n\n**หากยังไม่ได้ผล** กรุณาแจ้ง IT Support', 1, 189, NULL, '2024-01-02', '2026-02-13 14:25:48', NULL),
('KB003', 'วิธีเชื่อมต่อ VPN สำหรับ WFH', 'Network', '# การใช้งาน VPN\n\n1. ดาวน์โหลด **GlobalProtect** จาก Software Center\n2. ใส่ Portal Address: **vpn.company.com**\n3. Login ด้วย AD Account\n4. รอจน Status เป็น Connected\n\n> ต้องเปิด VPN ก่อนเข้าใช้ระบบภายในทุกครั้ง', 1, 321, NULL, '2024-01-03', '2026-02-13 14:25:48', NULL),
('KB004', 'นโยบายความปลอดภัยข้อมูลส่วนบุคคล (Internal)', 'Security', '# นโยบาย Data Privacy\n\n## ข้อปฏิบัติ\n- ห้ามส่ง Password ทาง Email\n- ใช้ MFA สำหรับระบบสำคัญ\n- Report เหตุการณ์น่าสงสัยทันที\n\n## การจัดเก็บข้อมูล\n- Encrypt ข้อมูลสำคัญ\n- Auto-lock หลัง 5 นาที', 0, 45, NULL, '2024-01-04', '2026-02-13 14:25:48', NULL),
('KB005', 'วิธีสั่งพิมพ์เอกสารผ่าน Network Printer', 'Hardware', '# สั่งพิมพ์ผ่าน Network Printer\n\n1. เปิด Control Panel > Devices and Printers\n2. คลิก Add a printer\n3. เลือก Printer ชื่อ **PRN-Floor3** หรือ **PRN-Floor4**\n4. ติดตั้ง Driver ถ้าถูกถาม\n5. ลองสั่ง Print Test Page', 1, 167, NULL, '2024-01-05', '2026-02-13 14:25:48', NULL),
('KB006', 'การขอเปลี่ยน Password (AD Reset)', 'Security', '# รีเซ็ตรหัสผ่าน Active Directory\n1. กด Ctrl + Alt + Del แล้วเลือก **Change a password**\n2. ใส่รหัสเดิม\n3. ใส่รหัสใหม่ (ต้องมีตัวเล็ก, ตัวใหญ่, ตัวเลข, อักขระพิเศษ)\n\n> กรณีลืมรหัสผ่าน ให้ติดต่อ IT Helpdesk โทร 9999 หรือสร้าง Ticket หมวด **Security**', 1, 542, NULL, '2024-01-20', '2026-02-13 14:25:48', NULL),
('KB007', 'ขั้นตอนการเบิก Software License ใหม่', 'Software', '# การเบิก License\nบริษัทมีนโยบายให้เบิก License เฉพาะที่จำเป็นต้องใช้ในการทำงานเท่านั้น\n\n1. ตรวจสอบรายชื่อ Software ที่มี License กลางใน Intranet\n2. หากไม่มีในรายการ ให้กรอกแบบฟอร์ม **Software Request Form (SRF)**\n3. ให้ Manager เซ็นอนุมัติ\n4. แนบไฟล์มาใน Ticket หมวด **Software**\n\n> ระยะเวลาดำเนินการประมาณ 3-5 วันทำการ', 1, 89, NULL, '2024-01-22', '2026-02-13 14:25:48', NULL),
('KB008', 'การแจ้งเหตุ Critical Incident (ระบบล่ม)', 'Process', '# Critical Incident Report\nหากพบระบบสำคัญล่ม (ERP, Email, Internet)\n\n1. **ห้าม** ส่ง Email (เพราะอาจใช้งานไม่ได้)\n2. ให้โทรแจ้งเบอร์ฉุกเฉิน IT: **02-123-9990** ทันที\n3. แจ้งอาการและผลกระทบ\n4. ทีม IT จะประกาศ Incident Status ผ่านทาง SMS และ Line Group', 1, 410, NULL, '2024-01-10', '2026-02-13 14:25:48', NULL),
('KB009', 'การตั้งค่า Email บนมือถือ (iOS/Android)', 'Network', '# ตั้งค่า Email บนมือถือ\n\n1. โหลดแอป **Microsoft Outlook**\n2. เลือก Add Account > ใส่ Email บริษัท\n3. ระบบจะพาไปหน้า Login ของบริษัท (ADFS)\n4. ใส่ Username/Password\n5. กดยืนยันผ่าน MFA (Microsoft Authenticator)', 1, 330, NULL, '2024-01-25', '2026-02-13 14:25:48', NULL),
('KB010', 'เข้าใจระดับความรุนแรง (Priority Level)', 'Process', '# SLA Priority\n\n- **Urgent**: ระบบล่มทั้งบริษัท, Data Loss, กระทบธุรกิจหลัก (Resolve: 4 ชม.)\n- **High**: กระทบกลุ่มคนทำงานไม่ได้, ระบบสำคัญช้ามาก (Resolve: 8 ชม.)\n- **Medium**: กระทบ 1-2 คน แต่พอทำงานอื่นทดแทนได้ (Resolve: 24 ชม.)\n- **Low**: คำถามการใช้งาน, ขอข้อมูล, ไม่กระทบการทำงาน (Resolve: 72 ชม.)', 1, 155, NULL, '2024-01-15', '2026-02-13 14:25:48', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `kb_tags`
--

CREATE TABLE `kb_tags` (
  `article_id` varchar(10) NOT NULL,
  `tag` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `kb_tags`
--

INSERT INTO `kb_tags` (`article_id`, `tag`) VALUES
('KB001', 'connection'),
('KB001', 'network'),
('KB001', 'wifi'),
('KB002', 'email'),
('KB002', 'outlook'),
('KB002', 'troubleshoot'),
('KB003', 'remote'),
('KB003', 'vpn'),
('KB003', 'wfh'),
('KB004', 'policy'),
('KB004', 'privacy'),
('KB004', 'security'),
('KB005', 'hardware'),
('KB005', 'print'),
('KB005', 'printer'),
('KB006', 'password'),
('KB006', 'reset'),
('KB006', 'security'),
('KB007', 'license'),
('KB007', 'request'),
('KB007', 'software'),
('KB008', 'critical'),
('KB008', 'incident'),
('KB008', 'process'),
('KB009', 'android'),
('KB009', 'email'),
('KB009', 'ios'),
('KB009', 'mobile'),
('KB010', 'policy'),
('KB010', 'priority'),
('KB010', 'sla');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` varchar(10) NOT NULL,
  `type` varchar(30) NOT NULL COMMENT 'ticket_created, ticket_assigned, ticket_resolved, sla_warning, csat_request, escalation, change_request',
  `to_email` varchar(150) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'Sent',
  `sent_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `type`, `to_email`, `subject`, `status`, `sent_at`) VALUES
('N001', 'ticket_created', 'admin@demo.com', '[TK-2024-001] คอมพิวเตอร์เปิดไม่ติด', 'Sent', '2024-01-15 09:30:00'),
('N002', 'ticket_assigned', 'siri@company.com', '[TK-2024-002] Assigned: ติดตั้ง Microsoft Office', 'Sent', '2024-01-14 14:30:00'),
('N003', 'ticket_resolved', 'wichai@company.com', '[TK-2024-003] Resolved: WiFi ห้องประชุม', 'Sent', '2024-01-13 12:00:00'),
('N004', 'sla_warning', 'admin@demo.com', 'SLA Warning: TK-2024-001 ใกล้ Breach', 'Sent', '2024-01-15 11:00:00'),
('N005', 'csat_request', 'wichai@company.com', 'กรุณาให้คะแนน TK-2024-003', 'Sent', '2024-01-13 14:00:00'),
('N006', 'escalation', 'admin@demo.com', 'Escalation: TK-2024-008 Malware ตรวจพบ', 'Sent', '2024-01-15 08:35:00'),
('N007', 'change_request', 'admin@demo.com', 'CR003 อยู่ระหว่างการ Review', 'Sent', '2024-01-14 09:00:00'),
('N008', 'ticket_created', 'admin@demo.com', '[TK-2024-010] ระบบ ERP เข้าใช้งานช้า', 'Sent', '2024-01-15 13:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `problems`
--

CREATE TABLE `problems` (
  `id` varchar(10) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `root_cause` text DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'Investigating' COMMENT 'Investigating, Identified, Resolved, Closed',
  `workaround` text DEFAULT NULL,
  `created_at` date NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `problems`
--

INSERT INTO `problems` (`id`, `title`, `description`, `root_cause`, `status`, `workaround`, `created_at`, `updated_at`) VALUES
('PB001', 'WiFi ชั้น 5 ขาดหายเป็นระยะ', 'WiFi ชั้น 5 มีปัญหาเชื่อมต่อไม่เสถียร เกิดซ้ำหลายครั้ง', 'Access Point Firmware เก่าทำให้ Channel Interference', 'Resolved', 'สลับไปใช้ WiFi ชั้น 4 ชั่วคราว', '2024-01-13', '2026-02-13 14:25:48'),
('PB002', 'ERP ช้าในช่วงเช้า', 'ระบบ ERP มีปัญหา Performance ช้ามากในช่วง 8:00-10:00 น.', NULL, 'Investigating', 'ใช้งานช่วงบ่ายจะเร็วกว่า', '2024-01-15', '2026-02-13 14:25:48');

-- --------------------------------------------------------

--
-- Table structure for table `problem_related_tickets`
--

CREATE TABLE `problem_related_tickets` (
  `problem_id` varchar(10) NOT NULL,
  `ticket_id` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `problem_related_tickets`
--

INSERT INTO `problem_related_tickets` (`problem_id`, `ticket_id`) VALUES
('PB001', 'TK-2024-003'),
('PB001', 'TK-2024-012'),
('PB002', 'TK-2024-010');

-- --------------------------------------------------------

--
-- Table structure for table `service_categories`
--

CREATE TABLE `service_categories` (
  `id` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `icon` varchar(50) DEFAULT NULL COMMENT 'FontAwesome class',
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `service_categories`
--

INSERT INTO `service_categories` (`id`, `name`, `icon`, `description`) VALUES
('access', 'Access & Security', 'fas fa-key', 'User accounts, permissions, and security incidents.'),
('hardware', 'Hardware', 'fas fa-laptop', 'Request new equipment or report hardware issues.'),
('software', 'Software', 'fas fa-code', 'Software installation, licensing, and troubleshooting.');

-- --------------------------------------------------------

--
-- Table structure for table `service_items`
--

CREATE TABLE `service_items` (
  `id` varchar(20) NOT NULL,
  `category_id` varchar(20) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `ticket_category` varchar(50) DEFAULT NULL COMMENT 'Maps to ticket category',
  `ticket_type` enum('Incident','Request') NOT NULL DEFAULT 'Request',
  `icon` varchar(50) DEFAULT NULL COMMENT 'FontAwesome class'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `service_items`
--

INSERT INTO `service_items` (`id`, `category_id`, `name`, `description`, `ticket_category`, `ticket_type`, `icon`) VALUES
('a1', 'access', 'New User Account', 'Create a new user account for onboarding.', 'Access', 'Request', 'fas fa-user-plus'),
('a2', 'access', 'Reset Password', 'Request a password reset for locked accounts.', 'Access', 'Request', 'fas fa-unlock-alt'),
('a3', 'access', 'Request VPN Access', 'Request remote access via VPN.', 'Access', 'Request', 'fas fa-shield-alt'),
('h1', 'hardware', 'Request New Laptop', 'Request a standard issue laptop for new employees or replacement.', 'Hardware', 'Request', 'fas fa-laptop'),
('h2', 'hardware', 'Report Hardware Fault', 'Report issues with existing hardware (monitor, keyboard, mouse, etc.).', 'Hardware', 'Incident', 'fas fa-tools'),
('h3', 'hardware', 'Request Peripheral', 'Request additional peripherals like monitors, docks, or headsets.', 'Hardware', 'Request', 'fas fa-mouse'),
('s1', 'software', 'Install New Software', 'Request installation of approved software.', 'Software', 'Request', 'fas fa-download'),
('s2', 'software', 'Report Software Bug', 'Report a bug or error in internal or external software.', 'Software', 'Incident', 'fas fa-bug'),
('s3', 'software', 'License Renewal', 'Request renewal or upgrade of software licenses.', 'Software', 'Request', 'fas fa-file-signature');

-- --------------------------------------------------------

--
-- Table structure for table `sla_policies`
--

CREATE TABLE `sla_policies` (
  `priority` varchar(20) NOT NULL,
  `response_time` int(11) NOT NULL COMMENT 'in hours',
  `resolve_time` int(11) NOT NULL COMMENT 'in hours',
  `escalate_after` int(11) NOT NULL COMMENT 'in hours',
  `unit` varchar(10) NOT NULL DEFAULT 'hours'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sla_policies`
--

INSERT INTO `sla_policies` (`priority`, `response_time`, `resolve_time`, `escalate_after`, `unit`) VALUES
('High', 2, 8, 4, 'hours'),
('Low', 8, 72, 48, 'hours'),
('Medium', 4, 24, 12, 'hours'),
('Urgent', 1, 4, 2, 'hours');

-- --------------------------------------------------------

--
-- Table structure for table `tickets`
--

CREATE TABLE `tickets` (
  `id` varchar(20) NOT NULL COMMENT 'e.g. TK-2024-001',
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('Open','In Progress','Pending','Resolved','Closed','Rejected') NOT NULL DEFAULT 'Open',
  `priority` varchar(20) NOT NULL DEFAULT 'Medium' COMMENT 'Low, Medium, High, Urgent',
  `type` enum('Incident','Request') NOT NULL DEFAULT 'Incident',
  `category` varchar(50) NOT NULL COMMENT 'Hardware, Software, Network, Security',
  `user_email` varchar(150) NOT NULL COMMENT 'Requester email',
  `channel` varchar(30) DEFAULT NULL COMMENT 'Phone, Email, Walk-in, Web Portal, Line',
  `asset_id` varchar(10) DEFAULT NULL,
  `urgency` varchar(10) DEFAULT 'Medium' COMMENT 'Low, Medium, High',
  `impact` varchar(10) DEFAULT 'Medium' COMMENT 'Low, Medium, High',
  `internal_note` text DEFAULT NULL COMMENT 'Internal staff notes',
  `pending_reason` text DEFAULT NULL COMMENT 'Reason when status=Pending',
  `root_cause` text DEFAULT NULL COMMENT 'Root cause when Resolved/Closed',
  `resolution_note` text DEFAULT NULL COMMENT 'Resolution details when Resolved/Closed',
  `csat_score` tinyint(4) DEFAULT NULL COMMENT '1-5 rating',
  `csat_comment` text DEFAULT NULL,
  `sla_response_due` datetime DEFAULT NULL,
  `sla_resolve_due` datetime DEFAULT NULL,
  `sla_response_met` tinyint(1) DEFAULT NULL COMMENT '1=met, 0=breached, NULL=pending',
  `sla_resolve_met` tinyint(1) DEFAULT NULL COMMENT '1=met, 0=breached, NULL=pending',
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tickets`
--

INSERT INTO `tickets` (`id`, `title`, `description`, `status`, `priority`, `type`, `category`, `user_email`, `channel`, `asset_id`, `urgency`, `impact`, `internal_note`, `pending_reason`, `root_cause`, `resolution_note`, `csat_score`, `csat_comment`, `sla_response_due`, `sla_resolve_due`, `sla_response_met`, `sla_resolve_met`, `created_at`, `updated_at`, `deleted_at`) VALUES
('TK-2024-001', 'คอมพิวเตอร์เปิดไม่ติด', 'กดปุ่ม Power แล้วหน้าจอไม่ติด มีเสียง beep 3 ครั้ง', 'In Progress', 'High', 'Incident', 'Hardware', 'somchai@company.com', 'Phone', 'A001', 'Medium', 'Medium', NULL, NULL, NULL, NULL, NULL, NULL, '2024-01-15 10:30:00', '2024-01-15 16:30:00', 1, NULL, '2024-01-15 08:30:00', '2024-01-15 10:00:00', NULL),
('TK-2024-002', 'ติดตั้ง Microsoft Office', 'ขอติดตั้ง MS Office 2021 LTSC สำหรับเครื่องใหม่', 'In Progress', 'Medium', 'Request', 'Software', 'manee@company.com', 'Web Portal', 'A002', 'Medium', 'Medium', NULL, NULL, NULL, NULL, NULL, NULL, '2024-01-14 17:00:00', '2024-01-15 13:00:00', 1, NULL, '2024-01-14 13:00:00', '2024-01-14 14:00:00', NULL),
('TK-2024-003', 'WiFi ห้องประชุมชั้น 5 เชื่อมต่อไม่ได้', 'Connect WiFi แล้วหลุดบ่อยมาก ประชุมไม่ได้เลย', 'Resolved', 'Urgent', 'Incident', 'Network', 'wichai@company.com', 'Phone', 'A007', 'Medium', 'Medium', NULL, NULL, NULL, NULL, 5, 'แก้ไขเร็วมาก ขอบคุณครับ', '2024-01-13 11:00:00', '2024-01-13 14:00:00', 1, 1, '2024-01-13 10:00:00', '2024-01-13 12:00:00', NULL),
('TK-2024-004', 'Printer ชั้น 3 กระดาษติด', 'Printer Laser ใหญ่ กระดาษ jamming ตลอด', 'Open', 'Medium', 'Incident', 'Hardware', 'farung@company.com', 'Walk-in', 'A005', 'Medium', 'Medium', NULL, NULL, NULL, NULL, NULL, NULL, '2024-01-15 15:00:00', '2024-01-16 11:00:00', NULL, NULL, '2024-01-15 11:00:00', '2024-01-15 11:00:00', NULL),
('TK-2024-005', 'ขอ VPN Access สำหรับ WFH', 'จะ Work from home สัปดาห์หน้า ขอเปิดสิทธิ์ VPN', 'Resolved', 'Low', 'Request', 'Security', 'darin@company.com', 'Email', NULL, 'Medium', 'Medium', NULL, NULL, NULL, NULL, 4, 'ขอบคุณค่ะ', '2024-01-12 17:00:00', '2024-01-15 09:00:00', 1, 1, '2024-01-12 09:00:00', '2024-01-12 11:00:00', NULL),
('TK-2024-006', 'รีเซ็ตรหัสผ่าน Email', 'ลืมรหัสผ่านเข้า Email บริษัท', 'Closed', 'High', 'Request', 'Security', 'ekachai@company.com', 'Phone', NULL, 'Medium', 'Medium', NULL, NULL, NULL, NULL, NULL, NULL, '2024-01-12 10:00:00', '2024-01-12 16:00:00', 1, 1, '2024-01-12 08:00:00', '2024-01-12 08:15:00', NULL),
('TK-2024-007', 'หน้าจอเป็นเส้น', 'หน้าจอ Monitor มีเส้นสีเขียวขึ้นกลางจอ', 'Resolved', 'Medium', 'Incident', 'Hardware', 'wipa@company.com', 'Web Portal', 'A003', 'Medium', 'Medium', NULL, NULL, NULL, NULL, 4, 'ขอบคุณครับ แต่ใช้เวลานิดนึง', '2024-01-10 18:00:00', '2024-01-11 14:00:00', 1, 0, '2024-01-10 14:00:00', '2024-01-12 16:00:00', NULL),
('TK-2024-008', 'ตรวจพบ Malware ในเครื่อง', 'Antivirus แจ้งเตือนไฟล์น่าสงสัยใน Drive D', 'In Progress', 'Urgent', 'Incident', 'Security', 'somsak@company.com', 'Web Portal', NULL, 'Medium', 'Medium', NULL, NULL, NULL, NULL, NULL, NULL, '2024-01-15 09:30:00', '2024-01-15 12:30:00', 1, NULL, '2024-01-15 08:30:00', '2024-01-15 08:35:00', NULL),
('TK-2024-009', 'Keyboard ปุ่มกดไม่ติด', 'ปุ่ม Enter และ Spacebar กดยากมาก', 'Closed', 'Low', 'Incident', 'Hardware', 'kanda@company.com', 'Walk-in', NULL, 'Medium', 'Medium', NULL, NULL, NULL, NULL, 4, 'เปลี่ยนปุ่มใหม่ให้ ขอบคุณค่ะ', '2024-01-13 17:00:00', '2024-01-16 09:00:00', 1, 1, '2024-01-13 09:00:00', '2024-01-14 11:00:00', NULL),
('TK-2024-010', 'ระบบ ERP เข้าใช้งานช้ามาก', 'ระบบ SAP ERP load ช้ามากกว่า 30 วินาทีต่อหน้า ทำงานไม่ทันตลอด', 'Open', 'High', 'Incident', 'Software', 'somchai@company.com', 'Web Portal', NULL, 'Medium', 'Medium', NULL, NULL, NULL, NULL, NULL, NULL, '2024-01-15 15:00:00', '2024-01-16 13:00:00', NULL, NULL, '2024-01-15 13:00:00', '2024-01-15 13:00:00', NULL),
('TK-2024-011', 'ขอสิทธิ์เข้าถึง Shared Drive', 'ต้องการสิทธิ์ Write ที่ \\\\fileserver\\marketing\\campaigns สำหรับอัพโหลดไฟล์ Campaign', 'Closed', 'Low', 'Request', 'Security', 'wichai@company.com', 'Email', NULL, 'Medium', 'Medium', NULL, NULL, NULL, NULL, 5, 'รวดเร็วมากครับ', '2024-01-11 17:00:00', '2024-01-14 09:00:00', 1, 1, '2024-01-11 09:00:00', '2024-01-11 16:00:00', NULL),
('TK-2024-012', 'Zoom ภาพตัดหายระหว่างประชุม', 'ประชุม Zoom แล้วภาพตัดหายเป็นระยะ Audio ยังปกติ คิดว่า Bandwidth ไม่พอ', 'Pending', 'Medium', 'Incident', 'Network', 'prayuth@company.com', 'Web Portal', NULL, 'Medium', 'Medium', NULL, 'รอ ISP เพิ่ม Bandwidth ภายในสัปดาห์นี้', NULL, NULL, NULL, NULL, '2024-01-14 14:00:00', '2024-01-16 10:00:00', 1, NULL, '2024-01-14 10:00:00', '2024-01-15 08:00:00', NULL),
('TK-2024-013', 'PowerShell Backup Script Error', 'Script backup มีปัญหาตอนรันคำสั่ง cd D:\\Backup SME ขึ้น Error', 'Open', 'Medium', 'Incident', 'Software', 'ekachai@company.com', 'Email', NULL, 'Medium', 'Medium', NULL, NULL, NULL, NULL, NULL, NULL, '2024-01-15 18:00:00', '2024-01-17 14:00:00', NULL, NULL, '2024-01-15 14:00:00', '2024-01-15 14:00:00', NULL),
('TK-2024-014', 'หน้าจอฟ้า (BSOD) ขณะใช้งาน', 'กำลังทำงานอยู่ดีๆ เครื่องก็ขึ้นจอฟ้า (Blue Screen) แล้วก็ Restart เอง เป็นแบบนี้มา 2 รอบแล้วครับ', 'Open', 'High', 'Incident', 'Hardware', 'somchai@company.com', 'Web Portal', 'A001', 'Medium', 'Medium', NULL, NULL, NULL, NULL, NULL, NULL, '2024-01-16 11:30:00', '2024-01-17 09:30:00', NULL, NULL, '2024-01-16 09:30:00', '2024-01-16 09:30:00', NULL),
('TK-2026-001', 'Install New Software', 'Request installation of approved software.', 'Closed', 'Medium', 'Request', 'Software', 'farung@company.com', 'Web Portal', NULL, 'Medium', 'Medium', '', NULL, 'Third-party Service', 'Remote ลงโปรแกรมให้', 5, '', '2026-02-14 02:18:06', '2026-02-14 22:18:06', NULL, NULL, '2026-02-13 22:18:06', '2026-02-13 22:18:06', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `ticket_assignees`
--

CREATE TABLE `ticket_assignees` (
  `ticket_id` varchar(20) NOT NULL,
  `user_id` varchar(10) NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ticket_assignees`
--

INSERT INTO `ticket_assignees` (`ticket_id`, `user_id`, `assigned_at`) VALUES
('TK-2024-001', 'ST004', '2026-02-13 14:25:48'),
('TK-2024-002', 'ST003', '2026-02-13 14:25:48'),
('TK-2024-003', 'ST002', '2026-02-13 14:25:48'),
('TK-2024-005', 'ST001', '2026-02-13 14:25:48'),
('TK-2024-006', 'ST005', '2026-02-13 14:25:48'),
('TK-2024-007', 'ST004', '2026-02-13 14:25:48'),
('TK-2024-008', 'ST001', '2026-02-13 14:25:48'),
('TK-2024-008', 'ST002', '2026-02-13 14:25:48'),
('TK-2024-009', 'ST005', '2026-02-13 14:25:48'),
('TK-2024-011', 'ST003', '2026-02-13 14:25:48'),
('TK-2024-012', 'ST002', '2026-02-13 14:25:48'),
('TK-2026-001', 'ST001', '2026-02-13 15:45:29');

-- --------------------------------------------------------

--
-- Table structure for table `ticket_attachments`
--

CREATE TABLE `ticket_attachments` (
  `id` int(11) NOT NULL,
  `ticket_id` varchar(20) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_type` varchar(100) NOT NULL,
  `file_size` int(11) DEFAULT NULL COMMENT 'in bytes',
  `file_path` varchar(500) NOT NULL COMMENT 'Storage path or URL',
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ticket_attachments`
--

INSERT INTO `ticket_attachments` (`id`, `ticket_id`, `file_name`, `file_type`, `file_size`, `file_path`, `uploaded_at`) VALUES
(1, 'TK-2024-001', 'error_screen.jpg', 'image/jpeg', 450000, '/uploads/tickets/TK-2024-001/error_screen.jpg', '2026-02-13 14:25:48'),
(2, 'TK-2024-013', 'powershell_error.png', 'image/png', 125000, '/uploads/tickets/TK-2024-013/powershell_error.png', '2026-02-13 14:25:48'),
(3, 'TK-2024-014', 'system_error.png', 'image/png', 450000, '/uploads/tickets/TK-2024-014/system_error.png', '2026-02-13 14:25:48');

-- --------------------------------------------------------

--
-- Table structure for table `ticket_timeline`
--

CREATE TABLE `ticket_timeline` (
  `id` int(11) NOT NULL,
  `ticket_id` varchar(20) NOT NULL,
  `action` varchar(100) NOT NULL,
  `user_name` varchar(100) NOT NULL,
  `detail` text DEFAULT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ticket_timeline`
--

INSERT INTO `ticket_timeline` (`id`, `ticket_id`, `action`, `user_name`, `detail`, `created_at`) VALUES
(1, 'TK-2024-001', 'สร้าง Ticket', 'สมชาย ใจดี', 'แจ้งปัญหาผ่านโทรศัพท์', '2024-01-15 08:30:00'),
(2, 'TK-2024-001', 'รับเรื่อง', 'กมล ทวีสุข', 'กำลังตรวจสอบ Hardware', '2024-01-15 09:00:00'),
(3, 'TK-2024-002', 'สร้าง Ticket', 'มานี มีตา', 'แจ้งขอติดตั้ง Software', '2024-01-14 13:00:00'),
(4, 'TK-2024-003', 'สร้าง Ticket', 'วิชัย เก่งมาก', 'แจ้งปัญหา Network', '2024-01-13 10:00:00'),
(5, 'TK-2024-003', 'แก้ไขเสร็จสิ้น', 'ภูมิ สุขสมบูรณ์', 'Reset Access Point และปรับ Channel', '2024-01-13 12:00:00'),
(6, 'TK-2024-004', 'สร้าง Ticket', 'ฟ้ารุ่ง รุ่งเรือง', 'แจ้งปัญหา Walk-in', '2024-01-15 11:00:00'),
(7, 'TK-2024-005', 'สร้าง Ticket', 'ดาริน สวยงาม', 'ขอสิทธิ์ VPN', '2024-01-12 09:00:00'),
(8, 'TK-2024-006', 'สร้าง Ticket', 'เอกชัย ชัยชนะ', 'แจ้งลืมรหัสผ่าน', '2024-01-12 08:00:00'),
(9, 'TK-2024-007', 'สร้าง Ticket', 'วิภา กล้าหาญ', 'แจ้งปัญหาหน้าจอ', '2024-01-10 14:00:00'),
(10, 'TK-2024-008', 'สร้าง Ticket', 'สมศักดิ์ รักเรียน', 'System Alert: Malware detected', '2024-01-15 08:30:00'),
(11, 'TK-2024-008', 'Escalation', 'System', 'Escalated to Manager due to High Risk', '2024-01-15 08:35:00'),
(12, 'TK-2024-009', 'สร้าง Ticket', 'กานดา มุ่งมั่น', 'แจ้งปัญหา Keyboard', '2024-01-13 09:00:00'),
(13, 'TK-2024-010', 'สร้าง Ticket', 'สมชาย ใจดี', 'แจ้งปัญหาผ่าน Web Portal', '2024-01-15 13:00:00'),
(14, 'TK-2024-011', 'สร้าง Ticket', 'วิชัย เก่งมาก', 'ขอสิทธิ์ผ่าน Email', '2024-01-11 09:00:00'),
(15, 'TK-2024-011', 'ปิด Ticket', 'ศิริ วงศ์สวัสดิ์', 'Grant Permission เรียบร้อย', '2024-01-11 16:00:00'),
(16, 'TK-2024-012', 'สร้าง Ticket', 'ประยุทธ์ ตั้งใจ', 'แจ้งปัญหาผ่าน Web Portal', '2024-01-14 10:00:00'),
(17, 'TK-2024-012', 'รับเรื่อง', 'ภูมิ สุขสมบูรณ์', 'กำลังตรวจสอบ Bandwidth', '2024-01-14 11:00:00'),
(18, 'TK-2024-012', 'รอดำเนินการ', 'ภูมิ สุขสมบูรณ์', 'รอ ISP เพิ่ม Bandwidth ภายในสัปดาห์นี้', '2024-01-15 08:00:00'),
(19, 'TK-2024-013', 'สร้าง Ticket', 'เอกชัย ชัยชนะ', 'แจ้งปัญหา Script Error ผ่าน Email', '2024-01-15 14:00:00'),
(20, 'TK-2024-014', 'สร้าง Ticket', 'สมชาย ใจดี', 'แจ้งปัญหาหน้าจอฟ้า', '2024-01-16 09:30:00'),
(21, 'TK-2024-014', 'Comment', 'admin', 'นานรึยัง', '2026-02-13 21:29:25'),
(22, 'TK-2026-001', 'Created', 'farung@company.com', NULL, '2026-02-13 22:18:06'),
(23, 'TK-2026-001', 'Auto-Assigned', 'System', 'Assigned to อธิชา กิตติพงศ์ based on skill match', '2026-02-13 22:18:06'),
(24, 'TK-2026-001', 'Comment', 'admin', 'ดำเนินการให้เรียบร้อย', '2026-02-13 22:44:23'),
(25, 'TK-2026-001', 'Assignees Updated', 'admin', 'Assignees set to: ST001', '2026-02-13 22:45:29'),
(26, 'TK-2026-001', 'Status Update', 'admin', 'Status changed to Closed', '2026-02-13 22:45:29'),
(27, 'TK-2026-001', 'CSAT Submitted', 'admin', 'Score: 5/5, Comment: -', '2026-02-13 22:46:19'),
(28, 'TK-2024-014', 'Comment', 'admin', 'กำลังตรวจสอบ', '2026-02-14 12:27:59'),
(29, 'TK-2024-014', 'Comment', 'admin', 'แก้ไขแล้ว', '2026-02-14 12:35:17');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` varchar(10) NOT NULL,
  `code` varchar(20) NOT NULL,
  `gender` enum('Male','Female','Other') DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `name_en` varchar(100) DEFAULT NULL COMMENT 'English name',
  `email` varchar(150) NOT NULL,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL COMMENT 'Hashed password (IT staff only)',
  `department` varchar(100) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `role` varchar(50) NOT NULL DEFAULT 'User' COMMENT 'IT Manager, Senior Support, Support Specialist, Junior Support, User',
  `level` tinyint(4) DEFAULT NULL COMMENT 'IT hierarchy level (1=Manager, 2=Senior, etc.)',
  `supervisor_id` varchar(10) DEFAULT NULL,
  `avatar` varchar(10) DEFAULT NULL COMMENT 'First character of name for avatar display',
  `phone` varchar(30) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `code`, `gender`, `name`, `name_en`, `email`, `username`, `password`, `department`, `position`, `role`, `level`, `supervisor_id`, `avatar`, `phone`, `location`, `created_at`, `updated_at`, `deleted_at`) VALUES
('ST001', 'EMP000', 'Male', 'อธิชา กิตติพงศ์', NULL, 'admin@demo.com', 'admin', 'password123', 'IT', 'IT Manager', 'IT Manager', 1, NULL, 'อ', '02-123-9999', 'HQ 5th Floor', '2026-02-13 14:25:48', '2026-02-14 06:56:41', NULL),
('ST002', 'EMP099', 'Male', 'ภูมิ สุขสมบูรณ์', NULL, 'phoom@company.com', 'phoom', 'password123', 'IT', 'Senior Support', 'Senior Support', 2, 'ST001', 'ภ', '02-123-9998', 'HQ 5th Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('ST003', 'EMP098', 'Female', 'ศิริ วงศ์สวัสดิ์', NULL, 'siri@company.com', 'siri', 'password123', 'IT', 'Support Specialist', 'Support Specialist', 3, 'ST002', 'ศ', '02-123-9997', 'HQ 5th Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('ST004', 'EMP097', 'Male', 'กมล ทวีสุข', NULL, 'kamol@company.com', 'kamol', 'password123', 'IT', 'Support Specialist', 'Support Specialist', 3, 'ST002', 'ก', '02-123-9996', 'HQ 5th Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('ST005', 'EMP096', 'Female', 'ดวงใจ แสงทอง', NULL, 'duangjai@company.com', 'duangjai', 'password123', 'IT', 'Junior Support', 'Junior Support', 4, 'ST003', 'ด', '02-123-9995', 'HQ 5th Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U001', 'EMP001', 'Male', 'สมชาย ใจดี', NULL, 'somchai@company.com', NULL, NULL, 'ฝ่ายขาย', 'Sales Manager', 'User', NULL, NULL, 'ส', '02-123-4567', 'HQ 2nd Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U002', 'EMP002', 'Female', 'มานี มีตา', NULL, 'manee@company.com', NULL, NULL, 'บัญชี', 'Accountant', 'User', NULL, NULL, 'ม', '02-123-4568', 'HQ 3rd Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U003', 'EMP003', 'Male', 'สมศักดิ์ รักเรียน', NULL, 'somsak@company.com', NULL, NULL, 'HR', 'HR Manager', 'User', NULL, NULL, 'ส', '02-123-4569', 'HQ 4th Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U004', 'EMP004', 'Female', 'วิภา กล้าหาญ', NULL, 'wipa@company.com', NULL, NULL, 'การตลาด', 'Marketing Lead', 'User', NULL, NULL, 'ว', '02-123-4570', 'HQ 2nd Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U005', 'EMP005', 'Male', 'ประยุทธ์ ตั้งใจ', NULL, 'prayuth@company.com', NULL, NULL, 'วิศวกรรม', 'Senior Engineer', 'User', NULL, NULL, 'ป', '02-123-4571', 'Factory A', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U006', 'EMP006', 'Female', 'กานดา มุ่งมั่น', NULL, 'kanda@company.com', NULL, NULL, 'ฝ่ายขาย', 'Sales Executive', 'User', NULL, NULL, 'ก', '02-123-4572', 'HQ 2nd Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U007', 'EMP007', 'Male', 'ชัยวัฒน์ พัฒนา', NULL, 'chaiwat@company.com', NULL, NULL, 'IT', 'Developer', 'User', NULL, NULL, 'ช', '02-123-4573', 'HQ 5th Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U008', 'EMP008', 'Female', 'ดาริน สวยงาม', NULL, 'darin@company.com', NULL, NULL, 'การตลาด', 'Content Creator', 'User', NULL, NULL, 'ด', '02-123-4574', 'HQ 2nd Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U009', 'EMP009', 'Male', 'เอกชัย ชัยชนะ', NULL, 'ekachai@company.com', NULL, NULL, 'วิศวกรรม', 'Engineer', 'User', NULL, NULL, 'อ', '02-123-4575', 'Factory A', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U010', 'EMP010', 'Female', 'ฟ้ารุ่ง รุ่งเรือง', NULL, 'farung@company.com', NULL, NULL, 'บัญชี', 'Admin', 'User', NULL, NULL, 'ฟ', '02-123-4576', 'HQ 3rd Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U011', 'EMP011', 'Male', 'George Smith', NULL, 'george@company.com', NULL, NULL, 'Management', 'Director', 'User', NULL, NULL, 'G', '02-123-4577', 'HQ 5th Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U012', 'EMP012', 'Male', 'Harry Potter', NULL, 'harry@company.com', NULL, NULL, 'IT', 'Security Specialist', 'User', NULL, NULL, 'H', '02-123-4578', 'HQ 5th Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U013', 'EMP013', 'Female', 'Isabella Ross', NULL, 'isabella@company.com', NULL, NULL, 'HR', 'Recruiter', 'User', NULL, NULL, 'I', '02-123-4579', 'HQ 4th Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U014', 'EMP014', 'Male', 'Jack Ma', NULL, 'jack@company.com', NULL, NULL, 'ฝ่ายขาย', 'Sales Director', 'User', NULL, NULL, 'J', '02-123-4580', 'HQ 2nd Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U015', 'EMP015', 'Female', 'Katie Bell', NULL, 'katie@company.com', NULL, NULL, 'การตลาด', 'Graphic Designer', 'User', NULL, NULL, 'K', '02-123-4581', 'HQ 2nd Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL),
('U016', 'EMP016', 'Male', 'วิชัย เก่งมาก', NULL, 'wichai@company.com', NULL, NULL, 'การตลาด', 'Marketing Specialist', 'User', NULL, NULL, 'ว', '02-123-4582', 'HQ 2nd Floor', '2026-02-13 14:25:48', '2026-02-13 14:25:48', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_permissions`
--

CREATE TABLE `user_permissions` (
  `user_id` varchar(10) NOT NULL,
  `permission` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_permissions`
--

INSERT INTO `user_permissions` (`user_id`, `permission`) VALUES
('ST001', 'all'),
('ST002', 'assets'),
('ST002', 'dashboard'),
('ST002', 'kb'),
('ST002', 'reports'),
('ST002', 'tickets'),
('ST002', 'tickets_manage'),
('ST002', 'users'),
('ST003', 'dashboard'),
('ST003', 'kb'),
('ST003', 'tickets'),
('ST004', 'assets'),
('ST004', 'dashboard'),
('ST004', 'tickets'),
('ST005', 'dashboard'),
('ST005', 'tickets');

-- --------------------------------------------------------

--
-- Table structure for table `user_skills`
--

CREATE TABLE `user_skills` (
  `user_id` varchar(10) NOT NULL,
  `skill` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_skills`
--

INSERT INTO `user_skills` (`user_id`, `skill`) VALUES
('ST001', 'Hardware'),
('ST001', 'Network'),
('ST001', 'Security'),
('ST001', 'Software'),
('ST002', 'Hardware'),
('ST002', 'Network'),
('ST003', 'Security'),
('ST003', 'Software'),
('ST004', 'Hardware'),
('ST005', 'Software');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `assets`
--
ALTER TABLE `assets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_assets_serial` (`serial`),
  ADD KEY `idx_assets_status` (`status`),
  ADD KEY `idx_assets_type` (`type`),
  ADD KEY `fk_assets_assigned_to` (`assigned_to`);

--
-- Indexes for table `change_requests`
--
ALTER TABLE `change_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_change_status` (`status`),
  ADD KEY `fk_change_requested_by` (`requested_by`);

--
-- Indexes for table `csat_responses`
--
ALTER TABLE `csat_responses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_csat_ticket` (`ticket_id`);

--
-- Indexes for table `kb_articles`
--
ALTER TABLE `kb_articles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_kb_category` (`category`),
  ADD KEY `idx_kb_public` (`is_public`);

--
-- Indexes for table `kb_tags`
--
ALTER TABLE `kb_tags`
  ADD PRIMARY KEY (`article_id`,`tag`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_type` (`type`),
  ADD KEY `idx_notifications_sent_at` (`sent_at`);

--
-- Indexes for table `problems`
--
ALTER TABLE `problems`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_problem_status` (`status`);

--
-- Indexes for table `problem_related_tickets`
--
ALTER TABLE `problem_related_tickets`
  ADD PRIMARY KEY (`problem_id`,`ticket_id`),
  ADD KEY `fk_prt_ticket` (`ticket_id`);

--
-- Indexes for table `service_categories`
--
ALTER TABLE `service_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `service_items`
--
ALTER TABLE `service_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_service_items_category` (`category_id`);

--
-- Indexes for table `sla_policies`
--
ALTER TABLE `sla_policies`
  ADD PRIMARY KEY (`priority`);

--
-- Indexes for table `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tickets_status` (`status`),
  ADD KEY `idx_tickets_priority` (`priority`),
  ADD KEY `idx_tickets_category` (`category`),
  ADD KEY `idx_tickets_type` (`type`),
  ADD KEY `idx_tickets_user_email` (`user_email`),
  ADD KEY `idx_tickets_created_at` (`created_at`),
  ADD KEY `fk_tickets_asset` (`asset_id`);

--
-- Indexes for table `ticket_assignees`
--
ALTER TABLE `ticket_assignees`
  ADD PRIMARY KEY (`ticket_id`,`user_id`),
  ADD KEY `fk_ticket_assignees_user` (`user_id`);

--
-- Indexes for table `ticket_attachments`
--
ALTER TABLE `ticket_attachments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_attachments_ticket` (`ticket_id`);

--
-- Indexes for table `ticket_timeline`
--
ALTER TABLE `ticket_timeline`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_timeline_ticket` (`ticket_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_users_code` (`code`),
  ADD UNIQUE KEY `uk_users_email` (`email`),
  ADD KEY `idx_users_department` (`department`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `fk_users_supervisor` (`supervisor_id`);

--
-- Indexes for table `user_permissions`
--
ALTER TABLE `user_permissions`
  ADD PRIMARY KEY (`user_id`,`permission`);

--
-- Indexes for table `user_skills`
--
ALTER TABLE `user_skills`
  ADD PRIMARY KEY (`user_id`,`skill`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `csat_responses`
--
ALTER TABLE `csat_responses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ticket_attachments`
--
ALTER TABLE `ticket_attachments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `ticket_timeline`
--
ALTER TABLE `ticket_timeline`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `assets`
--
ALTER TABLE `assets`
  ADD CONSTRAINT `fk_assets_assigned_to` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `change_requests`
--
ALTER TABLE `change_requests`
  ADD CONSTRAINT `fk_change_requested_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `csat_responses`
--
ALTER TABLE `csat_responses`
  ADD CONSTRAINT `fk_csat_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `kb_tags`
--
ALTER TABLE `kb_tags`
  ADD CONSTRAINT `fk_kb_tags_article` FOREIGN KEY (`article_id`) REFERENCES `kb_articles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `problem_related_tickets`
--
ALTER TABLE `problem_related_tickets`
  ADD CONSTRAINT `fk_prt_problem` FOREIGN KEY (`problem_id`) REFERENCES `problems` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_prt_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `service_items`
--
ALTER TABLE `service_items`
  ADD CONSTRAINT `fk_service_items_category` FOREIGN KEY (`category_id`) REFERENCES `service_categories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tickets`
--
ALTER TABLE `tickets`
  ADD CONSTRAINT `fk_tickets_asset` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `ticket_assignees`
--
ALTER TABLE `ticket_assignees`
  ADD CONSTRAINT `fk_ticket_assignees_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ticket_assignees_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `ticket_attachments`
--
ALTER TABLE `ticket_attachments`
  ADD CONSTRAINT `fk_attachments_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `ticket_timeline`
--
ALTER TABLE `ticket_timeline`
  ADD CONSTRAINT `fk_timeline_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_supervisor` FOREIGN KEY (`supervisor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `user_permissions`
--
ALTER TABLE `user_permissions`
  ADD CONSTRAINT `fk_user_permissions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_skills`
--
ALTER TABLE `user_skills`
  ADD CONSTRAINT `fk_user_skills_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
