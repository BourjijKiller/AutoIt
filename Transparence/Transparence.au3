#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>

#Region Déclaration des touches event
HotKeySet('^{F1}', "HotKeyFunc")
HotKeySet('^{F2}', "HotKeyFunc")
HotKeySet('^{F3}', "HotKeyFunc")
HotKeySet('^{F4}', "HotKeyFunc")
HotKeySet('^{F5}', "HotKeyFunc")
HotKeySet('^{F6}', "HotKeyFunc")
#EndRegion

; Dictionnaire (AdresseFenetre) = {transparence, ancre}
Global $dictionary = ObjCreate("Scripting.Dictionary")

MsgBox($MB_ICONINFORMATION, "Informations", "CTRL + F1 : Augmenter la transparence progressivement" & @CRLF & _
			"CTRL + F2 : Réduire la transparence progressivement" & @CRLF & _
			"CTRL + F3 : Attacher / Détacher une fenêtre au premier plan" & @CRLF & _
			"CTRL + F4 : Transparence au maximum" & @CRLF & _
			"CTRL + F5 : Transparence au minimum" & @CRLF & _
			"CTRL + F6 : Quitter")

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
			WindowFirstPlan()
		; F4 Key Pressed
		Case "^{F4}"
			; TODO transparence minimum
		; F5 Key Pressed
		Case "^{F5}"
			; Application de la transparence au maximum
			TransMoins(Null, True)
		; F6 Key Pressed
		Case "^{F6}"
			; Quitte le programme en appliquant les paramètres par défaut pour chaque fenêtre
			Stop()
    EndSwitch
EndFunc

#comments-start
Permet d'augmenter la transparence de la fenêtre active
#comments-end
Func TransPlus($fenAdressParam = Null, $transpMax = Null)
	Local $fenAdress = $fenAdressParam
	If($fenAdress = Null) Then
		$fenAdress = WinGetHandle(WinGetTitle("[ACTIVE]"))
	EndIf
	If(FenIsExist($dictionary, $fenAdress) == True) Then
		$transparence = GetFenCaracteristiques($dictionary, $fenAdress, "_transparence")
		If($transparence <= 245) Then
			$transparence = $transparence + 10
			WinSetTrans($fenAdress, '', $transparence)
			; Mise à jour de la transparence dans le dictionnaire
			SetFenCaracteristiques($dictionary, $fenAdress, $transparence, Null, "_transparence")
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
Si le paramètre $transpMin vaut True, la méthode permet de mettre directement la transparence de la fenêtre à 0 (Totalement transparente)
#comments-end
Func TransMoins($fenAdress = Null, $transpMin = False)
    If($fenAdress == Null) Then
		$fenAdress = WinGetHandle(WinGetTitle("[ACTIVE]"))
	EndIf
	If(FenIsExist($dictionary, $fenAdress) == True) Then
		$transparence = GetFenCaracteristiques($dictionary, $fenAdress, "_transparence")
		If($transpMin == True) Then
			$transparence = 0
			WinSetTrans($fenAdress, '', $transparence)
			SetFenCaracteristiques($dictionary, $fenAdress, $transparence, Null, "_transparence")
			$transpMin = False
		Else
			If($transparence >= 10) Then
				$transparence = $transparence - 10
				WinSetTrans($fenAdress, '', $transparence)
				SetFenCaracteristiques($dictionary, $fenAdress, $transparence, Null, "_transparence")
			Else
				MsgBox($MB_ICONWARNING + $MB_OK, "Erreur transparence > 255", "La transparence a atteint sa valeur maximum" & @CRLF & _
				"Impossible de l'augmenter davantage.")
			EndIf
		EndIf
	Else
		; Ajout de la fenêtre dans le dictionnaire
		InsertFenCaracteristiques($dictionary, $fenAdress)
		; Rappel de la fonction avec la nouvelle fenêtre
		$transpMin == True ? TransMoins($fenAdress, True) : TransMoins($fenAdress)
	EndIf
EndFunc

#comments-start
Permet d'ancrer / désancrer la fenêtre active au premier plan
#comments-end
Func WindowFirstPlan()
	$fenAdress = WinGetHandle(WinGetTitle("[ACTIVE]"))
	; Si la fenêtre est déjà référencée dans le dictionnaire, on traite $ancre
	If(FenIsExist($dictionary, $fenAdress) == True) Then
		; Vérification si la fenêtre n'est pas déjà ancrée
		$ancre = GetFenCaracteristiques($dictionary, $fenAdress, "_ancre")
		ConsoleWrite("Statut de l'ancre pour la fenêtre " & String($fenAdress) & " --> " & $ancre & @CRLF)
		; Si $ancre = False
		If(Not $ancre) Then
			WinSetState($fenAdress, "", @SW_SHOW)
			WinSetOnTop($fenAdress, "", $WINDOWS_ONTOP)
			If @error Then
				MsgBox($MB_OK + $MB_ICONERROR, "Ancrage", "Une erreur est survenue lors de l'ancrage")
			Else
				MsgBox($MB_OK + $MB_ICONINFORMATION, "Ancrage", "La fenêtre " & WinGetTitle($fenAdress) & " est ancrée au premier-plan")
				$ancre = True
				; Mise à jour du dictionnaire
				SetFenCaracteristiques($dictionary, $fenAdress, Null, $ancre, "_ancre")
			EndIf
		; Sinon, on supprime l'ancre pour pouvoir mettre d'autres fen�tres en premier plan
		Else
			WinSetOnTop($fenAdress, "", $WINDOWS_NOONTOP)
			If @error Then
				MsgBox($MB_OK + $MB_ICONERROR, "Dé-ancrage", "Une erreur est survenue lors de la suppression de l'ancrage")
			Else
				MsgBox($MB_OK + $MB_ICONWARNING, "Ancrage", "La fenêtre " & WinGetTitle($fenAdress) & " est désancrée du premier-plan")
				$ancre = False
				; Mise à jour du dictionnaire
				SetFenCaracteristiques($dictionary, $fenAdress, Null, $ancre, "_ancre")
			EndIf
		EndIf
	Else
		; La fenêtre n'existe pas, on l'ajoute dans le dictionnaire
		InsertFenCaracteristiques($dictionary, $fenAdress)
		; On rappel la fonction
		WindowFirstPlan()
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
		ConsoleWriteError("Erreur paramètre(s) incorrecte(s)" & @CRLF & "Merci de préciser la donnée à récupérer !" & @CRLF & _
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
		Dim $values = $dictionary.Item(String($sStringAdressFen))
		For $i = 0 To UBound($values) - 1
			For $j = 0 To UBound($values, 2) - 1
				If($data == "_transparence") Then
					If($j == 0) Then
						$values[$i][$j] = $transparence
					EndIf
				ElseIf($data == "_ancre") Then
					If($j == 1) Then
						$values[$i][$j] = $ancre
					EndIf
				EndIf
			Next
		Next
		$dictionary.Item(String($sStringAdressFen)) = $values
		; @error <--> succès ou non de la dernière instruction
		If @error Then
			MsgBox($MB_ICONERROR + $MB_OK, "Erreur Update", "Une erreur est survenue dans la modification des données")
		Else
			MsgBox($MB_ICONINFORMATION + $MB_OK, "Succès modification données", "Modification des données effectuée ! " & @CRLF & _
			"Valeur des données pour la fenêtre " & WinGetTitle($sStringAdressFen) & " : " & @CRLF & _
			"Transparence --> " & $dictionary.Item(String($sStringAdressFen))[0][0] & @CRLF & _
			"Ancre --> " & $dictionary.Item(String($sStringAdressFen))[0][1])
			; Focus remis sur la fenêtre active
			ControlFocus($sStringAdressFen, "", "")
			printDebug()
		EndIf
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
	$response = MsgBox($MB_YESNO + $MB_ICONQUESTION, "Fin du programme", "Quitter ? La transparence ainsi que l'ancre seront réinitialisés")
	If $response = $IDYES Then
		; On parcours toute les fenêtres présentent dans le dictionnaire pour réinitialiser appliquer les valeurs par défaut
		For $item In $dictionary
			; Remise de la transparence par défaut
			WinSetTrans(HWnd($item), '', 255)
			; Remise de l'ancre par défaut
			WinSetOnTop(HWnd($item), '', $WINDOWS_NOONTOP)
		Next
		Exit
	Else
		; On ne fait rien
	EndIf
EndFunc