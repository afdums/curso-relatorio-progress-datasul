
DEF TEMP-TABLE tt-item-nota NO-UNDO
    FIELD cod-estabel  LIKE nota-fiscal.cod-estabel
    FIELD serie        LIKE nota-fiscal.serie
    FIELD nr-nota-fis  LIKE nota-fiscal.nr-nota-fis
    FIELD dt-emis-nota LIKE nota-fiscal.dt-emis-nota
    FIELD nome-abrev   LIKE emitente.nome-abrev
    FIELD nome-emit    LIKE emitente.nome-emit
    FIELD nr-seq-fat   LIKE it-nota-fisc.nr-seq-fat
    FIELD it-codigo    LIKE ITEM.it-codigo
    FIELD desc-item    LIKE ITEM.desc-item
    FIELD fm-codigo    LIKE fam-comerc.fm-cod-com
    FIELD descricao    LIKE fam-comerc.descricao.

DEF VAR h-acomp AS HANDLE NO-UNDO.

DEFINE VARIABLE i-erro AS INTEGER     NO-UNDO.

RUN utp/ut-acomp.p PERSISTENT SET h-acomp.

RUN pi-inicializar IN h-acomp(INPUT "Relatorio de Notas").

FOR EACH nota-fiscal
    WHERE nota-fiscal.dt-emis-nota >= TODAY - 7
      AND nota-fiscal.cod-estabel   = "101"
      AND nota-fiscal.serie         = "1"
      AND nota-fiscal.nr-nota-fis  >= "" NO-LOCK:

    RUN pi-acompanhar IN h-acomp(INPUT "Nota Fiscal: " + nota-fiscal.nr-nota-fis).

    IF nota-fiscal.dt-cancela <> ? THEN //tira notas canceladas
        NEXT.

    FIND FIRST emitente OF nota-fiscal NO-LOCK NO-ERROR.

    IF AVAIL emitente THEN DO:
        FOR EACH it-nota-fisc OF nota-fiscal NO-LOCK:
            
            FIND FIRST ITEM OF it-nota-fisc NO-LOCK NO-ERROR.
            IF AVAIL ITEM THEN DO:
    
                FIND FIRST fam-comerc OF ITEM NO-LOCK NO-ERROR.
                IF AVAIL fam-comerc THEN DO:
    
                    CREATE tt-item-nota.
                    ASSIGN tt-item-nota.cod-estabel  = nota-fiscal.cod-estabel 
                           tt-item-nota.serie        = nota-fiscal.serie       
                           tt-item-nota.nr-nota-fis  = nota-fiscal.nr-nota-fis 
                           tt-item-nota.dt-emis-nota = nota-fiscal.dt-emis-nota
                           tt-item-nota.nome-abrev   = emitente.nome-abrev     
                           tt-item-nota.nome-emit    = emitente.nome-emit      
                           tt-item-nota.nr-seq-fat   = it-nota-fisc.nr-seq-fat 
                           tt-item-nota.it-codigo    = ITEM.it-codigo          
                           tt-item-nota.desc-item    = ITEM.desc-item          
                           tt-item-nota.fm-codigo    = fam-comerc.fm-cod-com   
                           tt-item-nota.descricao    = fam-comerc.descricao.   
    
                END.
    
            END.
    
        END.

    END.

END.

OUTPUT TO c:\temp\item-nota.csv.
EXPORT DELIMITER ";"
    "cod-estabel "
    "serie       "
    "nr-nota-fis "
    "dt-emis-nota"
    "nome-abrev  "
    "nome-emit   "
    "nr-seq-fat  "
    "it-codigo   "
    "desc-item   "
    "fm-codigo   "
    "descricao   ".
FOR EACH tt-item-nota:

    RUN pi-acompanhar IN h-acomp(INPUT "Imprimindo : " + tt-item-nota.nr-nota-fis).

    EXPORT DELIMITER ";" tt-item-nota.
END.
OUTPUT CLOSE.

RUN ShellExecuteA IN THIS-PROCEDURE (INPUT  0,
                                     INPUT  'open',
                                     INPUT  "c:\temp\item-nota.csv",
                                     INPUT  "",
                                     INPUT  "",
                                     INPUT  1,
                                     OUTPUT i-erro).

RUN pi-finalizar IN h-acomp.

PROCEDURE ShellExecuteA EXTERNAL "SHELL32" :
  DEFINE INPUT  PARAMETER HWND         AS LONG.
  DEFINE INPUT  PARAMETER lpOperation  AS CHAR.
  DEFINE INPUT  PARAMETER lpFile       AS CHAR.
  DEFINE INPUT  PARAMETER lpParameters AS CHAR.
  DEFINE INPUT  PARAMETER lpDirectory  AS CHAR.
  DEFINE INPUT  PARAMETER nShowCmd     AS LONG.
  DEFINE RETURN PARAMETER hInstance    AS LONG.
END PROCEDURE.
