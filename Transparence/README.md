# TRANSPARENCE DES FENÊTRES SUR WINDOWS

----------------------------------------
## DESCRIPTION
[En cours de rédaction]

----------------------------------------
## AVANCEMENT
| **Date** | **Etat de l'avancement** |
|:---:|:---:|
| _13/11/2018_ | Initialisation dans le dictionnaire des fenêtres focus par les touches menu, méthodes de gestion des transparences terminées, menu d'information au lancement du programme, lancement des bonnes méthodes en fonction de la touche clavier sélectionnée. |
| _16/11/2018_ | Mise à jour des valeurs de transparence dans le dictionnaire, en fonction du pointeur de fenêtre **(HWnd)**, lors du changement de cette dernière valeur, préservation du focus sur la fenêtre active après changement de la transparence, implémentation de la méthode **Stop()** permettant d'arrêter le programme en remettant les valeurs de transparence de toute les fenêtre à 255 (par défaut).
| _20/11/2018_ | Implémentation de l'ancrage et du désancrage de la fenêtre au premier plan, ainsi que de la mise à jour de la valeur d'ancrage de chaques fenêtres (**True ou False**) dans le dictionnaire. Implémentation du désancrage de toute les fenêtres dans la fonction **Stop()**. Mise en place de la touche événement permettant de déclencher la fonction **WindowFirstPlan()** afin de fixer la fenêtre active au premier plan. 

Le programme est fonctionnel. Il est possible de rendre plusieurs fenêtres transparente, et d'ancrer plusieurs de ces dernières au premier plan. Néanmoins, **des améliorations** doivent encore être implémentées avec **l'affichage de la transparence en % et du statut de l'ancrage sur la fenêtre concernée**.

**_[En phase de développement]_**