#include <Array.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>

#include <TypingCommon.au3>


Local $MAX_PIECES = 10

Local $fallingPieces[0] ; 0 = ID, 1 = text, 2 = finished?

Local $fallDistance = 1 ; pixels
Local $fallSpeed = 50 ; ms

Local $wordList = FileReadToArray($DATA_DIR & '\level' & 0 & '.txt')

;things to do:
; pieces at bottom = lost life
; don't draw pieces ontop of eachother
; can't have things like: ad, add, ads - very confusing
; add enter to clear
; progressively complicated words
; more color choices
; piece death animated (fade out? sound? AWESOME EXPLOSION???)
; User test


Func _CreateGamePage()


	$gui = _CreateChildWindow()
		GUISetBkColor($GUI_BK_COLOR)
		GUISetFont($GUI_FONT_SIZE)


	$panelTopY = $GUI_INIT_HEIGHT - $CHILD_WINDOW_Y_OFFSET - 40
	GUICtrlCreateLabel('', 0, $panelTopY, $GUI_INIT_WIDTH, 40)
		GUICtrlSetBkColor(-1, 0xC0C0C0)
		GUICtrlSetState(-1, $GUI_DISABLE)

	$txtGameInput = GUICtrlCreateInput('', $GUI_INIT_WIDTH / 2 - 100, $GUI_INIT_HEIGHT - $CHILD_WINDOW_Y_OFFSET - 40 + 5, 200, 30, $ES_CENTER)

	_GeneratePiece()

	_AddEnterPageEvent($gui, '_StartGame')

	GUISetState(@SW_HIDE, $gui)

	Return $gui

EndFunc

Func _NewGameWord()

	Return $wordList[Random(0, UBound($wordList) - 1)]

EndFunc


Func _StartGame()
	GUICtrlSetState($txtGameInput, $GUI_FOCUS)


	AdlibRegister('_DropPieces', $fallSpeed)


EndFunc

Func _GameEditChanged()

	ConsoleWrite('> Game edit changed' & @CRLF)

	$curText = GUICtrlRead($txtGameInput)
	$wordFound = False

	For $i = UBound($fallingPieces) - 1 to 0 Step -1

		If GUICtrlRead($fallingPieces[$i]) = $curText then

			GUICtrlDelete($fallingPieces[$i])
			_ArrayDelete($fallingPieces, $i)

			GUICtrlSetData($txtGameInput, '')
			$wordFound = True
		EndIf


	Next

	If $wordFound then _GeneratePiece() ; keep from doing it for every word in case of duplicates


EndFunc


Func _DropPieces()

	If Random(1, 50, 1) = 3 then ; 2% chance of generating one every 50ms
		_GeneratePiece()
	EndIf

	For $i = 0 to UBound($fallingPieces) - 1
		If $i >= UBound($fallingPieces) then ExitLoop; check needed cause pieces can die mid loop

		$piece = $fallingPieces[$i]

		$pos = ControlGetPos('', '', $piece)

;~ 		ConsoleWrite('> $x = ' & $pos[0] & ' $y = ' & $pos[1] & @CRLF)
		If IsArray($pos) then
			ControlMove('', '', $piece, $pos[0], $pos[1] + $fallDistance - $CHILD_WINDOW_Y_OFFSET)
		EndIf

	Next


EndFunc

Func _GeneratePiece()
	If UBound($fallingPieces) >= $MAX_PIECES then Return

	$text = _NewGameWord()


	$labelWidth = 50

	$xStart = Random(0, $GUI_INIT_WIDTH - $labelWidth, 1)


	$label = GUICtrlCreateLabel($text, $xStart, 0, $labelWidth, 30, BitOR($SS_CENTERIMAGE, $SS_CENTER))
		GUICtrlSetBkColor(-1, 16744576)

	_ArrayAdd($fallingPieces, $label)


EndFunc