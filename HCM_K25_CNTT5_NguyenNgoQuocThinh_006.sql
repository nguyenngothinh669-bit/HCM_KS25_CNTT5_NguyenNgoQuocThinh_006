CREATE DATABASE ktm_006_db ; 
USE ktm_006_db ; 

-- Phan 1 

CREATE TABLE Courses (
	course_id INT PRIMARY KEY AUTO_INCREMENT ,
    course_name VARCHAR(100) NOT NULL , 
    course_code VARCHAR(20) NOT NULL UNIQUE , 
    department VARCHAR(20) NOT NULL ,
    creation_date DATE NOT NULL 
) ; 

CREATE TABLE Students (
	student_id INT PRIMARY KEY AUTO_INCREMENT , 
    full_name VARCHAR(100) NOT NULL , 
    major VARCHAR(50) NOT NULL ,
    phone_number VARCHAR(15) NOT NULL UNIQUE ,
    gpa DECIMAL(2,1) DEFAULT 4.0 ,
    CONSTRAINT ck_gpa CHECK (gpa >= 0.0 AND gpa <= 4.0) 
) ; 

CREATE TABLE Enrollments (
	enrollment_id INT PRIMARY KEY AUTO_INCREMENT , 
    course_id INT NOT NULL ,
    student_id INT NOT NULL ,
    enroll_time DATETIME NOT NULL ,
    credits INT NOT NULL , 
    status ENUM('Pending','Completed','Dropped') NOT NULL , 
    
    CONSTRAINT ck_credits CHECK(credits > 0 ) , 
    CONSTRAINT fk_enrollments FOREIGN KEY (course_id) REFERENCES Courses (course_id),
    CONSTRAINT fk_students FOREIGN KEY (student_id) REFERENCES Students (student_id)
) ; 

CREATE TABLE Enrollment_Details (
	detail_id INT PRIMARY KEY AUTO_INCREMENT , 
    enrollment_id INT NOT NULL , 
    attendance_check VARCHAR(50) NOT NULL , 
    detail_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ,
    
    CONSTRAINT fl_enrollmet_details FOREIGN KEY (enrollment_id) REFERENCES Enrollments (enrollment_id) 
) ; 

CREATE TABLE Academic_Logs (
	log_id INT PRIMARY KEY AUTO_INCREMENT , 
    detail_id INT NOT NULL , 
    student_id INT NOT NULL ,
    log_time DATETIME NOT NULL , 
    note TEXT NOT NULL ,
    
    CONSTRAINT fk_academic_logs FOREIGN KEY (detail_id) REFERENCES Enrollment_Details (detail_id) 
) ; 

-- Phan 2 
-- Cau 1 : Insert 
INSERT INTO Courses (course_name,course_code  ,department ,creation_date) VALUES 
('Lập trình Java','JAVA01','CNTT','2023-12-03') ,
('Cấu trúc dữ liệu','DSA02','Khoa học máy tính','1996-11-25') ,
('Cơ sở dữ liệu','SQL03','CNTT','2001-07-08') ,
('Mạng máy tính','NET04','Truyền thông','1998-01-19') ,
('Trí tuệ nhân tạo','AI05','Khoa học máy tính','2000-09-30') ;

INSERT INTO Students (full_name,major,phone_number,gpa) VALUES 
('Nguyễn Văn Hải' ,'Hệ thống IT','0931112223',3.8) ,
('Trần Thu Hà' ,'Kỹ thuật PM','0932223334',4.0) ,
('Lê Quốc Tuấn' ,'An toàn IT','0933334445',3.6) ,
('Phạm Minh Châu' ,'Dữ liệu lớn','0934445556',3.9) ,
('Hoàng Gia Bảo' ,'Kỹ thuật PM','0935556667',3.7) ;

INSERT INTO Enrollments (enrollment_id,course_id,student_id,enroll_time,credits,status) VALUES 
(7001,1,1,'2024-05-20 08:00',3,'Pending'), 
(7002,2,2,'2024-05-20 09:30',4,'Completed'), 
(7003,3,3,'2024-05-20 10:15',3,'Pending'), 
(7004,4,5,'2024-05-21 07:00',3,'Completed'), 
(7005,5,4,'2024-05-21 08:45',4,'Dropped') ; 

INSERT INTO Enrollment_Details (detail_id,enrollment_id,attendance_check, detail_date) VALUES 
(8001,7002,'Đủ điểu kiện thi','2024-05-20 10:00') ,
(8002,7004,'Vắng 1 buổi' ,'2024-05-21 08:00') , 
(8003,7001,'Đang học','2024-05-20 09:00') , 
(8004,7003,'Nghỉ phép','2024-05-20 11:00') , 
(8005,7005,'Không đi học','2024-05-20 09:00') ; 

INSERT INTO Academic_Logs (detail_id,student_id,log_time,note) VALUES 
(8003,1,'2024-05-20 09:05','Bắt đầu lớp học'),
(8001,2,'2024-05-20 10:05','Hàn tất môn học'),
(8004,3,'2024-05-20 11:10','Đang sắp lịch bù'),
(8002,5,'2024-05-20 08:10','Chờ phê duyệt điểm'),
(8005,4,'2024-05-20 09:05','Hủy do vắng quá số'); 

-- Cau 2 
-- 2.1 
SET SQL_SAFE_UPDATES = 0 ; 
UPDATE Enrollments e
JOIN Courses c ON c.course_id = e.course_id 
SET credits = credits + 1 
WHERE status='Completed' AND  creation_date < '2000-01-01' ; 
SET SQL_SAFE_UPDATES = 1 ; 
-- 2.2 
DELETE FROM Academic_Logs WHERE log_time < '2024-05-20' ; 

-- Phan 3 
-- Cau 1 
SELECT full_name ,major,gpa FROM Students 
WHERE gpa > 3.8 OR major = 'Kỹ thuật PM' ; 
-- Cau 2 
SELECT course_name ,course_code FROM Courses 
WHERE (creation_date BETWEEN '1998-01-01' AND '2001-12-31') AND course_code LIKE 'A%' ; 
-- Cau 3 
SELECT enrollment_id ,enroll_time,credits FROM Enrollments 
ORDER BY credits DESC 
LIMIT 2 OFFSET 2 ; 

-- Phan 4 
-- Cau 1 
SELECT c.course_name ,s.full_name ,s.major,e.credits,e.enroll_time  
FROM Enrollments e 
JOIN Students s ON s.student_id = e.student_id 
JOIN Courses c ON c.course_id = e.course_id ; 
-- Cau 2 
SELECT s.full_name ,SUM(CASE WHEN e.status = 'Completed' THEN e.credits ELSE 0 END ) AS total_credits 
FROM Students s 
LEFT JOIN Enrollments e ON s.student_id = e.student_id 
GROUP BY s.student_id ,s.full_name 
HAVING total_credits > 120 ; 
-- Cau 3 
SELECT student_id , full_name , gpa FROM Students 
WHERE gpa = (SELECT MAX(gpa) max_gpa FROM Students) ; 

-- Phan 5 
-- cau 1 
CREATE INDEX idx_enrollments ON Enrollments (status,credits) ; 
-- Cau 2 
CREATE VIEW vw_show_data AS 
SELECT
	s.full_name,
    COUNT(e.enrollment_id) AS total_enrollemnts ,
    SUM(CASE WHEN e.status <> 'Dropped' THEN e.credits ELSE 0 END ) AS total_credits 
FROM Students s 
LEFT JOIN Enrollments e ON s.student_id = e.student_id 
GROUP BY s.student_id ,s.full_name ; 

-- Phan 6 
-- Cau 1 
DELIMITER //
CREATE TRIGGER trg_after_updates_enrollments 
AFTER UPDATE ON Enrollments 
FOR EACH ROW 
BEGIN 
	 DECLARE v_detail_id INT ; 
     DECLARE v_student_id INT ; 
     
	IF NEW.status = 'Completed' AND Old.status <> 'Completed' THEN 
		SELECT detail_id INTO v_detail_id 
        FROM Enrollment_Details 
        WHERE detail_id = NEW.detail_id 
        LIMIT 1 ; 
        
        SELECT student_id INTO v_student_id 
        FROM Students 
        WHERE student_id = NEW.student_id 
        LIMIT 1 ; 
        
		INSERT INTO Academic_logs (detail_id,student_id,note,log_time) 
        VALUES (v_detail_id,v_student_id,'Course completed',NOW()) ; 
    END IF ; 
END //  
DELIMITER ; 

-- Cau 2 
DELIMITER //
CREATE TRIGGER trg_after_insert_enrollments 
AFTER INSERT ON Enrollments 
FOr EACH ROW 
BEGIN 
	IF NEW.status = 'Completed' THEN 
		UPDATE Students 
        SET gpa = CASE WHEN (gpa + 0.1) > 4.0 THEN 4.0 ELSE (gpa+0.1) END 
        WHERE student_id = NEW.student_id ; 
    END IF ; 
END //  
DELIMITER ; 

-- Phan 7 
-- cau 1 
DELIMITER // 
CREATE PROCEDURE sp_check_status (p_student_id INT ,OUT p_message VARCHAR(50)) 
BEGIN 
	DECLARE v_total_credits INT ; 
    
    SELECT SUM(CASE WHEN status = 'Completed' THEN credits ELSE 0 END ) INTO v_total_credits 
    FROM Enrollments 
    WHERE student_id = p_student_id ; 
    
    IF v_total_credits > 100 THEN
		SET p_message = 'Excellent progress' ;
	ELSEIF v_total_credits = 100 THEN 
		SET p_message = 'Target met' ; 
	ELSE 
		SET p_message = 'Normal progress'; 
    END IF ; 
END // 
DELIMITER ; 

-- Cau 2 
DELIMITER // 
CREATE PROCEDURE sp_transfer_students (p_student_id INT,p_new_enrollment_id INT) 
BEGIN 
	DECLARE v_is_valid INT DEFAULT 0 ; 
	DECLARE v_detail_id INT ; 
	DECLARE v_student_id INT ; 
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
		ROLLBACK ; 
        RESIGNAL ; 
    END ; 
    
    START TRANSACTION ; 
    IF v_is_valid = 0 THEN 
		SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ERROR: Not found ' ; 
	ELSE 
		
		UPDATE Enrollments 
        SET student_id = p_student_id 
        WHERE enrollment_id = p_new_enrollment_id ; 
        
        SELECT detail_id INTO v_detail_id 
        FROM Enrollment_Details 
        WHERE enrollment_id = p_new_enrollment_id
        LIMIT 1 ; 
        
        SELECT student_id INTO v_student_id 
        FROM Students 
        WHERE student_id = p_student_id 
        LIMIT 1 ; 
        
		INSERT INTO Academic_logs (detail_id,student_id,note,log_time) 
        VALUES (v_detail_id,v_student_id,'Reassigned',NOW()) ; 
        
        COMMIT ; 
	END IF ; 
END // 
DELIMITER ; 
