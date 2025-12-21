*------------------------------------------------*
* Affiche le caractère stocké dans D1

AFFCAR:
    MOVE #6, D0
    TRAP #15
    RTS
*------------------------------------------------*

*------------------------------------------------*
* Stock un caractère saisie dans D1

SAISCAR:
    MOVE #5, D0
    TRAP #15
    RTS
*------------------------------------------------*

*------------------------------------------------*
*Positionne le curseur/efface l'écran   

POS_CURS:
    MOVE #11, D0
    TRAP #15
    RTS
*------------------------------------------------*

*------------------------------------------------*
*Arrête le programme

FINPRG:
    MOVE #9, D0
    TRAP #15
*------------------------------------------------*

*------------------------------------------------*
*Effectue un retour à la ligne

CHARIOT:
    MOVE.B  #$0A, D1                *\r
    JSR AFFCAR
    MOVE.B  #$0D, D1                *\n
    JSR AFFCAR
    RTS 
*------------------------------------------------*

*------------------------------------------------*
*Remplis la matrice de 0
*Arguments : A1 (adresse du tableau), D6 et D7 (dimensions)    

VIDER:
    MOVE.L  A1, SAVE_ADRESSE       *sauvegarde de l'adresse au début
    MOVE.L  #0, VAR_I              *i = 0
    MOVE.L  #0, VAR_J              *j = 0
 
LOOP_I:                            *DEBUT LOOP_I                                
    CMP.L   VAR_I, D6              *si i = height         
    BEQ     END_LOOP_I             *on sort de LOOP_I
    MOVE.L  #0, VAR_J              *j = 0
    
LOOP_J:                            *DEBUT LOOP_J
    CMP.L   VAR_J, D7              *si j == width
    BEQ     END_LOOP_J             *on sort de LOOP_J
    MOVE.B  #0, (A1)+              *on met 0 à l'adresse puis on augmente l'adresse de 1
    ADD.L   #1, VAR_J              *j++
    JMP     LOOP_J                 *retour à LOOP_J
    
END_LOOP_J:                        *FIN LOOP_J       
    ADD.L   #1, VAR_I              *i++
    JMP     LOOP_I                 *retour à LOOP_I

END_LOOP_I:                        *FIN LOOP_I 
    
    MOVE.L  SAVE_ADRESSE, A1       *A1 reviens à son adresse initiale
    RTS
*------------------------------------------------*

*------------------------------------------------*
*Affiche un tableau 2D
*Arguments : A1 (adresse du tableau), D6 et D7 (dimensions)
*Utilisés : D1 (pour stocker l'ASCII de 0 ou 1 et utiliser AFFCAR)
PRINT_GRID:
    MOVE.L  A1, SAVE_ADRESSE        *sauvegarde de l'adresse au début
    MOVE.L  #$0, D1                 *D1 = la couleur (0, 0, 0)
    MOVE.L  #0, VAR_I               *i = 0
    MOVE.L  #0, VAR_J               *j = 0
    
LOOP_I_PRINT:                       *DEBUT LOOP_I
    CMP.L   VAR_I, D7               *si i = height
    BEQ     END_LOOP_I_PRINT        *on sort de LOOP_I
    MOVE.L  #0, VAR_J               *j = 0
    
LOOP_J_PRINT:                       *DEBUT LOOP_J
    CMP.L   VAR_J, D6               *si j = width
    BEQ     END_LOOP_J_PRINT        *sortir de LOOP_J
    
    MOVE.B  (A1), VAR_TMP          *VAR_TMP = la valeur dans l'adresse puis on incrémente l'adresse
    ADD.L   #1, A1
    MOVE.L  #48, D1                 *D1 = 0
    CMP.B   #0, VAR_TMP             *si VAR_TMP = 0
    BEQ     SUITE_PRINT
IF_EQUAL_PRINT:                
    MOVE.L  #49, D1                 *sinon, D1 = 1
    
SUITE_PRINT:
    JSR     AFFCAR                  *afficher D1 (0 ou 1 selon la comparaison d'avant)
    ADD.L   #1, VAR_J               *j++
    JMP     LOOP_J_PRINT
    
END_LOOP_J_PRINT:
    JSR     CHARIOT                 *retour à la ligne
    ADD.L   #1, VAR_I               *i++
    JMP     LOOP_I_PRINT

END_LOOP_I_PRINT:
    MOVE.L  SAVE_ADRESSE, A1       *A1 reviens à son adresse initiale
    RTS
*------------------------------------------------*

*------------------------------------------------*
*Copie le contenu d'un tableau dans un autre
*Arguments : A1 et A2 (adresses des tableaux), D6 (taille de la mémoire utilisée par le tableau1)

COPY_GRID:
    MOVE.L #0, VAR_I                *i = 0
    MOVE.L A1, SAVE_ADRESSE         *sauvegarde des adresses du début
    MOVE.L A2, SAVE_ADRESSE2
FOR_I_CPY:
    MOVE.B (A1),(A2)               *contenu de A2 = contenu de A1
    ADD.L #1, A1                    *on incrémente les adresses
    ADD.L #1, A2
    ADD.L #1, VAR_I                 *i++
    CMP.L VAR_I, D6
    BNE FOR_I_CPY                   *si i != de la dimension on recommence
    
    MOVE.L SAVE_ADRESSE, A1
    MOVE.L SAVE_ADRESSE2, A2 
    RTS
*------------------------------------------------*

*------------------------------------------------*
*Applique les règles du jeu de la vie à chaque cellule
*Arguments : A1 et A2 (adresses des tableaux), D6 et D7 (dimensions)
*NOTES: Pour la première itération de recherche en 3x3, la cellule est deja en haut gauche
UPDATE:
    MOVE.L A1, SAVE_ADRESSE
    MOVE.L A2, SAVE_ADRESSE2
    ADD.L D6, A2                    *A2 saute la première ligne (bord haut) de t2
    MOVE.L #1, VAR_I                *i = 1 : on commence après le bord haut

LOOP_I_UPDATE:
    ADD.L #1, A2                    *A2 saute le 0 de bord gauche
    SUB.L #1, D7                    *D7 - 1 temporairement pour...
    CMP.L VAR_I, D7                 *...tester si i atteint la dernière ligne (hors bord)
    BEQ END_LOOP_I_UPDATE
    ADD.L #1, D7                    *Sinon on remet à la valeur initiale
    MOVE.L #1, VAR_J                *j = 1 : on commence après le bord gauche
    
LOOP_J_UPDATE:
    SUB.L #1, D6                    *D6 - 1 temporairement pour...
    CMP.L VAR_J, D6                 *...tester si j atteint la dernière colonne (hors bord)
    BEQ END_LOOP_J_UPDATE
    ADD.L #1, D6                    *Sinon on remet à la valeur initiale
    MOVE.B #0, VAR_SUM              *Compteur de cellules vivantes voisines
    MOVE.L #0, VAR_K                
    
LOOP_K_UPDATE:
    CMP.L #3, VAR_K                 *Boucle sur les 3 lignes du voisinage 3x3
    BEQ END_LOOP_K_UPDATE
    MOVE.L #0, VAR_L
    
LOOP_L_UPDATE:
    CMP.L #3, VAR_L                 *Boucle sur les 3 colonnes du voisinage 3x3
    BEQ END_LOOP_L_UPDATE
    MOVE.B (A1)+, D0                *D0 = valeur de la cellule (0 ou 1), A1++
    ADD.B D0, VAR_SUM               *On ajoute cette valeur au compteur
    ADD.L #1, VAR_L
    JMP LOOP_L_UPDATE

END_LOOP_L_UPDATE:
    SUB.L #3, A1                    *On recule A1 de 3 positions
    ADD.L D6, A1                    *On passe à la ligne d'après
    ADD.L #1, VAR_K
    JMP LOOP_K_UPDATE
    
END_LOOP_K_UPDATE:                  *Fin du parcours 3x3
    SUB.L D6, A1                    
    SUB.L D6, A1                    *On remonte de 2 lignes
    ADD.L #1, A1                    *On avance d'une colonne : retour à la cellule centrale (hors première itération)
    MOVE.B (A1), VAR_TMP
    CMP.B #1, VAR_TMP               *On regarde si la cellule est vivante
    BNE NOT_LIVING_UPDATE
    
LIVING_UPDATE:
    MOVE.B #1, VAR_TMP
    CMP.B #3, VAR_SUM               *Si la cellule est vivante et qu'il y en a 2 vivantes autour ou...
    BEQ END_IF_LOOP_J_UPDATE
    CMP.B #4, VAR_SUM               *...3 vivantes autour alors...
    BEQ END_IF_LOOP_J_UPDATE        *...elle survit
    MOVE.B #0, VAR_TMP              *Sinon elle meurt
    JMP END_IF_LOOP_J_UPDATE

NOT_LIVING_UPDATE:
    MOVE.B #1, VAR_TMP
    CMP.B #3, VAR_SUM               *Si la cellule est morte et a 3 cellules vivantes autour alors...
    BEQ END_IF_LOOP_J_UPDATE        *...elle naît
    MOVE.B #0, VAR_TMP              *Sinon elle reste morte

END_IF_LOOP_J_UPDATE:
    MOVE.B VAR_TMP, (A2)            *On écrit le nouvel état dans t2
    SUB.L D6, A1                    *On se positionne en haut à gauche de la prochaine grille 3x3
    ADD.L #1, A2                    *A2 avance à la cellule suivante dans t2
    ADD.L #1, VAR_J
    JMP LOOP_J_UPDATE
    
END_LOOP_J_UPDATE:
    ADD.L #1, D6                    *On restaure D6 (SUB avant comparaison)
    ADD.L #2, A1                    *A1 avance de 2 (on saute de ligne en ignorant bord droit puis gauche)
    ADD.L #1, A2                    *A2 avance de 1 (sauter le bord droit)
    ADD.L #1, VAR_I
    JMP LOOP_I_UPDATE
    
END_LOOP_I_UPDATE:
    ADD.L   #1, D7                  *On restaure D7 (SUB avant comparaison)
    MOVE.L  SAVE_ADRESSE, A2
    MOVE.L  SAVE_ADRESSE2, A1
    RTS

*------------------------------------------------*
*Transforme un nombre en chaîne de caractères
*Arguments : D0 (nombre à convertir)

NB_TO_STRING:
    ADD.L  #7, A1               *On décale A1 de 7 pour qu'il pointe sur le dernier octet du buffer
    MOVE.L A1, A2               *On le copie dans A2
    MOVE.B #0, (A2)             *On met le caractère de fin de chaîne au dernier octet
    
    CMP.L  #0, D0               *Si D0 = 0 alors...
    BNE    LOOP_NB_TO_STRING
    MOVE.B #'0', -(A2)          *...On déplace l'adresse d'A2 à gauche et on lui met le caractère 0
    MOVE.L A2, A1               *A1 prend A2 et c'est fini si le nb est = à 0
    RTS

LOOP_NB_TO_STRING:
    DIVU   #10, D0              *Sinon, on divise le nb par 10 (16 bits forts = reste, 16 bits faibles = quotient)
    MOVE.W D0, D3               *On copie le quotient dans D3 (donc ce qu'on aura à rediviser)
    SWAP   D0                   *On inverse les 16 bits
    ADD.B  #'0', D0             *On transforme le nb en ASCII en lui rajoutant la valeur du caractere de fin de chaine (48)
    MOVE.B D0, -(A2)            *On recule A2 d'un octet et on écrit le caractère
    MOVE.W D3, D0               *On remet D0 = quotient
    AND.L  #$0000FFFF, D0       *On nettoie les 16 bits forts

    CMP.W  #0, D0               *Tant que le quotient n'est pas 0
    BNE    LOOP_NB_TO_STRING    *On continue
    
    MOVE.L A2, A1               *On met le mot dans A1
    RTS

*------------------------------------------------*

*------------------------------------------------*
*Compte le nombre de cellules vivantes dans la grille
*Arguments : A1 (adresse du tableau), D6 et D7 (Dimensions du tableau)

COUNT_POP:
    MOVE.L A1, SAVE_ADRESSE
    MOVE.L D6, SAVE_D6
    MOVE.L D7, SAVE_D7

    CLR.L  D0              * compteur pop = 0
    CLR.L  VAR_I           * i = 0

    ADD.L  D6, A1          * saute la ligne du bord haut
    ADD.L  #1, A1          * saute le bord gauche
    SUB.L  #2, D6          * largeur intérieure
    SUB.L  #2, D7          * hauteur intérieure

LOOP_I_POP:
    CMP.L  VAR_I, D7
    BEQ    END_POP
    CLR.L  VAR_J           * j = 0

LOOP_J_POP:
    CMP.L  VAR_J, D6
    BEQ    END_ROW_POP

    CLR.L  D1
    MOVE.B (A1)+, D1
    AND.L  #1, D1
    ADD.L  D1, D0

    ADD.L  #1, VAR_J
    JMP    LOOP_J_POP

END_ROW_POP:
    ADD.L  #1, VAR_I
    ADD.L  #2, A1          * saute bord droit + bord gauche ligne suivante
    JMP    LOOP_I_POP

END_POP:
    MOVE.L SAVE_ADRESSE, A1
    MOVE.L SAVE_D6, D6
    MOVE.L SAVE_D7, D7
    RTS
*------------------------------------------------*






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
