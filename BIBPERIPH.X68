*------------------------------------------------*
*Récupère la résolution de la fenêtre d'affichage
RESOLUTION:
    MOVE #33, D0
    TRAP #15
    RTS
*------------------------------------------------*

*------------------------------------------------*
*Permet de récupérer les informations sur la souris (2 derniers bits = droite, gauche)
GET_MOUSE:
    MOVE #61, D0
    TRAP #15
    RTS
*------------------------------------------------*

*------------------------------------------------*
*Vérifie si l'utilisateur fait un clic gauche
*Arguments : D0 (états de la souris)

IF_LEFT_CLICK:
    MOVE.L #0, D1
    JSR GET_MOUSE                   *On prend les états de la souris
    AND.B #%00000001, D0            *On garde uniquement l'état du clic gauche
    RTS
*------------------------------------------------*

*------------------------------------------------*
*Vérifie si la souris est au dessus d'un élément (boutons, grille)
*Arguments : D1 (coordonées de la souris), D2, D3 (coordonées de l'élément)

ON_ELEMENT:
    MOVE.L (A1)+, D2        *D2 contient Y1 et X1 de l'élément
    MOVE.L (A1), D3         *D3 contient Y2 et X2 de l'élément
    SUB.L #1, A1            *On remet A1 à sa position initiale
    MOVE.L #0, D0           *Par défaut, la souris n'est pas dans l'élément
    
    CMP.W D1, D2            *Compare X1 avec le X de la souris
    BHI END_ON_ELEMENT       *Si X1 > X de la souris -> la souris est hors du bouton
    
    CMP.W D1, D3            *Compare X2 avec le X de la souris
    BCS END_ON_ELEMENT       *Si X2 < X de la souris -> la souris est hors du bouton
    
    *On échange les 16 bits de D1, D2, D3, maintenant :
    SWAP D1                 *D1 = Y de la souris
    SWAP D2                 *D2 = Y1
    SWAP D3                 *D3 = Y2
    
    CMP.W D1, D2            *Compare Y1 avec le Y de la souris
    BHI SWAP_BACK           *Si Y1 > Y de la souris -> la souris est hors du bouton
    
    CMP.W D1, D3            *Compare Y2 avec le Y de la souris
    BCS SWAP_BACK           *Si Y2 < Y de la souris -> la souris est hors du bouton
    
    MOVE.L #1, D0           *Si on a passé tous ces test, ça signifie que la souris est dans l'élément
    
SWAP_BACK:
    *On remet D1, D2 et D3 à leurs états d'origine
    SWAP D1
    SWAP D2
    SWAP D3
    
END_ON_ELEMENT:
    RTS
    
*------------------------------------------------*
    



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~

