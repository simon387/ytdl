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

_singleton(@ScriptName)

#Region Global Variables and Constants

Global Const $EN_APP_TITLE = "YTDLUI by simon - v0.14 - Hit {esc} to force exit!"
Global Const $EN_DEFAULT_URL = "http://www.youtube.com/watch?v=ebXbLfLACGM"
Global Const $EN_INPUT_URL_TIP_MESSAGE = "Paste here youtube link"
Global Const $EN_INPUT_URL_TIP_TITLE = "Info"
Global Const $EN_BUTTON_PASTE = "Paste"
Global Const $EN_BUTTON_PASTE_TIP_MESSAGE = "Paste from clipboard"
Global Const $EN_BUTTON_PASTE_TIP_TITLE = "Info"
Global Const $EN_INPUT_DOWNLOAD_TIP_MESSAGE = "Download destination"
Global Const $EN_INPUT_DOWNLOAD_TIP_TITLE = "Info"
Global Const $EN_BUTTON_SELECT = "Change"
Global Const $EN_BUTTON_SELECT_TIP_MESSAGE = "Change download destination"
Global Const $EN_BUTTON_SELECT_TIP_TITLE = "Info"
Global Const $EN_BUTTON_VIDEO = "Download video"
Global Const $EN_BUTTON_VIDEO_TIP_MESSAGE = "Start Video Download"
Global Const $EN_BUTTON_VIDEO_TIP_TITLE = "Info"
Global Const $EN_BUTTON_MP3 = "Download mp3"
Global Const $EN_BUTTON_MP3_TIP_MESSAGE = "Start Mp3 Download"
Global Const $EN_BUTTON_MP3_TIP_TITLE = "Info"
Global Const $EN_BUTTON_UPDATE = "Update"
Global Const $EN_BUTTON_UPDATE_TIP_MESSAGE = "Update to last YTDL version"
Global Const $EN_BUTTON_UPDATE_TIP_TITLE = "Info"
Global Const $EN_BUTTON_INFO = "About"
Global Const $EN_BUTTON_INFO_TIP_MESSAGE = "youtube-dl.exe -h >> output"
Global Const $EN_BUTTON_INFO_TIP_TITLE = "NERD!"
Global Const $EN_INTERRUPT_MESSAGE = "~ interrupt!"
Global Const $EN_MISSING_URL_MESSAGE = "Missing URL!"
Global Const $EN_SELECT_DEST_DIR = "Select destination directory"
Global Const $BUTTON_PASTE_ON_EVENT = "button_paste_clicked"
Global Const $BUTTON_SELECT_ON_EVENT = "button_select_clicked"
Global Const $BUTTON_VIDEO_MP3_INFO_ON_EVENT = "button_video_or_mp3_or_info_or_update_clicked"
Global Const $CLOSE_ON_EVENT = "close_clicked"
Global Const $GUI_ON_EVENT_MODE = "GUIOnEventMode"
Global Const $NOP_MILLIS = 10000
Global Const $REPO_LOC = "https://github.com/simon387/ytdl"
Global Const $EMPTY_STRING = ""
Global Const $SPACE_CHAR = " "
Global Const $DOWNLOAD_TAG = "[download]"
Global Const $ESC_KEY = "{esc}"
Global Const $ENTER_KEY = "{enter}"
Global Const $YOUTUBE_DL_PATH =  @TempDir & "\youtube-dl.exe"
Global Const $FFMPEG_PATH = @TempDir & "\ffmpeg.exe"
Global Const $FFPLAY_PATH = @TempDir & "\ffplay.exe"
Global Const $FFPROBE_PATH = @TempDir & "\ffprobe.exe"
Global Const $MSVCR100_PATH = @TempDir & "\msvcr100.dll"
Global Const $CMD_VIDEO = @TempDir & '\youtube-dl.exe -o "'
Global Const $CMD_NAME_PATTERN = '\%(title)s-%(id)s.%(ext)s" '
Global Const $CMD_AUDIO = '-x --audio-quality 0 --audio-format mp3'
Global Const $CMD_INFO = @TempDir & '\youtube-dl.exe -h'
Global Const $CMD_UPDATE = @TempDir & '\youtube-dl.exe -U'
Global $iPID = -1

#EndRegion Global Variables and Constants

#Region GUI Variables and GUI Settings

Global Const $form_main = GUICreate($EN_APP_TITLE, 543, 323, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_MAXIMIZEBOX, $WS_SIZEBOX, $WS_THICKFRAME,$WS_TABSTOP), 0)
Global Const $input_url = GUICtrlCreateInput($EN_DEFAULT_URL, 8, 10, 391, 21)
GUICtrlSetTip(-1, $EN_INPUT_URL_TIP_MESSAGE, $EN_INPUT_URL_TIP_TITLE, 1, 1)
Global Const $button_paste = GUICtrlCreateButton($EN_BUTTON_PASTE, 411, 8, 123, 25)
GUICtrlSetTip(-1, $EN_BUTTON_PASTE_TIP_MESSAGE, $EN_BUTTON_PASTE_TIP_TITLE, 1, 1)
GUICtrlSetOnEvent(-1, $BUTTON_PASTE_ON_EVENT)
Global Const $input_dest = GUICtrlCreateInput(@ScriptDir, 8, 42, 391, 21)
GUICtrlSetTip(-1, $EN_INPUT_DOWNLOAD_TIP_MESSAGE, $EN_INPUT_DOWNLOAD_TIP_TITLE, 1, 1)
Global Const $button_select = GUICtrlCreateButton($EN_BUTTON_SELECT, 411, 40, 123, 25)
GUICtrlSetTip(-1, $EN_BUTTON_SELECT_TIP_MESSAGE, $EN_BUTTON_SELECT_TIP_TITLE, 1, 1)
GUICtrlSetOnEvent(-1, $BUTTON_SELECT_ON_EVENT)
Global Const $button_video = GUICtrlCreateButton($EN_BUTTON_VIDEO, 8, 288, 123, 25)
GUICtrlSetTip(-1, $EN_BUTTON_VIDEO_TIP_MESSAGE, $EN_BUTTON_VIDEO_TIP_TITLE, 1, 1)
GUICtrlSetOnEvent(-1, $BUTTON_VIDEO_MP3_INFO_ON_EVENT)
Global Const $button_mp3 = GUICtrlCreateButton($EN_BUTTON_MP3, 143, 288, 123, 25)
GUICtrlSetTip(-1, $EN_BUTTON_MP3_TIP_MESSAGE, $EN_BUTTON_MP3_TIP_TITLE, 1, 1)
GUICtrlSetBkColor(-1, $COLOR_RED)
GUICtrlSetColor(-1, $COLOR_WHITE)
GUICtrlSetOnEvent(-1, $BUTTON_VIDEO_MP3_INFO_ON_EVENT)
Global Const $button_update = GUICtrlCreateButton($EN_BUTTON_UPDATE, 277, 288, 123, 25)
GUICtrlSetTip(-1, $EN_BUTTON_UPDATE_TIP_MESSAGE, $EN_BUTTON_UPDATE_TIP_TITLE, 1, 1)
GUICtrlSetOnEvent(-1, $BUTTON_VIDEO_MP3_INFO_ON_EVENT)
Global Const $button_info = GUICtrlCreateButton($EN_BUTTON_INFO, 412, 288, 123, 25)
GUICtrlSetTip(-1, $EN_BUTTON_INFO_TIP_MESSAGE, $EN_BUTTON_INFO_TIP_TITLE, 2, 1)
GUICtrlSetOnEvent(-1, $BUTTON_VIDEO_MP3_INFO_ON_EVENT)
Global Const $edit_out = GUICtrlCreateEdit($EMPTY_STRING, 8, 72, 525, 209, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_READONLY, $WS_HSCROLL, $WS_VSCROLL, $WS_CLIPSIBLINGS));
GUISetState(@SW_SHOW)
HotKeySet($ESC_KEY, $CLOSE_ON_EVENT)
Opt($GUI_ON_EVENT_MODE, 1)
GUISetOnEvent($GUI_EVENT_CLOSE, $CLOSE_ON_EVENT, $form_main)
Global Const $aAccelKeys[1][2] = [[$ENTER_KEY, $button_mp3]]
GUISetAccelerators($aAccelKeys)
Global $mButtons[2][8] = [[$button_video, $button_mp3, $button_select, $button_info, $button_update, $button_paste, $input_url, $input_dest], _
	[GUICtrlRead($button_video), GUICtrlRead($button_mp3), GUICtrlRead($button_select), GUICtrlRead($button_info), GUICtrlRead($button_update), _
	GUICtrlRead($button_paste), GUICtrlRead($input_url), GUICtrlRead($input_dest)]]

#EndRegion GUI Variables and GUI Settings

While 1
	Sleep($NOP_MILLIS)
WEnd

#Region Functions list

; #FUNCTION# ====================================================================================================================
; Author ........: Simone Celia
; Modified.......: Simone Celia
; ===============================================================================================================================
Func button_video_or_mp3_or_info_or_update_clicked()
	If check_URL(GUICtrlRead($input_url)) == 0 Then Return
	Local $path = GUICtrlRead($input_dest)
	If FileExists($path) <> 1 And @GUI_CtrlId <> $button_info Then Return
	disable_gui()
	FileInstall(".\youtube-dl.exe", $YOUTUBE_DL_PATH, 0)
	Local $sOutput = $EMPTY_STRING
	Local $sCommand = $CMD_VIDEO & $path & $CMD_NAME_PATTERN & GUICtrlRead($input_url)
	Local $sAudioParam = $EMPTY_STRING
	Select
		Case @GUI_CtrlId = $button_mp3
			FileInstall(".\ffmpeg.exe", $FFMPEG_PATH, 0)
			FileInstall(".\ffplay.exe", $FFPLAY_PATH, 0)
			FileInstall(".\ffprobe.exe", $FFPROBE_PATH, 0)
			FileInstall(".\msvcr100.dll", $MSVCR100_PATH, 0)
			$sAudioParam = $CMD_AUDIO
		Case @GUI_CtrlId = $button_info
			$sCommand = $CMD_INFO
			ShellExecute($REPO_LOC)
		Case @GUI_CtrlId = $button_update
			$sCommand = $CMD_UPDATE
	EndSelect
	;ConsoleWrite($sCommand & $SPACE_CHAR & $sAudioParam & @CRLF)
	$iPID = Run($sCommand & $SPACE_CHAR & $sAudioParam, @TempDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	GUICtrlSetData($edit_out, $EMPTY_STRING)
	While 1
		$sOutput = StdoutRead($iPID)
		If @error Then ExitLoop
		If $sOutput <> $EMPTY_STRING Then
			If StringInStr($sOutput, $DOWNLOAD_TAG) > 1 Then
				GUICtrlSetData($edit_out, $sOutput)
			Else
				GUICtrlSetData($edit_out, GUICtrlRead($edit_out) & $sOutput)
			EndIf
		EndIf
		$sOutput = StderrRead($iPID)
		If @error Then ExitLoop
		If $sOutput <> $EMPTY_STRING Then GUICtrlSetData($edit_out, GUICtrlRead($edit_out) & $sOutput)
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
	Local $destinationDirectory = FileSelectFolder($EN_SELECT_DEST_DIR, $EMPTY_STRING, $FSF_CREATEBUTTON + $FSF_NEWDIALOG + $FSF_EDITCONTROL, $EMPTY_STRING, $form_main)
	If $destinationDirectory <> $EMPTY_STRING Then GUICtrlSetData($input_dest, $destinationDirectory)
EndFunc

; #FUNCTION# ====================================================================================================================
; Author ........: Simone Celia
; Modified.......: Simone Celia
; ===============================================================================================================================
Func check_URL($url)
	If $url == $EMPTY_STRING Then
		GUICtrlSetData($edit_out, $EN_MISSING_URL_MESSAGE)
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
	If BitAND(WinGetState($form_main), $WIN_STATE_ACTIVE) Then
		If ProcessExists($iPID) <> 0 Then
			ProcessClose($iPID)
			GUICtrlSetData($edit_out, $EN_INTERRUPT_MESSAGE)
		Else
			Exit
		EndIf
	EndIf
EndFunc

#EndRegion Functions list
