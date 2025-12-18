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
    
    *Bouton CLEAR
    MOVE.L #B_CLEAR, A1
    JSR DRAW_BUTTON

    *Paramètres de dimensions
    MOVE.W NB_LIGNES, D6  
    MOVE.W NB_COLONNES, D7
    MOVE.W SIZE_CELL, D5
    
    *Remplissage des deux tableaux
    MOVE.L #TABLEAU1, A1
    JSR VIDER
    MOVE.L #TABLEAU2, A1
    JSR VIDER
    
    *Initialisation des pointeurs
    MOVE.L #TABLEAU1, PTAB1
    MOVE.L #TABLEAU2, PTAB2
    
    *Affichage initial
    MOVE.L PTAB1, A1
    JSR DRAW_GRID
    

    JSR DRAW_GENERATION
*------- BOUCLE PRINCIPALE -------*
BOUCLE_START:    
    
    
TEST_LEFT_CLICK:
    JSR IF_LEFT_CLICK
    CMP.B #1, D0
    BNE IN_PUSH_STOP
    
LEFT_CLICK:
    CMP.B #1, IN_PUSH
    BEQ IF_LEFT_CLICK_IN_GRID
    
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
    
    *BOUTON CLEAR
    MOVE.L #B_CLEAR, A1
    JSR ON_ELEMENT
    CMP.B #1, D0
    BEQ CLEAR_ACTION
    
    JMP IN_PUSH_START
    
IF_LEFT_CLICK_IN_GRID:
    MOVE.L D1, D2
    CMP.W GAP_X, D2
    BCS IN_PUSH_START
    SUB.W GAP_X, D2
    CMP.W WIDTH_CALC, D2
    BCC IN_PUSH_START
    
    SWAP D2
    CMP.W GAP_Y, D2
    BCS IN_PUSH_START
    SUB.W GAP_Y, D2
    CMP.W HEIGHT_CALC, D2
    BCC IN_PUSH_START
    
    JMP LEFT_CLICK_IN_GRID

*Actions des boutons
START_ACTION:
    MOVE.B #1, RUN
    JMP IN_PUSH_START
    
STOP_ACTION:
    MOVE.B #0, RUN
    JMP IN_PUSH_START
    
CLEAR_ACTION:
    CMP.B #1, RUN
    BEQ IN_PUSH_START
    MOVE.L PTAB1, A1
    MOVE.L PTAB2, A2
    JSR VIDER
    JSR DRAW_GRID
    MOVE.W #0, GENERATION
    JSR DRAW_GENERATION
    JMP IN_PUSH_START
    
LEFT_CLICK_IN_GRID:
    CMP.B #1, RUN
    BEQ IN_PUSH_START
    MOVE.B #1, D2
    JMP CLICK_IN_GRID
    
CLICK_IN_GRID:
    MOVE.W D1, D0
    MOVE.W #0, D1
    SWAP D1
    SUB.W GAP_X, D0
    SUB.W GAP_Y, D1
    ADD.L D5, D0
    ADD.L D5, D1
    DIVU D5, D0
    DIVU D5, D1
    MULU NB_LIGNES, D1
    MOVE.L PTAB1, A1
    MOVE.L PTAB2, A2
    AND.L #$0000FFFF, D0
    AND.L #$0000FFFF, D1
    ADD.L D0, A1
    ADD.L D1, A1
    CMP.B (A1), D2
    BEQ IN_PUSH_START
    MOVE.B D2, (A1)
    MOVE.L PTAB1, A1
    MOVE.L PTAB2, A2
    JSR DRAW_GRID
    JMP IN_PUSH_START

    
IN_PUSH_START:
    MOVE.B #1, IN_PUSH
    JMP SUITE_BOUCLE
    
IN_PUSH_STOP:
    MOVE.B #0, IN_PUSH
    JMP SUITE_BOUCLE
    
    
SUITE_BOUCLE:
    CMP.B #0, RUN
    BEQ BOUCLE_START
    
    JSR DRAW_GENERATION
    ADD.W #1, GENERATION
    MOVE.L PTAB1, A1
    MOVE.L PTAB2, A2
    JSR UPDATE
    JSR DRAW_GRID
    MOVE.L A1, PTAB1
    MOVE.L A2, PTAB2
    
    
    JMP BOUCLE_START

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
GAP_X: DC.W 200
GAP_Y: DC.W 150
WIDTH_CALC: DC.W 300
HEIGHT_CALC: DC.W 300

RUN: DC.B 0

IN_PUSH: DC.B 0

B_PLAY: 
        DC.W 15, 15, 65, 165		*Y1, X1, Y2, X2
        DC.W 18, 51        		    *X, Y
        DC.B 'START',0
        
B_STOP: 
        DC.W 15, 185, 65, 335		*Y1, X1, Y2, X2
        DC.W 18, 57         		*X, Y
        DC.B 'STOP',0,0
        
B_CLEAR: 
        DC.W 15, 355, 65, 505		*Y1, X1, Y2, X2
        DC.W 18, 54         		*X, Y
        DC.B 'CLEAR',0

GENERATION: DC.W 0
STR_GEN: DC.B 'GENERATION : ',0
BUF_NUM: DS.B 8

POPULATION: DC.W 0
STR_POP: DC.B 'POPULATION : ',0
BUF_POP: DS.B 8
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















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
