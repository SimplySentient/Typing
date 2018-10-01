#include <Array.au3>

HotKeySet('`', '_Select')
HotKeySet('{ESC}', '_Exit')

HotKeySet('^`', '_Sort')

ConsoleWrite(@CRLF)

While 1
	Sleep(10)
WENd


Func _Select()
	Send('{HOME}')
	Sleep(10)
	Send('{SHIFTDOWN}{END}{SHIFTUP}')
	Sleep(10)
	Send('^c')
	ConsoleWrite(ClipGet() & @CRLF)
EndFunc

Func _Exit()
	Exit
EndFunc


Func _Sort()


	Send('^a')
	Sleep(10)

	Send('^c')

	$text = ClipGet()

	$array = StringSplit($text, @LF)

;~ 	_ArrayDisplay($array, 'After split')

	For $i = $array[0] to 1 Step -1
		If StringStripWS($array[$i], 8) = '' then
			_ArrayDelete($array, $i)
		EndIf
	Next

	_ArraySort($array, 0, 1)

;~ 	_ArrayDisplay($array, 'After sort')


	$word = ''
	For $i = UBound($array) - 1 to 1 Step -1
		If $array[$i] = $word then
;~ 			ConsoleWrite('! ' & $array[$i] & ' = ' & $word & @CRLF)
			_ArrayDelete($array, $i)
		Else

;~ 			ConsoleWrite('> ' & $array[$i] & ' != ' & $word & @CRLF)
			$word = $array[$i]
		EndIf

	Next



	$text = ''

	For $i = 1 to UBound($array) - 1
		$text = $text & $array[$i] & @CRLF
	Next

	ClipPut($text)

	Send('^v')
EndFunc