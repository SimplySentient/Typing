#include <File.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>

#include <TypingCommon.au3>

Local Const $WPM_TIMER = 2000

Local $lblResultInter, $lblDisplayInter, $lblWPMInter

Local $currentSentence

Local $sentenceArray[0]

If @Compiled then
	$interDir = $DATA_DIR & '\sentences.txt'
Else
	$interDir = '.\resources\Sentences.txt'
EndIf

_FileReadToArray($interDir, $sentenceArray, 0) ; 0 - 0 based array

For $i = UBound($sentenceArray) - 1 to 0 Step -1
	If $sentenceArray[$i] = '' then _ArrayDelete($sentenceArray, $i)
Next

Local $interDiff = 0.1 ; starts only covering 30% of sentences (shorter) and gradually adds more
Local $interCorrect = 0

Local $wordsTyped = 0, $elapsedTime = 0

;~ Local $wordCountArray[20]

Func _CreateIntermediatePage()

	$gui = _CreateChildWindow() ;GUICreate('', $width, $height, 0, 50, $WS_CHILD, -1, $parent)
		GUISetBkColor($GUI_BK_COLOR)
		GUISetFont($GUI_FONT_SIZE)


	$ctrlWidth = 600
	$xStart = $GUI_INIT_WIDTH / 2 - $ctrlWidth / 2


	GUICtrlCreateLabel('In the box below type the sentence displayed. Use either of your thumbs to press the spacebar. ' & _
		'You must use capital letters otherwise the answer will be wrong. To make a letter capital hold down shift with ' & _
		'either your left or right little finger.',  _
		$xStart, 20, $ctrlWidth, 100)

	$lblDisplayInter = GUICtrlCreateLabel('', $xStart, 150, $ctrlWidth, 100, $SS_CENTER)
		GUICtrlSetFont(-1, 26)



	$lblResultInter = GUICtrlCreateLabel('', $xStart - 20, 260, $ctrlWidth + 40, 140)
		GUICtrlSetState(-1, $GUI_DISABLE)

	$txtInputInter = GUICtrlCreateInput('',  $xStart, 280, $ctrlWidth, 100, BitOR($SS_CENTER, $ES_MULTILINE))
		GUICtrlSetFont(-1, 24)

	$lblWPMInter = GUICtrlCreateLabel('Average WPM: N/A', $xStart, 500, $ctrlWidth, 30, $SS_CENTER)

	_NewSentence()


;~ 	GUICtrlSetState($txtInputInter, $GUI_FOCUS)

	_AddEnterPageEvent($gui, '_EnterPageInter')

	_AddLeavePageEvent($gui, '_OnInterExit')


	Return $gui


EndFunc

Func _OnInterExit()
	AdlibUnRegister('_CalcWPM')
EndFunc

Func _EnterPageInter()
	GUICtrlSetState($txtInputInter, $GUI_FOCUS)

	AdlibRegister('_CalcWPM', $WPM_TIMER)
EndFunc

Func _CalcWPM()

	$elapsedTime += $WPM_TIMER / 1000 ; convert to seconds

	$wpm = Round($wordsTyped / $elapsedTime * 60, 0) ; * 60 to convert to minutes

;~ 	ConsoleWrite('> $wordsTypes = ' & $wordsTyped & @TAB & '$elpasedTime = ' & $elapsedTime & @CRLF)

	If $wpm > 0 then ; don't update if they haven't completed any sentences yet
		GUICtrlSetData($lblWPMInter, $wpm & ' WPM')
	EndIf
EndFunc

Func _GenerateSentence()
	$max = Round((UBound($sentenceArray) - 1) * $interDiff)
	ConsoleWrite('+> $max = ' & $max & @CRLF)

;~ 	_ArrayDisplay($sentenceArray)
	Do

		$new = $sentenceArray[Random(0, $max)]
	Until $new <> $currentSentence

;~ 	$new = 'This is a really long sentence and maybe nobody will every type it but me.'

	$currentSentence = $new
	Return $currentSentence
EndFunc

Func _NewSentence()

	_GenerateSentence()
	GUICtrlSetData($lblDisplayInter, $currentSentence)

	GUICtrlSetData($txtInputInter, '')
EndFunc

Func _EditInterChanged()
	$input = GUICtrlRead($txtInputInter)
	If StringLen($input) = 0 Then Return

	$expected = GUICtrlRead($lblDisplayInter)

	If StringLen($expected) <> StringLen($input) Then Return ; shouldn't be able to get longer but just in case (e.g. pasting or mashing)

	$words = StringSplit($input, ' ')
	$wordsTyped += $words[0]

	If StringCompare($input, $expected, 1) = 0 Then
		_RightAnswerInter()
	Else
		_WrongAnswerInter()
	EndIf
EndFunc


Func _WrongAnswerInter()
	; ConsoleWrite('!> WRONG' & @CRLF)
	$correctCount = 0

	GUICtrlSetBkColor($lblResultInter, 0xFF0000)
;~ 	_ArrayAdd($accuracyRecord, False)
	AdlibRegister('_TimerEndWrongInter', $displayTime)
EndFunc   ;==>_WrongAnswer

Func _RightAnswerInter()
	; ConsoleWrite('+> RIGHT' & @CRLF)
	$correctCount = $correctCount + 1
;~ 	If $correctCount > 8 Then
;~ 		$difficulty = _Min($difficulty + 1, $MAX_DIFFICULTY)
;~ 		$correctCount = 0
;~ 	EndIf
	$interCorrect += 1
	If $interCorrect > 5 then ;5?
		$interDiff = $interDiff + 0.1

;~ 		ConsoleWrite('--> INCRESASING DIFF TO ' & $interDiff & @CRLF)
		If $interDiff > 1 then $interDiff = 1
		$interCorrect = 0
	EndIf


	GUICtrlSetBkColor($lblResultInter, 0x00FF00)
;~ 	_ArrayAdd($accuracyRecord, True)
	AdlibRegister('_TimerEndRightInter', $displayTime - ($difficulty * 80))
EndFunc   ;==>_RightAnswer

Func _TimerEndWrongInter()
	AdlibUnRegister('_TimerEndWrongInter')

	GUICtrlSetBkColor($lblResultInter, $GUI_BKCOLOR_TRANSPARENT)

	GUICtrlSetData($txtInputInter, '')
EndFunc   ;==>_TimerEndWrong

Func _TimerEndRightInter()
	AdlibUnRegister('_TimerEndRightInter')

	GUICtrlSetBkColor($lblResultInter, $GUI_BKCOLOR_TRANSPARENT)

	_NewSentence()
EndFunc   ;==>_TimerEndRight
