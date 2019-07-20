;
; 使用汇编语言创建一个简单的窗口
; 单击窗口客户区可以弹出提示窗口
;
.386
.model flat, stdcall
.stack 4096

; 程序部分宏定义，可以在Windows.h头文件中找到相应的值
IDI_APPLICATION		= 32512
IDC_ARROW			= 32512

WS_OVERLAPPEDWINDOW = 13565952
SW_SHOWDEFAULT		= 10

WM_DESTROY			= 0002H
WM_LBUTTONDOWN		= 0201H
CW_USEDEFAULT		= 080000000H

MB_OK                       = 00000000H
MB_OKCANCEL                 = 00000001H
MB_ABORTRETRYIGNORE         = 00000002H
MB_YESNOCANCEL              = 00000003H
MB_YESNO                    = 00000004H
MB_RETRYCANCEL              = 00000005H
MB_CANCELTRYCONTINUE        = 00000006H
MB_ICONHAND                 = 00000010H
MB_ICONQUESTION             = 00000020H
MB_ICONEXCLAMATION          = 00000030H
MB_ICONASTERISK             = 00000040H
MB_USERICON                 = 00000080H
MB_ICONWARNING              = MB_ICONEXCLAMATION
MB_ICONERROR                = MB_ICONHAND

IDOK						= 1
IDCANCEL					= 2
IDABORT						= 3
IDRETRY						= 4
IDIGNORE					= 5
IDYES						= 6
IDNO						= 7
IDCLOSE						= 8
IDHELP						= 9


; 程序使用到的函数声明。声明即可，由链接器链接到实际地址
ExitProcess					PROTO,dwExitCode:DWORD
PostQuitMessage				PROTO,dwExitCode:DWORD
DefWindowProcA				PROTO,hWnd:DWORD,msg:DWORD,wParam:DWORD,lParam:DWORD
LoadIconA					PROTO,hInstance:DWORD,lpIconName:DWORD
LoadCursorA					PROTO,hInstance:DWORD,lpCursorName:DWORD
RegisterClassA				PROTO,lpWndClass:DWORD
CreateWindowExA				PROTO,\
							dwExStyle:DWORD,lpClassName:DWORD,lpWindowName:DWORD,dwStyle:DWORD,\
							X:DWORD,Y:DWORD,nWidth:DWORD,nHeight:DWORD,\
							hWndParent:DWORD,hMenu:DWORD,hInstance:DWORD,lpParam:DWORD,

ShowWindow					PROTO,hWnd:DWORD,CmdShow:DWORD
DispatchMessageA			PROTO,lpMsg:DWORD
GetMessageA					PROTO,:DWORD,:DWORD,:DWORD,:DWORD
CreateSolidBrush			PROTO,:DWORD
MessageBoxA					PROTO,:DWORD,:DWORD,:DWORD,:DWORD

; 结构体定义，包括窗口类、点坐标、消息
WNDCLASS STRUCT
	style					DWORD 	?
	lpfnWndProc				DWORD 	?
	cbClsExtra				DWORD 	?
	cbWndExtra				DWORD 	?
	hInstance				DWORD 	?
	hIcon					DWORD 	?
	hCursor					DWORD 	?
	hbrBackground			DWORD 	?
	lpszMenuName			DWORD 	?
	lpszClassName			DWORD 	?
WNDCLASS ENDS

POINT STRUCT
	x						DWORD 	?
	y						DWORD 	?
POINT ENDS

MSG STRUCT
	hwnd					DWORD 	?
	message					DWORD 	?
	wParam					DWORD 	?
	lParam					DWORD 	?
	time					DWORD 	?
	pt						POINT 	<>
MSG ENDS

.data
windowtitle			BYTE		"Assembly Window", 0
className			BYTE		"mainwindow", 0
wc					WNDCLASS	<0, WinProc, 0, 0, 0, 0, 0, 0, 0, className>
WinMsg				MSG	 		<>
hWnd				DWORD 		?

.data
msgBoxtitle			BYTE		"你点击了客户区", 0
msgBoxText			BYTE		"使用汇编语言编写的窗口", 0
msgBoxOKText		BYTE		"你点击了【确定】",0
msgBoxCancelText	BYTE		"你点击了【取消】",0

.code
main PROC
	; 加载图标和鼠标指针
	invoke		LoadIconA, 0, IDI_APPLICATION
	mov			wc.hIcon, eax
	invoke		LoadCursorA, 0, IDC_ARROW
	mov			wc.hCursor, eax
	invoke		CreateSolidBrush, 00FFFFFFH
	mov			wc.hbrBackground, eax

	; 注册窗口类
	invoke		RegisterClassA, ADDR wc

	; 创建窗口
	invoke		CreateWindowExA, 0, ADDR className, ADDR windowtitle, WS_OVERLAPPEDWINDOW,
	CW_USEDEFAULT, CW_USEDEFAULT, 1280, 720, 0, 0, 0, 0
	mov hWnd, eax;

	; 显示窗口
	invoke		ShowWindow, hWnd, SW_SHOWDEFAULT

Message_Loop :
	invoke		GetMessageA, ADDR WinMsg, 0, 0, 0
	.if			eax == 0
				jmp Exit_Program
	.endif
	invoke		DispatchMessageA, ADDR WinMsg
	jmp			Message_Loop
Exit_Program :
	invoke ExitProcess, 0;
main ENDP

; 窗口过程
WinProc PROC, localhWnd:DWORD,localMsg:DWORD,wParam:DWORD,lParam:DWORD

	mov			eax, localMsg;

	.if			eax == WM_DESTROY
				invoke PostQuitMessage, 0
				jmp WinProcExit
	.endif
	.if			eax == WM_LBUTTONDOWN
				mov ebx, MB_ICONASTERISK
				or  ebx, MB_OKCANCEL
				invoke MessageBoxA, hWnd, ADDR msgBoxText,ADDR msgBoxtitle,ebx

				.if eax == IDOK
					invoke MessageBoxA, hWnd, ADDR msgBoxOKText,ADDR msgBoxtitle,MB_ICONWARNING
				.endif
				.if eax == IDCANCEL
					invoke MessageBoxA, hWnd, ADDR msgBoxCancelText,ADDR msgBoxtitle,MB_ICONWARNING
				.endif
				jmp WinProcExit
	.endif
	invoke DefWindowProcA, localhWnd, localMsg, wParam, lParam

WinProcExit :
	ret;
WinProc ENDP
END main