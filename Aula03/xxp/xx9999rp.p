{include/i-prgvrs.i XX9999RP 2.00.00.000}  /*** 010000 ***/

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i XX9999RP MCD}
&ENDIF

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

form
   unid-feder.pais
   unid-feder.estado
   unid-feder.no-estado
with stream-io width 132 down no-box frame f-corpo.

run utp/ut-acomp.p persistent set h-acomp.

run pi-inicializar in h-acomp (input "Listagem de Unidades de Federa‡Æo").

assign c-titulo-relat = "LISTAGEM DE UNIDADES DE FEDERA€ÇO".

assign c-sistema = "FATURAMENTO".

{include/i-rpcab.i}
{include/i-rpout.i}

view frame f-cabec.
view frame f-rodape.

/***Folha de Parƒmetros***/
assign c-sel:screen-value in frame f-param = "SELE€ÇO".
assign c-imp:screen-value in frame f-param = "IMPRESSÇO".
assign tt-param.c-pais-ini:label in frame f-param = "Pa¡s".
assign tt-param.c-estado-ini:label in frame f-param = "Estado".
assign tt-param.usuario:label in frame f-param = "Usu rio".
assign c-saida:label in frame f-param = "Destino".

for each unid-feder where
         unid-feder.pais   >= tt-param.c-pais-ini   and
         unid-feder.pais   <= tt-param.c-pais-fim   and
         unid-feder.estado >= tt-param.c-estado-ini and
         unid-feder.estado <= tt-param.c-estado-fim no-lock:

    run pi-acompanhar in h-acomp (input trim(string(unid-feder.pais)) + " - " +
                                        trim(string(unid-feder.estado))).

    disp unid-feder.pais
         unid-feder.estado
         unid-feder.no-estado
    with frame f-corpo.
    down with frame f-corpo.     

end.

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
