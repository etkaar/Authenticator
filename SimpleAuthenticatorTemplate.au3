; Copyright (c) 2021 etkaar <https://github.com/etkaar>
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
; OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
; ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
; OR OTHER DEALINGS IN THE SOFTWARE.

#include <Constants.au3>
#include <GUIConstants.au3>
#include <FontConstants.au3>
#include <ProgressConstants.au3>

; Program data and details
#pragma compile(Icon, C:\...\logo.ico)
#pragma compile(ProductVersion, 1.0)
#pragma compile(FileVersion, 1.0.0.0)
#pragma compile(ProductName, Authenticator)
#pragma compile(LegalCopyright, BrandName)

; Errors
$error_handler = ObjEvent('AutoIt.Error', '_ErrFunc')

; Window
$font_family = 'Segoe UI'
$font_size = 10
$width = 540
$height = 220
$padding = 15

;
; PERSONALIZATION
;
; The authenticator is designed to be used as personalized standalone program.
; Thus, this information is compiled within the .exe, and no additional
; information (e.g. key files, registry information) is required.
;
; Used in SendAuthenticationRequest()
;
$username = '...'
$auth_name = 'rclient-...-....'
$auth_key = '...'

; Language
$LANG_WINDOW_TITLE = 'BrandName – Personalisierter Authenticator'
$LANG_TEXT_TRAY_TIP = 'Gib dieses Programm keinesfalls weiter, auch nicht an andere Teammitglieder.'
$LANG_USER_DETAIL_NAME = 'Authentifizierung mit Nutzer: ' & $username
$LANG_TEXT_DESCRIPTION_LINE1 = 'Dieser Authenticator schaltet Dich in der Firewall frei, damit Du auf administrative Bereiche zugreifen kannst. Das Programm wird nach Authentifizierung geschlossen.'
$LANG_TEXT_DESCRIPTION_LINE2 = 'Es dauert danach etwa 3 Minuten, bis Du freigeschaltet wirst.'
$LANG_TEXT_AUTH_BUTTON = 'Authentifizierung anfordern'
$LANG_TITLE_NETWORK_ERROR = 'Netzwerkfehler'
$LANG_TEXT_NETWORK_ERROR = 'Verbindung zum Authentifizierungsserver kann nicht aufgebaut werden.'
$LANG_TITLE_AUTHENTICATED = 'Authentifiziert'
$LANG_TEXT_AUTHENTICATED = 'Authentifizierung erfolgreich. Das Programm wird nun geschlossen.'
$LANG_TITLE_AUTHENTICATION_ERROR = 'Authentifizierungsfehler'
$LANG_TEXT_AUTHENTICATION_ERROR = 'Aus unerfindlichen Gründen ist die Authentifizierung einfach so fehlgeschlagen.'
$LANG_TITLE_UNKNOWN_ERROR = 'Unbekannter Fehler'
$LANG_TEXT_UNKNOWN_ERROR = 'Es ist ein nicht behebbarer interner Fehler aufgetreten.'

; Tray settings
Opt('TrayMenuMode', 1)

TraySetState(1)

; Show tooltip
TraySetToolTip($LANG_WINDOW_TITLE)
TrayTip($LANG_WINDOW_TITLE, $LANG_TEXT_TRAY_TIP, 0, $TIP_NOSOUND)

; Create main window
$main_window = GUICreate($LANG_WINDOW_TITLE, $width, $height, -1, -1)
GUISetFont($font_size, $FW_NORMAL, $GUI_FONTNORMAL, $font_family)

; Show authenticating username
$text_user_details =  GUICtrlCreateLabel($LANG_USER_DETAIL_NAME, $padding, 15, ($width - 2 * $padding), 15, $SS_LEFT)
GUICtrlSetFont($text_user_details, ($font_size - 1), 700, 0, 'Consolas')

; Show description
$text_description1 = GUICtrlCreateLabel($LANG_TEXT_DESCRIPTION_LINE1, $padding, ($padding + 25), ($width - 2 * $padding), 50, $SS_LEFT)
$text_description2 = GUICtrlCreateLabel($LANG_TEXT_DESCRIPTION_LINE2, $padding, ($padding + 70), ($width - 2 * $padding), 50, $SS_LEFT)

; Create authentication button
$auth_button = GUICtrlCreateButton($LANG_TEXT_AUTH_BUTTON, ($width / 2 - 120), 125, 240, 70)
GUICtrlSetFont($auth_button, ($font_size + 1), 0, 0, $font_family)

; Show window
GUISetState(@SW_SHOW)

While 1
    $msg = GUIGetMsg()
	
	; Authentication
	If $msg = $auth_button Then
		; Hide auth button
		GUICtrlSetState($auth_button, $GUI_HIDE)
		
		; Start progress bar
		$auth_progress_bar = GUICtrlCreateProgress(($width / 2 - 120), (95 + (35 / 2)), 240, 35, $PBS_MARQUEE)
		GUICtrlSendMsg($auth_progress_bar, $PBM_SETMARQUEE, 1, 10)
		
		; Send authentication request
		SendAuthenticationRequest()
	EndIf
	
	; Close window
	If $msg = $GUI_EVENT_CLOSE Then
		GUISetState(@SW_HIDE)
		ExitLoop
	EndIf
	
	Sleep(50)
Wend

; Send authentication request to the desired service, e.g. a DynDNS service
Func SendAuthenticationRequest()
	; The service shall be able to find itself out the
	; ip address of the client; we do not transmit it.
	$full_request_uri = 'https://dyndns-service.example.com' & '/update/' & $auth_name & '/' & $auth_key

	$request = ObjCreate('WinHttp.WinHttpRequest.5.1')
	$request.Open('GET', $full_request_uri, False)
	$request.Send()
	
	If @Error then
		MsgBox(48, $LANG_TITLE_NETWORK_ERROR, $LANG_TEXT_NETWORK_ERROR)
		Exit
	EndIf

	If $request.Status = 200 then
		MsgBox(64, $LANG_TITLE_AUTHENTICATED, $LANG_TEXT_AUTHENTICATED)
		Exit
	Else
		; Re-show auth button
		GUICtrlSetState($auth_button, $GUI_SHOW)
		
		; Hide progress bar
		GUICtrlSetState($auth_progress_bar, $GUI_HIDE)
	
		MsgBox(48, $LANG_TITLE_AUTHENTICATION_ERROR, $LANG_TEXT_AUTHENTICATION_ERROR)
	EndIf
EndFunc

; Unexpected errors from AutoIt
Func _ErrFunc($error)
	MsgBox(48, $LANG_TITLE_UNKNOWN_ERROR, $LANG_TEXT_UNKNOWN_ERROR)
	Exit
EndFunc
