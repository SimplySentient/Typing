#include <Array.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <Math.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#include <TypingCommon.au3>

Local Const $LETTERS[29] = ['a', 's', 'd', 'f', 'j', 'k', 'l', ';', _ ; 0
		'g', 'h', 'e', 'i', 'r', 'u', 'w', 'o', _ ; 1 .. 2
		'q', 'p', 't', 'y', 'c', 'v', 'm', 'n', _ ; 3 .. 4
		'z', 'x', 'b', ',', '.'] ; 5

	; complete:
	; 0, 1, 2 - g,


Local Const $LEVEL_LIMITS[6] = [7, 11, 15, 19, 23, 28]
Local Const $MAX_LEVEL = 5

Local Const $MAX_DIFFICULTY = 4


Local $level = 0

Local $difficulty = 1 ; 1: 1 letter, 2: 2 letters, 3: 3 letters, 4: words


Local $typingGUI, $menuGUI
Local $lblResult, $lblDisplay, $lblAvgAccuracy, $btnIncreaseDifficulty,$lblDifficultyInfo


Local $difficultyBaseText = 'You are currently working on these keys: '



Local $keystrokeCount = 0 ; ; used for performance monitoring
Local $correctCount = 0 ;

Local $lastPhrase = '' ; avoid repeats

Local $displayTime = 600

Local $wordLists[5] ; array of arrays

Local $accuracyRecord[0]


Local $unlockLevel = INIRead($DATA_INI, 'Beginner', 'UnlockLevel', 0) ; start with only ASDFJKL; available


Local $textArray[6][3] = [ _
	['A S D F J K L and ;', 'These are the keys where your fingers rest', '_StartLevel0'], _
	['All previous keys and G H E and I', 'Use your index fingers for G and H and your middle fingers for E and I', '_StartLevel1'], _
	['All previous keys and R U W and O', 'Use your index fingers for R and U and your ring fingers for W and O', '_StartLevel2'], _
	['All previous keys and Q T Y and P', 'Use your pinky fingers for Q and P and your index fingers for T and Y', '_StartLevel3'], _
	['All previous keys and C V N and M', 'Use your left middle finger for C and your index fingers for V, N and M', '_StartLevel4'], _ ; is this the same as I was doing before?
	['All previous keys and Z X B , and .', 'Use your right pinky finger for Z, left ring finger for X, left index finger for B, right middle finger for , and right ring finger for .', '_StartLevel5']] ; add a "Everything option? Or let that come with sentences?

Local $btnArray[6]

_LoadWordLists()

Func _CreateBeginnerPage() ;$width, $height, $parent)

	$gui = _CreateChildWindow()
		GUISetBkColor($GUI_BK_COLOR)
		GUISetFont($GUI_FONT_SIZE)

	$yPos = 70
	$ctrlWidth = 700
	$xStart = $GUI_INIT_WIDTH / 2 - $ctrlWidth / 2


	GUICtrlCreateLabel('Start with keys where your fingers rest: ASDF and JKL;. Once you master those more keys will be added on.', $xStart + 100, 20, $ctrlWidth - 200, 35, $SS_CENTER)

	For $i = 0 to UBound($textArray) - 1

		$lblHeight = 75
		If $i = UBound($textArray) - 1 then ; only the last item needs to be taller
			$lblHeight = 95
		EndIf

		GUICtrlCreateLabel('', $xStart, $yPos, $ctrlWidth, $lblHeight)
			GUICtrlSetState(-1, $GUI_DISABLE)
			GUICtrlSetBkColor(-1, $GUI_PANEL_COLOR)

		$btnArray[$i] = GUICtrlCreateButton($textArray[$i][0], $xStart + 100, $yPos + 10, $ctrlWidth - 200, 35)
			GUICtrlSetOnEvent(-1, $textArray[$i][2])
			GUICtrlSetResizing(-1, BitOR($GUI_DOCKHCENTER, $GUI_DOCKSIZE))
		If $i > $unlockLevel then
			GUICtrlSetState(-1, $GUI_DISABLE)
		EndIf



		GUICtrlCreateLabel($textArray[$i][1], $xStart + 40, $yPos + 50, $ctrlWidth - 80, 50, $SS_CENTER)
			GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)

		$yPos = $yPos + $lblHeight + 10
	Next


	$menuGUI = $gui
	$typingGUI = _CreateTypingPage();$width, $height, $parent)


	_AddLeavePageEvent($typingGUI, '_OnBeginnerExit')

	GUISetState(@SW_HIDE, $gui)

	Return $gui

EndFunc


Func _OnBeginnerExit()
;~ 	WinSetState($typingGUI, '', @SW_HIDE)
	GUISetState(@SW_HIDE, $typingGUI)

	; update the menu in case they come back
	For $i = 0 to UBound($textArray) - 1
		If $i > $unlockLevel then
			GUICtrlSetState($btnArray[$i], $GUI_DISABLE)
		Else
			GUICtrlSetState($btnArray[$i], $GUI_ENABLE)
		EndIf
	Next
EndFunc

Func _CreateTypingPage();$width, $height, $parent)

	$gui = _CreateChildWindow() ;GUICreate('', $width, $Height, 0, 50, $WS_CHILD, -1, $parent)
		GUISetBkColor($GUI_BK_COLOR)
		GUISetFont($GUI_FONT_SIZE)


	$ctrlWidth = 600
	$xStart = $GUI_INIT_WIDTH / 2 - $ctrlWidth / 2


	GUICtrlCreateLabel('In the box below type the letter(s) displayed. Remember to type ' & _
		'with your left hand on the ASDF keys and your right hand on the JKL; keys. Keep your gaze focused on the screen and do not look at the keyboard.', _
		$xStart, 20, $ctrlWidth, 100)


	$lblDifficultyInfo = GUICtrlCreateLabel($difficultyBaseText & $textArray[$level][0], $xStart, 120, $ctrlWidth, 30, $SS_CENTER)



	$lblDisplay = GUICtrlCreateLabel('Type this', $xStart, 200, $ctrlWidth, 50, $SS_CENTER)
		GUICtrlSetFont(-1, 26)


	$lblResult = GUICtrlCreateLabel('', $xStart - 20, 260, $ctrlWidth + 40, 90)
		GUICtrlSetState(-1, $GUI_DISABLE)

	$txtInputBeginner = GUICtrlCreateInput('',  $xStart, 280, $ctrlWidth, 50, $SS_CENTER)
		GUICtrlSetFont(-1, 24)

	$lblAvgAccuracy = GUICtrlCreateLabel('Average Accuracy: N/A', $xStart, 500, $ctrlWidth, 30, $SS_CENTER)

	$btnIncreaseDifficulty = GUICtrlCreateButton("Good job! You've learned these keys well. Click here to add a few new keys.", $xStart, 570, $ctrlWidth, 30)
		GUICtrlSetState(-1, $GUI_HIDE)
		GUICtrlSetOnEvent(-1, '_IncreaseDifficulty')

	Return $gui
EndFunc

Func _StartLevel0()
	$level = 0
	_ShowTypingPage()
EndFunc

Func _StartLevel1()
	$level = 1
	_ShowTypingPage()
EndFunc


Func _StartLevel2()
	$level = 2
	_ShowTypingPage()
EndFunc


Func _StartLevel3()
	$level = 3
	_ShowTypingPage()
EndFunc


Func _StartLevel4()
	$level = 4
	_ShowTypingPage()
EndFunc


Func _StartLevel5()
	$level = 5
	_ShowTypingPage()
EndFunc

Func _IncreaseDifficulty()
	If $level < $MAX_LEVEL then
		$level = $level + 1

		_ResetInternals()

		_InitiateText()

	EndIf
EndFunc

Func _ResetInternals()
	$correctCount = 0
	GUICtrlSetState($btnIncreaseDifficulty, $GUI_HIDE)
	GUICtrlSetData($lblDifficultyInfo, $difficultyBaseText & $textArray[$level][0])

	$difficulty = 1
EndFunc

Func _ShowTypingPage()

	_ResetInternals()

	_InitiateText()

	GUISetState(@SW_SHOW, $typingGUI)
	GUISetState(@SW_HIDE, $menuGUI)

	GUICtrlSetState($txtInputBeginner, $GUI_FOCUS)

EndFunc


Func _InitiateText()

	GUICtrlSetData($lblDisplay, _GenerateText())

	GUICtrlSetData($txtInputBeginner, '')
EndFunc   ;==>_InitiateText

Func _LoadWordLists()
	For $i = 0 To 4
		$temp = FileReadToArray($DATA_DIR & '\level' & $i & '.txt')
		$wordLists[$i] = $temp
	Next
EndFunc   ;==>_LoadWordLists


Func _GenerateText()

	If $difficulty = 4 Then
		$list = $wordLists[$level]
		$result = ""
		Do
			$result = $list[Random(0, UBound($list) - 1, 1)]
		Until StringLen($result) > 0 ; just to guard against empty lines
	Else
		$limit = $LEVEL_LIMITS[$level]

		$result = ''

		For $i = 1 To $difficulty
			If Mod(Random(0, 10, 1), 2) = 0 then ; 50% chance to force letter to be one of the new ones being learned
				If $level > 0 then
					$lowerLimit = $LEVEL_LIMITS[$level - 1] + 1
				Else
					$lowerLimit = 0
				EndIf
			Else
				$lowerLimit = 0
			EndIf

			$result = $result & $LETTERS[Random($lowerLimit, $limit, 1)]
		Next
	EndIf

	;ConsoleWrite('> $result = ' & $result & ' = $lastPhrase = ' & $lastPhrase & @CRLF)

	If $result = $lastPhrase Then
		Return _GenerateText()

	EndIf

	$lastPhrase = $result

	Return $result
EndFunc   ;==>_GenerateText


Func _EditBeginnerChanged()
	$input = GUICtrlRead($txtInputBeginner)
	If StringLen($input) = 0 Then Return

	$expected = GUICtrlRead($lblDisplay)

	If StringLen($expected) <> StringLen($input) Then Return ; shouldn't be able to get longer but just in case (e.g. pasting or mashing)

	If $input = $expected Then
		_RightAnswer()
	Else
		_WrongAnswer()
	EndIf

	; update accuracy
;~ 	_ArrayDisplay($accuracyRecord)
	$correct = 0
	$attempted = 0
	For $i = 0 to UBound($accuracyRecord) - 1
		ConsoleWrite('> $i = ' & $i & @TAB & $accuracyRecord[$i] & @CRLF)

		If IsBool($accuracyRecord[$i]) then
			$attempted += 1
		EndIf

		If $accuracyRecord[$i] then
			$correct += 1
		EndIf
	Next
	ConsoleWrite('+> $correct = ' & $correct & @TAB & '$attempted = ' & $attempted & @CRLF)
	GUICtrlSetData($lblAvgAccuracy, 'Average Accuracy: ' & Round($correct / $attempted * 100) & '%')


EndFunc   ;==>_EditTextChanged

Func _WrongAnswer()
	; ConsoleWrite('!> WRONG' & @CRLF)
	$correctCount = 0

	GUICtrlSetBkColor($lblResult, 0xFF0000)
	_ArrayAdd($accuracyRecord, False)
	AdlibRegister('_TimerEndWrong', $displayTime)
EndFunc   ;==>_WrongAnswer

Func _RightAnswer()
	If @Compiled then
		$incDiffAt = 8
	Else
		$incDiffAt = 2
	EndIf
	; ConsoleWrite('+> RIGHT' & @CRLF)
	$correctCount = $correctCount + 1
	If $correctCount > $incDiffAt Then

		If $difficulty = $MAX_DIFFICULTY and $level < $MAX_LEVEL then
			If $correctCount > $incDiffAt * 2 then ; wait a bit longer before allowing user to add more keys
				GUICtrlSetState($btnIncreaseDifficulty, $GUI_SHOW)
				$unlockLevel = $level + 1
				INIWrite($DATA_INI, 'Beginner', 'UnlockLevel', $unlockLevel)
			EndIf
		Else
			$difficulty = _Min($difficulty + 1, $MAX_DIFFICULTY)
			$correctCount = 0
		EndIf
	EndIf

	GUICtrlSetBkColor($lblResult, 0x00FF00)
	_ArrayAdd($accuracyRecord, True)
	AdlibRegister('_TimerEndRight', $displayTime - ($difficulty * 80))
EndFunc   ;==>_RightAnswer

Func _TimerEndWrong()
	AdlibUnRegister('_TimerEndWrong')

	GUICtrlSetBkColor($lblResult, $GUI_BKCOLOR_TRANSPARENT)

	GUICtrlSetData($txtInputBeginner, '')
EndFunc   ;==>_TimerEndWrong

Func _TimerEndRight()
	AdlibUnRegister('_TimerEndRight')

	GUICtrlSetBkColor($lblResult, $GUI_BKCOLOR_TRANSPARENT)

	_InitiateText()
EndFunc   ;==>_TimerEndRight

