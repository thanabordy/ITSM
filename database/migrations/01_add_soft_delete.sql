-- Add soft delete column to Users
ALTER TABLE users ADD COLUMN deleted_at DATETIME DEFAULT NULL;

-- Add soft delete column to Assets
ALTER TABLE assets ADD COLUMN deleted_at DATETIME DEFAULT NULL;

-- Add soft delete column to Tickets
ALTER TABLE tickets ADD COLUMN deleted_at DATETIME DEFAULT NULL;

-- Add soft delete column to KB Articles
ALTER TABLE kb_articles ADD COLUMN deleted_at DATETIME DEFAULT NULL;
