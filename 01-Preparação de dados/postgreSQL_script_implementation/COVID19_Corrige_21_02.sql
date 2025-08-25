SET search_path TO D2;

ALTER TABLE ExamLabs ADD COLUMN IF NOT EXISTS DE_resultNum FLOAT;

UPDATE ExaDE_ResultNummLabs 
    SET DE_resultNum=Replace(Substring(de_resultado, '-?\d+,?\d*'), ',', '.')::FLOAT;

UPDATE ExamLabs
SET DE_ResultNum = CASE WHEN  de_resultado ~*'detectados anticorpos' THEN -1000
            WHEN  de_resultado ~*'(n.o detectado)|(n.o reagente)|(negativo)|(aus.ncia de anticorpos)' THEN -1111
            WHEN  de_resultado ~*'(detectado)|(reagente)|(positivo)' THEN -1000
            WHEN  de_resultado ~*'(indetect.avel)|(inconclusivo)' THEN -1234
            ELSE -2222 END
    
WHERE  De_Exame ~* '(covid)|(sars.cov.2)|(corona)';

