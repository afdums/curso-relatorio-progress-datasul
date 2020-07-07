{include/i-prgvrs.i XX9998RP 2.00.00.000}  /*** 010000 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i XX9998RP MCD}
&ENDIF

{utp/ut-glob.i}

/***Defini‡äes***/
def var c-sel            as char format "x(10)" no-undo.
def var c-imp            as char format "x(10)" no-undo.
def var c-des            as char format "x(10)" no-undo.
def var c-saida          as char format "x(40)" no-undo.

def var h-acomp          as handle              no-undo.

/***Defini‡Æo da tt-param***/
{xxp/xx9998.i}
    
def temp-table tt-digita
    field ordem   as integer   format ">>>>9"
    field exemplo as character format "x(30)"
    index id is primary unique
        ordem. 
        
def temp-table tt-raw-digita                   
    field raw-digita as raw.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

create tt-param.
raw-transfer raw-param to tt-param.

find first tt-param no-lock no-error.

find first param-global no-lock no-error.

{include/i-rpvar.i}

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Listagem de Unidades de Federa‡Æo").

{include/i-rpcab.i}
{include/i-rpout.i}

/* variaveis para geracao do arquivo em excel */
DEF VAR h-utapi033    AS HANDLE  NO-UNDO.
DEF VAR i-col         AS INTEGER NO-UNDO.
DEF VAR c-arquivo-xml AS CHAR    NO-UNDO.

/* Inicializar a "gravacao" do XML que sera convertido para excel*/
RUN utp/utapi033.p PERSISTENT SET h-utapi033.

/* Nome das colunas */
ASSIGN i-col = 1.

/* numero da coluna, tipo, titulo, formato, largura */
RUN piColumn IN h-utapi033 (INPUT i-col, INPUT "CHAR", INPUT "Pais", INPUT "", INPUT 100).
ASSIGN i-col = i-col + 1.
RUN piColumn IN h-utapi033 (INPUT i-col, INPUT "CHAR", INPUT "Estado", INPUT "", INPUT 60).
ASSIGN i-col = i-col + 1.
RUN piColumn IN h-utapi033 (INPUT i-col, INPUT "CHAR", INPUT "Descricao", INPUT "", INPUT 200).


FOR EACH unid-feder
    WHERE unid-feder.pais   >= tt-param.c-pais-ini
      AND unid-feder.pais   <= tt-param.c-pais-fim
      AND unid-feder.estado >= tt-param.c-estado-ini
      AND unid-feder.estado <= tt-param.c-estado-fim NO-LOCK:

    run pi-acompanhar in h-acomp (input trim(string(unid-feder.pais)) + " - " +
                                        trim(string(unid-feder.estado))).


    RUN piNewLine IN h-utapi033. //abre uma linha
    ASSIGN i-col = 1.
    RUN piLine IN h-utapi033 (INPUT i-col,  INPUT unid-feder.pais).
    ASSIGN i-col = i-col + 1.
    RUN piLine IN h-utapi033 (INPUT i-col,  INPUT unid-feder.estado).
    ASSIGN i-col = i-col + 1.
    RUN piLine IN h-utapi033 (INPUT i-col,  INPUT unid-feder.no-estado).

end.
       
/* salva o arquivo XML para ser convertido */
ASSIGN c-arquivo-xml = SESSION:TEMP-DIRECTORY + "XX9998" + REPLACE(STRING(TODAY),"/","-") + "-" + STRING(TIME) + ".xml".
        
RUN pi-acompanhar IN h-acomp(INPUT "Gerando planilha").
        
/* mostra em tela */
RUN piProcessa IN h-utapi033 (INPUT-OUTPUT c-arquivo-xml, INPUT "UFs", INPUT "Listagem de Unidades Federativas").

/* limpa da memoria a variavel */
IF VALID-HANDLE(h-utapi033) THEN
    DELETE OBJECT h-utapi033.

{include/i-rpclo.i}

run pi-finalizar in h-acomp.

return 'OK'.
