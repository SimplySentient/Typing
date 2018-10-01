#include-once
#include <Array.au3>
#include <AutoItConstants.au3>
#include <WindowsConstants.au3>


Global $mainGUI

Global $GUI_INIT_WIDTH = 1000, $GUI_INIT_HEIGHT = 680



Global $DATA_DIR = @AppDataDir & '\Typing'
If Not FileExists($DATA_DIR) then DirCreate($DATA_DIR)

Global $DATA_INI = $DATA_DIR & '\Settings.ini'

Global Const $GUI_BK_COLOR = 0xFFFFFF, $GUI_FONT_SIZE = 12, $GUI_PANEL_COLOR = 15987697


Global Const $CHILD_WINDOW_Y_OFFSET = 50

; controls that need global references - Could be done differently to avoid this
Global $txtInputBeginner, $txtInputInter
;game
Global $txtGameInput

Global $childWindows[0]

Global $leavePageEvents[0][2]
Global $enterPageEvents[0][2]


Func _CreateChildWindow()
	$gui = GUICreate('', $GUI_INIT_WIDTH, $GUI_INIT_HEIGHT, 0, $CHILD_WINDOW_Y_OFFSET, $WS_CHILD, -1, $mainGUI)

	_ArrayAdd($childWindows, $gui)

	Return $gui
EndFunc


Func _AddLeavePageEvent($gui, $funcName)
;~ 	If WinExists($gui) then ConsoleWrite('! WINNER WINNER' & @CRLF)

	_ArrayAdd($leavePageEvents, $gui & '|' & $funcName)

;~ 	_ArrayDisplay($leavePageEvents)

EndFunc

Func _LeavePageEvent()
	For $i = 0 to UBound($leavePageEvents) - 1

		ConsoleWrite('> state = ' & WinGetState(Hwnd($leavePageEvents[$i][0])) & @CRLF)
		If BitAND(WinGetState(HWnd($leavePageEvents[$i][0])), 2) then ;$WIN_STATE_VISIBLE then ; 4 is enabled.. not sure why visible isn't working
			ConsoleWrite('> Window is visible, calling: ' & $leavePageEvents[$i][1] & @CRLF)

			Call($leavePageEvents[$i][1])
		EndIf

	Next

EndFunc

Func _AddEnterPageEvent($gui, $funcName)
	_ArrayAdd($enterPageEvents, $gui & '|' & $funcName)

EndFunc

Func _EnterPageEvent($gui)
	For $i = 0 to UBound($enterPageEvents) - 1
		If $enterPageEvents[$i][0] = $gui then
			Call($enterPageEvents[$i][1])
		EndIf

	Next


EndFunc




