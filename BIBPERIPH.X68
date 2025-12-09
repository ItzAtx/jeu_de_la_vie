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


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
