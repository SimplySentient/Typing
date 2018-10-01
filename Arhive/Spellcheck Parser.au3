#include <File.au3>

HotKeySet('{ESC}', '_Exit')
HotKeySet('`', '_Test')

ConsoleWrite(@CRLF)

While 1
	Sleep(10)
WEnd


Func _Exit()
	Exit
EndFunc

Func _Test()

	Local $array[0]


	_FileReadToArray(@ScriptDir & '\dump-level4.txt', $array)

	ConsoleWrite('+> Ubound = ' & UBound($array) & @CRLF)


	; 3 is up to 15000 - had some y words next to h for some reason

	For $i = 1 to 3000

		_TestWord($array[$i])
	Next


EndFunc


Func _TestWord($word)
	Send('^a')
;~ 	Send('{DEL}')
	Send($word)
;~ 	ClipPut($word)
;~ 	Sleep(10)
;~ 	Send('^v')

	Send('{UP}') ; get to start of document

	Send('{F7}')
	Sleep(100)

	$pass = _IsValidWord()


	If $pass then
		ConsoleWrite($word & @CRLF)
		Send('{ENTER}')
	Else
		Send('!o') ; close spell check
	EndIf


EndFunc



Func _IsValidWord()
	$title = WinGetTitle('')

;~ 	ConsoleWrite('+> $title = ' & $title & @CRLF)

	Return $title <> 'Spelling: English (UK)'

EndFunc