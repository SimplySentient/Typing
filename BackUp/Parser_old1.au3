#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <GUIListView.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>

$gui = GUICreate('Parser', 400, 800)

$txtCanContain = GUICtrlCreateInput('asdfjk;l', 10, 10, 130, 25)
$txtMustContain = GUICtrlCreateInput('', 150, 10, 150, 25)

$btnAnalyze = GUICtrlCreateButton('Go', 400 - 50, 10, 40, 25)

$lstResults = GUICtrlCreateListView('', 10, 45, 380, 400, $LVS_REPORT, BitOr($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES, $WS_EX_CLIENTEDGE))
   _GUICtrlListView_AddColumn($lstResults, 'Results', 360)

$btnCreateText = GUICtrlCreateButton('Convert Checked to Text', 10, 455, 380, 25)


$txtResults = GUICtrlCreateEdit('', 10, 490, 380, 180)

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

   For $i = 0 to _GUICtrlListView_GetItemCount($lstResults) - 1
	  If _GUICtrlListView_GetItemChecked($lstResults, $i) then
		 $text = $text & StringLower(_GUICtrlListView_GetItemText($lstResults, $i)) & @CRLF
	  EndIf


   Next

   GUICtrlSetData($txtResults, $text)


EndFunc


Func _Analyze()
   GUISetCursor(1, 1)

   $file = FileOpen(@ScriptDir & '\words.txt')

   $line = FileReadLine($file)

   $canContain = GUICtrlRead($txtCanContain)
   $mustContain = GUICtrlRead($txtMustContain)
   $mustArray = StringSplit($mustContain, '')

   $canContain = $canContain & $mustContain

   Global $levelArray[0]

   While @error = 0

	 ; ConsoleWrite('> $line = ' & $line & @CRLF)

	  $split = StringSplit($line, '')

	  $include = True
	  For $i = 1 to $split[0]
		 If StringInStr($canCOntain, $split[$i]) = 0 then
			$include = False
		 EndIf
	  Next

	  If $include and $mustArray[0] > 0 then ; passed first check, check that must letters are in
		 $containsOneOfMust = false
		 For $i = 1 to $mustArray[0]
			If StringInStr($line, $mustArray[$i]) > 0 then
			   $containsOneOfMust = true
			EndIf
		 Next

		 $include = $containsOneOfMust
	  EndIf

	  If $include then _ArrayAdd($levelArray, $line)

	  $line = FileReadLine($file)

   WEnd

;~    _ArrayDisplay($levelArray)

   _GUICtrlListView_BeginUpdate($lstResults)
   _GUICtrlListView_DeleteAllItems($lstResults)
   For $i = 0 to UBound($levelArray) - 1
	  _GUICtrlListView_AddItem($lstResults, $levelArray[$i])
   Next
   _GUICtrlListView_EndUpdate($lstResults)



   FileClose($file)

   GUISetCursor(2, 0)
EndFunc