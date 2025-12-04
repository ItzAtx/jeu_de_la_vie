    ORG    $1000
START:                  ; first instruction of program
    
    *Dimensions de la fenêtre
    MOVE.L RESOL, D1
    JSR RESOLUTION
    
    *Couleur de fond
    MOVE.L	#$A3CCFF, D1
    JSR FILL_BACKGROUND
    
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

*------- BOUCLE PRINCIPALE (Infini pour le moment) -------*
BOUCLE_DEBUT:
    
    
    *Calcul de la nouvelle génération
    MOVE.L PTAB1, A1
    MOVE.L PTAB2, A2
    JSR UPDATE

    
    *Affichage de la grille mise à jour
    MOVE.L PTAB2, A1
    JSR DRAW_GRID
    
    *Échange des pointeurs pour la prochaine génération
    MOVE.L PTAB1, D0
    MOVE.L PTAB2, PTAB1
    MOVE.L D0, PTAB2
    
    *Délai pour ralentir l'animation
    MOVE.L #300000, D0
DELAY_LOOP:
    SUBQ.L #1, D0
    BNE DELAY_LOOP
    
    *Retour au début de la boucle
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

CONTINUE: DC.B 1

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
