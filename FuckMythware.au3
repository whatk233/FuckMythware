#NoTrayIcon
#RequireAdmin
#Region ;**** 由 AccAu3Wrapper_GUI 创建指令 ****
#AccAu3Wrapper_Icon=Ico.ico
#AccAu3Wrapper_Outfile=FuckMythware.exe
#AccAu3Wrapper_UseUpx=y
#AccAu3Wrapper_UseX64=n
#AccAu3Wrapper_Res_Comment=https://github.com/whatk233/FuckMythware
#AccAu3Wrapper_Res_Description=FuckMythware
#AccAu3Wrapper_Res_Fileversion=1.0.0.9
#AccAu3Wrapper_Res_Fileversion_AutoIncrement=y
#AccAu3Wrapper_Res_ProductVersion=1.0
#AccAu3Wrapper_Res_LegalCopyright=https://github.com/whatk233/FuckMythware
#AccAu3Wrapper_Res_Language=2052
#AccAu3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AccAu3Wrapper_Run_Tidy=y
#AccAu3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/sf=1 /sv=1
#EndRegion ;**** 由 AccAu3Wrapper_GUI 创建指令 ****
If @OSArch = 'x64' Then DllCall("kernel32.dll", "int", "Wow64DisableWow64FsRedirection", "int", 1) ;x64 重定向
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <WinAPIFiles.au3>
Opt("ExpandEnvStrings", 1) ;更改字符串原意和 % 符号的字面解释方式

;判断程序是否替换为讲述人
If "%Windir%\System32\narrator.exe" = @ScriptFullPath Or "%Windir%\SysWOW64\narrator.exe" = @ScriptFullPath Then ;程序所在目录是否为讲述人所在目录
	Dim $Narrator_Flag = 1
	Dim $Narrator_Btn = "恢复讲述人"
Else
	Dim $Narrator_Flag = 0
	Dim $Narrator_Btn = "替换讲述人"
EndIf

If FileExists("%windir%\system32\narrator.FuckMythware") = 1 Or FileExists("%windir%\SysWOW64\narrator.FuckMythware") = 1 Then ;判断是否存在备份文件
	Dim $Narrator_Flag = 1
	Dim $Narrator_Btn = "恢复讲述人"
Else
	Dim $Narrator_Flag = 0
	Dim $Narrator_Btn = "替换讲述人"
EndIf

FileInstall("ntsd.exe", @TempDir & "\ntsd.exe")
#Region ### START Koda GUI section ### Form=
;GUI
$Main = GUICreate("FuckMythware", 295, 235, -1, -1)
$Button1 = GUICtrlCreateButton("获取密码", 16, 24, 80, 33)
$Button2 = GUICtrlCreateButton("强制结束", 103, 24, 80, 33)
$Button3 = GUICtrlCreateButton($Narrator_Btn, 193, 24, 80, 33)
Local $State = GUICtrlCreateEdit("FuckMythware" & @CRLF & "极域电子教室辅助工具" & @CRLF & "https://blog.whatk.me    By Whatk " & @CRLF & "https://github.com/whatk233/FuckMythware V1.0(20180918)" & @CRLF & @CRLF, 5, 100, 280, 120, $WS_VSCROLL + $ES_READONLY)
;~ $Label1 = GUICtrlCreateLabel("关于", 72, 64, 28, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
If ProcessExists("StudentMain.exe") = True Then
	$JY_PID = ProcessList("StudentMain.exe")
	GUICtrlSetData($State, @CRLF & "极域电子教室正在运行 PID为：" & $JY_PID[1][1], 1)
Else
	GUICtrlSetData($State, @CRLF & "极域电子教室未运行", 1)
EndIf

;判断是否需要恢复讲述人
If FileExists(@TempDir & "\FuckMythware.Recovery") = 1 Then
	FileDelete(@TempDir & "\FuckMythware.Recovery") ;删除Flag文件
	GUICtrlSetState($Button3, $GUI_DISABLE) ;关闭按钮防止重复操作
	GUICtrlSetData($State, @CRLF & @CRLF & "即将恢复讲述人，请稍后", 1)
	Sleep(1500) ;延时防止没完全退出
	_Recovery_Narrator() ;恢复
EndIf

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button1
			_GetPwd()
		Case $Button2
			_Kill()
		Case $Button3
			_Narrator()
	EndSwitch
WEnd
;获取密码
Func _GetPwd()
	;从注册表中读取密码
	Local $Pwd1 = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\TopDomain\e-learning Class Standard\1.00", "UninstallPasswd")
	Local $Pwd2 = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\TopDomain\e-Learning Class Standard\1.00", "UninstallPasswd")
	;切割
	$Pwd1 = StringTrimLeft($Pwd1, 6)
	$Pwd2 = StringTrimLeft($Pwd2, 6)
	If $Pwd1 <> "" Then
		GUICtrlSetData($State, @CRLF & "管理员密码为：" & @CRLF, 1)
		GUICtrlSetData($State, $Pwd1 & @CRLF, 1)
	EndIf
	If $Pwd2 <> "" Then
		GUICtrlSetData($State, @CRLF & "管理员密码为：" & @CRLF, 1)
		GUICtrlSetData($State, $Pwd2 & @CRLF, 1)
	EndIf
	If $Pwd1 = "" And $Pwd2 = "" Then
		GUICtrlSetData($State, @CRLF & @CRLF & "密码获取失败，可能没安装极域或不适用当前版本，如有问题请提 issues" & @CRLF, 1)
	EndIf
EndFunc   ;==>_GetPwd

;结束进程
Func _Kill()
	GUICtrlSetData($State, @CRLF & "请稍后" & @CRLF, 1)
	;使用ntsd结束进程
	$JY_PID = ProcessList("StudentMain.exe")
	RunWait(@ComSpec & " /c " & @TempDir & '\ntsd.exe -c q -pn StudentMain.exe', @SW_HIDE)
	;用Autoit函数结束进程
	ProcessClose("StudentMain.exe")
	ProcessClose("GATESRV.exe")
	ProcessClose("MasterHelper.exe")
	ProcessClose("ProcHelper.exe")
	Sleep(1000)
	If ProcessExists("StudentMain.exe") = False Then
		GUICtrlSetData($State, @CRLF & "结束成功！", 1)
	Else
		GUICtrlSetData($State, @CRLF & "结束失败！", 1)
	EndIf
EndFunc   ;==>_Kill

Func _Narrator()
	GUICtrlSetState($Button3, $GUI_DISABLE) ;关闭按钮防止重复操作
	If $Narrator_Flag = 0 Then ;如果Flag为关闭（没替换讲述人）则替换
		_Replace_Narrator()
		Return
	EndIf
	If $Narrator_Flag = 1 Then ;如果Flag为开启（已替换讲述人）则恢复
		_Recovery_Narrator()
		Return
	EndIf
EndFunc   ;==>_Narrator

Func _Replace_Narrator() ;替换讲述人
	GUICtrlSetData($State, @CRLF & "替换讲述人为本程序中..." & @CRLF, 1)
	If FileExists("%Windir%\System32\narrator.exe") = 1 Then ;如果 System32 的讲述人存在则替换
		;提示
		GUICtrlSetData($State, @CRLF & "正在替换：" & @CRLF & "%Windir%\System32\narrator.exe", 1)
		Sleep(500)
		;用于后面校对用
		Local $Narrator_Size = FileGetSize("%Windir%\System32\narrator.exe")
		;提权
		GUICtrlSetData($State, @CRLF & "提权（1/2）", 1)
		RunWait(@ComSpec & " /c " & 'takeown /f "%windir%\system32\narrator.exe"')
		GUICtrlSetData($State, @CRLF & "提权（2/2）", 1)
		RunWait(@ComSpec & " /c " & 'icacls "%windir%\system32\narrator.exe" /grant administrators:F')
		;备份原讲述人
		GUICtrlSetData($State, @CRLF & "备份讲述人中...", 1)
		FileMove("%windir%\system32\narrator.exe", "%windir%\system32\narrator.FuckMythware", 1)
		If FileExists("%windir%\system32\narrator.FuckMythware") = 1 Then
			GUICtrlSetData($State, @CRLF & "备份完毕！文件名为：" & @CRLF & "%windir%\system32\narrator.FuckMythware", 1)
		Else
			GUICtrlSetData($State, @CRLF & "备份失败！终止操作！", 1) ;安全起见
			Return
		EndIf
		;替换
		GUICtrlSetData($State, @CRLF & "开始替换", 1) ;安全起见
		FileCopy(@ScriptFullPath, "%windir%\system32\narrator.exe")
		;校对是否替换完毕
		If FileGetSize("%Windir%\System32\narrator.exe") = $Narrator_Size Then ;替换失败则
			GUICtrlSetData($State, @CRLF & "替换失败！", 1)
			Return
		EndIf
		;提示
		GUICtrlSetData($State, @CRLF & "%Windir%\system32\narrator.exe" & @CRLF & "替换完毕！" & @CRLF, 1)
		Sleep(500)
	EndIf
	
	If FileExists("%Windir%\SysWOW64\narrator.exe") = 1 Then ;如果 SysWOW64 的讲述人存在则替换
		;提示
		GUICtrlSetData($State, @CRLF & "正在替换：" & @CRLF & "%Windir%\SysWOW64\narrator.exe", 1)
		Sleep(500)
		;用于后面校对用
		Local $Narrator_Size = FileGetSize("%Windir%\SysWOW64\narrator.exe")
		;提权
		GUICtrlSetData($State, @CRLF & "提权（1/2）", 1)
		RunWait(@ComSpec & " /c " & 'takeown /f "%windir%\SysWOW64\narrator.exe"')
		GUICtrlSetData($State, @CRLF & "提权（2/2）", 1)
		RunWait(@ComSpec & " /c " & 'icacls "%windir%\SysWOW64\narrator.exe" /grant administrators:F')
		;备份原讲述人
		GUICtrlSetData($State, @CRLF & "备份讲述人中...", 1)
		FileMove("%windir%\SysWOW64\narrator.exe", "%windir%\SysWOW64\narrator.FuckMythware", 1)
		If FileExists("%windir%\SysWOW64\narrator.FuckMythware") = 1 Then
			GUICtrlSetData($State, @CRLF & "备份完毕！文件名为：" & @CRLF & "%windir%\SysWOW64\narrator.FuckMythware", 1)
		Else
			GUICtrlSetData($State, @CRLF & "备份失败！终止操作！", 1) ;安全起见
			Return
		EndIf
		;替换
		GUICtrlSetData($State, @CRLF & "开始替换", 1) ;安全起见
		FileCopy(@ScriptFullPath, "%windir%\SysWOW64\narrator.exe")
		;校对是否替换完毕
		If $Narrator_Size <> FileGetSize("%Windir%\SysWOW64\narrator.exe") Then ;替换失败则
			GUICtrlSetData($State, @CRLF & "替换失败！", 1)
			Return
		EndIf
		;提示
		GUICtrlSetData($State, @CRLF & "%Windir%\SysWOW64\narrator.exe" & @CRLF & "完毕！" & @CRLF, 1)
		Sleep(500)
	EndIf
	;替换完毕操作
	FileDelete(@TempDir & "\FuckMythware.Recovery") ;删除Flag文件
	$Narrator_Flag = 1 ;设置flag为替换完毕
	GUICtrlSetData($State, @CRLF & "替换完毕！", 1)
	GUICtrlSetData($Button3, "恢复讲述人")
	GUICtrlSetState($Button3, $GUI_ENABLE) ;启用按钮
	Return
EndFunc   ;==>_Replace_Narrator

Func _Recovery_Narrator() ;恢复讲述人
	GUICtrlSetState($Button3, $GUI_DISABLE) ;关闭按钮防止重复操作
	If "%Windir%\System32\narrator.exe" = @ScriptFullPath Or "%Windir%\SysWOW64\narrator.exe" = @ScriptFullPath Then ;如果自身目录为讲述人目录则复制到别处在进行替换操作)
		MsgBox(0, "FuckMythware", "当前程序作为讲述人模式打开，无法进行恢复" & @CRLF & "点击“确定”后程序将复制自身到桌面再进行“恢复讲述人”")
		Local $New_World = "FuckMythware_" & @MON & @MDAY & @HOUR & @MIN & ".exe" ;文件名
		FileCopy(@ScriptFullPath, @DesktopDir & "\" & $New_World, 1) ;复制自身到桌面
		;写入flag文件，以便启动后恢复讲述人
		Local $Recovery_File_Flag = FileOpen(@TempDir & "\FuckMythware.Recovery", 2)
		FileWrite($Recovery_File_Flag, "FuckMythware.Recovery")
		GUISetState(@SW_HIDE) ;隐藏窗口
		Sleep(500)
		Run(@DesktopDir & "\" & $New_World) ;启动新程序
		Exit
	EndIf
	If FileExists("%windir%\system32\narrator.FuckMythware") = 1 Or FileExists("%windir%\SysWOW64\narrator.FuckMythware") = 1 Then ;判断是否存在备份文件
		GUICtrlSetData($State, @CRLF & "开始恢复讲述人", 1)
		If FileExists("%windir%\system32\narrator.FuckMythware") = 1 Then ;恢复 System32 的讲述人
			FileDelete("%windir%\system32\narrator.exe") ;删除假人
			FileMove("%windir%\system32\narrator.FuckMythware", "%windir%\system32\narrator.exe", 1) ;恢复
			If @error = 0 Then ;判断是否成功
				GUICtrlSetData($State, @CRLF & '位于 "System32" 的讲述人已恢复完毕！', 1)
			Else
				GUICtrlSetData($State, @CRLF & '位于 "System32" 的讲述人已恢复失败！', 1)
			EndIf
		EndIf
		If FileExists("%windir%\SysWOW64\narrator.FuckMythware") = 1 Then ;恢复 SysWOW64 的讲述人
			FileDelete("%windir%\SysWOW64\narrator.exe") ;删除假人
			FileMove("%windir%\SysWOW64\narrator.FuckMythware", "%windir%\SysWOW64\narrator.exe", 1) ;恢复
			If @error = 0 Then ;判断是否成功
				GUICtrlSetData($State, @CRLF & '位于 "SysWOW64" 的讲述人已恢复完毕！', 1)
			Else
				GUICtrlSetData($State, @CRLF & '位于 "SysWOW64" 的讲述人已恢复失败！', 1)
			EndIf
		EndIf
	Else
		GUICtrlSetData($State, @CRLF & "备份文件不存在！无法恢复！", 1)
		Return
	EndIf
	$Narrator_Flag = 0 ;设置flag为未替换
	GUICtrlSetData($State, @CRLF & '完毕！', 1)
	GUICtrlSetData($Button3, "替换讲述人")
	GUICtrlSetState($Button3, $GUI_ENABLE) ;启用按钮
EndFunc   ;==>_Recovery_Narrator

