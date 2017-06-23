;#Include <keyRec.au3>
;#Include <playRec.au3>
#include <GUIConstantsEx.au3>
#include <authread.au3>
#Include <misc.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <File.au3>
#include <array.au3>
$dll = DllOpen("user32.dll")
Opt("SendKeyDelay", 50)
Opt("SendKeyDownDelay", 50)
#cs
Name ..........: Rec N Play
Description ...: Records and plays keys
Autoit Version :
Author(s) .....: kosPa
#ce

$FileOpen = FileOpen("recording1.html", 1)
_AuThread_Startup()

HotKeySet ( "+0", "HotKeyFunc" )
HotKeySet ( "+1", "HotKeyFunc" )
HotKeySet ( "+2", "HotKeyFunc" )
HotKeySet ( "+4", "HotKeyFunc" )

Global $global_timer
Global $global_timer_rec
Global $global_timer_play

While 1
   Sleep(100)
WEnd

Func Terminate()
   $endtime = TimerDiff ($global_timer)
   ConsoleWrite($endtime)
   ;write endtime to file
    Exit
EndFunc

Func HotKeyFunc()
   Switch @HotKeyPressed
	  Case "+1"
         RecordKeys(1)
      Case "+2"
         RecordKeys(0)
	  Case "+4"
         PlayRecording(1)
	  Case "+0"
		 Terminate()
    EndSwitch
EndFunc   ;==>HotKeyFunc

Func RecordKeys($State)

   $global_timer_rec = TimerInit ()

   While $State
	  _CaptureKeys()
   WEnd
   ConsoleWrite("Recording Stopped.")
EndFunc

Func PlayRecording($State2)
   ;While $State2
	  Play()
   ;WEnd
EndFunc

;==============================REC===================================

Func _CapturePressTime($a)
   If _IsPressed ($a, $dll) Then

	  $timer = TimerInit ()

	  While (_IsPressed ($a, $dll) <> 0)
		 Sleep (50)
	  WEnd

	  $endtime = TimerDiff ($timer)
	  ConsoleWrite ( $endtime )

	  return $endtime
   EndIf
EndFunc

Func _LogKeyPressed($WhatToLog)
   ConsoleWrite(" WhatToLog= " & $WhatToLog)
   FileWrite($FileOpen, "[" & $WhatToLog & "],")
EndFunc



;============================PLAY=====================================

Func Play()
   $file = FileOpen("recording1.html", 0)

   $FileContent = FileRead($file)
   FileClose($file)

   ;Split to [data][data][data]...
   Local $keyArray = StringSplit($FileContent, ',', $STR_ENTIRESPLIT)

   Local $threeValueArray
   Local $keySymbolArray[400]
   Local $timeActiveArray[400]
   Local $globalPushTimeArray[400]

   ;iretate to values
   For $i = 1 To UBound($keyArray) -2
	  ConsoleWrite(" i= " & $i & " value:" & $keyArray[$i] & @CRLF)
	  $threeValueArray = StringSplit($keyArray[$i], ':', $STR_ENTIRESPLIT)

	  $keySymbolArray[$i] = $threeValueArray[1]
	  $timeActiveArray[$i] = $threeValueArray[2]
	  $globalPushTimeArray[$i] = $threeValueArray[3]

	  ; Cut ' [ ', ' ] '
	  $keySymbolArray[$i] = StringTrimLeft($keySymbolArray[$i], 1)
	  $globalPushTimeArray[$i] = StringTrimRight($globalPushTimeArray[$i], 1)

	  ;ConsoleWrite(" keySymbolArray[" & $keySymbolArray[$i] & "size= " & UBound($keySymbolArray) & @CRLF & " timeActiveArray[" & $timeActiveArray[$i] & " size= " & UBound($timeActiveArray) & @CRLF & "globalPushTimeArray[" & $globalPushTimeArray[$i] & " size=" & UBound($globalPushTimeArray) & @CRLF)
   Next

   $keySymbolArray = _ArrayRemoveBlanks($keySymbolArray)
   $timeActiveArray = _ArrayRemoveBlanks($timeActiveArray)
   $globalPushTimeArray =_ArrayRemoveBlanks($globalPushTimeArray)

   ; Start play global timer
   Local $timer_play = TimerInit()

   Local $working = 1
   Local $pushTime = 0
   Local $k = 0 ;array counter used for accessing $globalPushTimeArray values
   While $working
	  ;For $k = 1 To UBound($globalPushTimeArray) - 1

	  $pushTime = Round($globalPushTimeArray[$k]/1000,1)
	  $playTimer =  Round(TimerDiff($timer_play)/1000, 1)
	  ConsoleWrite("playTimer: " & $playTimer & ", pushTime: " & $pushTime & ", k: " & $k & ", key: " & $keySymbolArray[$k] & " timeActv: " & $timeActiveArray[$k] &  @CRLF)
	  ; Timers are equal.Print
	  If $pushTime = $playTimer Then

		 ;pushButton($keySymbolArray[$k], $timeActiveArray[$k])
		 ConsoleWrite("CREATING THREAD")
		 $hThread = _AuThread_StartThread("pushButton")
		 _AuThread_SendMessage($hThread, $keySymbolArray[$k] & ":" & $timeActiveArray[$k])
		 ;_AuThread_CloseThread($hThread)
		 ;increace counter0
		 If $k <> UBound($globalPushTimeArray) - 1 Then
			$k = $k + 1
		 Else
			$working = 0
		 EndIf
	  EndIf
	  ;Next
	  ;sleep(50)
	  ;$working = 0
   WEnd

   $k = 1 ;reset counter
EndFunc


; Removes Elemets that contain only whitespace characters and returns the new array.
; The count of the return is at $aRet[0].
Func _ArrayRemoveBlanks($array)
   ; Move backwards through the array deleting the blank lines
   For $i = UBound($array) - 1 To 0 Step -1
	   If $array[$i] = "" Then
		   _ArrayDelete($array, $i)
	   EndIf
   Next
   ;_ArrayDisplay($array)
   return $array
EndFunc

Func _Send($text, $milliseconds)
    ;$time = TimerInit()
    ;Do
    ;    Send($text)
    ;Until TimerDiff($time) > $milliseconds
	  $time = TimerInit()
	  While TimerDiff($time) < $milliseconds
		 Send($text)
	  WEnd
EndFunc


; When key is pressed get global time and store it with the key(ex A), keyPushTime, global_timer_now
Func _CaptureKeys()

    If _IsPressed('20') Then
      _LogKeyPressed('SPACE:' & _CapturePressTime('20') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('01') Then
        _LogKeyPressed('LEFT MOUSE BUTTON:' & _CapturePressTime('01') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('02') Then
        _LogKeyPressed('RIGHT MOUSE BUTTON:' & _CapturePressTime('02') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('04') Then
        _LogKeyPressed('MIDDLE MOUSE BUTTON:' & _CapturePressTime('04') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('05') Then
        _LogKeyPressed('2000/XP X1 MouseButton:' & _CapturePressTime('05') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('06') Then
        _LogKeyPressed('2000/XP X2 MouseButton:' & _CapturePressTime('06') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('08') Then
        _LogKeyPressed('BACKSPACE:' & _CapturePressTime('08') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('09') Then
        _LogKeyPressed('TAB:' & _CapturePressTime('09') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('0C') Then
        _LogKeyPressed('CLEAR:' & _CapturePressTime('0C') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('0D') Then
        _LogKeyPressed('ENTER::' & _CapturePressTime('0D') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('10') Then
        _LogKeyPressed('SHIFT:' & _CapturePressTime('10') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('11') Then
        _LogKeyPressed('CTRL:' & _CapturePressTime('11') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('12') Then
        _LogKeyPressed('ALT:' & _CapturePressTime('12') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('13') Then
        _LogKeyPressed('PAUSE:' & _CapturePressTime('13') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('14') Then
        _LogKeyPressed('CAPS:' & _CapturePressTime('14') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('1B') Then
        _LogKeyPressed('ESC:' & _CapturePressTime('1B') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('20') Then
        _LogKeyPressed('SPACE:' & _CapturePressTime('20') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('21') Then
        _LogKeyPressed('PAGEUP:' & _CapturePressTime('21') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('22') Then
        _LogKeyPressed('PAGEDOWN:' & _CapturePressTime('22') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('23') Then
        _LogKeyPressed('END:' & _CapturePressTime('23') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('24') Then
        _LogKeyPressed('HOME:' & _CapturePressTime('24') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('25') Then
        _LogKeyPressed('LEFTARROW:' & _CapturePressTime('25') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('26') Then
        _LogKeyPressed('UPARROW:' & _CapturePressTime('26') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('27') Then
        _LogKeyPressed('RIGHTARROW:' & _CapturePressTime('27') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('28') Then
        _LogKeyPressed('DOWNARROW:' & _CapturePressTime('28') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('29') Then
        _LogKeyPressed('SELECT:' & _CapturePressTime('29') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('2A') Then
        _LogKeyPressed('PRINT:' & _CapturePressTime('2A') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('2B') Then
        _LogKeyPressed('EXECUTE:' & _CapturePressTime('2B') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('2C') Then
        _LogKeyPressed('PRINTSCREEN:' & _CapturePressTime('2C') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('2D') Then
        _LogKeyPressed('INS:' & _CapturePressTime('2D') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('2E') Then
        _LogKeyPressed('DEL:' & _CapturePressTime('2E') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('5B') Then
        _LogKeyPressed('LEFTWINDOW:' & _CapturePressTime('5B') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('5C') Then
        _LogKeyPressed('RIGHTWINDOW:' & _CapturePressTime('5C') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('60') Then
        _LogKeyPressed('NUMKEYPAD:' & _CapturePressTime('60') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('61') Then
        _LogKeyPressed('NUMKEYPAD:' & _CapturePressTime('61') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('62') Then
        _LogKeyPressed('NUMKEYPAD:' & _CapturePressTime('62') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('63') Then
        _LogKeyPressed('NUMKEYPAD:' & _CapturePressTime('63') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('64') Then
        _LogKeyPressed('NUMKEYPAD:' & _CapturePressTime('64') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('65') Then
        _LogKeyPressed('NUMKEYPAD:' & _CapturePressTime('65') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('66') Then
        _LogKeyPressed('NUMKEYPAD:' & _CapturePressTime('66') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('67') Then
        _LogKeyPressed('NUMKEYPAD:' & _CapturePressTime('67') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('68') Then
        _LogKeyPressed('NUMKEYPAD:' & _CapturePressTime('68') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('69') Then
        _LogKeyPressed('NUMKEYPAD:' & _CapturePressTime('69') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('6A') Then
        _LogKeyPressed('MULTIPLY:' & _CapturePressTime('6A') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('6B') Then
        _LogKeyPressed('ADD:' & _CapturePressTime('6B') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('6C') Then
        _LogKeyPressed('SEPARATOR:' & _CapturePressTime('6C') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('6D') Then
        _LogKeyPressed('SUBTRACT:' & _CapturePressTime('6D') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('6E') Then
        _LogKeyPressed('DECIMAL:' & _CapturePressTime('6E') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('6F') Then
        _LogKeyPressed('DIVIDE:' & _CapturePressTime('6F') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('70') Then
        _LogKeyPressed('F1:' & _CapturePressTime('70') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('71') Then
        _LogKeyPressed('F2:' & _CapturePressTime('71') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('72') Then
        _LogKeyPressed('F3:' & _CapturePressTime('72') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('73') Then
        _LogKeyPressed('F4:' & _CapturePressTime('73') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('74') Then
        _LogKeyPressed('F5:' & _CapturePressTime('74') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('75') Then
        _LogKeyPressed('F6:' & _CapturePressTime('75') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('76') Then
        _LogKeyPressed('F7:' & _CapturePressTime('76') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('77') Then
        _LogKeyPressed('F8:' & _CapturePressTime('77') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('78') Then
        _LogKeyPressed('F9:' & _CapturePressTime('78') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('79') Then
        _LogKeyPressed('F10:' & _CapturePressTime('79') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('7A') Then
        _LogKeyPressed('F11:' & _CapturePressTime('7A') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('7B') Then
        _LogKeyPressed('F12:' & _CapturePressTime('7B') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('7C') Then
        _LogKeyPressed('F13:' & _CapturePressTime('7C') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('7D') Then
        _LogKeyPressed('F14:' & _CapturePressTime('7D') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('7E') Then
        _LogKeyPressed('F15:' & _CapturePressTime('7E') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('7F') Then
        _LogKeyPressed('F16:' & _CapturePressTime('7F') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('80H') Then
        _LogKeyPressed('F17:' & _CapturePressTime('80H') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('81H') Then
        _LogKeyPressed('F18:' & _CapturePressTime('81H') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('82H') Then
        _LogKeyPressed('F19:' & _CapturePressTime('82H') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('83H') Then
        _LogKeyPressed('F20:' & _CapturePressTime('83H') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('84H') Then
        _LogKeyPressed('F21:' & _CapturePressTime('84H') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('85H') Then
        _LogKeyPressed('F22:' & _CapturePressTime('85H') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('86H') Then
        _LogKeyPressed('F23:' & _CapturePressTime('86H') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('87H') Then
        _LogKeyPressed('F24:' & _CapturePressTime('86H') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('90') Then
        _LogKeyPressed('NUMLOCK:' & _CapturePressTime('90') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('91') Then
        _LogKeyPressed('SCROLLLOCK:' & _CapturePressTime('91') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('A1') Then
        _LogKeyPressed('RIGHTSHIFT:' & _CapturePressTime('A1') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('A2') Then
        _LogKeyPressed('LEFTCONTROL:' & _CapturePressTime('A2') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('A3') Then
        _LogKeyPressed('RIGHTCONTROL:' & _CapturePressTime('A3') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('A4') Then
        _LogKeyPressed('LEFTMENU:' & _CapturePressTime('A4') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('A5') Then
        _LogKeyPressed('RIGHTMENU:' & _CapturePressTime('A5') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('30') Then
        _LogKeyPressed('0:' & _CapturePressTime('30') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('31') Then
        _LogKeyPressed('1:' & _CapturePressTime('31') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('32') Then
        _LogKeyPressed('2:' & _CapturePressTime('32') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('33') Then
        _LogKeyPressed('3:' & _CapturePressTime('33') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('34') Then
        _LogKeyPressed('4:' & _CapturePressTime('34') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('35') Then
        _LogKeyPressed('5:' & _CapturePressTime('35') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('36') Then
        _LogKeyPressed('6:' & _CapturePressTime('36') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('37') Then
        _LogKeyPressed('7:' & _CapturePressTime('37') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('38') Then
        _LogKeyPressed('8:' & _CapturePressTime('38') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('39') Then
        _LogKeyPressed('9:' & _CapturePressTime('39') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('41') Then
    	_LogKeyPressed('A:' & _CapturePressTime('41') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('42') Then
        _LogKeyPressed('B:' & _CapturePressTime('42') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('43') Then
        _LogKeyPressed('C:' & _CapturePressTime('43') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('44') Then
        _LogKeyPressed('D:' & _CapturePressTime('44') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('45') Then
        _LogKeyPressed('E:' & _CapturePressTime('45') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('46') Then
        _LogKeyPressed('F:' & _CapturePressTime('46') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('47') Then
        _LogKeyPressed('G:' & _CapturePressTime('47') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('48') Then
        _LogKeyPressed('H:' & _CapturePressTime('48') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('49') Then
        _LogKeyPressed('I:' & _CapturePressTime('49') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('4A') Then
        _LogKeyPressed('J:' & _CapturePressTime('4A') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('4B') Then
        _LogKeyPressed('K:' & _CapturePressTime('4B') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('4C') Then
        _LogKeyPressed('L:' & _CapturePressTime('4C') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('4D') Then
        _LogKeyPressed('M:' & _CapturePressTime('4D') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('4E') Then
        _LogKeyPressed('N:' & _CapturePressTime('4E') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('4F') Then
        _LogKeyPressed('O:' & _CapturePressTime('4F') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('50') Then
        _LogKeyPressed('P:' & _CapturePressTime('50') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('51') Then
        _LogKeyPressed('Q:' & _CapturePressTime('51') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('52') Then
        _LogKeyPressed('R:' & _CapturePressTime('52') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('53') Then
        _LogKeyPressed('S:' & _CapturePressTime('53') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('54') Then
        _LogKeyPressed('T:' & _CapturePressTime('54') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('55') Then
        _LogKeyPressed('U:' & _CapturePressTime('55') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('56') Then
        _LogKeyPressed('V:' & _CapturePressTime('56') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('57') Then
        _LogKeyPressed('W:' & _CapturePressTime('57') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('58') Then
        _LogKeyPressed('X:' & _CapturePressTime('58') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('59') Then
        _LogKeyPressed('Y:' & _CapturePressTime('59') & ':' & TimerDiff($global_timer_rec))
    EndIf
    If _IsPressed('5A') Then
        _LogKeyPressed('Z:' & _CapturePressTime('5A') & ':' & TimerDiff($global_timer_rec))
    EndIf

    ;Sleep(75)
EndFunc

;Func PushButton($keySymbol, $timeActive)
Func PushButton()
   $sMsg = _AuThread_GetMessage()
   $data = StringSplit($sMsg, ':', $STR_ENTIRESPLIT)
   ;MsgBox(0, "Alert from thread", $data[1] & " " & $data[2])
   ConsoleWrite($data)
   Local $keySymbol = $data[1]
   Local $timeActive = $data[2]
   ;MsgBox(0, "Alert from thread", $data[1] & " " & $data[2])
    If $keySymbol == 'BACKSPACE' Then
        _Send('{BACKSPACE}', $timeActive)
    EndIf
    If $keySymbol == 'ESQ' Then
        _Send('{ESC}', $timeActive)
    EndIf
    If $keySymbol == 'SPACE' Then
        _Send('{SPACE}', $timeActive)
    EndIf
    If $keySymbol == '21' Then
        _Send('{PAGEUP}', $timeActive)
    EndIf
    If $keySymbol == '22' Then
        _Send('{PAGEDOWN}', $timeActive)
    EndIf
    If $keySymbol == '25' Then
        _Send('{LEFTARROW}', $timeActive)
    EndIf
    If $keySymbol == '26' Then
        _Send('{UPARROW}', $timeActive)
    EndIf
    If $keySymbol == '27' Then
        _Send('{RIGHTARROW}', $timeActive)
    EndIf
    If $keySymbol == '28' Then
        _Send('{DOWNARROW}', $timeActive)
    EndIf
    If $keySymbol == '2E' Then
        _Send('{DEL}', $timeActive)
    EndIf
    If $keySymbol == 'SHIFT' Then
        _Send('{RSHIFT}', $timeActive)
    EndIf
    If $keySymbol == 'A2' Then
        _Send('{LCTRL}', $timeActive)
    EndIf
    If $keySymbol == 'A3' Then
        _Send('{RCTRL}', $timeActive)
    EndIf
    If $keySymbol == '0' Then
        _Send('0', $timeActive)
    EndIf
    If $keySymbol == '1' Then
        _Send('1', $timeActive)
    EndIf
    If $keySymbol == '2' Then
        _Send('2', $timeActive)
    EndIf
    If $keySymbol == '3' Then
        _Send('3', $timeActive)
    EndIf
    If $keySymbol == '4' Then
        _Send('4', $timeActive)
    EndIf
    If $keySymbol == '5' Then
        _Send('5', $timeActive)
    EndIf
    If $keySymbol == '6' Then
        _Send('6', $timeActive)
    EndIf
    If $keySymbol == '7' Then
        _Send('7', $timeActive)
    EndIf
    If $keySymbol == '8' Then
        _Send('8', $timeActive)
    EndIf
    If $keySymbol == '9' Then
        _Send('9', $timeActive)
    EndIf
    If $keySymbol == 'A' Then
		_Send('A', $timeActive)
    EndIf
    If $keySymbol == 'B' Then
        _Send('B', $timeActive)
    EndIf
    If $keySymbol == 'C' Then
        _Send('C', $timeActive)
    EndIf
    If $keySymbol == 'D' Then
        _Send('D', $timeActive)
    EndIf
    If $keySymbol == 'E' Then
        _Send('E', $timeActive)
    EndIf
    If $keySymbol == 'F' Then
        _Send('F', $timeActive)
    EndIf
    If $keySymbol == 'G' Then
        _Send('G', $timeActive)
    EndIf
    If $keySymbol == 'H' Then
        _Send('H', $timeActive)
    EndIf
    If $keySymbol == 'I' Then
        _Send('I', $timeActive)
    EndIf
    If $keySymbol == 'J' Then
        _Send('J', $timeActive)
    EndIf
    If $keySymbol == 'K' Then
        _Send('K', $timeActive)
    EndIf
    If $keySymbol == 'L' Then
        _Send('L', $timeActive)
    EndIf
    If $keySymbol == 'M' Then
        _Send('M', $timeActive)
    EndIf
    If $keySymbol == 'N' Then
        _Send('N', $timeActive)
    EndIf
    If $keySymbol == 'O' Then
        _Send('O', $timeActive)
    EndIf
    If $keySymbol == 'P' Then
        _Send('P', $timeActive)
    EndIf
    If $keySymbol == 'Q' Then
        _Send('Q', $timeActive)
    EndIf
    If $keySymbol == 'R' Then
        _Send('R', $timeActive)
    EndIf
    If $keySymbol == 'S' Then
        _Send('S', $timeActive)
    EndIf
    If $keySymbol == 'T' Then
        _Send('T', $timeActive)
    EndIf
    If $keySymbol == 'U' Then
        _Send('U', $timeActive)
    EndIf
    If $keySymbol == 'V' Then
        _Send('V', $timeActive)
    EndIf
    If $keySymbol == 'W' Then
        _Send('W', $timeActive)
    EndIf
    If $keySymbol == 'X' Then
        _Send('X', $timeActive)
    EndIf
    If $keySymbol == 'Y' Then
        _Send('Y', $timeActive)
    EndIf
    If $keySymbol == 'Z' Then
        _Send('Z', $timeActive)
    EndIf

    ;Sleep(200)
EndFunc












;While 1
;_CaptureKeys()
;WEnd

#cs
Func _LogKeyPressed($WhatToLog)
;$WindowTitle = WinGetTitle("")
;$Date = " Date:{"&"<i>"&@mon&"-"&@mday&"-"&@year&"</i>"&"}"
;$Time = " Time:{"&"<i>"&@hour&":"&@min&"."&@sec&"."&@msec&"</i>"&"}"

    ;If $WindowTitle = $WindowCheck Then
	    ConsoleWrite(" WhatToLog= " & $WhatToLog)
        FileWrite($FileOpen, "[" & $WhatToLog & "],")
    ;Else
        ;$WindowCheck = $WindowTitle
        ;FileWrite($FileOpen, "<table border="&""""&"1"&""""&"><tr><th>WindowTitle:"&"["&"<i>"&$WindowTitle&"</i>"&"]"&$User&$Date&$Time&"</th>"&"</tr></table>")
    ;EndIf
 EndFunc
 #ce