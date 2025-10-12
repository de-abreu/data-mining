-------------------------------------------------------------------------------------------------------
-- Caetano Traina Júnior -- Agosto de 2016 ------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

--=======================================================================================================--
--==    Roda NomesProprios-Carga.sql  						--==--  Cria a tabela de Nomes próprios    ==--
--==    Roda SobreNomes-Carga.sql                           --==--  Cria a tabela de Sobrenomes        ==--
--==    Roda: CreateInsertTab-Cidades.sql                   --==--  Cria a tabela de Cidades do brasil ==--
--==    Roda Cria-Alunos.sql  -->  Só até o bloco indicado: --==--  Cria a tabela Aluno80K             ==--
--==    Roda Cria-Prof.sql    -->  Só até o bloco indicado: --==--  Cria a tabela Professor80K         ==--
--==    Roda USPAnuario-Q1.04.sql  --  Usa USPAnuario-Q1.04.csv  --  Gera UnidadeUSP                   ==--
--==    Roda USPAnuario-T3.02.sql  --  Usa USPAnuario-T3.02.csv  --  Gera DeptoUSP                     ==--
--==    Roda Cria-Discip.sql  -->  Só até o bloco indicado: --==--  Cria a tabela Discip80K            ==--
--==================================================================================================

--===============================================================================================---
--===============================================================================================---
-- Gerar as Turmas --============================================================================---
--===============================================================================================---
-- Criar e popular a tabela: PrepTurma
DROP TABLE IF EXISTS PrepTurma CASCADE;
-- CREATE TABLE PrepTurma (
--     Codigo      DECIMAL(5),
--     Sigla       CHAR(7),
--     NTurmas      DECIMAL(2),
--     NNalunos    DECIMAL(3),
-- 
-- 	DiscipId    INTEGER,
-- 	DeptoId     INTEGER,
-- 	Unidade     TEXT
-- 	);
--	Codigo, Sigla, NTurmas, NNalunos, DiscipId, DeptoId, Unidade

SELECT PrepDiscip.Sigla Sigla,
       CAST(ABS(4-4*(Random()+Random()+Random())+Random()+Random()) AS INTEGER) NTurmas, 
       10*CAST((DeptoUSP.NNAlunosTeorica+DeptoUSP.NNAlunosPratica)/20 AS INTEGER)+20 NNAlunos, 
       PrepDiscip.DiscipId, 
       PrepDiscip.DeptoId, 
       PrepDiscip.Unidade
    INTO PrepTurma
    FROM PrepDiscip, DeptoUSP
    WHERE PrepDiscip.DiscipDeptoID=DeptoUSP.DeptoId;
-- Sigla, NTurmas, NNAlunos, DiscipID, DeptoId, Unidade

UPDATE PrepTurma
    SET NTurmas=1
    WHERE NTurmas<1;

-- SELECT * FROM PrepTurma Order by DiscipId;

-- SELECT NTurmas, Count(*) FROM PrepTurma GROUP BY NTurmas ORDER BY NTurmas

--=================================================
-- Criar e popular a tabela: Turma e TurmaExtendida
DROP TABLE IF EXISTS TurmaE;
DROP TABLE IF EXISTS Turma;
--CREATE TABLE TurmaE (
--    Sigla       CHAR(7),
--    Numero      DECIMAL(2),
--    Codigo      DECIMAL(5),
--    NNalunos    DECIMAL(3),
--    DiscipId    INTEGER,    --E
--    DeptoId     INTEGER,    --E
--    Unidade     TEXT        --E
--    );

DROP SEQUENCE IF EXISTS NTurma;
CREATE SEQUENCE NTurma START 1000;
SELECT PrepTurma.Sigla,
       generate_series(1,NTurmas) Numero, 
       NextVal('NTurma') Codigo,
       PrepTurma.NNAlunos, 
       PrepTurma.DiscipId, 
       PrepTurma.DeptoId, 
       PrepTurma.Unidade
    INTO TurmaE
    FROM PrepTurma;

DROP SEQUENCE NTurma;

SELECT TurmaE.Sigla,
       TurmaE.Numero, 
       TurmaE.Codigo,
       TurmaE.NNAlunos 
    INTO Turma
    FROM TurmaE;

-- SELECT Numero, Count(*) FROM TurmaE WHERE Unidade='ICMC' GROUP BY Numero ORDER BY Numero

--===============================================================================================---
--===============================================================================================---
-- Gerar as Matrículas --========================================================================---
--===============================================================================================---
DROP TABLE IF EXISTS Matricula;
DROP TABLE IF EXISTS PrepMatricula;
--CREATE TABLE Matricula (
--    CodigoTurma DECIMAL(4),
--    NUSP        DECIMAL(8),
--    NotaP1      DECIMAL(3,1),
--    NotaP2      DECIMAL(3,1),
--    NotaSub     DECIMAL(3,1),
--    MediaT      DECIMAL(3,1),
--    Frequencia  DECIMAL(3)
--	);

DROP SEQUENCE IF EXISTS NMatric;
CREATE SEQUENCE NMatric START 1;
SELECT TurmaE.Codigo CodigoTurma,
--     CAST(79999*Random()+1 AS INTEGER) IdAluno,
       CAST(((SELECT Valor FROM AcadVarInt WHERE Nome='GeraAlunos')-1)*Random()+1 AS INTEGER) IdAluno,
	   CAST(0 as DECIMAL(8))   NUSP,
       NextVal('NMatric') MatricId,
       generate_series(1,CAST(10+((NNAlunos-10)*Random()) AS INTEGER)) Numero,
	   NNAlunos
    INTO PrepMatricula
    FROM TurmaE;
DROP SEQUENCE NMatric;

--Select Min(IdAluno), Max(IdAluno) from PrepMatricula;

--DROP TABLE TurmaE;

DROP INDEX IF EXISTS PrepAluno_IX;
CREATE INDEX PrepAluno_IX ON PrepAluno(ID);
UPDATE PrepMatricula M
    SET NUSP=(SELECT A.NUSP FROM PrepAluno A WHERE M.IdAluno=A.ID
        );

-- Remove (NUSP, Sigla, Ano, Semestre) duplicados
DROP TABLE IF EXISTS UNIMATR;
WITH Dup AS (SELECT NUSP, Count(*)
         FROM PrepMatricula
         GROUP BY NUSP
         HAVING Count(*)>1 ),
     Fica AS (SELECT Row_Number() OVER(Partition BY T.NUSP) AS N, T.*
         FROM PrepMatricula T JOIN Dup ON (T.NUSP)=(Dup.NUSP) )
    SELECT * INTO TEMPORARY UniMatr FROM Fica WHERE N=1;
DELETE FROM PrepMatricula M
    USING UniMatr
    WHERE (UniMatr.NUSP)=(M.NUSP);
INSERT INTO PrepMatricula(CodigoTurma, NUSP)
    SELECT CodigoTurma, NUSP
        FROM UniMatr;

SELECT CodigoTurma, 
       NUSP, 
       CAST(0 as DECIMAL(3,1)) NotaP1,
       CAST(0 as DECIMAL(3,1)) NotaP2,
       CAST(0 as DECIMAL(3,1)) NotaSub,
       CAST(0 as DECIMAL(3,1)) MediaP,
       CAST(0 as DECIMAL(3,1)) MediaT,
       CAST(0 as DECIMAL(3,1)) NF,
       CAST(0 as DECIMAL(3))   Frequencia
    INTO Matricula
    FROM PrepMatricula;

---- Preencher notas de provas e Médias de trabalho
UPDATE Matricula 
    SET NotaP1=CASE WHEN Random() >.1  THEN (5*Random()+3*Random()+2*Random()+.01)::Numeric(3,1) END,
        NotaP2=CASE WHEN Random() >.15 THEN (2*NotaP1/3+8*(Random()-.5))/1.4+4. END,
        NotaSub=CASE WHEN Random() >.6 THEN ((NotaP1+NotaP2)/3+6*(Random()-.5))/1.3+3. END,
        MediaT=CASE WHEN Random() >.05 THEN 40*(.25-(Random()-.5)^2) END;

UPDATE Matricula 
    SET NotaSub=(5*Random()+3*Random()+2*Random()+.01)::Numeric(3,1)
    WHERE NotaP1+NotaP2<10 AND Random()>.1;

UPDATE Matricula 
    SET NotaP2=(5*Random()+3*Random()+2*Random()+.01)::Numeric(3,1)
    WHERE NotaP2 NOT Between 0. AND 10.;

UPDATE Matricula 
    SET NotaSub=(5*Random()+3*Random()+2*Random()+.01)::Numeric(3,1)
    WHERE NotaSub NOT Between 0. AND 10.;

---- Calcular a média das provas: Sub do mal!
UPDATE Matricula 
    SET MediaP=CASE WHEN NotaSub IS NOT NULL AND COALESCE(NotaP1,0)>=COALESCE(NotaP2,0) AND NotaSub>COALESCE(NotaP2,0) THEN (COALESCE(NotaP2,0)+NotaSub)/2 
                    WHEN NotaSub IS NOT NULL AND COALESCE(NotaP2,0)>COALESCE(NotaP1,0) AND NotaSub>COALESCE(NotaP1,0) THEN (COALESCE(NotaP1,0)+NotaSub)/2 
					ELSE (COALESCE(NotaP1,0)+COALESCE(NotaP2,0))/2
                    END;

-- Média de provas e trabalhos não variam muito, e trabalhos tendem a ter notas maiores:
UPDATE Matricula 
    SET MediaT=(MediaT+MediaP+10)/3
    WHERE Abs(MediaT-MediaP)>4 AND MediaT IS NOT NULL AND MediaP IS NOT NULL;

UPDATE Matricula 
    SET NF=(COALESCE(MediaT,0)+MediaP)/2;


--===============================================================================================---
-- Gerar Ministra --=============================================================================---
--===============================================================================================---
DROP TABLE IF EXISTS Ministra CASCADE;
SELECT P.NUSP NNFuncProf, CodigoT, MD5(P.Nome||(CodigoT::TEXT)) LivroTexto INTO Ministra
    FROM PrepProf P JOIN (
         WITH NProf AS (SELECT Count(*) N FROM Professor)
              SELECT T.Codigo CodigoT, ((NProf.N+1)*Random())::INT Prof FROM Turma T, NProf
                UNION
              SELECT T.Codigo, ((NProf.N+1)*Random())::INT FROM Turma T, NProf WHERE Random()<0.02 -- 

    ) PM ON PM.Prof=P.Id;

----- Como está a distribuição de disciplinas por professor?
-- SELECT Tot, Count(*)
--     FROM (SELECT NNFuncProf, Count(*) Tot
--               FROM Ministra
--               GROUP BY 1
--               ORDER BY 2 ) Temp
--     GROUP BY Tot

----- Quais turmas tem mais de um professor ministrando?
-- SELECT CodigoT, Count(*)
--     FROM Ministra
--     GROUP BY 1
--     ORDER BY 2 DESC

--===============================================================================================---
--== FIM ========================================================================================---
--===============================================================================================---

-- Medias de provas Finais:
-- SELECT MediaP::INT, COUNT(*) from Matricula GROUP BY MediaP::INT ORDER BY 1;
-- SELECT NF::INT, COUNT(*) from Matricula GROUP BY NF::INT ORDER BY 1;

--Distribuições das notas 
-- SELECT NotaP1::INT, COUNT(*) from Matricula GROUP BY NotaP1::INT ORDER BY 1;
-- 
-- SELECT NotaP1::INT, NotaP2::INT, COUNT(*) from Matricula 
--     where NotaP1::INT=5
-- GROUP BY NotaP1::INT, NotaP2::INT ORDER BY 1, 2;


-----------------------------------------------------------
---- Para calcular medias (tal como definido em SCC640)
-- Alter table Matricula add MediaP numeric(3,1)
-- Alter table Matricula add MediaT numeric(3,1)
-- Alter table Matricula add NF numeric(3,1)
-- 
-- select *, 
--      CASE WHEN MediaP>=5 AND MediaT>=5 THEN NF=(.6*MediaP+.4*MediaT)/2
--           WHEN MediaP>=5 AND MediaT<5  THEN NF=(.3*MediaP+.4*MediaT)/2
--           WHEN MediaP<5  AND MediaT>=5 THEN NF=(.6*MediaP+.2*MediaT)/2
--           WHEN MediaP<5  AND MediaT<5  THEN NF=(.3*MediaP+.2*MediaT)/2
--                              END final
--     FROM Matricula limit 10


--==================================================================================================
--==================================================================================================
--ATÉ AQUI       ===================================================================================
--==================================================================================================
--==================================================================================================

-- -- Numero de turmas por número de alunos por turma
-- SELECT Cnt AlunoPTurma, Count(*) Turmas
--         FROM (Select CodigoTurma, Count(Codigoturma) Cnt from Matricula 
--         GROUP BY CodigoTurma) AS T
--     GROUP BY Cnt
--     ORDER BY Cnt;
-- 
-- -- Numero de Matriculas por Aluno
-- SELECT NMAT MatrPAluno, Count(*) Turmas
--         FROM (Select NUSP, Count(*) NMat from Matricula 
--         GROUP BY NUSP) AS T
--     GROUP BY NMat
--     ORDER BY NMat;


--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
CREATE OR REPLACE VIEW Tabelas AS
        SELECT 1::Integer AS Numero, 'Nomes'::Text  AS NomeTab, Count(*)::Integer AS NroTuplas FROM Nomes UNION 
        SELECT 2, 'Sobrenomes',     Count(*) FROM Sobrenomes    UNION 
        SELECT 3, 'Cidades',        Count(*) FROM Cidades       UNION 
        SELECT 4, 'UnidadeUSP',     Count(*) FROM UnidadeUSP    UNION 
        SELECT 5, 'DeptoUSP',       Count(*) FROM DeptoUSP      UNION 
        SELECT 51, 'Alunos',        Count(*) FROM Alunos        UNION 
        SELECT 11, 'PrepAluno',     Count(*) FROM PrepAluno     UNION 
        SELECT 52, 'Professor',     Count(*) FROM Professor     UNION 
        SELECT 21, 'Niveis',        Count(*) FROM Niveis        UNION 
        SELECT 12, 'PrepProf',      Count(*) FROM PrepProf      UNION 
        SELECT 53, 'Discip',        Count(*) FROM Discip        UNION 
        SELECT 13, 'PrepDiscip',    Count(*) FROM PrepDiscip    UNION 
        SELECT 54, 'Matricula',     Count(*) FROM Matricula     UNION 
        SELECT 14, 'PrepMatricula', Count(*) FROM PrepMatricula UNION 
        SELECT 55, 'Turma',         Count(*) FROM Turma         UNION 
        SELECT 15, 'PrepTurma',     Count(*) FROM PrepTurma     UNION
        SELECT 16, 'Ministra',      Count(*) FROM Ministra      -----
    ORDER BY Numero;

DELETE FROM AcadVarInt WHERE Nome='CountTurma';
INSERT INTO AcadVarInt 
    SELECT 'CountTurma' Nome, NroTuplas Valor FROM Tabelas WHERE NomeTab='Turma';

TABLE Tabelas;


--==================================================================================================
-- FALTA: Colocar nomes adequados para livros em Ministra ==========================================
--==================================================================================================

