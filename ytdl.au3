#pragma compile(Icon, .\shell32_299.ico)
#NoTrayIcon
_singleton(@ScriptName); #include <ButtonConstants.au3>;#include <EditConstants.au3>;Global Const $ES_AUTOVSCROLL = 64;Global Const $ES_AUTOHSCROLL = 128;Global Const $ES_READONLY = 2048;#include <GUIConstantsEx.au3>;Global Const $GUI_EVENT_CLOSE = -3;#include <StaticConstants.au3>;Global Const $GUI_ENABLE = 64;Global Const $GUI_DISABLE = 128;#include <WindowsConstants.au3>;Global Const $WS_HSCROLL = 0x00100000;Global Const $WS_VSCROLL = 0x00200000;Global Const $WS_CLIPSIBLINGS = 0x04000000;#include <Misc.au3>
Global Const $form_main = GUICreate("YTDLUI by simon - v0.13 - Hit {esc} to force exit!", 543, 323, -1, -1, -2133917696, 0);BitOR($GUI_SS_DEFAULT_GUI,$WS_MAXIMIZEBOX,$WS_SIZEBOX,$WS_THICKFRAME,$WS_TABSTOP)
Global Const $input_url = GUICtrlCreateInput("http://www.youtube.com/watch?v=ebXbLfLACGM", 8, 10, 391, 21)
GUICtrlSetTip(-1, "Paste here youtube link", "Info", 1, 1)
Global Const $button_paste = GUICtrlCreateButton("Paste", 411, 8, 123, 25)
GUICtrlSetTip(-1, "Paste from clipboard", "Info", 1, 1)
GUICtrlSetOnEvent(-1, "button_paste_clicked")
Global Const $input_dest = GUICtrlCreateInput(@ScriptDir, 8, 42, 391, 21)
GUICtrlSetTip(-1, "Download destination", "Info", 1, 1)
Global Const $button_select = GUICtrlCreateButton("Change", 411, 40, 123, 25)
GUICtrlSetTip(-1, "Change download destination", "Info", 1, 1)
GUICtrlSetOnEvent(-1, "button_select_clicked")
Global Const $button_video = GUICtrlCreateButton("Download video", 8, 288, 123, 25)
GUICtrlSetTip(-1, "Start Video Download", "Info", 1, 1)
GUICtrlSetOnEvent(-1, "button_video_or_mp3_or_info_or_update_clicked")
Global Const $button_mp3 = GUICtrlCreateButton("Download mp3", 143, 288, 123, 25)
GUICtrlSetTip(-1, "Start Mp3 Download", "Info", 1, 1)
GUICtrlSetBkColor(-1, 16711680);#include <ColorConstants.au3>
GUICtrlSetColor(-1, 16777215 )
GUICtrlSetOnEvent(-1, "button_video_or_mp3_or_info_or_update_clicked")
Global Const $button_update = GUICtrlCreateButton("Update", 277, 288, 123, 25)
GUICtrlSetTip(-1, "Update to last YTDL version", "Info", 1, 1)
GUICtrlSetOnEvent(-1, "button_video_or_mp3_or_info_or_update_clicked")
Global Const $button_info = GUICtrlCreateButton("Nerd!", 412, 288, 123, 25)
GUICtrlSetTip(-1, "youtube-dl.exe -h >> output", "NERD!", 2, 1)
GUICtrlSetOnEvent(-1, "button_video_or_mp3_or_info_or_update_clicked")
Global Const $edit_out = GUICtrlCreateEdit("", 8, 72, 525, 209, 70256832);BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_READONLY,$WS_HSCROLL,$WS_VSCROLL,$WS_CLIPSIBLINGS)
GUISetState(@SW_SHOW)
HotKeySet("{esc}", "close_clicked")
Opt('GUIOnEventMode', 1)
GUISetOnEvent(-3, "close_clicked", $form_main)
Global Const $aAccelKeys[1][2] = [["{enter}", $button_mp3]]
GUISetAccelerators($aAccelKeys)
Global $iPID = -1
Global $m[2][8] = [[$button_video, $button_mp3, $button_select, $button_info, $button_update, $button_paste, $input_url, $input_dest], _
	[GUICtrlRead($button_video), GUICtrlRead($button_mp3), GUICtrlRead($button_select), GUICtrlRead($button_info), GUICtrlRead($button_update), _
	GUICtrlRead($button_paste), GUICtrlRead($input_url), GUICtrlRead($input_dest)]]

Func button_video_or_mp3_or_info_or_update_clicked()
	If checkURL(GUICtrlRead($input_url)) = 0 Then Return
	Local $path = GUICtrlRead($input_dest)
	If FileExists($path) <> 1 And @GUI_CtrlId <> $button_info Then Return
	disable_gui()
	FileInstall(".\youtube-dl.exe", @TempDir & "\youtube-dl.exe", 0)
	Local $sOutput = ""
	Local $sCommand = @TempDir & '\youtube-dl.exe -o "' & $path & '\%(title)s-%(id)s.%(ext)s" ' & GUICtrlRead($input_url)
	Local $sAudioParam = ""
	Select
		Case @GUI_CtrlId = $button_mp3
			FileInstall(".\ffmpeg.exe",   @TempDir & "\ffmpeg.exe", 0)
			FileInstall(".\ffplay.exe",   @TempDir & "\ffplay.exe", 0)
			FileInstall(".\ffprobe.exe",  @TempDir & "\ffprobe.exe", 0)
			FileInstall(".\msvcr100.dll", @TempDir & "\msvcr100.dll", 0);ShellExecute(@TempDir)
			$sAudioParam = '-x --audio-quality 0 --audio-format mp3'
		Case @GUI_CtrlId = $button_info
			$sCommand = @TempDir & '\youtube-dl.exe -h'
		Case @GUI_CtrlId = $button_update
			$sCommand = @TempDir & '\youtube-dl.exe -U'
	EndSelect
	;ConsoleWrite($sCommand & ' ' & $sAudioParam & @CRLF)
	$iPID = Run($sCommand & ' ' & $sAudioParam, @TempDir, @SW_HIDE, 0x2 + 0x4);$STDERR_CHILD + $STDOUT_CHILD)
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
	WEnd
	enable_gui()
EndFunc

Func button_paste_clicked()
	GUICtrlSetData($input_url, ClipGet())
EndFunc

Func button_select_clicked()
	Local $destinationDirectory = FileSelectFolder("Select destination directory", "", 7, "", $form_main)
	If $destinationDirectory <> "" Then GUICtrlSetData($input_dest, $destinationDirectory)
EndFunc

Func checkURL($url)
	If $url == "" Then
		GUICtrlSetData($edit_out, "Missing URL!")
		Return 0
	EndIf
	Return 1
EndFunc

Func disable_gui()
	For $i = 0 To UBound($m, 2) -1
		GUICtrlSetState($m[0][$i], 128)
	Next
	$m[1][6] = GUICtrlRead($input_url)
	$m[1][7] = GUICtrlRead($input_dest)
EndFunc

Func enable_gui()
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

Func _singleton($sOccurenceName, $iFlag = 0)
	Local Const $ERROR_ALREADY_EXISTS = 183
	Local Const $SECURITY_DESCRIPTOR_REVISION = 1
	Local Const $tagSECURITY_ATTRIBUTES = "dword Length;ptr Descriptor;bool InheritHandle"
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
EndFunc
