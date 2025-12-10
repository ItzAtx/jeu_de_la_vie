    ORG    $1000
START:                  ; first instruction of program
    
    *Dimensions de la fenêtre
    MOVE.L RESOL, D1
    JSR RESOLUTION
    
    *Couleur de fond
    MOVE.L	#$262945, D1
    JSR FILL_BACKGROUND

    *Création des boutons
    MOVE.L #$8D6B96, D1         *Couleurs des boutons
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR

    *Bouton START
    MOVE.L #B_PLAY, A1
    JSR DRAW_BUTTON

    *Bouton STOP
    MOVE.L #B_STOP, A1
    JSR DRAW_BUTTON

    *Paramètres de dimensions
    MOVE.W NB_LIGNES, D6  
    MOVE.W NB_COLONNES, D7
    MOVE.W SIZE_CELL, D5
    
    *Remplissage des deux tableaux
    MOVE.L #TABLEAU1, A1
    JSR REMPLIR
    MOVE.L #TABLEAU2, A1
    JSR REMPLIR
    
    *On met des 1 dans t1 
    MOVE.L #TABLEAU1, A1   
    
    ADD.L #68, A1
    MOVE.B #1, (A1)
    SUB.L #68, A1
    
    ADD.L #100, A1
    MOVE.B #1, (A1)
    SUB.L #100, A1
    
    ADD.L #132, A1
    MOVE.B #1, (A1)
    SUB.L #132, A1
    
    *Initialisation des pointeurs
    MOVE.L #TABLEAU1, PTAB1
    MOVE.L #TABLEAU2, PTAB2
    
    *Affichage initial
    MOVE.L PTAB1, A1
    JSR DRAW_GRID
    
    JSR CHARIOT
    JSR CHARIOT

*------- BOUCLE PRINCIPALE -------*
BOUCLE_DEBUT:
    
TEST_LEFT_CLICK:
    JSR IF_LEFT_CLICK
    CMP.B #1, D0
    BNE IN_PUSH_STOP
    
LEFT_CLICK:
    CMP.B #1, IN_PUSH
    BEQ SUITE_BOUCLE
    
    *BOUTON START
    MOVE.L #B_PLAY, A1
    JSR ON_ELEMENT
    CMP.B #1, D0
    BEQ START_ACTION
    
    *BOUTON STOP
    MOVE.L #B_STOP, A1
    JSR ON_ELEMENT
    CMP.B #1, D0
    BEQ STOP_ACTION
    
    JMP IN_PUSH_START

*Actions des boutons
START_ACTION:
    MOVE.B #1, RUN
    JMP IN_PUSH_START
    
STOP_ACTION:
    MOVE.B #0, RUN
    JMP IN_PUSH_START
    
IN_PUSH_START:
    MOVE.B #1, IN_PUSH
    JMP SUITE_BOUCLE
    
IN_PUSH_STOP:
    MOVE.B #0, IN_PUSH
    JMP SUITE_BOUCLE
    
    
SUITE_BOUCLE:
    CMP.B #0, RUN
    BEQ BOUCLE_DEBUT
    
    MOVE.L PTAB1, A1
    MOVE.L PTAB2, A2
    JSR UPDATE
    JSR DRAW_GRID
    MOVE.L A1, PTAB1
    MOVE.L A2, PTAB2
    
    
    JMP BOUCLE_DEBUT

*------- FIN BOUCLE -------*

FIN_BOUCLE:
    JMP FINPRG
    
    
    
    INCLUDE 'BIBLIO.X68'
    INCLUDE 'BIBPERIPH.X68'
    INCLUDE 'BIBGRAPH.X68'
    
    ORG $2000
    
TABLEAU1: DS.B 32*32
TABLEAU2: DS.B 32*32
PTAB1: DC.L 0
PTAB2: DC.L 0
NB_CASES: DC.W 32*32
NB_LIGNES: DC.W 32
NB_COLONNES: DC.W 32

RESOL: DC.W 700, 500

SIZE_CELL: DC.W 10
GAP_X: DC.W 150
GAP_Y: DC.W 50

RUN: DC.B 1

IN_PUSH: DC.B 0

B_PLAY: DC.W 15, 15, 165, 65		*X1, Y1, X2, Y2
        DC.W 51, 18         		*X, Y
        DC.B 'START',0

B_STOP: DC.W 15, 185, 65, 335		*Y1, X1, Y2, X2
        DC.W 18, 56         		*X, Y
        DC.B 'STOP',0

*----------------------VARIABLES BIBLIOTHEQUES----------------------

VAR_I: DC.L 0
VAR_J: DC.L 0
VAR_K: DC.L 0
VAR_L: DC.L 0

SAVE_ADRESSE: DC.L 0
SAVE_ADRESSE2: DC.L 0

VAR_TMP: DC.B 0
VAR_SUM: DC.B 0

    END    START        ; last line of source
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~


