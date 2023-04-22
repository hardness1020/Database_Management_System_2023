/* create and use database */
CREATE DATABASE HealthyDB;
USE HealthyDB;


/* info */
CREATE TABLE self (
    student_id VARCHAR(10) NOT NULL,
    name VARCHAR(10) NOT NULL,
    department VARCHAR(10) NOT NULL,
    year VARCHAR(10) NOT NULL,
    PRIMARY KEY (student_id)
);
INSERT INTO `self` VALUES ('r10631026', '張名翔', '生機系', '碩二');
SELECT DATABASE();
SELECT * FROM self;


/* create table */
CREATE TABLE User (
    user_id INT AUTO_INCREMENT,
    username VARCHAR(40) NOT NULL,
    password VARCHAR(40) NOT NULL,
    PRIMARY KEY (user_id),
    CHECK (username != password)
);

CREATE TABLE Admin (
    user_id INT UNIQUE NOT NULL,
    database_account VARCHAR(40) NOT NULL,
    cloud_account VARCHAR(40),
    PRIMARY KEY (user_id),
    CONSTRAINT fk_admin_user_id FOREIGN KEY (user_id) REFERENCES User(user_id)
);

CREATE TABLE Normal (
    user_id INT UNIQUE NOT NULL,
    self_inrtoduction VARCHAR(40),
    address ENUM('Taipei', 'Taichung', 'Kaohsiung', 'Other', 'Unknown') DEFAULT 'Unknown',
    PRIMARY KEY (user_id),
    CONSTRAINT fk_normal_user_id FOREIGN KEY (user_id) REFERENCES User(user_id)
);

CREATE TABLE Promoter (
    user_id INT UNIQUE NOT NULL,
    total_profit FLOAT DEFAULT 0,
    excepted_profit FLOAT DEFAULT 0,
    created_by_admin_id INT NOT NULL,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_promoter_user_id FOREIGN KEY (user_id) REFERENCES User(user_id),
    CONSTRAINT fk_promoter_created_by_admin_id FOREIGN KEY (created_by_admin_id) REFERENCES Admin(user_id) 
);

CREATE TABLE Customer (
    user_id INT UNIQUE NOT NULL,
    consumption INT DEFAULT 0,
    is_active ENUM('Y', 'N') DEFAULT 'N',
    PRIMARY KEY (user_id),
    CONSTRAINT fk_customer_user_id FOREIGN KEY (user_id) REFERENCES User(user_id)
);

CREATE TABLE Author (
    user_id INT UNIQUE NOT NULL,
    total_liked_number INT DEFAULT 0,
    total_saved_number INT DEFAULT 0,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_author_user_id FOREIGN KEY (user_id) REFERENCES User(user_id)
);

CREATE TABLE Coupon (
    promoter_id INT NOT NULL,
    code VARCHAR(40) NOT NULL,
    discount FLOAT NOT NULL,
    expire_date DATE NOT NULL,
    CONSTRAINT fk_coupon_promoter_id FOREIGN KEY (promoter_id) REFERENCES Promoter(user_id),
    PRIMARY KEY (promoter_id, code),
    CHECK (discount > 0 AND discount < 1)
);

CREATE TABLE Health (
    health_id INT NOT NULL,
    precaution VARCHAR(40) NOT NULL,
    suggestion VARCHAR(40) NOT NULL,
    PRIMARY KEY (health_id)
);

CREATE TABLE Disease (
    disease_id INT NOT NULL,
    severity ENUM('low', 'medium', 'high') NOT NULL,
    action_plan VARCHAR(40) NOT NULL,
    PRIMARY KEY (disease_id)
);

CREATE TABLE Report (
    report_id INT NOT NULL,
    date DATE NOT NULL,
    content VARCHAR(40) NOT NULL,
    author_id INT NOT NULL,
    previous_version_id INT UNIQUE,
    inherited_health_id INT UNIQUE,
    inherited_disease_id INT UNIQUE,
    PRIMARY KEY (report_id),
    CONSTRAINT fk_report_author_id FOREIGN KEY (author_id) REFERENCES Author(user_id),
    CONSTRAINT fk_report_previous_version_id FOREIGN KEY (previous_version_id) REFERENCES Report(report_id),
    CONSTRAINT fk_report_inherited_health_id FOREIGN KEY (inherited_health_id) REFERENCES Health(health_id),
    CONSTRAINT fk_report_inherited_disease_id FOREIGN KEY (inherited_disease_id) REFERENCES Disease(disease_id),
    CHECK (inherited_health_id IS NOT NULL OR inherited_disease_id IS NOT NULL)
);

CREATE TABLE Category (
    category_id INT NOT NULL,
    name VARCHAR(40) NOT NULL,
    PRIMARY KEY (category_id)
);

CREATE TABLE Article (
    article_id INT NOT NULL,
    date DATE NOT NULL,
    content VARCHAR(40) NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (article_id),
    CONSTRAINT fk_article_author_id FOREIGN KEY (author_id) REFERENCES Author(user_id)
);

CREATE TABLE ArticleCategory (
    article_id INT NOT NULL,
    category_id INT NOT NULL,
    CONSTRAINT fk_article_id FOREIGN KEY (article_id) REFERENCES Article(article_id),
    CONSTRAINT fk_category_id FOREIGN KEY (category_id) REFERENCES Category(category_id),
    PRIMARY KEY (article_id, category_id)
);

CREATE TABLE CustomerBuyReport (
    customer_id INT NOT NULL,
    report_id INT NOT NULL,
    coupon_promoter_id INT,
    coupon_code VARCHAR(40),
    CONSTRAINT fk_buy_customer_id FOREIGN KEY (customer_id) REFERENCES Customer(user_id),
    CONSTRAINT fk_buy_report_id FOREIGN KEY (report_id) REFERENCES Report(report_id),
    CONSTRAINT fk_buy_coupon FOREIGN KEY (coupon_promoter_id, coupon_code) REFERENCES Coupon(promoter_id, code),
    PRIMARY KEY (customer_id, report_id)
);

CREATE TABLE UserLikeArticle (
    user_id INT NOT NULL,
    article_id INT NOT NULL,
    CONSTRAINT fk_like_user_id FOREIGN KEY (user_id) REFERENCES User(user_id),
    CONSTRAINT fk_like_article_id FOREIGN KEY (article_id) REFERENCES Article(article_id),
    PRIMARY KEY (user_id, article_id)
);

CREATE TABLE UserSaveArticle (
    user_id INT NOT NULL,
    article_id INT NOT NULL,
    CONSTRAINT fk_save_user_id FOREIGN KEY (user_id) REFERENCES User(user_id),
    CONSTRAINT fk_save_article_id FOREIGN KEY (article_id) REFERENCES Article(article_id),
    PRIMARY KEY (user_id, article_id)
);


/* insert */
INSERT INTO `Health` (health_id, precaution, suggestion) VALUES (1, '避免過度練習', '多吃蔬菜水果');
INSERT INTO `Health` (health_id, precaution, suggestion) VALUES (2, '避免勞累', '多睡眠');
INSERT INTO `Health` (health_id, precaution, suggestion) VALUES (3, '不要抽菸', '多運動');
INSERT INTO `Disease` (disease_id, severity, action_plan) VALUES (1, 'low', '多休息');
INSERT INTO `Disease` (disease_id, severity, action_plan) VALUES (2, 'medium', '多吃藥');
INSERT INTO `Disease` (disease_id, severity, action_plan) VALUES (3, 'high', '定期複檢');

INSERT INTO `User` (username, password) VALUES ('smith', 'password123');
SET @smith_id = LAST_INSERT_ID();
INSERT INTO `Admin` (user_id, database_account) VALUES (@smith_id, 'password123');
INSERT INTO `Normal` (user_id) VALUES (@smith_id);
INSERT INTO `Promoter` (user_id, created_by_admin_id) VALUES (@smith_id, @smith_id);
INSERT INTO `Coupon` (promoter_id, code, discount, expire_date) VALUES (@smith_id, '123456', 0.5, '2020-12-31');
INSERT INTO `Author` (user_id) VALUES (@smith_id);
INSERT INTO `Report` (report_id, date, content, author_id, inherited_health_id) 
              VALUES (1, '2020-01-01', 'test1', @smith_id, 1);
INSERT INTO `Category` (category_id, name) VALUES (1, 'test1');
INSERT INTO `Article` (article_id, date, content, author_id) 
               VALUES (1, '2020-01-01', 'test1', @smith_id);
INSERT INTO `ArticleCategory` (article_id, category_id) VALUES (1, 1);


INSERT INTO `User` (username, password) VALUES ('doe', 'secret456');
SET @doe_id = LAST_INSERT_ID();
INSERT INTO `Admin` (user_id, database_account) VALUES (@doe_id, 'secret456');
INSERT INTO `UserLikeArticle` (user_id, article_id) VALUES (@doe_id, 1);
INSERT INTO `UserSaveArticle` (user_id, article_id) VALUES (@doe_id, 1);
INSERT INTO `Customer` (user_id, consumption) VALUES (@doe_id, 5000);
INSERT INTO `CustomerBuyReport` (customer_id, report_id, coupon_promoter_id, coupon_code) VALUES (@doe_id, 1, 1, '123456');

INSERT INTO `User` (username, password) VALUES ('ross', 'happytrees789');
SET @ross_id = LAST_INSERT_ID();
INSERT INTO `Admin` (user_id, database_account) VALUES (@ross_id, 'happytrees789');
INSERT INTO `Author` (user_id) VALUES (@ross_id);
INSERT INTO `Report` (report_id, date, content, author_id, inherited_disease_id) 
              VALUES (2, '2021-01-01', 'test2', @ross_id, 2);
INSERT INTO `Category` (category_id, name) VALUES (2, 'test2');
INSERT INTO `Article` (article_id, date, content, author_id) 
               VALUES (2, '2021-01-01', 'test2', @ross_id);
INSERT INTO `ArticleCategory` (article_id, category_id) VALUES (2, 1);
INSERT INTO `ArticleCategory` (article_id, category_id) VALUES (2, 2);
INSERT INTO `UserLikeArticle` (user_id, article_id) VALUES (@ross_id, 1);
INSERT INTO `UserLikeArticle` (user_id, article_id) VALUES (@ross_id, 2);
INSERT INTO `UserSaveArticle` (user_id, article_id) VALUES (@ross_id, 1);

INSERT INTO `User` (username, password) VALUES ('john', 'pass9836rd123');
SET @john_id = LAST_INSERT_ID();
INSERT INTO `Normal` (user_id) VALUES (@john_id);
INSERT INTO `Promoter` (user_id, created_by_admin_id) VALUES (@john_id, @smith_id);
INSERT INTO `Coupon` (promoter_id, code, discount, expire_date) VALUES (@john_id, '12345678', 0.5, '2025-12-31');
INSERT INTO `Customer` (user_id, consumption) VALUES (@john_id, 1000);
INSERT INTO `CustomerBuyReport` (customer_id, report_id) VALUES (@john_id, 2);

INSERT INTO `User` (username, password) VALUES ('bob', 'pass564rd123');
SET @bob_id = LAST_INSERT_ID();
INSERT INTO `Normal` (user_id) VALUES (@bob_id);
INSERT INTO `Author` (user_id) VALUES (@bob_id);
INSERT INTO `Report` (report_id, date, content, author_id, inherited_disease_id) 
              VALUES (3, '2022-01-01', 'test3', @bob_id, 3);
INSERT INTO `Category` (category_id, name) VALUES (3, 'test3');
INSERT INTO `Article` (article_id, date, content, author_id) 
               VALUES (3, '2022-01-01', 'test3', @bob_id);
INSERT INTO `ArticleCategory` (article_id, category_id) VALUES (3, 1);
INSERT INTO `ArticleCategory` (article_id, category_id) VALUES (3, 2);
INSERT INTO `ArticleCategory` (article_id, category_id) VALUES (3, 3);

INSERT INTO `User` (username, password) VALUES ('jane', 'paefeword123');
SET @jane_id = LAST_INSERT_ID();
INSERT INTO `Normal` (user_id) VALUES (@jane_id);
INSERT INTO `Promoter` (user_id, created_by_admin_id) VALUES (@jane_id, @smith_id);
INSERT INTO `Coupon` (promoter_id, code, discount, expire_date) VALUES (@jane_id, '123456789', 0.5, '2025-12-31');
INSERT INTO `Customer` (user_id, consumption) VALUES (@jane_id, 1000);
INSERT INTO `CustomerBuyReport` (customer_id, report_id, coupon_promoter_id, coupon_code) VALUES (@jane_id, 2, 4, '12345678');
INSERT INTO `CustomerBuyReport` (customer_id, report_id, coupon_promoter_id, coupon_code) VALUES (@jane_id, 3, 6, '123456789');
INSERT INTO `UserLikeArticle` (user_id, article_id) VALUES (@jane_id, 2);
INSERT INTO `UserSaveArticle` (user_id, article_id) VALUES (@jane_id, 2);


/* create two views */
CREATE VIEW customer_with_high_severity_report AS
SELECT Customer.user_id, User.username, Report.report_id FROM User, Customer, CustomerBuyReport, Report, Disease
WHERE  Disease.severity = 'high' AND
       Customer.user_id = CustomerBuyReport.customer_id AND
       CustomerBuyReport.report_id = Report.report_id AND
       Report.inherited_disease_id = Disease.disease_id AND
       User.user_id = Customer.user_id;

CREATE VIEW promoter_with_non_expired_coupon AS
Select Promoter.user_id, User.username, Coupon.code, Coupon.discount, Coupon.expire_date FROM User, Promoter, Coupon
WHERE  Coupon.expire_date > NOW() AND
       User.user_id = Promoter.user_id AND
       Promoter.user_id = Coupon.promoter_id;


/***** homework 3 commands *****/
/* basic select */
SELECT *
FROM User
WHERE (username LIKE 'j%' OR username LIKE 'b%') 
        AND NOT username LIKE '%n';

/* basic projection */
SELECT username, password
FROM User
WHERE (username LIKE 'j%' OR username LIKE 'b%') 
        AND NOT username LIKE '%n';

/* basic rename */
SELECT username AS 帳號, password AS 密碼
FROM User
WHERE (username LIKE 'j%' OR username LIKE 'b%') 
        AND NOT username LIKE '%n';

/* union */
(SELECT user_id FROM Promoter)
UNION
(SELECT user_id FROM Customer);

/* equijoin */
SELECT *
FROM User JOIN Promoter
ON User.user_id = Promoter.user_id;

/* natural join */
SELECT *
FROM User NATURAL JOIN Promoter;

/* theta join */
SELECT *
FROM Report, CustomerBuyReport, Coupon
WHERE Report.report_id = CustomerBuyReport.report_id AND
      CustomerBuyReport.coupon_promoter_id = Coupon.promoter_id AND
      CustomerBuyReport.coupon_code = Coupon.code AND
      Coupon.promoter_id = Report.author_id;

/* three table join */
SELECT username, content
FROM User, Author, Report
WHERE User.user_id = Author.user_id AND
      Author.user_id = Report.author_id;

/* aggregate */
SELECT username, COUNT(*) AS 買過報告數量, MAX(Report.date) AS 最近買報告日期, MIN(Report.date) AS 最早買報告日期
FROM User, Customer, CustomerBuyReport, Report
WHERE User.user_id = Customer.user_id AND
      Customer.user_id = CustomerBuyReport.customer_id AND
      CustomerBuyReport.report_id = Report.report_id
GROUP BY username;

/* aggregate 2 */
SELECT username, COUNT(*) AS 優惠券數量, AVG(discount) AS 平均折扣, SUM(expire_date > NOW()) AS 未過期數量
FROM User, Promoter, Coupon
WHERE User.user_id = Promoter.user_id AND
      Promoter.user_id = Coupon.promoter_id
GROUP BY username;

/* in */ 
SELECT *
FROM Disease
WHERE severity IN ('high', 'medium');

/* in 2 */
SELECT *
From Report
WHERE inherited_disease_id IN (SELECT disease_id FROM Disease WHERE severity = 'high');

/* correlated nested query */
SELECT *
FROM Report
WHERE report_id IN (SELECT report_id 
                    FROM CustomerBuyReport, Coupon 
                    WHERE CustomerBuyReport.coupon_promoter_id = Coupon.promoter_id AND
                          CustomerBuyReport.coupon_code = Coupon.code AND
                          Coupon.promoter_id = Report.author_id);
                        
/* correlated nested query 2 */
SELECT *
FROM Report
WHERE EXISTS (SELECT * 
              FROM CustomerBuyReport, Coupon 
              WHERE CustomerBuyReport.coupon_promoter_id = Coupon.promoter_id AND
                    CustomerBuyReport.coupon_code = Coupon.code AND
                    Coupon.promoter_id = Report.author_id);

/* bonus 1 */
SELECT *
FROM Customer LEFT OUTER JOIN User
ON Customer.user_id = User.user_id;

/* bonus 2 */
SELECT *
FROM Report
WHERE NOT EXISTS (SELECT * 
                  FROM CustomerBuyReport, Coupon 
                  WHERE CustomerBuyReport.coupon_promoter_id = Coupon.promoter_id AND
                        CustomerBuyReport.coupon_code = Coupon.code AND
                        Coupon.promoter_id = Report.author_id);


/* drop database */
DROP DATABASE HealthyDB;