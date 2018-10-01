#include <GuiConstants.au3>
#include <windowsconstants.au3>

Const $SM_CXFIXEDFRAME = 7
;~ Global Const $WM_ENTERSIZEMOVE = 0x231,$WM_EXITSIZEMOVE = 0x232
Global $guiWid = 500, $Guiht = 500
;~ Global Const $WS_EX_COMPOSITED = 0x2000000
$Main_GUI = GUICreate("Main", 500, 500, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_MAXIMIZEBOX, $WS_CLIPSIBLINGS),$WS_EX_COMPOSITED);, $WS_EX_LAYERED);$WS_POPUP + $WS_SYSMENU + $WS_MINIMIZEBOX
;$gamegui = GUICreate("QBC", 1280, 1024, -1, -1, $WS_POPUP + $WS_SYSMENU + $WS_MINIMIZEBOX, $WS_EX_LAYERED)
GUISetBkColor(0xfffaf0, $Main_GUI)
GUISetState(@SW_SHOW, $Main_GUI)
$Btn_Exit = GUICtrlCreateButton("E&xit", 10, 10, 90, 20)
GUICtrlSetResizing(-1,BitOr($Gui_DOCKTOP,$GUI_DOCKLEFT,$GUI_DOCKWIDTH,$GUI_DOCKHEIGHT))

$wtitle = DllCall('user32.dll', 'int', 'GetSystemMetrics', 'int', $SM_CYCAPTION)
$wtitle = $wtitle[0]
$wside = DllCall('user32.dll', 'int', 'GetSystemMetrics', 'int', $SM_CXFIXEDFRAME)
$wside = $wside[0]
$childHt = ($GuiHt - 50)/2 - $wtitle - 2* $wside
$childWid = $GuiWid/2 - 2 * $wside

$Child1_GUI = GUICreate("Child1",$childWid, $childHt, 0, 50, BitOR($WS_CHILD, 0));,$WS_EX_LAYERED)
GUISetBkColor(0, $Child1_GUI)
$Btn_Test = GUICtrlCreateButton("Test", 10, 10, 90, 20)
DllCall("user32.dll", "int", "SetParent", "hwnd", WinGetHandle($Child1_GUI), "hwnd", WinGetHandle($Main_GUI))
GUISetState(@SW_SHOW, $Child1_GUI)

$Child2_GUI = GUICreate("Child2", $childWid, $childHt, $GuiWid/2, 50);, $WS_POPUP)
GUISetBkColor(0x0ff0000, $Child2_GUI)
GUISetState($Child2_GUI)
DllCall("user32.dll", "int", "SetParent", "hwnd", WinGetHandle($Child2_GUI), "hwnd", WinGetHandle($Main_GUI))
GUISetState(@SW_SHOW, $Child2_GUI)

$Child3_GUI = GUICreate("Child3", $childWid, $childHt, 0, 50 + $childHt + 2*$wside + $wtitle, $WS_CAPTION);,$WS_EX_LAYERED)
GUISetBkColor(0x00ff00, $Child3_GUI)
DllCall("user32.dll", "int", "SetParent", "hwnd", WinGetHandle($Child3_GUI), "hwnd", WinGetHandle($Main_GUI))
GUISetState(@SW_SHOW, $Child3_GUI)

$Child4_GUI = GUICreate("Child4", $childWid, $childHt, $GuiWid/2, 50 +$childHt + 2*$wside + $wtitle);, $WS_POPUP)
GUISetBkColor(0x00000ff, $Child4_GUI)
DllCall("user32.dll", "int", "SetParent", "hwnd", WinGetHandle($Child4_GUI), "hwnd", WinGetHandle($Main_GUI))
GUISetState(@SW_SHOW, $Child4_GUI)

GuiSwitch($Main_GUI)
GUIRegisterMsg($WM_SIZE, "SetChildrenToBed")
;GUIRegisterMsg($WM_ENTERSIZEMOVE,"ensm")
;GUIRegisterMsg($WM_EXITSIZEMOVE,"exsm")
Opt("mousecoordmode", 2)
$winact = ''

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE, $Btn_Exit
            Exit
        Case $Btn_Test
            MsgBox(0, "Test", "Hit Button on Child Window")
    EndSwitch


WEnd

Func SetChildrenToBed($hWnd,$iMsg,$wparam,$lparam)
    Local $clientHt = BitAnd($lparam,0xffff)
    Local $clientWid = BitShift($lparam,16)
    WinMove($Child1_GUI,"",0,50,$clientHt/2,($clientWid-50)/2)
    WinMove($Child2_GUI,"",$clientHt/2,50,$clientHt/2,($clientWid-50)/2)
    WinMove($Child3_GUI,"",0,50 + ($clientWid-50)/2,$clientHt/2,($clientWid-50)/2)
    WinMove($Child4_GUI,"",$clientHt/2,50 + ($clientWid-50)/2,$clientHt/2,($clientWid-50)/2)
EndFunc
Func ensm()
GUISetStyle( BitOR($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_MAXIMIZEBOX, $WS_CLIPSIBLINGS),$WS_EX_COMPOSITED,$Main_GUI)
EndFunc
func exsm()
    GUISetStyle( BitOR($GUI_SS_DEFAULT_GUI, $WS_SIZEBOX, $WS_MAXIMIZEBOX, $WS_CLIPSIBLINGS),-1,$Main_GUI)
EndFunc