DO $$
BEGIN
    SET datestyle to DMY, ISO;

    DROP SCHEMA IF EXISTS HSL CASCADE;
    DROP SCHEMA IF EXISTS GRUPOFLEURY CASCADE;
    DROP SCHEMA IF EXISTS EINSTEIN CASCADE;
    DROP SCHEMA IF EXISTS HC CASCADE;
    DROP SCHEMA IF EXISTS BPSP CASCADE;

    CREATE SCHEMA HSL;
    CREATE SCHEMA GRUPOFLEURY;
    CREATE SCHEMA EINSTEIN;
    CREATE SCHEMA HC;
    CREATE SCHEMA BPSP;

    CREATE TABLE HSL.Pacientes AS TABLE D2.Pacientes WITH NO DATA;
    CREATE TABLE HSL.ExamLabs AS TABLE D2.ExamLabs WITH NO DATA;
    CREATE TABLE HSL.Desfechos AS TABLE D2.Desfechos WITH NO DATA;

    CREATE TABLE GRUPOFLEURY.Pacientes AS TABLE D2.Pacientes WITH NO DATA;
    CREATE TABLE GRUPOFLEURY.ExamLabs AS TABLE D2.ExamLabs WITH NO DATA;
    CREATE TABLE GRUPOFLEURY.Desfechos AS TABLE D2.Desfechos WITH NO DATA;

    CREATE TABLE EINSTEIN.Pacientes AS TABLE D2.Pacientes WITH NO DATA;
    CREATE TABLE EINSTEIN.ExamLabs AS TABLE D2.ExamLabs WITH NO DATA;
    CREATE TABLE EINSTEIN.Desfechos AS TABLE D2.Desfechos WITH NO DATA;

    ALTER TABLE EINSTEIN.ExamLabs DROP COLUMN IF EXISTS ID_ATENDIMENTO;

    CREATE TABLE HC.Pacientes AS TABLE D2.Pacientes WITH NO DATA;
    CREATE TABLE HC.ExamLabs AS TABLE D2.ExamLabs WITH NO DATA;
    CREATE TABLE HC.Desfechos AS TABLE D2.Desfechos WITH NO DATA;

    CREATE TABLE BPSP.Pacientes AS TABLE D2.Pacientes WITH NO DATA;
    CREATE TABLE BPSP.ExamLabs AS TABLE D2.ExamLabs WITH NO DATA;
    CREATE TABLE BPSP.Desfechos AS TABLE D2.Desfechos WITH NO DATA;


    ALTER TABLE D2.Pacientes ADD COLUMN DE_Hospital TEXT;
    ALTER TABLE D2.ExamLabs ADD COLUMN DE_Hospital TEXT;
    ALTER TABLE D2.Desfechos ADD COLUMN DE_Hospital TEXT;


    COPY HSL.Pacientes FROM '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/datasets/HSL/HSL_Pacientes.csv' WITH (FORMAT csv, HEADER, ENCODING 'UTF8', DELIMITER '|');
    COPY HSL.ExamLabs FROM '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/datasets/HSL/HSL_Exames.csv' WITH (FORMAT csv, HEADER, ENCODING 'UTF8', DELIMITER '|');
    COPY HSL.Desfechos FROM '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/datasets/HSL/HSL_Desfechos.csv' WITH (FORMAT csv, HEADER, ENCODING 'UTF8', DELIMITER '|');

    COPY GRUPOFLEURY.Pacientes FROM '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/datasets/GrupoFleury/GrupoFleury_Pacientes.csv' WITH (FORMAT csv, HEADER, ENCODING 'UTF8', DELIMITER '|');
    COPY GRUPOFLEURY.ExamLabs FROM '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/datasets/GrupoFleury/GrupoFleury_Exames.csv' WITH (FORMAT csv, HEADER, ENCODING 'UTF8', DELIMITER '|');
        
    COPY EINSTEIN.Pacientes FROM '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/datasets/EinsteinAgosto/EINSTEIN_Pacientes.csv' WITH (FORMAT csv, ENCODING 'UTF8', DELIMITER '|', HEADER);
    COPY EINSTEIN.ExamLabs FROM '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/datasets/EinsteinAgosto/EINSTEIN_Exames.csv' WITH (FORMAT csv, ENCODING 'UTF8', DELIMITER '|', HEADER);

    COPY HC.Pacientes FROM '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/datasets/HC/HC_PACIENTES.csv' WITH (FORMAT csv, HEADER, ENCODING 'UTF8', DELIMITER '|');
    COPY HC.ExamLabs FROM '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/datasets/HC/HC_EXAMES.csv' WITH (FORMAT csv, HEADER, ENCODING 'UTF8', DELIMITER '|');
        
    COPY BPSP.Pacientes FROM '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/datasets/BPSP/bpsp_pacientes_01.csv' WITH (FORMAT csv, HEADER, ENCODING 'UTF8', DELIMITER '|');
    COPY BPSP.ExamLabs FROM '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/datasets/BPSP/bpsp_exames_01.csv' WITH (FORMAT csv, HEADER, ENCODING 'UTF8', DELIMITER '|');
    COPY BPSP.Desfechos FROM '/home/user/Public/USP/Ciência da Computação/Semestre 6/Mineração de dados/01-Introdução-Preparação de dados/datasets/BPSP/bpsp_desfecho_01.csv' WITH (FORMAT csv, HEADER, ENCODING 'UTF8', DELIMITER '|');


    INSERT INTO D2.Pacientes SELECT *, 'HSL' as DE_Hospital FROM HSL.Pacientes;
    INSERT INTO D2.ExamLabs SELECT *, 'HSL' as DE_Hospital FROM HSL.ExamLabs;
    INSERT INTO D2.Desfechos SELECT *, 'HSL' as DE_Hospital FROM HSL.Desfechos;

    INSERT INTO D2.Pacientes SELECT *, 'GRUPOFLEURY' as DE_Hospital FROM GRUPOFLEURY.Pacientes;
    INSERT INTO D2.ExamLabs SELECT *, 'GRUPOFLEURY' as DE_Hospital FROM GRUPOFLEURY.ExamLabs;
    INSERT INTO D2.Desfechos SELECT *, 'GRUPOFLEURY' as DE_Hospital FROM GRUPOFLEURY.Desfechos;

    INSERT INTO D2.Pacientes SELECT *, 'EINSTEIN' as DE_Hospital FROM EINSTEIN.Pacientes;
    INSERT INTO D2.ExamLabs SELECT *, 'EINSTEIN' as DE_Hospital, NULL as id_atendimento FROM EINSTEIN.ExamLabs;
    INSERT INTO D2.Desfechos SELECT *, 'EINSTEIN' as DE_Hospital FROM EINSTEIN.Desfechos;

    INSERT INTO D2.Pacientes SELECT *, 'HC' as DE_Hospital FROM HC.Pacientes;
    INSERT INTO D2.ExamLabs SELECT *, 'HC' as DE_Hospital FROM HC.ExamLabs;
    INSERT INTO D2.Desfechos SELECT *, 'HC' as DE_Hospital FROM HC.Desfechos;

    INSERT INTO D2.Pacientes SELECT *, 'BPSP' as DE_Hospital FROM BPSP.Pacientes;
    INSERT INTO D2.ExamLabs SELECT *, 'BPSP' as DE_Hospital FROM BPSP.ExamLabs;
    INSERT INTO D2.Desfechos SELECT *, 'BPSP' as DE_Hospital FROM BPSP.Desfechos;

END$$;

ANALYZE;

SELECT 'Pacientes D2', Count(*) FROM D2.Pacientes 
UNION
SELECT 'ExamLabs D2',  Count(*) FROM D2.ExamLabs  
UNION
SELECT 'Desfechos D2', Count(*) FROM D2.Desfechos
;
