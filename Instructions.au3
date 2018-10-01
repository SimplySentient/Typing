


Global $instructionData[3][2] = [['placement.jpg', 'When typing your fingers should be placed as shown in the picture above. Your left ' & _
		'index finger should be resting on F and your right on J. Let your hands be relaxed and comfortable. Your palms should be resting on a flat surface.'], _
		['ergonomics.jpg', 'The goal of typing is to be able to type all the letters without looking at the keyboard. This allows you to keep ' & _
		'your eyes free to focus on the computer screen. To do this you must memorize where the keys are and avoid looking at the keyboard. ' & _
		'You may be tempted to look down at your keyboard if you forget where a key is but instead of looking take a moment to think and see if you can recall where the key is.'], _
		['', 'Once you have learned the entire alphabet you can move on to typing sentances. For sentances use either of your thumbs to press the ' & _
		'the spacebar key. To make a capital letter hold down shift with either your left or right pinky and then press the letter you want.'] _
		]

Global $currentInstructionStep = 0


Global $picImage, $lblText, $btnNext, $btnPrevious, $btnGoToBeginner


Func _CreateInstructionPage($exitFunction) ;$width, $height, $parent)
	$gui = _CreateChildWindow() ; GUICreate('', $width, $height, 0, 50, $WS_CHILD, -1, $parent)
		GUISetBkColor($GUI_BK_COLOR)
		GUISetFont($GUI_FONT_SIZE)

	$imageHBorder = 100
	$imageHeight = 496 / 800 * ($GUI_INIT_WIDTH - $imageHBorder * 2) * 0.7 ; image is 1100 x 777, scaled dcown a bit due to monitors with low resolution

	$picImage = GUICtrlCreatePic('', $imageHBorder, 0, $GUI_INIT_WIDTH - $imageHBorder * 2, $imageHeight)
		GUICtrlSetResizing(-1, BitOR($GUI_DOCKHCENTER, $GUI_DOCKSIZE))

	$lblText = GUICtrlCreateLabel('', 50, $imageHeight + 20, $GUI_INIT_WIDTH - 100, 120, $SS_CENTER)
		GUICtrlSetFont(-1, 14)

	$btnPrevious = GUICtrlCreateButton('Previous', $GUI_INIT_WIDTH / 2 - 110, $imageHeight + 140, 100, 30)
		GUICtrlSetState(-1, $GUI_DISABLE)
		GUICtrlSetOnEvent(-1, '_PreviousInstruction')

	$btnNext = GUICtrlCreateButton('Next', $GUI_INIT_WIDTH / 2 + 10, $imageHeight + 140, 100, 30)
		GUICtrlSetOnEvent(-1, '_NextInstruction')


	$btnGoToBeginner = GUICtrlCreateButton('Go To Beginner', $GUI_INIT_WIDTH / 2 - 110, $imageHeight + 180, 226, 30)
		GUICtrlSetOnEvent(-1, $exitFunction)
		GUICtrlSetState(-1, $GUI_HIDE)

	_ShowCurrentInstruction()


	GUISetState(@SW_HIDE, $gui)

	Return $gui
EndFunc

;~ Func _GoToBeginner()



;~ EndFunc

Func _PreviousInstruction()

	$currentInstructionStep = $currentInstructionStep - 1

	_ShowCurrentInstruction()

EndFunc


Func _NextInstruction()
	$currentInstructionStep = $currentInstructionStep + 1

	_ShowCurrentInstruction()

EndFunc

Func _ShowCurrentInstruction()

	$pic = $DATA_DIR & '\' & $instructionData[$currentInstructionStep][0]
	If $instructionData[$currentInstructionStep][0] <> '' then
		GUICtrlSetImage($picImage, $pic)
;~ 		ConsoleWrite('> ' & $pic & @CRLF)
	Else
		GUICtrlSetImage($picImage, '')
	EndIf
	GUICtrlSetData($lblText, $instructionData[$currentInstructionStep][1])

	If $currentInstructionStep > 0 then
		GUICtrlSetState($btnPrevious, $GUI_ENABLE)
	Else
		GUICtrlSetState($btnPrevious, $GUI_DISABLE)
	EndIf

	If $currentInstructionStep < UBound($instructionData) - 1 then
		GUICtrlSetState($btnNext, $GUI_ENABLE)
		GUICtrlSetState($btnGoToBeginner, $GUI_HIDE)
	Else
		GUICtrlSetState($btnNext, $GUI_DISABLE)
		GUICtrlSetState($btnGoToBeginner, $GUI_SHOW)
	EndIf

EndFunc