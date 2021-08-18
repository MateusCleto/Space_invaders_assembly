;___________________________________________________________________________

  .486
  .model flat, stdcall
  option casemap :none

  include Space_invader.inc

;___________________________________________________________________________

;As macros foram declaradas no .inc

;___________________________________________________________________________

.code

start:

    ;instancia os atributos para a criacao da tela

	  mov hInstance,   FUNC(GetModuleHandle, NULL)
	  mov CommandLine, FUNC(GetCommandLine)
	  mov hIcon,       FUNC(LoadIcon,hInstance,1)
	  mov hCursor,     FUNC(LoadCursor,NULL,IDC_ARROW)
	  mov sWid,        FUNC(GetSystemMetrics,SM_CXSCREEN)
	  mov sHgt,        FUNC(GetSystemMetrics,SM_CYSCREEN)

    ;chama a proc de criacao de tela
	  call Main

	  invoke ExitProcess,eax

;___________________________________________________________________________

Main proc

    LOCAL Wtx:DWORD,Wty:DWORD

    ;cria tela

    STRING szClassName,"SpaceInvader"

    invoke RegisterWinClass,ADDR WndProc,ADDR szClassName,
                      hIcon,hCursor,COLOR_BTNFACE+1

    invoke TopXY,wid,sWid
    mov Wtx, eax
    invoke TopXY,hgt,sHgt
    mov Wty, eax

    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES,
                          ADDR szClassName,
                          chr$("Space Invader"),
                          WS_POPUP or WS_SYSMENU or WS_CAPTION,
                          Wtx,Wty,wid,hgt,
                          NULL,NULL,
                          hInstance,NULL
    mov hWnd,eax

    DisplayWindow hWnd,SW_SHOWNORMAL

    call MsgLoop ;chama loop de mensagens

    ret

Main endp

;___________________________________________________________________________

RegisterWinClass proc lpWndProc:DWORD, lpClassName:DWORD,
                      Icon:DWORD, Cursor:DWORD, bColor:DWORD

    LOCAL wc:WNDCLASSEX

    ;seta variaveis de criacao de tela

    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNCLIENT or \
                           CS_BYTEALIGNWINDOW
    m2m wc.lpfnWndProc,    lpWndProc
    mov wc.cbClsExtra,     NULL
    mov wc.cbWndExtra,     NULL
    m2m wc.hInstance,      hInstance
    m2m wc.hbrBackground,  bColor
    mov wc.lpszMenuName,   NULL
    m2m wc.lpszClassName,  lpClassName
    m2m wc.hIcon,          Icon
    m2m wc.hCursor,        Cursor
    m2m wc.hIconSm,        Icon

    invoke RegisterClassEx, ADDR wc

    ret

RegisterWinClass endp

;___________________________________________________________________________

MsgLoop proc

    LOCAL msg:MSG

    ;direciona os eventos para Wnd

    jmp InLoop

    StartLoop:
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
    InLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      test eax, eax
      jnz StartLoop

    mov eax, msg.wParam
    ret

MsgLoop endp

;___________________________________________________________________________

WndProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    ;trata os eventos

    Switch uMsg

      Case WM_CREATE
        invoke CreateProc,hWin

      Case WM_TIMER
        invoke TimerProc,hWin

      Case WM_PAINT
        invoke PaintProc,hWin

      Case WM_KEYDOWN
      	invoke KeyDownProc,hWin,wParam

      Case WM_CLOSE
        invoke KillTimer,hWin,222

      Case WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    Endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

;___________________________________________________________________________

CreateProc proc hWin:DWORD

    ;seta variaveis realcionadas a tela para o seu uso inicial

    invoke SetTimer,hWin,222,1,NULL

    invoke BitmapFromResource, hInstance, 10
    mov    hBmpB, eax
    invoke BitmapFromResource, hInstance, 11
    mov    hBmpA, eax
    invoke BitmapFromResource, hInstance, 12
    mov    hBmpShip, eax
    invoke BitmapFromResource, hInstance, 13
    mov    hBmpShoot, eax

    mov eax, hgt
    sub eax, 50
    sub eax, shipSize
    mov pos.y, eax
    mov eax, 20
    mov pos.x, eax

    mov ebx, 0
    mov eax, 50
    mov edx, 50
    .While ebx < posAliensSize ;loop para setar vetor de posicao de aliens 
    	mov posAliens[ebx*POINT].x, edx
    	mov posAliens[ebx*POINT].y, eax
    	add eax, 50
    	.If eax > 250
    		mov eax, 50
    		add edx, 50
        mov bigPosA.y, eax
    	.Endif
    	mov bigPosA.x, edx
    	inc ebx
    .EndW

    PlayMusic

    ret

CreateProc endp

;___________________________________________________________________________

TimerProc proc hWin:DWORD

  ;realiza as acoes que ocorrem a todo instante de jogo

  .If timerA > 3 ;timerA é usado para diminuir a velocidade dos aliens
  	.If contA == 0 ;contA é usado para saber qual o sentido do movimento
  		mov ebx, bigPosA.x
  		add ebx, aliensSize
      add ebx, 30
  		.If ebx < wid       ;aumenta o deslocamento dos aliens caso o alien 
  			mov ebx, vAliens  ;mais afastado estiver a 30px do fim da tela
  			add disA.x, ebx
  		.Else                 ;caso o alien mais afastado tiver passado do fim da tela
  			mov contA, 1        ;inverte o sentido do movimento
  			mov ebx, aliensSize 
  			add disA.y, ebx ;aumenta o deslocamento dos aliens no eixo y
  			add disA.y, 10

        mov eax, bigPosA.y 
        add eax, aliensSize
        add eax, 30
        .If pos.y < eax ;caso o alien mais afastado do topo da tela
          Gameover      ; tiver passado a nave, o jogador perde
        .Endif
  		.Endif
  	.Elseif contA == 1  ;mesmo processo, mas sem os aliens descerem
  		.If disA.x > 0
  			mov ebx, vAliens
  			sub disA.x, ebx
  		.Else
  			mov contA, 0
  		.Endif
  	.Endif
    mov timerA, 0
  .Endif
  inc timerA

	mov eax, wid
	mov ecx, 0
	sub ecx, vShots
	.If posShot.y < eax ;se o tiro estiver dentro da tela
		mov ecx, vShots
		sub posShot.y, ecx ;diminui a posicao y do tiro
		mov ecx, 0
		.While ecx < posAliensSize
			mov eax, posShot.x
			sub eax, disA.x
			mov edx, posShot.y
			sub edx, disA.y
			.If posAliens[ecx*POINT].y < edx && posAliens[ecx*POINT].x < eax
				sub eax, aliensSize
				sub edx, aliensSize
				.If posAliens[ecx*POINT].y > edx && posAliens[ecx*POINT].x > eax ;se o tiro estiver dentro de um alien
					;falta o caso com alien dentro do tiro
					;mas como o tiro é pequeno isso não influencia muito
					mov eax, wid
					mov edx, hgt
					mov posAliens[ecx*POINT].x, eax ;posicao do alien e setada para fora da tela
					mov posAliens[ecx*POINT].y, edx
					mov posShot.x, eax ;posicao do tiro e setada para fora da tela
					mov posShot.y, edx
          inc points
          mov killed, 1
				.Endif
			.Endif
			inc ecx
		.EndW
	.Else
		mov posShot.y, eax
	.Endif

  mov bigPosA.y, 0
  mov bigPosA.x, 0
  mov ecx, 0
  .While ecx < posAliensSize ;encontra os aliens mais afastados
    mov edx, wid
    mov ebx, hgt
    mov eax, bigPosA.x
    .If posAliens[ecx*POINT].x > eax && posAliens[ecx*POINT].x < edx
      mov eax, posAliens[ecx*POINT].x
      mov bigPosA.x, eax
    .Endif
    mov eax, bigPosA.y
    .If posAliens[ecx*POINT].y > eax && posAliens[ecx*POINT].y < ebx
      mov eax, posAliens[ecx*POINT].y
      mov bigPosA.y, eax
    .Endif
    inc ecx
  .EndW
  mov eax, disA.x
  add bigPosA.x, eax
  mov eax, disA.y
  add bigPosA.y, eax

  .If killed == 1 ;como estavam sendo usados os registradores no if que descobre se os aliens deviam ter morrido
    PlayKilled    ;tive que tocar aqui a musica deles morrendo
    mov killed, 0
  .Endif

  invoke InvalidateRect,hWnd,NULL,FALSE ;chama o metodo de printar a tela

  ret

TimerProc endp

;___________________________________________________________________________

PaintProc proc hWin:DWORD

	  LOCAL hDC   :DWORD
    LOCAL hOld  :DWORD
    LOCAL memDC :DWORD
    LOCAL ps    :PAINTSTRUCT
    LOCAL rect  :RECT 

    ;printa a tela

    invoke BeginPaint,hWnd,ADDR ps
    mov hDC, eax

    invoke CreateCompatibleDC,hDC
    mov memDC, eax
    
    .If gameover == 0
      DrawImage    hDC,hOld,memDC,hBmpB,0,0,dis0,wid,hgt
      DrawImagePos hDC,hOld,memDC,hBmpShip,pos,dis0,shipSize,shipSize
      DrawImagePos hDC,hOld,memDC,hBmpShoot,posShot,dis0,shotsSize,shotsSize
      DrawImages   hDC,hOld,memDC,hBmpA,posAliens,disA,aliensSize,aliensSize,posAliensSize

      invoke GetClientRect,hWnd, ADDR rect 
      mov ecx, cat$(str$(0),chr$("Pontos: "),str$(points),chr$(13, 10))
      inc ecx
      invoke DrawText, hDC, ecx,-1, ADDR rect, DT_SINGLELINE
    .Else
      DrawImage hDC,hOld,memDC,hBmpB,0,0,dis0,wid,hgt
      invoke GetClientRect,hWnd, ADDR rect 
      mov ecx, chr$("GAME OVER")
      invoke DrawText, hDC, ecx,-1, ADDR rect, DT_SINGLELINE or DT_CENTER or DT_VCENTER 
    .Endif

    invoke SelectObject,hDC,hOld
    invoke DeleteDC,memDC

    invoke EndPaint,hWin,ADDR ps

    ret

PaintProc endp

;___________________________________________________________________________

KeyDownProc proc hWin:DWORD, wParam:DWORD

  ;muda as variaveis conforme as teclas são apertadas

	Switch wParam
  		Case VK_LEFT
  			.If pos.x > 40
  				sub pos.x, 5
  			.Endif
    	Case VK_RIGHT
    		mov ebx, wid
    		sub ebx, 70
    		.If pos.x < ebx
  				add pos.x, 5
  			.Endif
    	Case VK_SPACE
			mov eax, wid
			.If posShot.y >= eax ;só é permitido atirar se não houver tiros na tela
        PlayShoot
				mov eax, pos.x
				mov posShot.x, eax
        mov ebx, 2
        mov eax, shipSize
        mov edx, 0
        div ebx
        add posShot.x, eax

				mov eax, pos.y
				mov posShot.y, eax
			.Endif
  	Endsw

  	ret

KeyDownProc endp

;___________________________________________________________________________

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1
    shr wDim, 1
    mov eax, wDim
    sub sDim, eax

    return sDim

TopXY endp

;___________________________________________________________________________

end start