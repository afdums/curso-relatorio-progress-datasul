OUTPUT TO c:\temp\teste-saldo.txt.
FOR EACH saldo-estoq
    WHERE saldo-estoq.cod-estabel >= "101"
      AND saldo-estoq.cod-estabel <= "101"
      AND saldo-estoq.cod-depos   >= ""
      AND saldo-estoq.cod-depos   <= "ZZZ"
      AND saldo-estoq.it-codigo   >= "05"
      AND saldo-estoq.it-codigo   <= "05ZZZZZ"
      AND saldo-estoq.qtidade-atu <> 0 /*- Este campo n∆o faz parte de nenhum indice, se deixarmos aqui, pode afetar negativamente a performance da execuá∆o do relat¢rio */
    NO-LOCK
    BREAK BY saldo-estoq.it-codigo:

    FIND FIRST ITEM OF saldo-estoq NO-LOCK NO-ERROR.

    DISP saldo-estoq.cod-estabel
         saldo-estoq.cod-depos  
         saldo-estoq.it-codigo  
         ITEM.desc-item         
         saldo-estoq.cod-localiz
         saldo-estoq.lote       
         saldo-estoq.qtidade-atu (TOTAL BY saldo-estoq.it-codigo)
        WITH WIDTH 240.

END.
OUTPUT CLOSE.
