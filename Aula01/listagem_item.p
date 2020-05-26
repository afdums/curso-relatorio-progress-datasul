/*&glob val1 Ativo
&glob val2 Obsoleto Ordens Automÿticas
&glob val3 Obsoleto Todas as Ordens
&glob val4 Totalmente Obsoleto*/

OUTPUT TO c:\temp\itens.txt.
FOR EACH ITEM NO-LOCK
         WHERE ITEM.ge-codigo = 5:
    DISP ITEM.it-codigo
              ITEM.desc-item
              ITEM.fm-codigo
              ITEM.fm-cod-com
              ITEM.deposito-pad
              INT(ITEM.cod-obsoleto)
              ENTRY(ITEM.cod-obsoleto,"Ativo,Obsoleto Ordens Automaticas,Obsoleto Todas AS Ordens,Totalmente Obsoleto",",") FORMAT "X(20)" COLUMN-LABEL "Situacao"
        WITH WIDTH 200
        .
END.
OUTPUT CLOSE.
