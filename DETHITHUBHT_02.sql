CREATE DATABASE QLBV
USE QLBV 

CREATE TABLE Benhvien (
	mabv char(4) primary key,
	tenbv varchar(50),
	diachi varchar(50)
	)

CREATE TABLE Nhasx (
	mansx char(4) primary key,
	tensx varchar(50),
	diachi varchar(50)
	)

CREATE TABLE Thuoc (
	mathuoc char(4) primary key,
	tenthuoc varchar(20),
	dvt varchar(5),
	giathuoc money,
	mansx char(4) FOREIGN KEY REFERENCES Nhasx(mansx)
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
	mabv char(4) FOREIGN KEY REFERENCES Benhvien(mabv),
	mabn char(4) FOREIGN KEY REFERENCES Benhnhan(mabn),
	ngkham smalldatetime,
	chandoan varchar(50),
	ghichu varchar(100)
	)

CREATE TABLE Toathuoc (
	makb char(10) FOREIGN KEY REFERENCES Khambenh(makb),
	mathuoc char(4) FOREIGN KEY REFERENCES Thuoc(mathuoc),
	sl int,
	trigia money,
	PRIMARY KEY(makb, mathuoc)
	)

-- CAU 1.2 
ALTER TABLE Nhasx ALTER COLUMN diachi varchar(100)

-- CAU 1.3
INSERT INTO Benhvien(mabv, tenbv, diachi) VALUES
('BV1','BV1','SG1');

INSERT INTO Benhnhan(mabn, hoten, sdt, ngsinh, gioitinh) VALUES
('BN1','BN1','123','12/12/2012','Nam');

INSERT INTO Khambenh(makb, mabv, mabn, ngkham, chandoan, ghichu) VALUES
('KB1','BV1','BN1','12/12/2022','LAO','BENHLAO');

-- CAU 2.1
ALTER TABLE Benhnhan
ADD CONSTRAINT GT_CK CHECK ( gioitinh IN ('Nam','Nu'))

-- CAU 2.2 
ALTER TABLE Toathuoc
ADD CONSTRAINT SL_CK CHECK (sl > 0)

-- CAU 2.3 
GO 
CREATE TRIGGER TGMOII
ON Toathuoc
FOR INSERT, UPDATE 
AS 
BEGIN 
	UPDATE Toathuoc 
	SET trigia = INS.sl * Thuoc.giathuoc
	FROM inserted INS
	JOIN Toathuoc TT ON INS.makb = TT.makb AND INS.mathuoc = TT.mathuoc
	JOIN Thuoc ON INS.mathuoc = Thuoc.mathuoc
END 

-- CAU 3.1 
SELECT Thuoc.*, tensx
FROM Thuoc
JOIN Nhasx NSX ON Thuoc.mansx = NSX.mansx
ORDER BY giathuoc DESC 

-- CAU 3.2 
SELECT BN.mabn, hoten, COUNT(DISTINCT makb) AS Solankham 
FROM Benhnhan BN
JOIN Khambenh KB ON BN.mabn = KB.mabn 
WHERE YEAR(ngkham) = 2016 
GROUP BY BN.mabn, hoten, MONTH(ngkham)

-- CAU 3.3 
SELECT Nhasx.mansx, tensx, diachi 
FROM Nhasx 
EXCEPT 
SELECT Nhasx.mansx, tensx, diachi 
FROM Nhasx
JOIN Thuoc ON Nhasx.mansx = Thuoc.mansx 
WHERE giathuoc > 59000

-- CAU 3.4 
SELECT BV.mabv, tenbv
FROM Benhvien BV 
JOIN Khambenh KB ON BV.mabv = KB.mabv 
WHERE YEAR(ngkham) = 2017 
GROUP BY BV.mabv, tenbv 
HAVING COUNT(KB.mabn) = (
	SELECT MAX(Luot)
	FROM (
		SELECT BV.mabv, COUNT(KB.mabn) AS Luot
		FROM Benhvien BV 
		JOIN Khambenh KB ON BV.mabv = KB.mabv 
		WHERE YEAR(ngkham) = 2017
		GROUP BY BV.mabv ) AS BANG)

-- CAU 3.5 
SELECT BN.mabn, hoten 
FROM Benhnhan BN 
JOIN Khambenh KB ON BN.mabn = KB.mabn
JOIN Benhvien BV ON KB.mabv = BV.mabv
WHERE YEAR(ngkham) = 2017 AND BV.mabv = 'bv1'
EXCEPT 
SELECT BN.mabn, hoten 
FROM Benhnhan BN 
JOIN Khambenh KB ON BN.mabn = KB.mabn
JOIN Benhvien BV ON KB.mabv = BV.mabv
WHERE YEAR(ngkham) = 2017 AND BV.mabv = 'bv2'

-- CAU 3.6 
SELECT BV.mabv, tenbv 
FROM Benhvien BV
WHERE NOT EXISTS (
	SELECT * 
	FROM Benhnhan BN 
	WHERE gioitinh = 'Nam' AND YEAR(ngsinh) < 1980 AND NOT EXISTS(
		SELECT *
		FROM Khambenh KB 
		WHERE KB.mabv = BV.mabv 
		AND KB.mabn = BN.mabn ))
