CREATE DATABASE ATIVIDADES_SP
USE ATIVIDADES_SP


/*PACIENTE*/
CREATE TABLE Paciente(
	CPF INT PRIMARY KEY IDENTITY NOT NULL,
	Nome VARCHAR(100) NOT NULL,
	Telefone VARCHAR(11) NULL,
	Email VARCHAR(50) NULL,
	Cidade VARCHAR(50) NULL,
)

/*MEDICO*/
CREATE TABLE Medico(
	CRM INT PRIMARY KEY IDENTITY NOT NULL,
	Nome VARCHAR(50) NOT NULL
)

/*CONSULTA*/
CREATE TABLE Consulta(
	CPF INT,
	CRM INT,
	DataHora DATETIME NOT NULL,
	Valor DECIMAL(15, 2) NULL,
	PRIMARY KEY (CPF, CRM, DataHora),
	FOREIGN KEY (CPF) REFERENCES Paciente(CPF),
	FOREIGN KEY (CRM) REFERENCES Medico(CRM),
)

SELECT * FROM Paciente
SELECT * FROM Medico
SELECT * FROM Consulta ORDER BY DataHora

/*PROCEDURE*/
CREATE PROCEDURE SP_CadastraMedico(
	@Nome VARCHAR(50)
)
AS
BEGIN
	INSERT INTO Medico (Nome)
	VALUES (@Nome)
END

EXEC SP_CadastraMedico 'Doutor João'
EXEC SP_CadastraMedico 'Doutor José'


/*PROCEDURE*/
CREATE PROCEDURE SP_CadastraPaciente(
	@Nome VARCHAR(100),
	@Telefone VARCHAR(11),
	@Email VARCHAR(50),
	@Cidade VARCHAR(50)
)
AS
BEGIN
	INSERT INTO Paciente(Nome, Telefone, Email, Cidade)
	VALUES (@Nome, @Telefone, @Email, @Cidade)
END

EXEC SP_CadastraPaciente 'Rivaldo', '3030-4040', 'rivaldo@gmail.com', 'Curitiba'
EXEC SP_CadastraPaciente 'Ronaldo', '4040-3030', 'ronaldo@gmail.com', 'Colombo'
EXEC SP_CadastraPaciente 'Romário', '3434-3434', 'romario@gmail.com', 'Rio de Janeiro'


/*PROCEDURE*/
CREATE PROCEDURE SP_RegistraConsulta(
	@CPF INT,
	@CRM INT,
	@DataHora DATETIME,
	@Valor DECIMAL(15, 2))
AS
BEGIN
	IF(@DataHora < GETDATE())
		BEGIN
			INSERT INTO Consulta (CPF, CRM, DataHora, Valor)
			VALUES (@CPF, @CRM, @DataHora, @Valor)
		END
	ELSE
		BEGIN
			SELECT 'Data da consulta fora dos paramêtros permitidos'
		END
END

EXEC SP_RegistraConsulta 2, 2, '2017-11-07 22:00:00', 125.00
EXEC SP_RegistraConsulta 3, 2, '2017-11-07 22:00:00', 125.00
EXEC SP_RegistraConsulta 3, 2, '2016-10-09 22:00:00', 1525.00

CREATE PROCEDURE sp_AgendaConsulta (
	@CPF INT,
	@CRM INT,
	@DataHora DATETIME)
AS
BEGIN
	
	IF @DataHora < GETDATE()
		BEGIN
			SELECT 'A Data da consulta deve ser uma data Futura'
		END
	ELSE
		BEGIN
			INSERT INTO Consulta (CPF, CRM, DataHora)
		VALUES (@CPF, @CRM, @DataHora)
	END
END

EXEC sp_AgendaConsulta 2, 1, '2017-11-12 21:30:00'
EXEC sp_AgendaConsulta 1, 2, '2017-11-11 14:00:00'

SELECT * FROM CONSULTA


/*PROCEDURE*/
CREATE PROCEDURE SP_ExpurgaConsulta
AS 
BEGIN
	DELETE Consulta WHERE DATEDIFF(DAY, DataHora, GETDATE()) > 365
END

EXEC SP_ExpurgaConsulta

CREATE PROCEDURE SP_PacienteCidade(
	@Cidade VARCHAR(50)
)
AS
BEGIN
	SELECT Nome FROM Paciente WHERE Cidade = @Cidade ORDER BY Nome
END

EXEC SP_PacienteCidade 'Curitiba'


/*PROCEDURE*/
CREATE PROCEDURE SP_PacientesSemConsulta
AS
BEGIN
	SELECT Nome FROM Paciente WHERE CPF NOT IN (SELECT CPF FROM Consulta) ORDER BY Nome
END

EXEC SP_PacientesSemConsulta


/*PROCEDURE*/
CREATE PROCEDURE SP_ValorEmConsultas(
	@Medico VARCHAR(50)
)
AS
BEGIN
	SELECT M.CRM, M.Nome, SUM(C.Valor)
	FROM Medico M
	JOIN Consulta C ON C.CRM = M.CRM AND C.Valor IS NOT NULL
	WHERE M.Nome = @Medico
	GROUP BY M.CRM, M.Nome
END

EXEC SP_ValorEmConsultas 'Doutor João'


/*PROCEDURE*/
CREATE PROCEDURE SP_PostergarConsultas(
	@Dias INT
)
AS
BEGIN
	UPDATE Consulta SET DataHora = DATEADD(DAY, @Dias, DataHora) WHERE DataHora > GETDATE()
END

EXEC SP_PostergarConsultas 30



