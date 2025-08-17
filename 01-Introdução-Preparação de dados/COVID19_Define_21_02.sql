DROP SCHEMA D2 CASCADE;
CREATE SCHEMA D2;

CREATE TABLE D2.Pacientes(
	ID_Paciente TEXT,
	IC_Sexo CHAR,
	AA_Nascimento CHAR(4),
	CD_Pais TEXT,
	CD_UF TEXT,
	CD_Municipio TEXT,
	CD_Reproduzido TEXT
);

CREATE TABLE D2.ExamLabs(
	ID_Paciente TEXT,
	ID_Atendimento TEXT,
	DT_Coleta TEXT,
	DE_Origem TEXT,
	DE_Exame TEXT,
	DE_Analito TEXT,
	DE_Resultado TEXT,
	CD_Unidade TEXT,
	CD_ValorReferencia TEXT
);

CREATE TABLE D2.Desfechos(
	ID_Paciente TEXT,
	ID_Atendimento TEXT,
	DT_Atendimento DATE,
	DE_TipoAtendimento TEXT,
	ID_Clinica INT,
	DE_Clinica TEXT,
	DT_Desfecho TEXT,
	DE_Desfecho TEXT
);
