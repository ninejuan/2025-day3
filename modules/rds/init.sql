CREATE DATABASE IF NOT EXISTS userdb 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- 아래 created_at, updated_at 칼럼은 dump 보고 삽입여부 결정

USE userdb;

CREATE TABLE IF NOT EXISTS user (
  id              VARCHAR(255) NOT NULL,
  username        VARCHAR(255) NOT NULL,
  email           VARCHAR(255) NOT NULL,
  status_message  VARCHAR(255) NOT NULL,
  -- created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  -- updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),                                
  UNIQUE KEY uk_username (username),               
  KEY idx_email (email)
  -- KEY idx_created_at (created_at)
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  ROW_FORMAT=COMPRESSED;

CREATE INDEX idx_email_status ON user(email, status_message(50));

ANALYZE TABLE user;

CREATE USER IF NOT EXISTS 'userapp'@'%' IDENTIFIED BY 'UserApp2025!';
GRANT SELECT, INSERT, UPDATE ON userdb.user TO 'userapp'@'%';

FLUSH PRIVILEGES;
