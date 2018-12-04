; #INDEX# =======================================================================================================================
; Title .........: ytdl
; AutoIt Version : 3.3.14.5
; Description ...: GUI for youtube-dl software
; Author(s) .....: Simone Celia
; ===============================================================================================================================

#pragma compile(Icon, .\shell32_299.ico)
#pragma compile(Compression, 1)

#NoTrayIcon
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ColorConstants.au3>
#include <EditConstants.au3>
#include <AutoItConstants.au3>
#include <FileConstants.au3>
#include "osFunctions.au3"
; #include <ButtonConstants.au3>Global Const $ES_READONLY = 2048;#include <StaticConstants.au3>;Global Const $WS_HSCROLL = 0x00100000;Global Const $WS_VSCROLL = 0x00200000;Global Const $WS_CLIPSIBLINGS = 0x04000000;#include <Misc.au3>

_singleton(@ScriptName)

#Region Global Variables and Constants with GUI code

Global Const $form_main = GUICreate("YTDLUI by simon - v0.14 - Hit {esc} to force exit!", 543, 323, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_MAXIMIZEBOX, $WS_SIZEBOX, $WS_THICKFRAME,$WS_TABSTOP), 0)
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
GUICtrlSetBkColor(-1, $COLOR_RED)
GUICtrlSetColor(-1, $COLOR_WHITE)
GUICtrlSetOnEvent(-1, "button_video_or_mp3_or_info_or_update_clicked")
Global Const $button_update = GUICtrlCreateButton("Update", 277, 288, 123, 25)
GUICtrlSetTip(-1, "Update to last YTDL version", "Info", 1, 1)
GUICtrlSetOnEvent(-1, "button_video_or_mp3_or_info_or_update_clicked")
Global Const $button_info = GUICtrlCreateButton("About", 412, 288, 123, 25)
GUICtrlSetTip(-1, "youtube-dl.exe -h >> output", "NERD!", 2, 1)
GUICtrlSetOnEvent(-1, "button_video_or_mp3_or_info_or_update_clicked")
Global Const $edit_out = GUICtrlCreateEdit("", 8, 72, 525, 209, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_READONLY, $WS_HSCROLL, $WS_VSCROLL, $WS_CLIPSIBLINGS));
GUISetState(@SW_SHOW)
HotKeySet("{esc}", "close_clicked")
Opt('GUIOnEventMode', 1)
GUISetOnEvent($GUI_EVENT_CLOSE, "close_clicked", $form_main)
Global Const $aAccelKeys[1][2] = [["{enter}", $button_mp3]]
GUISetAccelerators($aAccelKeys)
Global $iPID = -1
Global $mButtons[2][8] = [[$button_video, $button_mp3, $button_select, $button_info, $button_update, $button_paste, $input_url, $input_dest], _
	[GUICtrlRead($button_video), GUICtrlRead($button_mp3), GUICtrlRead($button_select), GUICtrlRead($button_info), GUICtrlRead($button_update), _
	GUICtrlRead($button_paste), GUICtrlRead($input_url), GUICtrlRead($input_dest)]]

#EndRegion Global Variables and Constants with GUI code

While 1
	Sleep(10000)
WEnd

#Region Functions list

; #FUNCTION# ====================================================================================================================
; Author ........: Simone Celia
; Modified.......: Simone Celia
; ===============================================================================================================================
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
			FileInstall(".\msvcr100.dll", @TempDir & "\msvcr100.dll", 0)
			$sAudioParam = '-x --audio-quality 0 --audio-format mp3'
		Case @GUI_CtrlId = $button_info
			$sCommand = @TempDir & '\youtube-dl.exe -h'
			ShellExecute("https://github.com/simon387/ytdl")
		Case @GUI_CtrlId = $button_update
			$sCommand = @TempDir & '\youtube-dl.exe -U'
	EndSelect
	;ConsoleWrite($sCommand & ' ' & $sAudioParam & @CRLF)
	$iPID = Run($sCommand & ' ' & $sAudioParam, @TempDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
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

; #FUNCTION# ====================================================================================================================
; Author ........: Simone Celia
; Modified.......: Simone Celia
; ===============================================================================================================================
Func button_paste_clicked()
	GUICtrlSetData($input_url, ClipGet())
EndFunc

; #FUNCTION# ====================================================================================================================
; Author ........: Simone Celia
; Modified.......: Simone Celia
; ===============================================================================================================================
Func button_select_clicked()
	Local $destinationDirectory = FileSelectFolder("Select destination directory", "", $FSF_CREATEBUTTON + $FSF_NEWDIALOG + $FSF_EDITCONTROL, "", $form_main)
	If $destinationDirectory <> "" Then GUICtrlSetData($input_dest, $destinationDirectory)
EndFunc

; #FUNCTION# ====================================================================================================================
; Author ........: Simone Celia
; Modified.......: Simone Celia
; ===============================================================================================================================
Func checkURL($url)
	If $url == "" Then
		GUICtrlSetData($edit_out, "Missing URL!")
		Return 0
	EndIf
	Return 1
EndFunc

; #FUNCTION# ====================================================================================================================
; Author ........: Simone Celia
; Modified.......: Simone Celia
; ===============================================================================================================================
Func disable_gui()
	For $i = 0 To UBound($mButtons, 2) -1
		GUICtrlSetState($mButtons[0][$i], $GUI_DISABLE)
	Next
	$mButtons[1][6] = GUICtrlRead($input_url)
	$mButtons[1][7] = GUICtrlRead($input_dest)
EndFunc

; #FUNCTION# ====================================================================================================================
; Author ........: Simone Celia
; Modified.......: Simone Celia
; ===============================================================================================================================
Func enable_gui()
	For $i = 0 To UBound($mButtons, 2) -1
		GUICtrlSetState($mButtons[0][$i], $GUI_ENABLE)
		GUICtrlSetData($mButtons[0][$i], $mButtons[1][$i])
	Next
	$iPID = -1
EndFunc

; #FUNCTION# ====================================================================================================================
; Author ........: Simone Celia
; Modified.......: Simone Celia
; ===============================================================================================================================
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

#EndRegion Functions list
