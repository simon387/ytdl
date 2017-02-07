#cs
   interfaccia grafica di youtube-dl
#ce

#NoTrayIcon
;~ #include <ButtonConstants.au3>
;~ #include <EditConstants.au3>
;~ Global Const $ES_AUTOVSCROLL = 64
;~ Global Const $ES_AUTOHSCROLL = 128
;~ Global Const $ES_READONLY = 2048
;~ #include <GUIConstantsEx.au3>
;~ Global Const $GUI_EVENT_CLOSE = -3
;~ #include <StaticConstants.au3>
;~ Global Const $GUI_ENABLE = 64
;~ Global Const $GUI_DISABLE = 128
;~ #include <WindowsConstants.au3>
;~ Global Const $WS_HSCROLL = 0x00100000
;~ Global Const $WS_VSCROLL = 0x00200000
;~ Global Const $WS_CLIPSIBLINGS = 0x04000000
;~ #include <Misc.au3>
Global Const $tagSECURITY_ATTRIBUTES = "dword Length;ptr Descriptor;bool InheritHandle"

_Singleton(@ScriptName)
Global Const $form_main = GUICreate("YTDLUI by simon - v0.11 - {esc} per forzare uscita!", 523, 323, -1, -1, -2133917696, 0);BitOR($GUI_SS_DEFAULT_GUI,$WS_MAXIMIZEBOX,$WS_SIZEBOX,$WS_THICKFRAME,$WS_TABSTOP)
Global Const $input_url = GUICtrlCreateInput("http://www.youtube.com/watch?v=ebXbLfLACGM", 152, 10, 281, 21)
	GUICtrlSetTip(-1, "Incolla qui il link di una pagina di youtube", "Info", 1, 1)
Global Const $button_paste = GUICtrlCreateButton("Incolla", 440, 8, 75, 25)
	GUICtrlSetTip(-1, "Incolla il contenuto degli appunti", "Info", 1, 1)
Global Const $input_dest = GUICtrlCreateInput(@ScriptDir, 152, 42, 281, 21)
	GUICtrlSetTip(-1, "Questa è la destinazione del download", "Info", 1, 1)
Global Const $button_select = GUICtrlCreateButton("Seleziona", 440, 40, 75, 25)
	GUICtrlSetTip(-1, "Cambia la destinazione del download", "Info", 1, 1)
Global Const $button_go = GUICtrlCreateButton("Download video", 8, 288, 123, 25)
	GUICtrlSetTip(-1, "Avvia il download del video", "Info", 1, 1)
Global Const $button_mp3 = GUICtrlCreateButton("Download mp3", 152, 288, 123, 25)
	GUICtrlSetTip(-1, "Avvia il download nel formato mp3", "Info", 1, 1)
Global Const $button_update = GUICtrlCreateButton("Aggiorna", 360, 288, 75, 25)
	GUICtrlSetTip(-1, "Scarica l'ultima versione del modulo YTDL", "Info", 1, 1)
Global Const $button_info = GUICtrlCreateButton("Roba Nerd", 440, 288, 75, 25)
	GUICtrlSetTip(-1, "youtube-dl.exe -h >> output", "NERD!", 2, 1)
Global Const $edit_out = GUICtrlCreateEdit("", 8, 72, 505, 209, 70256832);BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_READONLY,$WS_HSCROLL,$WS_VSCROLL,$WS_CLIPSIBLINGS)
GUICtrlCreateLabel("Cartella di destinazione", 8, 44, 114, 17)
GUICtrlCreateLabel("Link del video da elaborare", 8, 12, 134, 17)
GUISetState(@SW_SHOW)

HotKeySet("{esc}", "close_clicked")
Opt('GUIOnEventMode', 1)
GUISetOnEvent(-3, "close_clicked", $form_main)
GUICtrlSetOnEvent($button_go, "button_clicked")
GUICtrlSetOnEvent($button_mp3, "button_clicked")
GUICtrlSetOnEvent($button_info, "button_clicked")
GUICtrlSetOnEvent($button_update, "button_clicked")
GUICtrlSetOnEvent($button_select, "button_select_clicked")
GUICtrlSetOnEvent($button_paste, "button_paste_clicked")
Global $aAccelKeys[1][2] = [["{enter}", $button_go]]
GUISetAccelerators($aAccelKeys)
Global $iPID = -1
Global $m[2][8] = [[$button_go, $button_mp3, $button_select, $button_info, $button_update, $button_paste, $input_url, $input_dest], _
	[GUICtrlRead($button_go), GUICtrlRead($button_mp3), GUICtrlRead($button_select), GUICtrlRead($button_info), GUICtrlRead($button_update), _
	GUICtrlRead($button_paste), GUICtrlRead($input_url), GUICtrlRead($input_dest)]]

Func button_clicked()
	If checkURL(GUICtrlRead($input_url)) = 0 Then Return
	Local $path = GUICtrlRead($input_dest)
   If FileExists($path) <> 1 And @GUI_CtrlId <> $button_info Then Return
   disabilita()
   FileInstall(".\youtube-dl.exe", @TempDir & "\youtube-dl.exe", 0)
   Local $sOutput = ""
   Local $string_1 = @TempDir & '\youtube-dl.exe -o "' & $path & '\%(title)s-%(id)s.%(ext)s" ' & GUICtrlRead($input_url)
   Local $string_2 = ""
   Select
		Case @GUI_CtrlId = $button_mp3
			FileInstall(".\ffmpeg.exe",  @TempDir & "\ffmpeg.exe",  0)
			FileInstall(".\ffplay.exe",  @TempDir & "\ffplay.exe",  0)
			FileInstall(".\ffprobe.exe", @TempDir & "\ffprobe.exe", 0)
			$string_2 = '-x --audio-quality 0 --audio-format mp3'
		Case @GUI_CtrlId = $button_info
			$string_1 = @TempDir & '\youtube-dl.exe -h'
		Case @GUI_CtrlId = $button_update
			$string_1 = @TempDir & '\youtube-dl.exe -U'
	EndSelect
;~ 	ConsoleWrite($string_1 & ' ' & $string_2 & @CRLF)
   $iPID = Run($string_1 & ' ' & $string_2, @TempDir, @SW_HIDE, 0x2 + 0x4);$STDERR_CHILD + $STDOUT_CHILD)
	GUICtrlSetData($edit_out, '')
   While 1
		$sOutput = StdoutRead($iPID)
		If @error Then ExitLoop
		If $sOutput <> '' Then
			If StringInStr($sOutput, "[download]") > 1 Then
				GUICtrlSetData($edit_out, $sOutput)
			Else
				GUICtrlSetData($edit_out, GUICtrlRead($edit_out) & $sOutput)
			EndIf
		EndIf
		$sOutput = StderrRead($iPID)
		If @error Then ExitLoop
		If $sOutput <> '' Then GUICtrlSetData($edit_out, GUICtrlRead($edit_out) & $sOutput)
		#cs
			$sOutput &= StdoutRead($iPID)
			If @error Then ExitLoop; Exit the loop if the process closes or StdoutRead returns an error.
			If GUICtrlRead($edit_out) <> $sOutput Then GUICtrlSetData($edit_out, StringReplace($sOutput, "[download", @CRLF & "[download"))
			$sOutput &= StderrRead($iPID)
			If @error Then ExitLoop; Exit the loop if the process closes or StdoutRead returns an error.
			If GUICtrlRead($edit_out) <> $sOutput Then GUICtrlSetData($edit_out, StringReplace($sOutput, "[download", @CRLF & "[download"))
			Sleep(250)
		#ce
	WEnd
	abilita()
EndFunc

Func button_paste_clicked()
	GUICtrlSetData($input_url, ClipGet())
EndFunc

Func button_select_clicked()
	Local $temp = FileSelectFolder("Seleziona la cartella di destinazione", "", 7, "", $form_main)
	If $temp <> "" Then GUICtrlSetData($input_dest, $temp)
EndFunc

Func checkURL($string)
	If $string == "" Then
		GUICtrlSetData($edit_out, "URL mancante!")
		Return 0
	EndIf
	Return 1
EndFunc

Func disabilita()
	For $i = 0 To UBound($m, 2) -1
		GUICtrlSetState($m[0][$i], 128)
	Next
	$m[1][6] = GUICtrlRead($input_url)
	$m[1][7] = GUICtrlRead($input_dest)
EndFunc

Func abilita()
	For $i = 0 To UBound($m, 2) -1
		GUICtrlSetState($m[0][$i], 64)
		GUICtrlSetData($m[0][$i], $m[1][$i])
	Next
	$iPID = -1
EndFunc

Func close_clicked()
	If BitAND(WinGetState($form_main), 8) Then
		If ProcessExists($iPID) <> 0 Then
			ProcessClose($iPID)
			GUICtrlSetData($edit_out, '~ interrupt!')
		Else
			Exit
		EndIf
	EndIf
EndFunc

While 1
	Sleep(10000)
WEnd

Func _Singleton($sOccurenceName, $iFlag = 0)
	Local Const $ERROR_ALREADY_EXISTS = 183
	Local Const $SECURITY_DESCRIPTOR_REVISION = 1
	Local $tSecurityAttributes = 0

	If BitAND($iFlag, 2) Then
		; The size of SECURITY_DESCRIPTOR is 20 bytes.  We just
		; need a block of memory the right size, we aren't going to
		; access any members directly so it's not important what
		; the members are, just that the total size is correct.
		Local $tSecurityDescriptor = DllStructCreate("byte;byte;word;ptr[4]")
		; Initialize the security descriptor.
		Local $aRet = DllCall("advapi32.dll", "bool", "InitializeSecurityDescriptor", _
				"struct*", $tSecurityDescriptor, "dword", $SECURITY_DESCRIPTOR_REVISION)
		If @error Then Return SetError(@error, @extended, 0)
		If $aRet[0] Then
			; Add the NULL DACL specifying access to everybody.
			$aRet = DllCall("advapi32.dll", "bool", "SetSecurityDescriptorDacl", _
					"struct*", $tSecurityDescriptor, "bool", 1, "ptr", 0, "bool", 0)
			If @error Then Return SetError(@error, @extended, 0)
			If $aRet[0] Then
				; Create a SECURITY_ATTRIBUTES structure.
				$tSecurityAttributes = DllStructCreate($tagSECURITY_ATTRIBUTES)
				; Assign the members.
				DllStructSetData($tSecurityAttributes, 1, DllStructGetSize($tSecurityAttributes))
				DllStructSetData($tSecurityAttributes, 2, DllStructGetPtr($tSecurityDescriptor))
				DllStructSetData($tSecurityAttributes, 3, 0)
			EndIf
		EndIf
	EndIf

	Local $aHandle = DllCall("kernel32.dll", "handle", "CreateMutexW", "struct*", $tSecurityAttributes, "bool", 1, "wstr", $sOccurenceName)
	If @error Then Return SetError(@error, @extended, 0)
	Local $aLastError = DllCall("kernel32.dll", "dword", "GetLastError")
	If @error Then Return SetError(@error, @extended, 0)
	If $aLastError[0] = $ERROR_ALREADY_EXISTS Then
		If BitAND($iFlag, 1) Then
			DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $aHandle[0])
			If @error Then Return SetError(@error, @extended, 0)
			Return SetError($aLastError[0], $aLastError[0], 0)
		Else
			Exit -1
		EndIf
	EndIf
	Return $aHandle[0]
EndFunc   ;==>_Singleton
#cs
Func button_go_clicked()
;~    ConsoleWrite(' -o "' &  @DesktopDir & '\%(title)s-%(id)s.%(ext)s" ' & GUICtrlRead($input_url) & @CRLF)
;~    Local $pid = ShellExecute(@TempDir & "\youtube-dl.exe", ' -o "' & @DesktopDir & '\%(title)s-%(id)s.%(ext)s" ' & GUICtrlRead($input_url), @TempDir)
    $iPID = Run(@TempDir & '\youtube-dl.exe -o "' & @DesktopDir & '\%(title)s-%(id)s.%(ext)s" ' & GUICtrlRead($input_url), @TempDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
    Local $sOutput = ""
    While 1
        $sOutput &= StdoutRead($iPID)
        If @error Then ExitLoop; Exit the loop if the process closes or StdoutRead returns an error.
        GUICtrlSetData($edit_out, $sOutput)
        $sOutput &= StderrRead($iPID)
        If @error Then ExitLoop; Exit the loop if the process closes or StdoutRead returns an error.
        GUICtrlSetData($edit_out, $sOutput)
        Sleep(250)
    WEnd
EndFunc
Func button_mp3_clicked()
;~    FileInstall ("C:\Documents and Settings\TS_BOT\Desktop\Nuova cartella\ffmpeg.exe", @TempDir & "\ffmpeg.exe", 0)
;~    FileInstall ("C:\Documents and Settings\TS_BOT\Desktop\Nuova cartella\ffplay.exe", @TempDir & "\ffplay.exe", 0)
;~    FileInstall ("C:\Documents and Settings\TS_BOT\Desktop\Nuova cartella\ffprobe.exe", @TempDir & "\ffprobe.exe", 0)
   FileInstall ("F:\SRC\autoit\ytdl\ffmpeg.exe",  @TempDir & "\ffmpeg.exe", 0)
   FileInstall ("F:\SRC\autoit\ytdl\ffplay.exe",  @TempDir & "\ffplay.exe", 0)
   FileInstall ("F:\SRC\autoit\ytdl\ffprobe.exe", @TempDir & "\ffprobe.exe", 0)
   $iPID = ShellExecute(@TempDir & "\youtube-dl.exe", ' -o "' & @DesktopDir & '\%(title)s-%(id)s.%(ext)s" ' & GUICtrlRead($input_url)& " -x --audio-quality 0 --audio-format mp3", @TempDir)
;~     If $pid <> -1 And $pid <> 0 Then ProcessWaitClose($pid)
EndFunc
#ce
#cs
   Local $iPID = Run(@ComSpec & ' /C DIR "' & $sFilePath & $sFilter & '" /B /A-D /S', $sFilePath, @SW_HIDE, $STDOUT_CHILD)
;~     ; If you want to search with files that contains unicode characters, then use the /U commandline parameter.
;~     ; Wait until the process has closed using the PID returned by Run.
    ProcessWaitClose($iPID)
;~     ; Read the Stdout stream of the PID returned by Run. This can also be done in a while loop. Look at the example for StderrRead.
    Local $sOutput = StdoutRead($iPID)
    GUICtrlSetData($edit_out, "")
    Local $sOutput = ""
    While 1
        $sOutput = StdoutRead($iPID)
        If @error Then ; Exit the loop if the process closes or StdoutRead returns an error.
            ExitLoop
        EndIf
        MsgBox($MB_SYSTEMMODAL, "Stdout Read:", $sOutput)
            GUICtrlSetData($edit_out, GUICtrlRead($edit_out) & @CRLF & $sOutput)
    WEnd
;~     ; Use StringSplit to split the output of StdoutRead to an array. All carriage returns (@CRLF) are stripped and @CRLF (line feed) is used as the delimiter.
    Local $aArray = StringSplit(StringTrimRight(StringStripCR($sOutput), StringLen(@CRLF)), @CRLF)
    If @error Then
        MsgBox($MB_SYSTEMMODAL, "", "It appears there was an error trying to find all the files in the current script directory.")
    Else
        ; Display the results.
        _ArrayDisplay($aArray)
    EndIf
#ce