CREATE TABLE D2.Analise_Covid AS
SELECT 
	P.*,
	D.DT_Desfecho,
	D.DT_Atendimento,
	E.ID_ATENDIMENTO,
	E.DT_Coleta,
	D.DE_Desfecho,
	E.DE_Exame,
	E.DE_Resultado,
	CASE 
    WHEN E.DE_ResultNum = -1000 THEN 'P'
    WHEN E.DE_ResultNum = -1111 THEN 'N'
	  ELSE ' '
	END AS classe
FROM D2.Pacientes P
	JOIN D2.ExamLabs E 
		ON P.ID_Paciente = E.ID_Paciente
	JOIN D2.Desfechos D 
		ON P.ID_Paciente = D.ID_Paciente
		AND E.ID_Atendimento = D.ID_Atendimento
WHERE E.De_Exame ~* '(covid)|(corona)';

ALTER TABLE D2.Analise_Covid
    ADD CONSTRAINT pk_analise_covid PRIMARY KEY (Id_Paciente, Id_Atendimento, Dt_Coleta);