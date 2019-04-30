CREATE DATABASE EXEMPLO_TRIGGERS

USE EXEMPLO_TRIGGERS
-- DEFINIÇÃO TABELAS


CREATE TABLE departamento
(
  iddepto INT IDENTITY,
  nome    VARCHAR(60)
)
ALTER TABLE DEPARTAMENTO ADD PRIMARY KEY (iddepto)

INSERT INTO departamento VALUES ('INFORMATICA')
INSERT INTO departamento VALUES ('COMPRAS')
INSERT INTO departamento VALUES ('FINANCEIRO')

SELECT * FROM departamento
-------------------------------------------------------------------------------------------
CREATE TABLE projeto
(
  idprojeto INT IDENTITY,
  nome      VARCHAR(60),
  cidade    VARCHAR(60)
)
ALTER TABLE projeto ADD PRIMARY KEY (idprojeto)
--------------------------------------------------------------------------------------------
CREATE TABLE empregado
(
  rgemp   VARCHAR(15) NOT NULL,
  nome    VARCHAR(60),
  cpf     VARCHAR(11),
  iddepto INT,
  salario DECIMAL(10,2)
)
ALTER TABLE empregado ADD PRIMARY KEY (rgemp)
ALTER TABLE empregado ADD CONSTRAINT fk_iddepto FOREIGN KEY (iddepto) REFERENCES DEPARTAMENTO(iddepto)

INSERT INTO empregado(rgemp,nome,cpf,iddepto,salario) VALUES('62245','JOSE SILVA','172228',2,937)
INSERT INTO empregado(rgemp,nome,cpf,iddepto,salario) VALUES('4534245','ANA SEIXAS','622172228',1,1500)
INSERT INTO empregado(rgemp,nome,cpf,iddepto,salario) VALUES('345345','RENATO JOSE','485172458',3,2500)
INSERT INTO empregado(rgemp,nome,cpf,iddepto,salario) VALUES('5645346','MARCIO NIETIEDT','543472458',2,2500)
INSERT INTO empregado(rgemp,nome,cpf,iddepto,salario) VALUES('325346','MARCIA NIETIEDT','5367472458',2,3750)

SELECT * FROM empregado
----------------------------------------------------------------------------------------------------------------------
CREATE TABLE dependentes
(
  iddep INT IDENTITY NOT NULL,
  rgemp VARCHAR(15) NOT NULL,
  nome  VARCHAR(60),
  data_nascimento DATE,
  relacao CHAR(01),
  sexo    CHAR(01)
)
ALTER TABLE dependentes ADD PRIMARY KEY (iddep,rgemp)
ALTER TABLE dependentes ADD CONSTRAINT fk_rgemp FOREIGN KEY (rgemp) REFERENCES EMPREGADO(rgemp)


-- TRIGGERS
-----------------------------------------------------------------------------------
--Crie um trigger que evite que sejam inseridos novos dependentes (na tabela dependentes) se a idade do dependente for maior que 18 anos e ele for do sexo masculino. 

CREATE TRIGGER TGR_DEPENDENTES_BI ON dependentes
INSTEAD OF INSERT
AS
BEGIN
  DECLARE @sexo  CHAR(01),
          @idade INT,
          @nome VARCHAR(60),
          @data_nascimento DATETIME,
          @relacao CHAR(01),
          @rgemp VARCHAR(15)
-- DADOS
  SELECT @sexo = sexo, 
         @idade = datediff(yyyy,data_nascimento, GETDATE()),
         @nome = nome, 
         @data_nascimento = data_nascimento, 
         @relacao = relacao,
         @rgemp = rgemp
  FROM INSERTED
  --
  IF @sexo = 'M' AND @idade > 18
  BEGIN
    SELECT 'MENSAGEM: SEXO E IDADE NAO PERMITIDO'
  END
  ELSE
  BEGIN
    INSERT INTO dependentes(rgemp,nome,data_nascimento,relacao,sexo) VALUES(@rgemp,@nome,@data_nascimento,@relacao,@sexo)    
  END	
  --
  RETURN
END

INSERT INTO dependentes (rgemp,nome,data_nascimento,relacao,sexo) values('62245','CARLOS SILVA','1972-07-30','F','M')
INSERT INTO dependentes (rgemp,nome,data_nascimento,relacao,sexo) values('62245','ANA SILVA','1972-07-30','F','F')
INSERT INTO dependentes (rgemp,nome,data_nascimento,relacao,sexo) values('62245','XICO SILVA','1999-07-15','F','M')
INSERT INTO dependentes (rgemp,nome,data_nascimento,relacao,sexo) values('62245','RODRIGO SILVA','1990-08-30','F','M')
INSERT INTO dependentes (rgemp,nome,data_nascimento,relacao,sexo) values('325346','DIEGO DE NETO','2001-05-05','F','F')

SELECT * FROM dependentes
-----------------------------------------------------------------------------------

--  trigger de insercao que atualize valor salario em R$ 50
CREATE TRIGGER TGR_EMPREGADO_AI ON empregado
FOR INSERT
AS
BEGIN
  DECLARE @rgemp VARCHAR(15)
  SELECT @rgemp = rgemp FROM INSERTED
  --UPDATE empregado SET salario = 50 WHERE rgemp = @rgemp
  --
  RETURN
END

select * from empregado

UPDATE EMPREGADO SET SALARIO =  SALARIO + 50 where RGEMP = 345345

-----------------------------------------------------------------------------------

-- trigger de exclusao que nao exclua projeto em que localizacao CURITIBA OU SAO PAULO
CREATE TRIGGER projeto_de ON projeto
INSTEAD OF DELETE
AS
BEGIN
  DECLARE @idprojeto INT,
          @cidade VARCHAR(60)
  -- BUSCAR VALORES
  SELECT @idprojeto = idprojeto,
         @cidade    = cidade
  FROM DELETED
  
  IF @cidade NOT IN('CURITIBA','SAO PAULO')
  BEGIN
    DELETE projeto WHERE @idprojeto = idprojeto 
  END
  ELSE
  BEGIN
    SELECT 'MENSAGEM: CIDADE NAO PERMITE EXCLUSAO'
  END
  --
  RETURN
END


INSERT INTO projeto (nome,cidade) VALUES('PROJETO PREFEITURA LAJEADO','LAJEADO')
INSERT INTO projeto (nome,cidade) VALUES('PROJETO PREFEITURA OSASCO','OSASCO')
INSERT INTO projeto (nome,cidade) VALUES('PROJETO CENTRAL 156 RIO','RIO DE JANEIRO')
INSERT INTO projeto (nome,cidade) VALUES('PROJETO 156 CURITIBA','CURITIBA')
INSERT INTO projeto (nome,cidade) VALUES('PROJETO 156 SAO PAULO','SAO PAULO')
INSERT INTO projeto (nome,cidade) VALUES('PROJETO CHIP DOG CURITIBA','CURITIBA')

SELECT * FROM projeto

DELETE FROM projeto WHERE idprojeto = 6

-----------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

-- TRIGGER insert, update que so permite PROJETOS cidades CURITIBA, SAO PAULO
CREATE TRIGGER projeto_IU ON projeto
AFTER INSERT, UPDATE
AS
BEGIN
  DECLARE @idprojeto INT,
          @cidade VARCHAR(60),
          @nome   VARCHAR(60)
  -- VALIDAR INSERT e UPDATE
  IF EXISTS( SELECT * FROM INSERTED )
  BEGIN
    SELECT @idprojeto = idprojeto,
           @cidade    = cidade,
           @nome      = nome
    FROM INSERTED
    --
    IF @cidade IN('CURITIBA','SAO PAULO')
    BEGIN
     INSERT INTO projeto (nome,cidade) VALUES(@nome,@cidade)
    END
    ELSE
    BEGIN
      SELECT 'MENSAGEM: INSERT OU UPDATE - PROJETO NAO PERMITE ESTA CIDADE'
    END
  END
   --
  RETURN
END
-- *********************

select * from projeto

INSERT INTO projeto (nome,cidade) VALUES('PROJETO PREFEITURA LAJEADO','LAJEADO')
INSERT INTO projeto (nome,cidade) VALUES('PROJETO PREFEITURA OSASCO','OSASCO')
INSERT INTO projeto (nome,cidade) VALUES('PROJETO CENTRAL 156 RIO','RIO DE JANEIRO')
INSERT INTO projeto (nome,cidade) VALUES('PROJETO 156 CURITIBA','CURITIBA')
INSERT INTO projeto (nome,cidade) VALUES('PROJETO 156 SAO PAULO','SAO PAULO')
INSERT INTO projeto (nome,cidade) VALUES('PROJETO CHIP DOG CURITIBA','CURITIBA')

 UPDATE projeto SET cidade = 'LONDRINA' WHERE idprojeto = 2