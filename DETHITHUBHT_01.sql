CREATE DATABASE QLPK
USE QLPK 

CREATE TABLE Phongkham  (
	maph char(4) primary key,
	tenph varchar(50),
	diachi varchar(50)
	)

CREATE TABLE Nhacungcap (
	mancc char(4) primary key,
	tenncc varchar(50),
	diachi varchar(50)
	)

CREATE TABLE Thuoc (
	mathuoc char(4) primary key,
	tenthuoc varchar(20),
	dvt varchar(5),
	giathuoc money,
	mancc char(4) FOREIGN KEY REFERENCES Nhacungcap(mancc)
	)

CREATE TABLE Benhnhan (
	mabn char(4) primary key,
	hoten varchar(50),
	sdt varchar(10),
	ngsinh smalldatetime,
	gioitinh char(3)
	)

CREATE TABLE Khambenh (
	makb char(10) primary key,
	maph char(4) FOREIGN KEY REFERENCES Phongkham(maph),
	mabn char(4) FOREIGN KEY REFERENCES Benhnhan(mabn),
	ngkham smalldatetime,
	chandoan varchar(50),
	ghichu varchar(100)
	)

CREATE TABLE Donthuoc (
	makb char(10) FOREIGN KEY REFERENCES Khambenh(makb),
	mathuoc char(4) FOREIGN KEY REFERENCES Thuoc(mathuoc),
	sl int,
	thanhtien money,
	primary key (makb, mathuoc)
	)

-- CAU 1.2
ALTER TABLE Nhacungcap ADD ghichu varchar(50)

-- CAU 1.3
INSERT INTO Nhacungcap (mancc, tenncc, diachi) VALUES 
('NCC1','NCC1','SO1'),
('NCC2','NCC2','SO2');
INSERT INTO Thuoc (mathuoc, tenthuoc, dvt, giathuoc, mancc) VALUES
('T01','T01','VI','10000','NCC1'),
('T02','T02','VI','20000','NCC2');

-- CAU 2.1 
ALTER TABLE Thuoc 
ADD CONSTRAINT GIATHUOC_CK CHECK (giathuoc > 0)

-- CAU 2.2
ALTER TABLE Thuoc 
ADD CONSTRAINT DVT_CK CHECK (dvt IN ('chai','hop','vien'))

-- CAU 2.3 
GO
CREATE TRIGGER TGNEE
ON Donthuoc
FOR INSERT, UPDATE
AS 
BEGIN 
	UPDATE Donthuoc
	SET thanhtien = INS.sl * Thuoc.giathuoc
	FROM inserted INS
	JOIN Donthuoc DT ON INS.makb = DT.makb AND INS.mathuoc = DT.mathuoc
	JOIN Thuoc ON INS.mathuoc = Thuoc.mathuoc
END

-- CAU 3.1 
SELECT Thuoc.* , tenncc
FROM Thuoc
JOIN Nhacungcap NCC ON Thuoc.mancc = NCC.mancc
ORDER BY giathuoc ASC 

-- CAU 3.2 
SELECT PH.maph, SUM(thanhtien) AS Doanhthu
FROM Phongkham PH 
JOIN Khambenh KB ON PH.maph = KB.maph
JOIN Donthuoc DT ON KB.makb = DT.makb
JOIN Thuoc ON DT.mathuoc = Thuoc.mathuoc
WHERE YEAR(ngkham) = 2017 
GROUP BY PH.maph, MONTH(ngkham)

-- CAU 3.3
SELECT NCC.mancc, tenncc 
FROM Nhacungcap NCC
EXCEPT 
SELECT NCC.mancc, tenncc 
FROM Nhacungcap NCC
JOIN Thuoc ON NCC.mancc = Thuoc.mancc
WHERE giathuoc <= 30000

-- CAU 3.4 
SELECT BN.mabn, hoten
FROM Benhnhan BN 
JOIN Khambenh KB ON BN.mabn = KB.mabn
WHERE YEAR(ngkham) = 2017
GROUP BY BN.mabn, hoten 
HAVING COUNT(DISTINCT KB.makb) = (
	SELECT MAX(Lankham)
	FROM (
		SELECT BN.mabn, hoten, COUNT (DISTINCT KB.makb) AS Lankham
		FROM Benhnhan BN 
		JOIN Khambenh KB ON BN.mabn = KB.mabn 
		WHERE YEAR(ngkham) = 2017
		GROUP BY BN.mabn, hoten
		) AS BP) 

-- CAU 3.5 
SELECT BN.mabn, hoten 
FROM Benhnhan BN 
JOIN Khambenh KB ON BN.mabn = KB.mabn
JOIN Phongkham PH ON KB.maph = PH.maph
WHERE ngkham = '1/1/2017' AND PH.maph = 'pk1' 
INTERSECT 
SELECT BN.mabn, hoten 
FROM Benhnhan BN 
JOIN Khambenh KB ON BN.mabn = KB.mabn
JOIN Phongkham PH ON KB.maph = PH.maph
WHERE ngkham = '1/1/2017' AND PH.maph = 'pk2'

-- CAU 3.6
SELECT PH.maph 
FROM Phongkham PH 
WHERE NOT EXISTS (
	SELECT *
	FROM Benhnhan BN
	WHERE gioitinh = 'Nu' AND YEAR(ngsinh) = 1960
	AND NOT EXISTS (
		SELECT *
		FROM Khambenh KB 
		WHERE KB.maph = PH.maph 
		AND KB.mabn = BN.mabn ))

