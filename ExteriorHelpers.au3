#include <Array.au3>

HotKeySet('`', '_Func')
HotKeySet('{ESC}', '_Esc')


While 1
	Sleep(10)
WEnd

Func _Func()

	$data = ClipGet()


	$array = StringSplit($data, @LF, 2) ; 2 = 0 based array

;~ 	_ArrayDisplay($array)


	$long = 'sdjfkdjfkdjfkdfjdkfjdkfjdkfjdkfdkjfslkdfjlsdkfjsdlfjsldkjflsdjflsdjkfjslkdjflsdjflksdjflkjsdlkfjsdlkfjjjdkjfkdjfkdjfkdjfkdjfkdjfkdjfkdjfkjdkfjdkfjkdjfdf'
	$shortest = $long

	$switchIndex = -1

	For $i = 0 to UBound($array) - 1
		For $j = $i to UBound($array) - 1
			If StringLen($array[$j]) < StringLen($shortest) then
				$shortest = $array[$j]
				$switchIndex = $j
			EndIf
		Next

		ConsoleWrite('> $i = ' & $i & @TAB & '$shortest = ' & $shortest & @TAB & '$switchIndex = ' & $switchIndex & @CRLF)

		$array[$switchIndex] = $array[$i]
		$array[$i] = $shortest

		$shortest = $long
	Next


	_ArrayDisplay($array)

	_ArrayToClip($array, @CRLF)

EndFunc


Func _Esc()
	Exit
EndFunc