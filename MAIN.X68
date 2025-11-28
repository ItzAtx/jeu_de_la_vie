
    ORG    $1000
START:                  ; first instruction of program
    
    *Dimensions de la fenêtre
    MOVE.L #$028A028A, D1
    JSR RESOLUTION
    
    *Paramètres de dimensions
    MOVE.W NB_LIGNES, D6  
    MOVE.W NB_COLONNES, D7
    
    *Remplissage des deux tableaux
    MOVE.L #TABLEAU1, A1
    JSR REMPLIR
    MOVE.L #TABLEAU2, A1
    JSR REMPLIR
    
    *On met des 1 dans t1 et on l'affiche
    MOVE.L #TABLEAU1, A1   
    
    ADD.L #26, A1
    MOVE.B #1, (A1)
    SUB.L #26, A1
    
    ADD.L #38, A1
    MOVE.B #1, (A1)
    SUB.L #38, A1
    
    ADD.L #50, A1
    MOVE.B #1, (A1)
    SUB.L #50, A1
       
    JSR PRINT_GRID
    
    *Update + affichage
    MOVE.L #TABLEAU1, A1
    MOVE.L #TABLEAU2, A2
    JSR UPDATE
    JSR CHARIOT
    JSR CHARIOT
    JSR PRINT_GRID
    
    *Update + affichage
    MOVE.L #TABLEAU1, A2
    MOVE.L #TABLEAU2, A1
    JSR UPDATE
    JSR CHARIOT
    JSR CHARIOT
    JSR PRINT_GRID
    
    JMP FINPRG
    
    
    
    INCLUDE 'BIBLIO.X68'
    INCLUDE 'BIBPERIPH.X68'
    INCLUDE 'BIBGRAPH.X68'
    
    ORG $2000
TABLEAU1: DS.B 12*12
TABLEAU2: DS.B 12*12
RESOL: DC.W 700, 500
NB_CASES DC.W 12*12
NB_LIGNES: DC.W 12
NB_COLONNES: DC.W 12

*----------------------VARIABLES BIBLIO----------------------
VAR_I: DC.L 0
VAR_J: DC.L 0
VAR_K: DC.L 0
VAR_L: DC.L 0
SAVE_ADRESSE DC.L 0
SAVE_ADRESSE2 DC.L 0
VAR_TMP DC.B 0
VAR_SUM DC.B 0

    END    START        ; last line of source






















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
