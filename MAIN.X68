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
    
    *Bouton RANDOM
    MOVE.L #B_RANDOM, A1
    JSR DRAW_BUTTON

    *Paramètres de dimensions
    MOVE.W NB_LIGNES, D6  
    MOVE.W NB_COLONNES, D7
    MOVE.W SIZE_CELL, D5
    
    *Remplissage des deux tableaux de 0
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
    
    *Affichage des labels à 0
    JSR DRAW_GENERATION
    MOVE.L PTAB1, A1
    JSR COUNT_POP
    MOVE.W D0, POPULATION
    JSR DRAW_POP
    
*------- BOUCLE PRINCIPALE -------*
BOUCLE_START:    
    
*Test si l'utilisateur à cliqué    
TEST_LEFT_CLICK:
    JSR IF_LEFT_CLICK
    CMP.B #1, D0
    BNE IN_PUSH_STOP

*Tests des coordonnées sur lesquelles l'utilisateur a pu cliquer
LEFT_CLICK:
    CMP.B #1, IN_PUSH *Si le clic est maintenu, on test les coordonées de la grille directement
    BEQ  IF_LEFT_CLICK_IN_GRID
    
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
    
    *BOUTON RANDOM
    MOVE.L #B_RANDOM, A1
    JSR ON_ELEMENT
    CMP.B #1, D0
    BEQ RANDOM_ACTION
    
    JMP IN_PUSH_START

*Si l'utilisateur a cliqué sur la grille    
IF_LEFT_CLICK_IN_GRID:
    MOVE.L D1, D2 *D1 contiens les coordonnées de la souris (Y 16 bits | X 16 bits)
    
    CMP.W GAP_X, D2 *Compare X avec la marge gauche
    BCS IN_PUSH_START *Si X < marge gauche, on sort
    SUB.W GAP_X, D2 *D2 = X - marge gauche (distance entre X et la marge gauche)
    CMP.W WIDTH_CALC, D2 *Compare X-marge gauche <= WIDTH_CALC
    BCC IN_PUSH_START
    
    SWAP D2 *Swap des coordonées de la souris -> Y dans les 16 bits faibles
    
    CMP.W GAP_Y, D2 *Compare Y avec la marge haute
    BCS IN_PUSH_START *Si Y < marge haute, on sort
    SUB.W GAP_Y, D2 *D2 = Y - marge haute
    CMP.W HEIGHT_CALC, D2 *Compare Y-marge haute <= HEIGHT_CALC
    BCC IN_PUSH_START
    
    JMP LEFT_CLICK_IN_GRID

*Actions des boutons
START_ACTION:
    CMP.B #1, RANDOM_RUNNING *Si le random tourne, on ignore
    BEQ BOUCLE_START
    
    *On change la couleur du bouton pour afficher qu'il est en cours d'utilisation
    MOVE.L #$351E3B, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
    MOVE.L #B_PLAY, A1
    JSR DRAW_BUTTON
    MOVE.L PTAB1, A1
    
    MOVE.B #1, RUN
    JMP IN_PUSH_START
    
STOP_ACTION:
    MOVE.B #0, RUN
    MOVE.B #0, RANDOM_RUNNING
    
    *On redessine les boutons START et RANDOM à l'état par défaut
    MOVE.L #$8D6B96, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
    MOVE.L #B_PLAY, A1
    JSR DRAW_BUTTON
    MOVE.L #B_RANDOM, A1
    JSR DRAW_BUTTON
    MOVE.L PTAB1, A1
    
    JMP IN_PUSH_START
    
CLEAR_ACTION:
    *Si le random ou le jeu tourne, on ne fait rien
    CMP.B #1, RUN
    BEQ IN_PUSH_START
    CMP.B #1, RANDOM_RUNNING
    BEQ IN_PUSH_START
    
    *Reset tableaux
    MOVE.L PTAB1, A1
    JSR VIDER
    MOVE.L PTAB2, A1
    JSR VIDER
    
    *Reset compteurs
    MOVE.L PTAB1, A1
    JSR DRAW_GRID
    MOVE.W #0, GENERATION
    JSR DRAW_GENERATION
    MOVE.W #0, POPULATION
    JSR DRAW_POP
    
    JMP IN_PUSH_START
    
RANDOM_ACTION:
    CMP.B #1, RUN
    BEQ BOUCLE_START *Si le programme est déjà en cours (génération), alors on ne lance pas de random
    
    *Calcul de nombre de case réelle
    
    *Suppression bords haut/bas
    MOVE NB_CASES, D0
    MOVE NB_LIGNES, D1
    MULU #2, D1 *2 lignes de bord haut/bas
    SUB D1, D0
    
    *Suppression bords gauche/droite
    MOVE NB_COLONNES, D1
    MULU #2, D1 *2 colonnes gauche/droite
    SUB #4, D1 *Les coins ont été retirés avec le calcul des lignes
    SUB D1, D0
    
    *Si population = nombre de cases réelle, on ne génère rien
    CMP.W POPULATION, D0
    BEQ IN_PUSH_START
    
    *Comme pour START, on change la couleur du bouton pour afficher qu'il est en cours d'utilisation
    MOVE.L #$351E3B, D1
    JSR SET_FILL_COLOR
    JSR SET_PEN_COLOR
    MOVE.L #B_RANDOM, A1
    JSR DRAW_BUTTON
    MOVE.L PTAB1, A1
    
    MOVE.B #1, RANDOM_RUNNING
    JMP IN_PUSH_START
  
    
LEFT_CLICK_IN_GRID:
    CMP.B #1, RUN *Si le jeu est en route, on ne fait rien
    BEQ IN_PUSH_START
    CMP.B #1, RANDOM_RUNNING *Si le random est en route, on ne fait rien
    BEQ IN_PUSH_START
    MOVE.B #1, D2
    JMP CLICK_IN_GRID
    
CLICK_IN_GRID:
    MOVE.W D1, D0 *Copie les 16 bits faibles (X) dans D0
    MOVE.W #0, D1 
    SWAP D1 *Swap pour avoir Y dans les 16 bits faibles de D1
    
    SUB.W GAP_X, D0 *Xr = X - 300
    SUB.W GAP_Y, D1 *Yr = Y - 125
    
    ADD.L D5, D0 *D5 contiens la taille d'une cellule (10)
    ADD.L D5, D1
    DIVU D5, D0 *Colonne = (Xr + 10) / 10
    DIVU D5, D1 *Ligne = (Yr + 10) / 10
    
    MULU NB_COLONNES, D1 *D1 = Ligne * 32 (nombre de lignes à sauter)
    
    *Les adresses pointent sur les tableaux
    MOVE.L PTAB1, A1
    
    *Nettoyage des 16 bits forts
    AND.L #$0000FFFF, D0
    AND.L #$0000FFFF, D1
    
    ADD.L D1, A1 *A2 += (ligne * 32)
    ADD.L D0, A1 *A1 += colonne
    
    CMP.B (A1), D2 *Compare l'état actuelle de la cellule
    BEQ IN_PUSH_START *Si cellule déjà vivante, on passe
    MOVE.B D2, (A1) *Sinon on la met vivante
    
    *On remet les pointeurs au début
    MOVE.L PTAB1, A1
    
    JSR DRAW_GRID
    
    JSR COUNT_POP *On met à jour la population au fur et à mesure qu'on ajoute des cellules
    MOVE D0, POPULATION
    JSR DRAW_POP
    
    JMP IN_PUSH_START

    
IN_PUSH_START:
    MOVE.B #1, IN_PUSH
    JMP SUITE_BOUCLE
    
IN_PUSH_STOP:
    MOVE.B #0, IN_PUSH
    JMP SUITE_BOUCLE
    
    
SUITE_BOUCLE: *Branche gérant un non conflit entre START et RANDOM
    CMP.B #1, RUN
    BEQ SUITE_BOUCLE_RUN
    CMP.B #1, RANDOM_RUNNING
    BEQ SUITE_BOUCLE_RANDOM
    JMP BOUCLE_START
    
SUITE_BOUCLE_RANDOM: *Branche gérant l'état RANDOM
    *Update de la population
    MOVE.L PTAB1, A1
    JSR COUNT_POP
    MOVE.W D0, POPULATION
    
    *Nouvelle cellule
    JSR ADD_RANDOM_CELL
    JSR DRAW_GRID
    JSR COUNT_POP
    MOVE D0, POPULATION
    JSR DRAW_POP
    JMP BOUCLE_START
    
SUITE_BOUCLE_RUN: *Branche gérant l'état START
    *Update des compteurs
    JSR DRAW_GENERATION
    
    MOVE.L PTAB1, A1
    JSR COUNT_POP
    MOVE.W D0, POPULATION
    JSR DRAW_POP
    
    ADD.W #1, GENERATION
    
    *Update des cellules
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
GAP_X: DC.W 300 *Distance entre le bord gauche de l'écran et le bord gauche de la grille
GAP_Y: DC.W 125 *Distance entre le bord haut de l'écran et le bord haut de la grille
WIDTH_CALC: DC.W 300 *Largeur de la grille
HEIGHT_CALC: DC.W 300 *Hauteur de la grille

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
        
B_RANDOM:
        DC.W 15, 525, 65, 675
        DC.W 18, 52
        DC.B 'RANDOM', 0

GENERATION: DC.W 0
STR_GEN: DC.B 'GENERATION : ',0
BUF_NUM: DS.B 12

POPULATION: DC.W 0
STR_POP: DC.B 'POPULATION : ',0
BUF_POP: DS.B 12

RANDOM_RUNNING: DC.B 0
*----------------------VARIABLES BIBLIOTHEQUES----------------------

VAR_I: DC.L 0
VAR_J: DC.L 0
VAR_K: DC.L 0
VAR_L: DC.L 0

SAVE_ADRESSE: DC.L 0
SAVE_ADRESSE2: DC.L 0
SAVE_D6: DC.L 0
SAVE_D7: DC.L 0

VAR_TMP: DC.B 0
VAR_SUM: DC.B 0

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
