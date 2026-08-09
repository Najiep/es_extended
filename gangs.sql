-- ESX Gang System schema for existing databases.
-- This file is safe to run more than once on MySQL/MariaDB.

SET @has_gang_column = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'gang'
);
SET @sql = IF(
    @has_gang_column = 0,
    'ALTER TABLE `users` ADD COLUMN `gang` VARCHAR(50) NULL DEFAULT ''nogang'' AFTER `job_grade`',
    'SELECT 1' 
);
PREPARE esx_gang_stmt FROM @sql;
EXECUTE esx_gang_stmt;
DEALLOCATE PREPARE esx_gang_stmt;

SET @has_gang_grade_column = (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'gang_grade'
);
SET @sql = IF(
    @has_gang_grade_column = 0,
    'ALTER TABLE `users` ADD COLUMN `gang_grade` INT NULL DEFAULT 0 AFTER `gang`',
    'SELECT 1' 
);
PREPARE esx_gang_stmt FROM @sql;
EXECUTE esx_gang_stmt;
DEALLOCATE PREPARE esx_gang_stmt;

CREATE TABLE IF NOT EXISTS `gangs` (
    `name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `gang_grades` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `gang_name` VARCHAR(50) NOT NULL,
    `grade` INT NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_gang_grade` (`gang_name`, `grade`),
    KEY `idx_gang_name` (`gang_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `gangs` (`name`, `label`) VALUES ('nogang', 'No Gang');
INSERT IGNORE INTO `gang_grades` (`gang_name`, `grade`, `name`, `label`) VALUES ('nogang', 0, 'nogang', 'No Gang');
