;___________________________________________________________________________

;includes

      include \masm32\include\windows.inc
      include \masm32\include\masm32.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\Comctl32.inc
      include \masm32\include\comdlg32.inc
      include \masm32\include\shell32.inc
      include \masm32\include\oleaut32.inc
      include \masm32\include\ole32.inc
      include \masm32\include\winmm.inc
      include \masm32\include\msimg32.inc 
      include \masm32\macros\macros.asm



;bibliotecas

      includelib \masm32\lib\masm32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\oleaut32.lib
      includelib \masm32\lib\ole32.lib
      includelib \masm32\lib\winmm.lib
      includelib \masm32\lib\msimg32.lib

;___________________________________________________________________________

;prototipos

        WinMain          PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc          PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY            PROTO :DWORD,:DWORD
        KeyDownProc      PROTO :DWORD,:DWORD
        TimerProc        PROTO :DWORD
	      PaintProc        PROTO :DWORD
        CreateProc       PROTO :DWORD
        RegisterWinClass PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        MsgLoop          PROTO
        Main             PROTO

;macros

      DisplayWindow MACRO handl, ShowStyle
        invoke ShowWindow,handl, ShowStyle
        invoke UpdateWindow,handl
      ENDM

      DrawImage MACRO hDC, hOld, memDC, hBmp, posX, posY, disp, wid, hgt
        invoke SelectObject,memDC,hBmp
        mov hOld, eax
        mov ecx,  posX
        add ecx,  disp.x
        mov edx,  posY
        add edx,  disp.y
        invoke BitBlt,hDC,ecx,edx,wid,hgt,memDC,0,0,SRCCOPY
      ENDM

      DrawImagePos MACRO hDC, hOld, memDC, hBmp, pos, disp, wid, hgt
        DrawImage hDC,hOld,memDC,hBmp,pos.x,pos.y,disp,wid,hgt
      ENDM

      DrawImages MACRO hDC, hOld, memDC, hBmp, array, disp, wid, hgt, qtd
        mov ebx, 0
        .repeat
          DrawImagePos hDC,hOld,memDC,hBmp,array[ebx*POINT],disp,wid,hgt
          inc ebx
        .until ebx == qtd
      ENDM

      PlayShoot MACRO
        mov open_lpstrDeviceType,  0h     
        mov open_lpstrElementName, OFFSET mShoot
        invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback                  
        invoke mciSendCommandA,open_wDeviceID,MCI_PLAY,MCI_FROM or MCI_NOTIFY,offset play_dwCallback
      ENDM

      PlayKilled MACRO
        mov open_lpstrDeviceType1,  0h     
        mov open_lpstrElementName1, OFFSET mKilled
        invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback1                  
        invoke mciSendCommandA,open_wDeviceID1,MCI_PLAY,MCI_FROM or MCI_NOTIFY,offset play_dwCallback1
      ENDM

      PlayMusic MACRO
        mov open_lpstrDeviceType1,  0h     
        mov open_lpstrElementName1, OFFSET music
        invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback1                  
        invoke mciSendCommandA,open_wDeviceID1,MCI_PLAY,MCI_FROM or MCI_NOTIFY,offset play_dwCallback1
      ENDM

      Gameover MACRO
      	  mov gameover, 1
      	  invoke InvalidateRect,hWnd,NULL,FALSE
      ENDM


;variaveis
	.const
		CREF_TRANSPARENT  EQU 00FFFFFFh

    .data
    	music                  db    "Music.wav",0
        mShoot                 db    "Shoot.wav",0
        mKilled                db    "Killed.wav",0
        pos                    POINT <0,0>
        posAliens              POINT 55  dup(<0,0>)
        posShot                POINT <wid,hgt>
        wid                    dd    800
        hgt                    dd    508
        points                 dd    0       

        ;aux
        gameover               dd    0
        killed                 dd    0
        timerA                 dd    0
        contA                  dd    0
        vAliens                dd    2
        vShots                 dd    10
        posAliensSize          dd    55
        aliensSize             dd    30
        shotsSize              dd    10
        shipSize               dd    30
        bigPosA                POINT <0,0>
        dis0                   POINT <0,0>
        disA                   POINT <40,0>

    .data?
        hInstance              dd ?
        CommandLine            dd ?
        hIcon                  dd ?
        hCursor                dd ?
        sWid                   dd ?
        sHgt                   dd ?
        hWnd                   dd ?
        hBmpB                  dd ?
        hBmpA                  dd ?
        hBmpShip               dd ?
        hBmpShoot              dd ?
       
        ;music
        open_dwCallback        dd ?
        open_wDeviceID         dd ?
        open_lpstrDeviceType   dd ?
        open_lpstrElementName  dd ?
        open_lpstrAlias        dd ?
        generic_dwCallback     dd ?
        play_dwCallback        dd ?
        play_dwFrom            dd ?
        play_dwTo              dd ?

        open_dwCallback1        dd ?
        open_wDeviceID1         dd ?
        open_lpstrDeviceType1   dd ?
        open_lpstrElementName1  dd ?
        open_lpstrAlias1        dd ?
        generic_dwCallback1     dd ?
        play_dwCallback1        dd ?
        play_dwFrom1            dd ?
        play_dwTo1              dd ?

;___________________________________________________________________________