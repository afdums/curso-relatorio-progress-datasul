{include/i-prgvrs.i XX1000RP 2.00.00.000}  /*** 010000 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i XX1000RP MCD}
&ENDIF

{utp/ut-glob.i}

/***Definiá‰es***/
def var c-sel            as char format "x(10)" no-undo.
def var c-imp            as char format "x(10)" no-undo.
def var c-des            as char format "x(10)" no-undo.
def var c-saida          as char format "x(40)" no-undo.

def var h-acomp          as handle              no-undo.

/***Definiá∆o da tt-param***/
{xxp/xx1000.i}
    
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

assign c-empresa = grupo.

/***Definiá∆o de Forms***/
form
    c-sel                    colon 25 no-label skip(1)
    tt-param.cod-estabel-ini colon 45 space (2) "|<   >|" at 70 tt-param.cod-estabel-fim   no-label colon 80
    tt-param.cod-depos-ini   colon 45 space (2) "|<   >|" at 70 tt-param.cod-depos-fim     no-label colon 80
    tt-param.it-codigo-ini   colon 45 space (2) "|<   >|" at 70 tt-param.it-codigo-fim     no-label colon 80 SKIP(1)
    c-imp                    colon 25 no-label skip(1)
    c-saida                  colon 45
    tt-param.usuario         colon 45
with stream-io side-labels width 132 frame f-param.

form
   saldo-estoq.cod-estabel
   saldo-estoq.cod-depos
   saldo-estoq.it-codigo
   ITEM.desc-item
   saldo-estoq.cod-localiz
   saldo-estoq.lote
   saldo-estoq.qtidade-atu
with stream-io width 240 down no-box frame f-corpo.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Listagem de saldo em estoque").

assign c-titulo-relat = "LISTAGEM DE SALDO EM ESTOQUE".

assign c-sistema = "ESTOQUE".

{include/i-rpcab.i}
{include/i-rpout.i}

view frame f-cabec.
view frame f-rodape.

/***Folha de ParÉmetros***/
assign c-sel:screen-value in frame f-param = "SELEÄ«O".
assign c-imp:screen-value in frame f-param = "IMPRESS«O".

assign tt-param.cod-estabel-ini:label in frame f-param = "Estabel".
assign tt-param.cod-depos-ini:label in frame f-param = "Depos".
assign tt-param.it-codigo-ini:label in frame f-param = "ITEM".

assign tt-param.usuario:label in frame f-param = "Usu†rio".
assign c-saida:label in frame f-param = "Destino".

FOR EACH saldo-estoq
    WHERE saldo-estoq.cod-estabel >= tt-param.cod-estabel-ini
      AND saldo-estoq.cod-estabel <= tt-param.cod-estabel-fim
      AND saldo-estoq.cod-depos   >= tt-param.cod-depos-ini
      AND saldo-estoq.cod-depos   <= tt-param.cod-depos-fim
      AND saldo-estoq.it-codigo   >= tt-param.it-codigo-ini
      AND saldo-estoq.it-codigo   <= tt-param.it-codigo-fim
      AND saldo-estoq.qtidade-atu <> 0 /*- Este campo n∆o faz parte de nenhum indice, se deixarmos aqui, pode afetar negativamente a performance da execuá∆o do relat¢rio */
    NO-LOCK:

    /*IF saldo-estoq.qtidade-atu = 0 THEN
        NEXT.*/

    FIND FIRST ITEM OF saldo-estoq NO-LOCK NO-ERROR.

    RUN pi-acompanhar IN h-acomp(INPUT "Imprimindo " + saldo-estoq.cod-estabel + " - " + saldo-estoq.cod-depos + " - " + saldo-estoq.it-codigo).

    DISP saldo-estoq.cod-estabel
         saldo-estoq.cod-depos  
         saldo-estoq.it-codigo  
         ITEM.desc-item         
         saldo-estoq.cod-localiz
         saldo-estoq.lote       
         saldo-estoq.qtidade-atu (TOTAL)
        WITH FRAME f-corpo.
    DOWN WITH FRAME f-corpo.

END.

run pi-acompanhar in h-acomp  (input "Imprimindo Folha de Parametros").

case tt-param.destino:
   when 1 then do:
        assign c-des = "Impressora".
   end.
   when 2 then do:
        assign c-des = "Arquivo".
   end.
   when 3 then do:
          assign c-des = "Terminal".
   end.
end.

page. //PULA PµGINA

disp c-sel
     tt-param.cod-estabel-ini
     tt-param.cod-estabel-fim
     tt-param.cod-depos-ini
     tt-param.cod-depos-fim
     tt-param.it-codigo-ini
     tt-param.it-codigo-fim
     c-imp
     trim(c-des) + '  -  ' + tt-param.arquivo @ c-saida
     tt-param.usuario with frame f-param.
       
{include/i-rpclo.i}

run pi-finalizar in h-acomp.

return 'OK'.
