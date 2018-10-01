#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

; helpers
#include <TypingCommon.au3>
#include <Instructions.au3>
#include <Beginner.au3>
#include <Intermediate.au3>
#include <Game.au3>

Opt('GUIOnEventMode', 1)


HotKeySet('{ESC}', '_Exit')

Global $homeGUI, $instructionGUI, $beginnerGUI, $intermediateGUI, $gameGUI


Global $btnHome

Global $activePage ; GUI handle for each page


; install files
FileInstall('.\Resources\level0.txt', $DATA_DIR & '\level0.txt')
FileInstall('.\Resources\level1.txt', $DATA_DIR & '\level1.txt')
FileInstall('.\Resources\level2.txt', $DATA_DIR & '\level2.txt')
FileInstall('.\Resources\level3.txt', $DATA_DIR & '\level3.txt')
FileInstall('.\Resources\level4.txt', $DATA_DIR & '\level4.txt')
FileInstall('.\Resources\level5.txt', $DATA_DIR & '\level5.txt')
FileInstall('.\Resources\sentences.txt', $DATA_DIR & '\sentences.txt')

FileInstall('.\Resources\ergonomics.jpg', $DATA_DIR & '\ergonomics.jpg')
FileInstall('.\Resources\placement.jpg', $DATA_DIR & '\placement.jpg')


_CreateGUI()


While 1
	Sleep(10)
WEnd

Func _CreateGUI()
	$mainGUI = GUICreate('Typing', $GUI_INIT_WIDTH, $GUI_INIT_HEIGHT, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX, $WS_CAPTION)) ; $WS_SIZEBOX, $WS_MAXIMIZEBOX,
		GUISetOnEvent($GUI_EVENT_CLOSE, '_Exit')
		GUISetBkColor($GUI_BK_COLOR)

	$btnHome = GUICtrlCreateButton('Menu', $GUI_INIT_WIDTH / 2 - 100, 10, 200, 40)
		GUICtrlSetOnEvent(-1, '_Home')
		GUICtrlSetState(-1, $GUI_HIDE)
		GUICtrlSetFont(-1, 14)
		GUICtrlSetResizing(-1, BitOR($GUI_DOCKHCENTER, $GUI_DOCKSIZE))


	_CreateHomePage()
	$instructionGUI = _CreateInstructionPage('_ShowBeginnerPage') ;'_CustomGoToBeginner') ;$guiWidth, $guiHeight, $mainGUI)
	$beginnerGUI = _CreateBeginnerPage() ;$guiWidth, $guiHeight, $mainGUI)
	$intermediateGUI = _CreateIntermediatePage()
	$gameGUI = _CreateGamePage()

	_ShowPage($homeGUI)

	GUIRegisterMsg($WM_SIZE, '_Resize')
	GUIRegisterMsg($WM_COMMAND, '_CommandMsg')


	GUISetState(@SW_SHOW, $mainGUI)
EndFunc

Func _Resize()
;~ 	ConsoleWrite('> here!' & @CRLF)

	$pos = WinGetPos($mainGUI)

;~ 	ConsoleWrite('$pos = [' & $pos[0] & ', ' & $pos[1] & ', ' & $pos[2] & ', ' & $pos[3] & ']' & @CRLF)

	For $i = 0 to UBound($childWindows) - 1
		$result = WinMove($childWindows[$i], '', Default, Default, $pos[2], $pos[3])

;~ 		ConsoleWrite('$i = ' & $i & ', $result = ' & $result & @CRLF)
	Next

EndFunc


Func _CommandMsg($hWnd, $msg, $wParam, $lParam)

	$idFrom = BitAND($wParam, 0x0000FFFF)
	$iCode = BitShift($wParam, 16)

	Switch $idFrom
		Case $txtInputBeginner
			Switch $iCode
				Case $EN_UPDATE
					_EditBeginnerChanged()
			EndSwitch
		Case $txtInputInter
			Switch $iCode
				Case $EN_UPDATE
					_EditInterChanged()
			EndSwitch

		Case $txtGameInput
			Switch $iCode
				Case $EN_UPDATE
					_GameEditChanged()
			EndSwitch

	EndSwitch

EndFunc   ;==>_CommandMsg

Func _CreateHomePage()
	$width = 500
	$xStart = $GUI_INIT_WIDTH / 2 - $width / 2


	$homeGUI = _CreateChildWindow() ;GUICreate('', $guiWidth, $guiHeight, 0, 50, $WS_CHILD, -1, $mainGUI)
		GUISetBkColor($GUI_BK_COLOR)
		GUISetFont($GUI_FONT_SIZE)

	Local $textArray[4][4] = [ _
		['Instructions', 'Learn How To Type', 'Start here if you have very little or no experience typing. This covers basics on how to position ' & _
		'your fingers and what to focus on when typing.', '_ShowInstructionPage'], _
		['Beginner', 'Learn the Letters', 'Go through the steps of learning all the letters of the alphabet. Start with the ASDF and JKL; keys and ' & _
		'gradually add on more letters.', '_ShowBeginnerPage'], _
		['Intermediate', 'Typing Sentences', 'Move on from typing simple letters and words to typing full sentences. This adds using capitals and ' & _
		'punctuation.', '_ShowIntermediatePage'], _
		['Game Mode', 'Play a Game', 'Learn to type while playing a game. Keep the falling letters and words from hitting the ground.' , '_ShowGamePage'] ] ;, _
;~ 		['Advanced', 'Typing Paragraphs', 'Work on building up typing accuracy and speed by typing full paragraphs of text.', '_ShowAdvancedPage']		]

	For $i = 0 to UBound($textArray) - 2
		$tempY = $i * 140
		GUICtrlCreateLabel('', $xStart - 50, $tempY, $width + 100, 130, $SS_CENTER)
			GUICtrlSetBkColor(-1, $GUI_PANEL_COLOR)
			GUICtrlSetState(-1, $GUI_DISABLE)

		GUICtrlCreateLabel($textArray[$i][0], $xStart, $tempY + 5, $width, 30, $SS_CENTER)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
			GUICtrlSetFont(-1, 16)

		GUICtrlCreateLabel($textArray[$i][2], _
			$xStart, $tempY + 30, $width, 40)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

		GUICtrlCreateButton($textArray[$i][1], $xStart, $tempY + 80, $width, 40)
			GUICtrlSetOnEvent(-1, $textArray[$i][3])
			GUICtrlSetResizing(-1, BitOR($GUI_DOCKHCENTER, $GUI_DOCKSIZE))

	 Next

EndFunc

Func _Home()
	_LeavePageEvent()
;~ 	SLeep(1000)
	_ShowPage($homeGUI)
EndFunc

Func _ShowInstructionPage()
	_ShowPage($instructionGUI)
EndFunc

Func _ShowBeginnerPage()
	_ShowPage($beginnerGUI)
EndFunc

Func _ShowIntermediatePage()
	_ShowPage($intermediateGUI)
EndFunc

Func _ShowGamePage()
	_ShowPage($gameGUI)
EndFunc

Func _ShowPage($gui)
	GUISetState(@SW_HIDE, $activePage)
	If $gui <> $homeGUI then
		GUICtrlSetState($btnHome, $GUI_SHOW)
	Else
		GUICtrlSetState($btnHome, $GUI_HIDE)
	EndIf

	GUISetState(@SW_SHOW, $gui)
	$activePage = $gui

	_EnterPageEvent($activePage)
EndFunc

Func _Exit()
	Exit
EndFunc

