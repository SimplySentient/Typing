#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <GUIListView.au3>
#include <ListViewConstants.au3>
#include <File.au3>
#include <WindowsConstants.au3>

HotKeySet('!^q', '_LoadFromDump')

$gui = GUICreate('Parser', 400, 800)

$txtCanContain = GUICtrlCreateInput('asdfjk;l', 10, 10, 130, 25)
$txtMustContain = GUICtrlCreateInput('', 150, 10, 80, 25)

$txtNotContain = GUICtrlCreateInput('', 240, 10, 80, 25)


$btnAnalyze = GUICtrlCreateButton('Go', 400 - 50, 10, 40, 25)

$lstResults = GUICtrlCreateListView('', 10, 45, 380, 400, $LVS_REPORT, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES, $WS_EX_CLIENTEDGE))
_GUICtrlListView_AddColumn($lstResults, 'Results', 360)

$btnCreateText = GUICtrlCreateButton('Convert Checked to Text', 10, 455, 380, 25)


$txtResults = GUICtrlCreateEdit('', 10, 490, 380, 180)


$prgProgres = GUICtrlCreateProgress(10, 700, 380, 25)

GUISetState(@SW_SHOW)

While 1
	$msg = GUIGetMsg()

	Switch $msg
		Case $btnAnalyze
			_Analyze()

		Case $btnCreateText
			_CreateText()

		Case $GUI_EVENT_CLOSE
			Exit


	EndSwitch

WEnd

Func _CreateText()

	$text = ''

	For $i = 0 To _GUICtrlListView_GetItemCount($lstResults) - 1
		If _GUICtrlListView_GetItemChecked($lstResults, $i) Then
			$text = $text & StringLower(_GUICtrlListView_GetItemText($lstResults, $i)) & @CRLF
		EndIf


	Next

	GUICtrlSetData($txtResults, $text)


EndFunc   ;==>_CreateText

Func _LoadFromDump()
	Local $array[0]

	_FileReadToArray(@ScriptDir & '\dump.txt', $array)

	_GUICtrlListView_BeginUpdate($lstResults)
	_GUICtrlListView_DeleteAllItems($lstResults)
	For $i = 0 To UBound($array) - 1
		_GUICtrlListView_AddItem($lstResults, $array[$i])
	Next
	_GUICtrlListView_EndUpdate($lstResults)

EndFunc


Func _Analyze()
	GUISetCursor(1, 1)

	$totalLines = _FileCountLines(@ScriptDir & '\words.txt')
	$step = 0
	$currentLine = 0

	$file = FileOpen(@ScriptDir & '\words.txt')

	$line = FileReadLine($file)

	$canContain = GUICtrlRead($txtCanContain)
	$mustContain = GUICtrlRead($txtMustContain)
	$mustArray = StringSplit($mustContain, '')
	$notContain = GUICtrlRead($txtNotContain)
	$notArray = StringSplit($notContain, '')

	$canContain = $canContain & $mustContain

	Global $levelArray[9999999]

	ConsoleWrite('+> $totalLines = ' & $totalLines & @CRLF)

	$currentIndex = 0


	While @error = 0

		; ConsoleWrite('> $line = ' & $line & @CRLF)
		$include = True

		If $notArray[0] > 0 then ; check that it doesn't contain any exluded letters
			$containsContraband = False
			For $I = 1 to $notArray[0]
				If StringInStr($line, $notArray[$i]) > 0 Then
					$containsContraband = True
					ExitLoop
				EndIf
			Next

			$include = Not $containsContraband
		EndIf

		If $include and $mustArray[0] > 0 Then ; check that must letters are in
			$containsOneOfMust = False
			For $i = 1 To $mustArray[0]
				If StringInStr($line, $mustArray[$i]) > 0 Then
					$containsOneOfMust = True
					ExitLoop
				EndIf
			Next

			$include = $containsOneOfMust
		EndIf

		$split = StringSplit($line, '')
		If $include then
			For $i = 1 To $split[0]
				If StringInStr($canContain, $split[$i]) = 0 Then
					$include = False
					ExitLoop
				EndIf
			Next
		EndIf

		If $include Then
;~ 			_ArrayAdd($levelArray, $line)
			$levelArray[$currentIndex] = $line
			$currentIndex += 1

			ConsoleWrite('> $currentLine = ' & $currentLine & ', ' & $line & @CRLF)

		EndiF

		If Round($currentLine / $totalLines * 100) <> $step then
			$step = Round($currentLine / $totalLines * 100)
			GUICtrlSetData($prgProgres, $step)

		EndIf

		$line = FileReadLine($file)
		If @error then ExitLoop


		$currentLine += 1

	WEnd

	Redim $levelArray[$currentIndex]

;~    _ArrayDisplay($levelArray)

	_GUICtrlListView_BeginUpdate($lstResults)
	_GUICtrlListView_DeleteAllItems($lstResults)
	For $i = 0 To UBound($levelArray) - 1
		_GUICtrlListView_AddItem($lstResults, $levelArray[$i])
	Next
	_GUICtrlListView_EndUpdate($lstResults)

	_FileWriteFromArray(@ScriptDir & '\dump.txt', $levelArray)

	FileClose($file)

	GUISetCursor(2, 0)
EndFunc   ;==>_Analyze
