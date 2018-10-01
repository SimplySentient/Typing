#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <Math.au3>



Opt('GUIOnEventMode', 1)

HotKeySet('{ESC}', '_Exit')
HotKeySet('^!q', '_Debug')


Global Const $LETTERS[28] = ['a', 's', 'd', 'f', 'j', 'k', 'l', ';', _ ; 0
						  'g', 'h', 'e', 'i', 'r', 'u', 'w', 'o', _  ; 1 .. 2
						  'q', 'p', 't', 'y', 'v', 'm', 'b', 'n', _ ; 3 .. 4
						  'x', 'z', ',', '.'] ; 5
Global Const $LEVEL_LIMITS[6] = [7, 11, 15, 19, 23, 27]

Global $level = 0

Global $difficulty = 1; 1: 1 letter, 2: 2 letters, 3: 3 letters, 4: words or gibberish?
Global Const $MAX_DIFFICULTY = 4

Global $keystrokeCount = 0; ; used for performance monitoring
Global $correctCount = 0;

Global $lastPhrase = '' ; avoid repeats

Global $displayTime = 500

Global $wordLists[5] ; array of arrays
;~ ; asdf jkl;
;~ Global Const $WORDS_LVL_0[15] = ['sad', 'dad', 'lad', 'lass', 'fad', 'ask', 'add', 'all', 'asks', 'fads', 'fall', _;
;~ 							    'sass', 'flask', 'flasks', 'salsa']

;~ ; + gh ei
;~ Global Const $WORDS_LVL_1[60] = ['jade', 'kill', 'seed', 'dead', 'deed', 'ladle', 'aid', 'leeks', 'ill', 'idle', 'fiddle', 'feed', 'seek', _ ; 13
;~ 							    'flash', 'dash', 'had', 'gal', 'gag', 'ash', 'flag', 'glad', 'saga', 'flags', 'ahead', 'age', 'eagle', _  ; 13
;~ 								'ease', 'eased', 'edge', 'edges', 'eel', 'eels', 'egg', 'eggs', 'fake', 'fed', 'field', 'fields', 'flea', _ ; 13
;~ 								'flesh', 'gas', 'gash', 'geek', 'geese', 'he', 'head', 'heed', 'hedge', 'lake', 'lakes', 'leash', 'legal', _ ; 13
;~ 								'sea', 'seals', 'shake', 'self', 'seek', 'sleek', 'sledge', 'glass'] ; 8
;~ ; + ru wo
;~ ;Global Const $WORDS_LVL_2[?] = ['ajar', 'ark', 'dark', 'drag', 'grass', 'hard', 'harsh', 'rags', 'rash', 'shard', 'shark', 'flaw', _
;~ ;							    'hawk', 'jaw', 'jaws', 'saw', 'saws', 'walk', 'walks', 'wall', 'was', 'wash', 'dual', 'dug', 'dull', _
;~ ;								'dusk', 'fluff', 'flush', 'full', 'fuss', 'gull', 'haul', 'hug', 'hugs', 'husk', 'laugh', 'skull', _
;~ ;								'slug', 'slush', 'us', 'usual',
;~ ;

Global $lblDisplay, $txtInput, $lblResult
Global $menuBasicDiff

_LoadWordLists()

_CreateGUI()


While 1
   Sleep(20)

WEnd

Func _LoadWordLists()
	For $i = 0 to 4

		$temp = FileReadToArray(@ScriptDir & '\level' & $i & '.txt')


		$wordLists[$i] = $temp

	Next

;~ 	For $i = 0 to 4
;~ 		_ArrayDisplay($wordLists[$i], $i)
;~ 	Next


EndFunc

Func _Debug()
	$difficulty = 4
EndFunc

Func _GenerateText()

   If $difficulty = 4 then

		$list = $wordLists[$level]
		$result = $list[Random(0, UBound($list) - 1, 1)]

   Else

	  $limit = $LEVEL_LIMITS[$level]

	  $result = ''

	  For $i = 1 to $difficulty
		 $result = $result & $LETTERS[Random(0, $limit, 1)]
	  Next
   EndIf

   ;ConsoleWrite('> $result = ' & $result & ' = $lastPhrase = ' & $lastPhrase & @CRLF)

   If $result = $lastPhrase then
	  Return _GenerateText()

   EndIf

   $lastPhrase = $result
   Return $result
EndFunc

Func _CreateGUI()
   Local Const $DIFF_TEXT[6] = ['Basic home row' & @TAB & 'asdfjk;l', 'Full home row + ei' & @TAB & '+ghei', _
							    'Full home row + ei + ruwo' & @TAB & '+ruwo', 'All mid and top rows' & @TAB & '+qpty', _
								'Mid, top, + vmbn' & @TAB & '+vmbn', 'All' & @TAB & '+zx,.']



   $gui = GUICreate('Typing', 800, 400)
	  GUISetBkColor(0xFFFFFF, $gui)
   GUISetOnEvent($GUI_EVENT_CLOSE, '_Exit')

   $menuLvl = GUICtrlCreateMenu('Level')


   For $i = 0 to UBound($DIFF_TEXT) - 1

	  $temp = GUICtrlCreateMenuItem($DIFF_TEXT[$i], $menuLvl, -1, 1)
		 If $i = 0 then
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


EndFunc

Func _ChangeDifficulty()
   ;ConsoleWrite('+> @GUI_CtrlID = ' & @GUI_CtrlID & @CRLF)

   $level = @GUI_CtrlID - $menuBasicDiff
   $difficulty = 1
   $correctCount = 0

   _InitiateText()
   ;ConsoleWrite('$level = ' & $level)


EndFunc

Func _ResetLength()
   $difficulty = 1
   $correctCount = 0
   _InitiateText()
EndFunc

Func _InitiateText()

   GUICtrlSetData($lblDisplay, _GenerateText())

   GUICtrlSetData($txtInput, '')
EndFunc


Func _EditTextChanged()

   $input = GUICtrlRead($txtInput)
   If StringLen($input) = 0 then Return

   $expected = GUICtrlRead($lblDisplay)


   If StringLen($expected) <> StringLen($input) then Return ; shouldn't be able to get longer but just in case (e.g. pasting)

   ; determine if the correct key was hit
   If $input = $expected then ;StringLeft($expected, StringLen($input)) Then
	  _RightAnswer()

   Else
	  _WrongAnswer()
   EndIf

;~    If $input = $expected then
;~ 	  _InitiateText()
;~    EndIf

EndFunc

Func _WrongAnswer()
   ; ConsoleWrite('!> WRONG' & @CRLF)
   $correctCount = 0

   ;GUI_BKCOLOR_TRANSPARENT

   GUICtrlSetBkColor($lblResult, 0xFF0000)
   AdlibRegister('_TimerEndWrong', $displayTime)
EndFunc

Func _RightAnswer()
  ; ConsoleWrite('+> RIGHT' & @CRLF)
   $correctCount = $correctCount + 1
   If $correctCount > 10 then
	  $difficulty = _Min($difficulty + 1, $MAX_DIFFICULTY)
	  $correctCount = 0
   EndIf

   GUICtrlSetBkColor($lblResult, 0x00FF00)
   AdlibRegister('_TimerEndRight', $displayTime - ($difficulty * 80))
EndFunc

Func _TimerEndWrong()
   AdlibUnRegister('_TimerEndWrong')

   GUICtrlSetBkColor($lblResult, $GUI_BKCOLOR_TRANSPARENT)

   GUICtrlSetData($txtInput, '')
EndFunc

Func _TimerEndRight()
   AdlibUnRegister('_TimerEndRight')

   GUICtrlSetBkColor($lblResult, $GUI_BKCOLOR_TRANSPARENT)

   _InitiateText()
EndFunc

;~ Func _EditTextChanged()

;~    $input = GUICtrlRead($txtInput)
;~    If StringLen($input) = 0 then Return

;~    $expected = GUICtrlRead($lblDisplay)

;~    ; determine if the correct key was hit
;~    If $input = StringLeft($expected, StringLen($input)) Then
;~ 	 ; ConsoleWrite('+> RIGHT' & @CRLF)
;~ 	  $correctCount = $correctCount + 1
;~ 	  If $correctCount > $difficulty * 10 then
;~ 		 $difficulty = _Min($difficulty + 1, $MAX_DIFFICULTY)
;~ 		 $correctCount = 0
;~ 	  EndIf
;~    Else
;~ 	 ; ConsoleWrite('!> WRONG' & @CRLF)
;~ 	 $correctCount = 0
;~    EndIf

;~    If $input = $expected then
;~ 	  _InitiateText()
;~    EndIf

;~ EndFunc

Func _CommandMsg($hWnd, $msg, $wParam, $lParam)

   ;ConsoleWrite('+> $wParam = ' & $wParam & @TAB & '$lParam = ' & $msg & @CRLF)

   $idFrom = BitAnd($wParam, 0x0000FFFF)
   $iCode = BitShift($wParam, 16)

   Switch $idFrom
	  Case $txtInput
		 Switch $iCode
			Case $EN_UPDATE
			   _EditTextChanged()
		 EndSwitch


   EndSwitch




EndFunc

Func _Exit()
   Exit
EndFunc