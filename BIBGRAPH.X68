SET_PEN_COLOR:
    MOVE #80, D0
    TRAP #15
    RTS
    
SET_FILL_COLOR:
    MOVE #81, D0
    TRAP #15
    RTS
    
DRAW_PIX:
    MOVE #82, D0
    TRAP #15
    RTS
    
GET_PIX_COLOR:
    MOVE #83, D0
    TRAP #15
    RTS
    
DRAW_LINE:
    MOVE #84, D0
    TRAP #15
    RTS
    
DRAW_TO:
    MOVE #85, D0
    TRAP #15
    RTS
    
MOVE_TO:
    MOVE #86, D0
    TRAP #15
    RTS
    
DRAW_FILL_RECT:
    MOVE #87, D0
    TRAP #15
    RTS
    
    
WIDTH_PEN:
    MOVE #93, D0
    TRAP #15
    RTS
    
DRAW_MODE:
    MOVE #92, D0
    TRAP #15
    RTS

*-----------------------------------------------------------------------*
*Efface l'écran
 
CLEAR_SCREEN:
    MOVE.W  #$FF00, D1
    JSR     POS_CURS
    RTS
    
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*Dessine une cellule
*Argument : D1 (couleur et X1), D2 (Y1), D3 et D4 (X2 et Y2), D5 (taille d'une cellule)
*On utilise aussi les variables GAP_X et GAP_Y

DRAW_CELL:
    JSR SET_PEN_COLOR
    JSR SET_FILL_COLOR
    
    *Calcul des coordonées du coin supérieur gauche
    MOVE.L VAR_J, D1
    MOVE.L VAR_I, D2
    MULU D5, D1             *D1 = j * taille_cellule = X1
    MULU D5, D2             *D2 = i * taille_cellule= Y1
    
    *Calcul des coordonées du coin inférieur droit
    MOVE.L D1, D3
    MOVE.L D2, D4
    ADD.L D5, D3            *D3 = X1 + taille_cellule= X2
    ADD.L D5, D4            *D4 = Y1 + taille_cellule= Y2
    
    * Appliquer les marges/décalages pour centrer ou positionner la grille
    ADD.W   GAP_X, D1            * X1 += décalage horizontal
    ADD.W   GAP_Y, D2            * Y1 += décalage vertical
    ADD.W   GAP_X, D3            * X2 += décalage horizontal
    ADD.W   GAP_Y, D4            * Y2 += décalage vertical
    
    JSR DRAW_FILL_RECT
    RTS
    
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*Dessine une grille
*Arguments : A1 (adresse du tableau), D6 et D7 (dimensions)
 
DRAW_GRID:
    MOVE.L A1, SAVE_ADRESSE
    MOVE.L #0, D1
    MOVE.L #0, VAR_I
    ADD.L D6, A1                *On saute la première ligne de bord
    ADD.L #1, A1                *On saute le bord gauche de la ligne
    SUB.L #2, D6                *On enleve les deux lignes de bord de la hauteur
    SUB.L #2, D7                *On enleve les deux 0 de bord de la largeur
    
LOOP_I_DRAW_GRID:
    CMP.L VAR_I, D7
    BEQ END_LOOP_I_DRAW_GRID   *Si i = D7 alors on sort de la boucle
    MOVE.L #0, VAR_J
    
LOOP_J_DRAW_GRID:
    CMP.L VAR_J, D6
    BEQ END_LOOP_J_DRAW_GRID   *Si j = D6 alors on sort de la boucle
    MOVE.B (A1)+, D0           *D0 contient l'état de la cellule actuelle
    MOVE.L #$FFFFFF, D1        *D1 contient la couleur blanche
    CMP.B #0, D0               *Si cellule morte, blanc
    BEQ SUITE_DRAW_GRID
    MOVE.L #$000000, D1        *Si cellule vivante, noir
    
SUITE_DRAW_GRID:
    JSR DRAW_CELL              *On dessine la cellule
    ADD.L #1, VAR_J
    JMP LOOP_J_DRAW_GRID
    
END_LOOP_J_DRAW_GRID:
    ADD.L #1, VAR_I
    ADD.L #2, A1               *On passe les bords
    JMP LOOP_I_DRAW_GRID
    
END_LOOP_I_DRAW_GRID:
    ADD.L #2, D6
    ADD.L #2, D7
    MOVE.L SAVE_ADRESSE, A1 *On restitue les valeurs
    RTS
*-----------------------------------------------------------------------*

*-----------------------------------------------------------------------*
*Remplis le fond d'une couleur
*Arguments : D1 (couleur et X1), D2, D3 et D4 (Y1, X2, Y2)

FILL_BACKGROUND:
    JSR SET_PEN_COLOR
    JSR SET_FILL_COLOR
    
    MOVE.L RESOL, D0
    MOVE.W #0, D1               *D1 = X1 = 0 (D1.W = 0)
    MOVE.W #0, D2               *D2 = Y1 = 0 (D2.W = 0)
    MOVE.W	D0, D4              *D4 = Y2 = largeur (D0.W = largeur)
    SWAP	D0                  *On inverse la largeur et la hauteur dans D0
    MOVE.W	D0, D3              *D3 = X2 = hauteur (D0.W = hauteur)
    JSR     DRAW_FILL_RECT
	RTS
	
*-----------------------------------------------------------------------*





*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
