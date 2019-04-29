CREATE DATABASE ATIVIDADES_TRIGGER
USE ATIVIDADES_TRIGGER

CREATE TABLE Caixa(
	DataCaixa DATE,
	Saldo_Inicial DECIMAL(10, 2),
	Saldo_Final DECIMAL(10, 2)
)

INSERT INTO Caixa VALUES ('2014-05-16', 100, 100)

CREATE TABLE Vendas(
	DataVenda DATE,
	Codigo INT,
	Valor DECIMAL(10, 2)
)

CREATE TRIGGER TGR_VENDAS_AI ON Vendas
FOR INSERT
AS
BEGIN
	DECLARE
		@Valor DECIMAL(10, 2),
		@Data DATETIME
	SELECT @Data = DataVenda, @Valor = Valor FROM INSERTED
	UPDATE Caixa SET Saldo_Final = Saldo_Final + @Valor
	WHERE DataCaixa = @Data
END

INSERT INTO Vendas VALUES ('2014-05-16', 2, 30)

SELECT * FROM Caixa
SELECT * FROM Vendas


CREATE TRIGGER TGR_VENDAS_DELETE ON Vendas
FOR DELETE
AS
BEGIN
	DECLARE
		@Valor DECIMAL(10, 2),
		@Data DATETIME
	SELECT @Data = DataVenda, @Valor = Valor FROM DELETED
	UPDATE Caixa SET Saldo_Final = Saldo_Final - @Valor
	WHERE DataCaixa = @Data
END

DELETE FROM Vendas WHERE Codigo = 2

SELECT * FROM Caixa


/*-----------ATIVIDADE-----------*/

CREATE TABLE Empregado(
	RGEmp VARCHAR(15) NOT NULL,
	Nome VARCHAR(50) NOT NULL,
	CPF INT NOT NULL, 
	IDDepto INT NOT NULL,
	Salario DECIMAL(10, 2) NOT NULL
)

INSERT INTO Empregado VALUES ('999999', 'Empregado 1', 12345, 1, 4000.00)
INSERT INTO Departamento VALUES (1, 'Departamento 1')

SELECT * FROM Empregado
SELECT * FROM Departamento

CREATE TABLE Departamento(
	IDDepto INT NOT NULL,
	Nome VARCHAR(50) NOT NULL
)

CREATE TABLE Projeto(
	IDProjeto INT NOT NULL,
	Nome VARCHAR(50) NOT NULL,
	Cidade VARCHAR(50) NOT NULL
)

CREATE TABLE Dependentes(
	IDDep INT NOT NULL,
	RGEmp INT NOT NULL,
	Nome VARCHAR(50) NOT NULL,
	Data_Nascimento DATE NOT NULL,
	Relacao VARCHAR(50) NOT NULL,
	Sexo VARCHAR(1) NOT NULL
)

INSERT INTO Dependentes VALUES (1, '999999', 'Dependente 1', '1992-12-12', 'Filho', 'M')

SELECT * FROM Dependentes

DROP TRIGGER TGR_DEPENTES_INS

CREATE TRIGGER TGR_DEPENTES_INS ON Dependentes
INSTEAD OF INSERT
AS
BEGIN
	DECLARE
		@Data_Nascimento DATE,
		@Sexo VARCHAR(1)
	SELECT @Data_Nascimento = Data_Nascimento, @Sexo = Sexo FROM INSERTED
	IF DATEDIFF(YEAR, @Data_Nascimento, GETDATE()) > 18	AND @Sexo = 'M'
		BEGIN
			DELETE FROM inserted
		END
	ELSE
		BEGIN
			INSERT INTO Dependentes SELECT * FROM INSERTED
		END
END

INSERT INTO Dependentes VALUES (1, '999999', 'Dependente ERRADO', '1992-12-12', 'Filho', 'M'),
(1, '999999', 'Dependente CERTO', '2012-12-12', 'Filho', 'M')

SELECT * FROM Dependentes
