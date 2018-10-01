#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <Math.au3>

; use app data?
FileInstall('level0.txt', @ScriptDir & '\', 1)
FileInstall('level1.txt', @ScriptDir & '\', 1)
FileInstall('level2.txt', @ScriptDir & '\', 1)
FileInstall('level3.txt', @ScriptDir & '\', 1)
FileInstall('level4.txt', @ScriptDir & '\', 1)
FileInstall('level5.txt', @ScriptDir & '\', 1)


Opt('GUIOnEventMode', 1)

HotKeySet('{ESC}', '_Exit')
HotKeySet('^!q', '_Debug')


Global Const $LETTERS[29] = ['a', 's', 'd', 'f', 'j', 'k', 'l', ';', _ ; 0
		'g', 'h', 'e', 'i', 'r', 'u', 'w', 'o', _ ; 1 .. 2
		'q', 'p', 't', 'y', 'v', 'm', 'b', 'n', _ ; 3 .. 4
		'c', 'x', 'z', ',', '.'] ; 5
Global Const $LEVEL_LIMITS[6] = [7, 11, 15, 19, 23, 28]

Global $level = 0

Global $difficulty = 1 ; 1: 1 letter, 2: 2 letters, 3: 3 letters, 4: words
Global Const $MAX_DIFFICULTY = 4

Global $keystrokeCount = 0 ; ; used for performance monitoring
Global $correctCount = 0 ;

Global $lastPhrase = '' ; avoid repeats

Global $displayTime = 500

Global $wordLists[5] ; array of arrays

Global $lblDisplay, $txtInput, $lblResult
Global $menuBasicDiff

_LoadWordLists()

_CreateGUI()


While 1
	Sleep(20)

WEnd

Func _LoadWordLists()
	For $i = 0 To 4

		$temp = FileReadToArray(@ScriptDir & '\level' & $i & '.txt')


		$wordLists[$i] = $temp

	Next

EndFunc   ;==>_LoadWordLists

Func _Debug()
	$difficulty = 4
EndFunc   ;==>_Debug

Func _GenerateText()

	If $difficulty = 4 Then

		$list = $wordLists[$level]
		$result = $list[Random(0, UBound($list) - 1, 1)]

	Else

		$limit = $LEVEL_LIMITS[$level]

		$result = ''

		For $i = 1 To $difficulty
			$result = $result & $LETTERS[Random(0, $limit, 1)]
		Next
	EndIf

	;ConsoleWrite('> $result = ' & $result & ' = $lastPhrase = ' & $lastPhrase & @CRLF)

	If $result = $lastPhrase Then
		Return _GenerateText()

	EndIf

	$lastPhrase = $result
	Return $result
EndFunc   ;==>_GenerateText

Func _CreateGUI()
	Local Const $DIFF_TEXT[6] = ['Basic home row' & @TAB & 'asdfjk;l', 'Full home row + ei' & @TAB & '+ghei', _
			'Full home row + ei + ruwo' & @TAB & '+ruwo', 'All mid and top rows' & @TAB & '+qpty', _
			'Mid, top, + vmbn' & @TAB & '+vmbn', 'All' & @TAB & '+zxc,.']

	$gui = GUICreate('Typing', 800, 400)
	GUISetBkColor(0xFFFFFF, $gui)
	GUISetOnEvent($GUI_EVENT_CLOSE, '_Exit')

	$menuLvl = GUICtrlCreateMenu('Level')


	For $i = 0 To UBound($DIFF_TEXT) - 1

		$temp = GUICtrlCreateMenuItem($DIFF_TEXT[$i], $menuLvl, -1, 1)
		If $i = 0 Then
			GUICtrlSetState(-1, $GUI_CHECKED)
			$menuBasicDiff = $temp
		EndIf
		GUICtrlSetOnEvent(-1, '_ChangeDifficulty')
	Next

	GUICtrlCreateMenuItem('', $menuLvl) ; seperator

	GUICtrlCreateMenuItem('Reset phrase length', $menuLvl)
	GUICtrlSetOnEvent(-1, '_ResetLength')


	$lblDisplay = GUICtrlCreateLabel('', 10, 60, 780, 40, $SS_CENTER)
	GUICtrlSetFont(-1, 26)



	$lblResult = GUICtrlCreateLabel('', 0, 160, 800, 130, $SS_CENTER)
	;GUICtrlSetBkColor(-1, 0)

	$txtInput = GUICtrlCreateInput('', 100, 200, 600, 50, $ES_CENTER)
	GUICtrlSetFont(-1, 24)

	GUIRegisterMsg($WM_COMMAND, '_CommandMsg')

	_InitiateText()

	GUISetState()

;~    GUICtrlSEtState($txtInput, $GUI_FOCUS)


EndFunc   ;==>_CreateGUI

Func _ChangeDifficulty()
	;ConsoleWrite('+> @GUI_CtrlID = ' & @GUI_CtrlID & @CRLF)

	$level = @GUI_CtrlId - $menuBasicDiff
	$difficulty = 1
	$correctCount = 0

	_InitiateText()
	;ConsoleWrite('$level = ' & $level)


EndFunc   ;==>_ChangeDifficulty

Func _ResetLength()
	$difficulty = 1
	$correctCount = 0
	_InitiateText()
EndFunc   ;==>_ResetLength

Func _InitiateText()

	GUICtrlSetData($lblDisplay, _GenerateText())

	GUICtrlSetData($txtInput, '')
EndFunc   ;==>_InitiateText


Func _EditTextChanged()

	$input = GUICtrlRead($txtInput)
	If StringLen($input) = 0 Then Return

	$expected = GUICtrlRead($lblDisplay)


	If StringLen($expected) <> StringLen($input) Then Return ; shouldn't be able to get longer but just in case (e.g. pasting)

	; determine if the correct key was hit
	If $input = $expected Then ;StringLeft($expected, StringLen($input)) Then
		_RightAnswer()
	Else
		_WrongAnswer()
	EndIf

EndFunc   ;==>_EditTextChanged

Func _WrongAnswer()
	; ConsoleWrite('!> WRONG' & @CRLF)
	$correctCount = 0

	;GUI_BKCOLOR_TRANSPARENT

	GUICtrlSetBkColor($lblResult, 0xFF0000)
	AdlibRegister('_TimerEndWrong', $displayTime)
EndFunc   ;==>_WrongAnswer

Func _RightAnswer()
	; ConsoleWrite('+> RIGHT' & @CRLF)
	$correctCount = $correctCount + 1
	If $correctCount > 10 Then
		$difficulty = _Min($difficulty + 1, $MAX_DIFFICULTY)
		$correctCount = 0
	EndIf

	GUICtrlSetBkColor($lblResult, 0x00FF00)
	AdlibRegister('_TimerEndRight', $displayTime - ($difficulty * 80))
EndFunc   ;==>_RightAnswer

Func _TimerEndWrong()
	AdlibUnRegister('_TimerEndWrong')

	GUICtrlSetBkColor($lblResult, $GUI_BKCOLOR_TRANSPARENT)

	GUICtrlSetData($txtInput, '')
EndFunc   ;==>_TimerEndWrong

Func _TimerEndRight()
	AdlibUnRegister('_TimerEndRight')

	GUICtrlSetBkColor($lblResult, $GUI_BKCOLOR_TRANSPARENT)

	_InitiateText()
EndFunc   ;==>_TimerEndRight


Func _CommandMsg($hWnd, $msg, $wParam, $lParam)

	;ConsoleWrite('+> $wParam = ' & $wParam & @TAB & '$lParam = ' & $msg & @CRLF)

	$idFrom = BitAND($wParam, 0x0000FFFF)
	$iCode = BitShift($wParam, 16)

	Switch $idFrom
		Case $txtInput
			Switch $iCode
				Case $EN_UPDATE
					_EditTextChanged()
			EndSwitch


	EndSwitch

EndFunc   ;==>_CommandMsg

Func _Exit()
	Exit
EndFunc   ;==>_Exit
