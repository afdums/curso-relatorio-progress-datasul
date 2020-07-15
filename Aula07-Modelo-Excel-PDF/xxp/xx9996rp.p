{include/i-prgvrs.i XX9997RP 2.00.00.000}  /*** 010000 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i XX9997RP MCD}
&ENDIF

{utp/ut-glob.i}

/***Defini‡äes***/
def var c-sel            as char format "x(10)" no-undo.
def var c-imp            as char format "x(10)" no-undo.
def var c-des            as char format "x(10)" no-undo.
def var c-saida          as char format "x(40)" no-undo.

def var h-acomp          as handle              no-undo.

/***Defini‡Æo da tt-param***/
{xxp/xx9997.i}
    
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

run pi-inicializar in h-acomp (input "Gera‡Æo de Pedidos de Compra").

{include/i-rpcab.i}
{include/i-rpout.i}

/* endereco do excel */
DEF VAR chExcel    AS office.iface.excel.ExcelWrapper  NO-UNDO.
DEF VAR chArquivo  AS office.iface.excel.WorkBook      NO-UNDO.
DEF VAR chPlanilha AS office.iface.excel.WorkSheet     NO-UNDO.

/* armazena o caminho do arquivo modelo */
DEF VAR c-modelo AS CHAR NO-UNDO.

ASSIGN c-modelo = SEARCH("xxp\xx9997.xls").

/* variavel para o caminho do arquivo PDF e do arquivo Excel */
DEF VAR c-arq-excel AS CHAR NO-UNDO.
DEF VAR c-arq-pdf   AS CHAR NO-UNDO.

DEF VAR i-linha AS INTEGER NO-UNDO.

/* inicializa o excel */
{office/office.i Excel chExcel}

/* esconde do usuario */
chExcel:VISIBLE = NO.
        
FIND FIRST pedido-compr
     WHERE pedido-compr.num-pedido = tt-param.i-num-pedido NO-LOCK NO-ERROR.
IF AVAIL pedido-compr THEN DO:

    FIND FIRST emitente
         WHERE emitente.cod-emitente = pedido-compr.cod-emitente NO-LOCK NO-ERROR.

    /* caminhos onde sera salvo o arquivo em excel e em PDF */
    ASSIGN c-arq-excel = SESSION:TEMP-DIRECTORY + "PC" + STRING(pedido-compr.num-pedido) + ".xls"
           c-arq-pdf   = SESSION:TEMP-DIRECTORY + "PC" + STRING(pedido-compr.num-pedido) + ".pdf".

    /* copia o modelo para o novo caminho */
    OS-COPY VALUE (c-modelo) VALUE (c-arq-excel).
    
    /* abre o arquivo em memoria */
    chArquivo = chExcel:workbooks:OPEN(c-arq-excel).

    /* se posiciona na aba 1 da planilha */
    chPlanilha  = chArquivo:Sheets:ITEM(1).

    /* escreve alguma coisa na celula K2 */
    chPlanilha:Range('K2'):SetValue(STRING(pedido-compr.num-pedido)).

    chPlanilha:Range('C5'):SetValue(emitente.nome-emit).
    chPlanilha:Range('D6'):SetValue(STRING(emitente.cgc, "99.999.999/9999-99")).
    chPlanilha:Range('D7'):SetValue(emitente.ins-estadual).

    ASSIGN i-linha = 14. //primeira linha de ordens de compra no excel
    FOR EACH ordem-compra
        WHERE ordem-compra.num-pedido = pedido-compr.num-pedido NO-LOCK:

        FIND FIRST ITEM
             WHERE ITEM.it-codigo = ordem-compra.it-codigo NO-LOCK NO-ERROR.

        chPlanilha:Range('B' + STRING(i-linha)):SetValue(ordem-compra.numero-ordem).
        chPlanilha:Range('C' + STRING(i-linha)):SetValue(ordem-compra.it-codigo).
        chPlanilha:Range('D' + STRING(i-linha)):SetValue(ITEM.desc-item).
        chPlanilha:Range('I' + STRING(i-linha)):SetValue(ordem-compra.sc-codigo).
        chPlanilha:Range('J' + STRING(i-linha)):SetValue(ordem-compra.qt-solic).
        chPlanilha:Range('K' + STRING(i-linha)):SetValue(ITEM.un).
        chPlanilha:Range('L' + STRING(i-linha)):SetValue(ordem-compra.qt-solic * ordem-compra.preco-fornec).

        /* vai para a proxima linha */
        ASSIGN i-linha = i-linha + 1.

    END.

    chPlanilha:Range('L30'):SetValue("=SUM(L14:L" + STRING(i-linha - 1) + ")").


    /* salva as alteracoes feitas no excel */
    chArquivo:SaveAs(c-arq-excel,1,"","",NO,NO,NO).

    /* salva o arquivo em PDF */
    chArquivo:ExportAsFixedFormat(0,c-arq-pdf,0,TRUE,FALSE,?,?,FALSE).    
    
    chExcel:VISIBLE = YES.

END.


{include/i-rpclo.i}

RUN pi-finalizar IN h-acomp.

RETURN 'OK'.

