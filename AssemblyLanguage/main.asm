;
; ʹ�û�����Դ���һ���򵥵Ĵ���
; �������ڿͻ������Ե�����ʾ����
;
.386
.model flat, stdcall
.stack 4096

; ���򲿷ֺ궨�壬������Windows.hͷ�ļ����ҵ���Ӧ��ֵ
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


; ����ʹ�õ��ĺ����������������ɣ������������ӵ�ʵ�ʵ�ַ
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

; �ṹ�嶨�壬���������ࡢ�����ꡢ��Ϣ
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
msgBoxtitle			BYTE		"�����˿ͻ���", 0
msgBoxText			BYTE		"ʹ�û�����Ա�д�Ĵ���", 0
msgBoxOKText		BYTE		"�����ˡ�ȷ����",0
msgBoxCancelText	BYTE		"�����ˡ�ȡ����",0

.code
main PROC
	; ����ͼ������ָ��
	invoke		LoadIconA, 0, IDI_APPLICATION
	mov			wc.hIcon, eax
	invoke		LoadCursorA, 0, IDC_ARROW
	mov			wc.hCursor, eax
	invoke		CreateSolidBrush, 00FFFFFFH
	mov			wc.hbrBackground, eax

	; ע�ᴰ����
	invoke		RegisterClassA, ADDR wc

	; ��������
	invoke		CreateWindowExA, 0, ADDR className, ADDR windowtitle, WS_OVERLAPPEDWINDOW,
	CW_USEDEFAULT, CW_USEDEFAULT, 1280, 720, 0, 0, 0, 0
	mov hWnd, eax;

	; ��ʾ����
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

; ���ڹ���
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