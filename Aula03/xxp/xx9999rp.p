/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i XX9999RP 2.00.00.000}  /*** 010000 ***/

&IF "{&EMSFND_VERSION}" >= "1.00"
&THEN
{include/i-license-manager.i XX9999RP MCD}
&ENDIF


/******************************************************************************
**
**   Programa: CD1006rp.p
**
**   Data....: Novembro de 1999.
**
**   Autor...: DATASUL S.A.
**
**   Objetivo: Listagem das Unidades da Federa‡Æo - Internacinal.
**  
*******************************************************************************/
{utp/ut-glob.i}

/***Defini‡äes***/
def var c-sel            as char format "x(10)" no-undo.
def var c-imp            as char format "x(10)" no-undo.
def var c-des            as char format "x(10)" no-undo.
def var c-saida          as char format "x(40)" no-undo.
def var h-acomp          as handle              no-undo.

/***Defini‡Æo da tt-param***/
{xxp/xx9999.i}
    
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

/***Defini‡Æo de Forms***/
form
    c-sel                  colon 25 no-label skip(1)
    tt-param.c-pais-ini    colon 45 space (2) "|<   >|" at 70 tt-param.c-pais-fim   no-label colon 80
    tt-param.c-estado-ini  colon 45 space (2) "|<   >|" at 70 tt-param.c-estado-fim no-label colon 80 skip(1)
    c-imp                  colon 25 no-label skip(1)
    c-saida                colon 45
    tt-param.usuario       colon 45
with stream-io side-labels width 132 frame f-param.

/* Inicio -- Projeto Internacional -- ut-trfrrp.p adicionado */
RUN utp/ut-trfrrp.p (INPUT FRAME f-param:HANDLE).

form
   unid-feder.pais
   unid-feder.estado
   unid-feder.no-estado
with stream-io width 132 down no-box frame f-corpo.

/* Inicio -- Projeto Internacional -- ut-trfrrp.p adicionado */
RUN utp/ut-trfrrp.p (INPUT FRAME f-corpo:HANDLE).

{utp/ut-liter.i Pa¡s}
assign unid-feder.pais:label in frame f-corpo = trim(return-value).

{utp/ut-liter.i Nome_Estado}
assign unid-feder.no-estado:label in frame f-corpo = trim(return-value).

run utp/ut-acomp.p persistent set h-acomp.

{utp/ut-liter.i "Listagem_de_Unidades_de_Federa‡Æo"}
run pi-inicializar in h-acomp (input trim(return-value)).

{utp/ut-liter.i LISTAGEM_DE_UNIDADES_DE_FEDERA€ÇO * L}
assign c-titulo-relat = trim(return-value).

{utp/ut-liter.i FATURAMENTO  * r }
assign c-sistema = trim(return-value).

{include/i-rpcab.i}
{include/i-rpout.i}

view frame f-cabec.
view frame f-rodape.

/***Folha de Parƒmetros***/
{utp/ut-liter.i SELE€ÇO * L}
assign c-sel:screen-value in frame f-param = trim(return-value).

{utp/ut-liter.i IMPRESSÇO * L}
assign c-imp:screen-value in frame f-param = trim(return-value).

{utp/ut-liter.i Pa¡s}
assign tt-param.c-pais-ini:label in frame f-param = trim(return-value).

{utp/ut-liter.i Estado}
assign tt-param.c-estado-ini:label in frame f-param = trim(return-value).

{utp/ut-liter.i Usu rio *}
assign tt-param.usuario:label in frame f-param = trim(return-value).

{utp/ut-liter.i Destino *}
assign c-saida:label in frame f-param = trim(return-value).

/***Processamento***/
if connected("lcarg") then do:
   run local/arg/arg283.p (input table tt-param,
                           input h-acomp).
end.                           
else do:
    for each unid-feder where
             unid-feder.pais   >= tt-param.c-pais-ini   and
             unid-feder.pais   <= tt-param.c-pais-fim   and
             unid-feder.estado >= tt-param.c-estado-ini and
             unid-feder.estado <= tt-param.c-estado-fim no-lock on stop undo, leave:

        run pi-acompanhar in h-acomp (input trim(string(unid-feder.pais)) + " - " +
                                            trim(string(unid-feder.estado))).

        disp unid-feder.pais
             unid-feder.estado
             unid-feder.no-estado
        with frame f-corpo.
        down with frame f-corpo.     

    end.
end.

/***Parƒmetros***/
{utp/ut-liter.i Imprimindo_Folha_de_Parƒmetros}
run pi-acompanhar in h-acomp  (input trim(return-value)).

case tt-param.destino:
   when 1 then do:
        {utp/ut-liter.i Impressora *} 
        assign c-des = trim(return-value).
   end.
   when 2 then do:
        {utp/ut-liter.i Arquivo *}
        assign c-des = trim(return-value).
   end.
   when 3 then do:
          {utp/ut-liter.i Terminal *}
          assign c-des = trim(return-value).
   end.
end.

page.
disp c-sel
     tt-param.c-pais-ini
     tt-param.c-pais-fim
     tt-param.c-estado-ini
     tt-param.c-estado-fim
     c-imp
     trim(c-des) + '  -  ' + tt-param.arquivo @ c-saida
     tt-param.usuario with frame f-param.
       
{include/i-rpclo.i}
run pi-finalizar in h-acomp.
return 'OK'.
