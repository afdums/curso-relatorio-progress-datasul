DEFINE VARIABLE c-empresa       AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-titulo-relat  AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-rodape        AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-sistema       AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-programa      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-versao        AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-revisao       AS CHARACTER   NO-UNDO.
DEFINE VARIABLE c-arquivo-saida AS CHARACTER   NO-UNDO.
DEFINE VARIABLE i-erro          AS INTEGER     NO-UNDO.

DEFINE STREAM str-rel.

DEF TEMP-TABLE tt-item NO-UNDO
    FIELD it-codigo LIKE ITEM.it-codigo
    FIELD desc-item LIKE ITEM.desc-item.

ASSIGN c-empresa      = "DUMS SISTEMAS INTIGENTES"
       c-titulo-relat = "Relacao de Itens"
       c-sistema      = "Datasul"
       c-programa     = "XX99999"
       c-versao       = "1"
       c-revisao      = "0".

ASSIGN c-rodape = "DATASUL - " + c-sistema + " - " + c-programa + " - V:" + c-versao + "." + c-revisao.
       c-rodape = fill("-", 132 - length(c-rodape)) + c-rodape.

FORM HEADER
     FILL("-", 132) FORMAT "X(132)" SKIP
     c-empresa FORMAT "X(40)" c-titulo-relat AT 47 FORMAT "X(66)"
     FILL("-", 112) FORMAT "x(110)" TODAY FORMAT "99/99/9999"
     "-" STRING(TIME, "HH:MM:SS") SKIP(1)
     WITH STREAM-IO WIDTH 132 NO-LABELS NO-BOX PAGE-TOP FRAME f-cabecalho.

FORM HEADER
     c-rodape FORMAT "X(132)"
     WITH STREAM-IO WIDTH 132 NO-LABELS NO-BOX PAGE-BOTTOM FRAME f-rodape.

FORM tt-item.it-codigo
     tt-item.desc-item
     WITH WIDTH 132 FRAME f-relatorio NO-BOX NO-LABELS STREAM-IO.

ASSIGN c-arquivo-saida = "c:\temp\exemplo-cabecalho-rodape.txt".

RUN pi-geracao.

OUTPUT STREAM str-rel TO VALUE(c-arquivo-saida) CONVERT TARGET "iso8859-1".
VIEW STREAM str-rel FRAME f-cabecalho. //Este comando ‚ colocado s¢ uma vez, na definicao esta como HEADER e ele entende que a cada pagina deve mostrar
FOR EACH tt-item:
    DISP STREAM str-rel
         tt-item.it-codigo
         tt-item.desc-item
        WITH FRAME f-relatorio.
    DOWN STREAM str-rel WITH FRAME f-relatorio.

    PAGE STREAM str-rel.
END.
VIEW STREAM str-rel FRAME f-rodape.
OUTPUT STREAM str-rel CLOSE.

RUN ShellExecuteA IN THIS-PROCEDURE (INPUT  0,
                                     INPUT  'open',
                                     INPUT  c-arquivo-saida,
                                     INPUT  "",
                                     INPUT  "",
                                     INPUT  1,
                                     OUTPUT i-erro).

PROCEDURE ShellExecuteA EXTERNAL "SHELL32" :
    DEFINE INPUT  PARAMETER HWND         AS LONG.
    DEFINE INPUT  PARAMETER lpOperation  AS CHAR.
    DEFINE INPUT  PARAMETER lpFile       AS CHAR.
    DEFINE INPUT  PARAMETER lpParameters AS CHAR.
    DEFINE INPUT  PARAMETER lpDirectory  AS CHAR.
    DEFINE INPUT  PARAMETER nShowCmd     AS LONG.
    DEFINE RETURN PARAMETER hInstance    AS LONG.
END PROCEDURE.

PROCEDURE pi-geracao:

    FOR EACH ITEM
        WHERE ITEM.cod-estabel = "101"
          AND ITEM.ge-codigo   = 5    NO-LOCK:
        CREATE tt-item.
        ASSIGN tt-item.it-codigo = ITEM.it-codigo
               tt-item.desc-item = ITEM.desc-item.
    END.


END PROCEDURE.
