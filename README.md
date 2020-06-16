# Curso Geração de Relatórios Utilizando Progress Datasul

##### Aula01
	Nesta aula será demonstrado a estrutura de alguns DERs internos do banco de dados progress
	Definição de temp-tables
	Consulta identadas (OF e WHERE).
	Geração de TXT.
	Definição de Forms.
	Abertura via shellExecute:
		PROCEDURE ShellExecuteA EXTERNAL "SHELL32" :
		  DEFINE INPUT  PARAMETER HWND         AS LONG.
		  DEFINE INPUT  PARAMETER lpOperation  AS CHAR.
		  DEFINE INPUT  PARAMETER lpFile       AS CHAR.
		  DEFINE INPUT  PARAMETER lpParameters AS CHAR.
		  DEFINE INPUT  PARAMETER lpDirectory  AS CHAR.
		  DEFINE INPUT  PARAMETER nShowCmd     AS LONG.
		  DEFINE RETURN PARAMETER hInstance    AS LONG.
		END PROCEDURE.
		
		RUN ShellExecuteA IN THIS-PROCEDURE (INPUT  0,
                                             INPUT  'open',
                                             INPUT  c-arquivo-saida,
                                             INPUT  "",
                                             INPUT  "",
                                             INPUT  1,
                                             OUTPUT h-inst).

##### Aula03
	Criação de relatórios com interface grafica para utilizacao pelo usuario