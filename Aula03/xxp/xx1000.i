def temp-table tt-param no-undo
    field destino      as int
    field arquivo      as char format "x(35)"
    field usuario      as char format "x(12)"
    field data-exec    as date
    field hora-exec    as int
    /* daqui para baixo coloco os meus campos de sele‡Æo */
    FIELD cod-estabel-ini AS CHAR FORMAT "X(5)"
    FIELD cod-estabel-fim AS CHAR FORMAT "X(5)"
    FIELD cod-depos-ini   AS CHAR FORMAT "X(3)"
    FIELD cod-depos-fim   AS CHAR FORMAT "X(3)"
    FIELD it-codigo-ini   AS CHAR FORMAT "X(16)"
    FIELD it-codigo-fim   AS CHAR FORMAT "X(16)".
