﻿#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>

#Region Déclaration des touches event
HotKeySet('^{F1}', "HotKeyFunc")
HotKeySet('^{F2}', "HotKeyFunc")
HotKeySet('^{F3}', "HotKeyFunc")
HotKeySet('^{F4}', "HotKeyFunc")
#EndRegion

; Dictionnaire (AdresseFenetre) = {transparence, ancre}
Global $dictionary = ObjCreate("Scripting.Dictionary")

MsgBox($MB_ICONINFORMATION, "Informations", "CTRL + F1 : Augmenter la transparence " & @CRLF & _
			"CTRL + F2 : Réduire la transparence" & @CRLF & _
			"CTRL + F3 : Attacher / Détacher une fenêtre au premier plan" & @CRLF & _
			"CTRL + F4 : Quitter")

; Boucle pour laisser tourner le programme
 While True
	Sleep(100)
WEnd

#comments-start
Evénement permettant de lancer les fonctions avec paramètre(s) en fonction de la touche pressée
#comments-end
Func HotKeyFunc()
    Switch @HotKeyPressed
		; F1 Key Pressed
        Case "^{F1}"
			; Augmentation de la transparence de la fenêtre active
            TransPlus()
		; F2 Key Pressed
        Case "^{F2}"
			; Diminution de la transparence de la fenêtre active
            TransMoins()
		; F3 Key Pressed
        Case "^{F3}"
			; Ancrage | Dé-ancrage de la fenêtre active
			; TODO fonction ancrage
		; F4 Key Pressed
		Case "^{F4}"
			; Quitte le programme en appliquant les paramètres par défaut pour chaque fenêtre
			Stop()
    EndSwitch
EndFunc

#comments-start
Permet d'augmenter la transparence de la fenêtre active
#comments-end
Func TransPlus($fenAdressParam = Null)
	Local $fenAdress = $fenAdressParam
	If($fenAdress = Null) Then
		$fenAdress = ControlGetHandle(WinGetTitle("[ACTIVE]"), "", "")
	EndIf
	If(FenIsExist($dictionary, $fenAdress) == True) Then
		$transparence = GetFenCaracteristiques($dictionary, $fenAdress, "_transparence")
		If($transparence <= 245) Then
			$transparence = $transparence + 10
			WinSetTrans($fenAdress, '', $transparence)
			; Mise à jour de la transparence dans le dictionnaire
			SetFenCaracteristiques($dictionary, $fenAdress, $transparence, Null, "_transparence")
			printDebug()
		Else
			MsgBox($MB_ICONWARNING + $MB_OK, "Erreur transparence > 255", "La transparence a atteint sa valeur maximum" & @CRLF & _
			"Impossible de l'augmenter davantage.")
		EndIf
	Else
		; Ajout de la fenêtre dans le dictionnaire
		InsertFenCaracteristiques($dictionary, $fenAdress)
		; Rappel de la fonction avec la nouvelle fenêtre
		TransPlus($fenAdress)
	EndIf
EndFunc

#comments-start
Permet de diminuer la transparence de la fenêtre active
#comments-end
Func TransMoins($fenAdress = Null)
    If($fenAdress == Null) Then
		$fenAdress = ControlGetHandle(WinGetTitle("[ACTIVE]"), "", "")
	EndIf
	If(FenIsExist($dictionary, $fenAdress) == True) Then
		$transparence = GetFenCaracteristiques($dictionary, $fenAdress, "_transparence")
		If($transparence >= 10) Then
			$transparence = $transparence - 10
			WinSetTrans($fenAdress, '', $transparence)
			SetFenCaracteristiques($dictionary, $fenAdress, $transparence, Null, "_transparence")
			printDebug()
		Else
			MsgBox($MB_ICONWARNING + $MB_OK, "Erreur transparence > 255", "La transparence a atteint sa valeur maximum" & @CRLF & _
			"Impossible de l'augmenter davantage.")
		EndIf
	Else
		; Ajout de la fenêtre dans le dictionnaire
		InsertFenCaracteristiques($dictionary, $fenAdress)
		; Rappel de la fonction avec la nouvelle fenêtre
		TransMoins($fenAdress)
	EndIf
EndFunc

#comments-start
Permet d'ancrer / désancrer la fenêtre active au premier plan
#comments-end
Func WindowFirstPlan()
	; Récupération fenêtre active
	$fenActive = WinGetTitle("[ACTIVE]")
	; Si la fenêtre n'est pas ancrêe, on l'ancre
	If(Not $ancre) Then
		WinSetState($fenActive, "", @SW_SHOW)
		MsgBox($MB_OK + $MB_ICONWARNING, "Ancrage", "La fen�tre est ancr�e au premier-plan")
		WinSetOnTop($fenActive, "", $WINDOWS_ONTOP)
		$ancre = True
		; Sinon, on supprime l'ancre pour pouvoir mettre d'autres fen�tres en premier plan
	Else
		WinSetOnTop($fenActive, "", $WINDOWS_NOONTOP)
		MsgBox($MB_OK + $MB_ICONWARNING, "Ancrage", "La fen�tre est d�sancr�e du premier-plan")
		$ancre = False
	EndIf
EndFunc

#comments-start
Vérifie si la fenêtre active existe déjà dans le dictionnaire
#comments-end
Func FenIsExist(ByRef $dictionary, ByRef $sStringAdressFen)
	$exist = False
	For $item In $dictionary
		If($item == $sStringAdressFen) Then
			$exist = True
		EndIf
	Next
	return $exist
EndFunc

#comments-start
Obtient la valeur de la transparence / ancre de la fenêtre si elle est présente dans le dictionnaire
#comments-end
Func GetFenCaracteristiques(ByRef $dictionary, ByRef $sStringAdressFen, $data = Null)
	If($data == Null) Then
		MsgBox($MB_ICONERROR + $MB_OK, "Erreur paramètre(s) incorrecte(s)", "Merci de préciser la donnée à récupérer !" & @CRLF & _
		"Usage : GetFenCaracteristiques(dictionary, adresseFen, (_transparence | _ancre))")
	Else
		For $item In $dictionary
			If($item == $sStringAdressFen) Then
				If($data == "_transparence") Then
					return $dictionary.Item($item)[0][0]
				ElseIf($data == "_ancre") Then
					return $dictionary.Item($item)[0][1]
				EndIf
			EndIf
		Next
	EndIf
EndFunc

#comments-start
Met à jour les valeurs transparence / ancre dans le dictionnaire
#comments-end
Func SetFenCaracteristiques(ByRef $dictionary, ByRef $sStringAdressFen, $transparence, $ancre, $data = Null)
	If($data == Null) Then
		MsgBox($MB_ICONERROR + $MB_OK, "Erreur paramètre(s) incorrecte(s)", "Merci de préciser la donnée à modifier !" & @CRLF & _
		"Usage : SetFenCaracteristiques(dictionary, adresseFen, transparence, ancre, (_transparence | _ancre))")
	Else
		; $data = (_transparence | _ancre)
		Switch $data
			; Mise à jour de la transparence
			Case "_transparence"
				Dim $values = $dictionary.Item(String($sStringAdressFen))
				For $i = 0 To UBound($values) - 1
					For $j = 0 To UBound($values, 2) - 1
						If($j == 0) Then
							$values[$i][$j] = $transparence
						EndIf
					Next
				Next
				$dictionary.Item(String($sStringAdressFen)) = $values
				; @error <--> succès ou non de la dernière instruction
				If @error Then
					MsgBox($MB_ICONERROR + $MB_OK, "Erreur Update Transparence", "Une erreur est survenue dans la modification de la transparence")
				Else
					MsgBox($MB_ICONINFORMATION + $MB_OK, "Succès modification transparence", "Modification de transparence effectuée ! " & @CRLF & _
					"Valeur de transparence pour la fenêtre " & WinGetTitle($sStringAdressFen) & " : " & _
					$dictionary.Item(String($sStringAdressFen))[0][0], 3)
					; Focus remis sur la fenêtre active
					ControlFocus($sStringAdressFen, "", "")
				EndIf
			; Mise à jour de l'ancre
			Case "_ancre"
		EndSwitch
	EndIf
EndFunc

#comments-start
Insère les valeurs transparence / ancre du dictionnaire en fonction de l'adresse de la fenêtre
#comments-end
Func InsertFenCaracteristiques(ByRef $dictionary, ByRef $sStringAdressFen, $transparence = 255, $ancre = False)
#comments-start
Tableau contenant la valeur de la transparence ainsi que le booléen d'ancrage concernant la fenêtre
Pour 1 ligne , on a 2 colonnes (2 valeurs)
Initialisation taille minimum
#comments-end
	Dim $aArray[1][2]
	For $i = 0 To UBound($aArray) - 1
		For $j = 0 to UBound($aArray, 2) - 1
			If($j == 0) Then
				$aArray[$i][$j] = $transparence
			Else
				$aArray[$i][$j] = $ancre
			EndIf
		Next
	Next
	; Si la fenêtre n'existe pas, on l'ajoute avec les caractéristiques transparence / ancre
	If(FenIsExist($dictionary, $sStringAdressFen) == False) Then
		$dictionary.add(String($sStringAdressFen), $aArray)
	; Sinon, on affiche un message d'erreur
	Else
		ConsoleWriteError("Violation de contrainte de clé dans le dictionnaire !" & @CRLF & _
		"La fenêtre d'adresse " & String($sStringAdressFen) & " existe déjà" & @CRLF)
	EndIf
	printDebug()
EndFunc

; Mode dev
Func printDebug()
	ConsoleWrite("Contenu du dictionnaire :" & @CRLF)
	ConsoleWrite('{' & @CRLF)
	For $item In $dictionary
		ConsoleWrite(">> Adresse de la fenêtre " & $item & " --> " & StringFormat("Transparence[%i]", $dictionary.Item($item)[0][0]) & ", " & StringFormat("Ancre[%s]", $dictionary.Item($item)[0][1]))
		ConsoleWrite(@CRLF)
	Next
	ConsoleWrite('}' & @CRLF)
EndFunc
; END Mode dev

#comments-start
Permet l'arrêt du programme et le reset des modifications
#comments-end
Func Stop()
	$response = MsgBox($MB_YESNO + $MB_ICONQUESTION, "Fin du programme", "Quitter ? La transparence sera réinitialisée")
	If $response = $IDYES Then
		; On parcours toute les fenêtres présentent dans le dictionnaire pour réinitialiser appliquer les valeurs par défaut
		For $item In $dictionary
			; Remise de la transparence par défaut
			WinSetTrans(HWnd($item), '', 255)
			; TODO Dé-ancrage
		Next
		Exit
	Else
		; On ne fait rien
	EndIf
EndFunc