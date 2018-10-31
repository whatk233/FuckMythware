#NoTrayIcon
#RequireAdmin
#Region ;**** 由 AccAu3Wrapper_GUI 创建指令 ****
#AccAu3Wrapper_Icon=Ico.ico
#AccAu3Wrapper_Outfile=FuckMythware.exe
#AccAu3Wrapper_UseX64=n
#AccAu3Wrapper_Res_Comment=https://github.com/whatk233/FuckMythware
#AccAu3Wrapper_Res_Description=FuckMythware
#AccAu3Wrapper_Res_Fileversion=1.0.2.2
#AccAu3Wrapper_Res_Fileversion_AutoIncrement=y
#AccAu3Wrapper_Res_ProductVersion=1.0
#AccAu3Wrapper_Res_LegalCopyright=https://github.com/whatk233/FuckMythware
#AccAu3Wrapper_Res_Language=2052
#AccAu3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AccAu3Wrapper_Run_Tidy=y
#AccAu3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/sf=1 /sv=1
#EndRegion ;**** 由 AccAu3Wrapper_GUI 创建指令 ****
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <WinAPIFiles.au3>
If @OSArch = 'x64' Then DllCall("kernel32.dll", "int", "Wow64DisableWow64FsRedirection", "int", 1) ;x64 重定向
Local $SysVer = Number(StringLeft(FileGetVersion(@WindowsDir & "\System32\Kernel32.dll", "ProductVersion"), 3)) ;系统版本，用于判断当前系统
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

#Region ### START Koda GUI section ### Form=
;GUI
$Main = GUICreate("FuckMythware", 320, 235, -1, -1)
$Button1 = GUICtrlCreateButton("获取密码", 25, 20, 115, 30)
$Button4 = GUICtrlCreateButton($Narrator_Btn, 170, 20, 115, 30)
$Button2 = GUICtrlCreateButton("冻结进程", 20, 55, 90, 30)
$Button3 = GUICtrlCreateButton("解冻进程", 115, 55, 90, 30)
$Button5 = GUICtrlCreateButton("结束进程", 210, 55, 90, 30)
Local $State = GUICtrlCreateEdit("FuckMythware" & @CRLF & "极域电子教室辅助工具" & @CRLF & "https://blog.whatk.me    By Whatk " & @CRLF & "https://github.com/whatk233/FuckMythware" & @CRLF & "V1.0.2(181031)" & @CRLF & @CRLF, 5, 100, 305, 120, $WS_VSCROLL + $ES_READONLY)
;~ $Label1 = GUICtrlCreateLabel("关于", 72, 64, 28, 17)
GUISetFont(8, 400, 0, "微软雅黑")
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
	GUICtrlSetState($Button4, $GUI_DISABLE) ;关闭按钮防止重复操作
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
			_ProcessPause()
		Case $Button3
			_ProcessResume()
		Case $Button4
			_Narrator()
		Case $Button5
			_Kill()
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

;冻结进程
Func _ProcessPause()
	GUICtrlSetData($State, @CRLF & "请稍后" & @CRLF, 1)
	Local $ProcessName_Array = StringSplit("StudentMain.exe,GATESRV.exe,MasterHelper.exe,ProcHelper.exe", ",", 2)
	For $ProcessName In $ProcessName_Array
		If ProcessExists($ProcessName) Then ;检测进程是否存在，不存在则不操作
			_ProcessPauseSwitch($ProcessName, True)
		EndIf
	Next
	Sleep(500)
	GUICtrlSetData($State, @CRLF & "冻结完毕！", 1)
EndFunc   ;==>_ProcessPause

;解冻进程
Func _ProcessResume()
	GUICtrlSetData($State, @CRLF & "请稍后" & @CRLF, 1)
	Local $ProcessName_Array = StringSplit("StudentMain.exe,GATESRV.exe,MasterHelper.exe,ProcHelper.exe", ",", 2)
	For $ProcessName In $ProcessName_Array
		If ProcessExists($ProcessName) Then ;检测进程是否存在，不存在则不操作
			_ProcessPauseSwitch($ProcessName, False)
		EndIf
	Next
	Sleep(500)
	GUICtrlSetData($State, @CRLF & "解冻完毕！", 1)
EndFunc   ;==>_ProcessResume

Func _Narrator()
	GUICtrlSetState($Button4, $GUI_DISABLE) ;关闭按钮防止重复操作
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
	GUICtrlSetData($Button4, "恢复讲述人")
	GUICtrlSetState($Button4, $GUI_ENABLE) ;启用按钮
	Return
EndFunc   ;==>_Replace_Narrator

Func _Recovery_Narrator() ;恢复讲述人
	GUICtrlSetState($Button4, $GUI_DISABLE) ;关闭按钮防止重复操作
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
	GUICtrlSetData($Button4, "替换讲述人")
	GUICtrlSetState($Button4, $GUI_ENABLE) ;启用按钮
EndFunc   ;==>_Recovery_Narrator

Func _Kill()
	GUICtrlSetState($Button5, $GUI_DISABLE) ;关闭按钮防止重复操作
	GUICtrlSetData($State, @CRLF & "结束进程中..." & @CRLF, 1)
	FileInstall("ntsd.exe", @TempDir & "\ntsd.exe") ;释放ntsd到临时目录
	Local $ProcessName_Array = StringSplit("StudentMain.exe,GATESRV.exe,MasterHelper.exe,ProcHelper.exe", ",", 2)
	For $ProcessName In $ProcessName_Array
		If ProcessExists($ProcessName) Then ;检测进程是否存在，不存在则不操作
			If $SysVer <> "10.0" Then ;Win10貌似不能用ntsd，所以提示
				_Ntsd($ProcessName) ;Ntsd结束进程
			Else
				GUICtrlSetData($State, @CRLF & "Win10 暂不支持使用 Ntsd 结束带保护进程，我们也在找解决方案" & @CRLF, 1)
			EndIf
			ProcessClose($ProcessName) ;AU3自带函数结束进程
			Sleep(500) ;暂停0.5秒
			If ProcessExists($ProcessName) Then ;检测进程是否存在并返回提示
				GUICtrlSetData($State, @CRLF & "结束 " & StringTrimRight($ProcessName, 4) & " 失败！" & @CRLF, 1)
			Else
				GUICtrlSetData($State, @CRLF & "结束 " & StringTrimRight($ProcessName, 4) & " 成功！" & @CRLF, 1)
			EndIf
		EndIf
	Next
	FileDelete(@TempDir & "\ntsd.exe")
	GUICtrlSetData($State, @CRLF & "结束进程执行完毕！" & @CRLF, 1)
	GUICtrlSetState($Button5, $GUI_ENABLE) ;启用按钮
EndFunc   ;==>_Kill

Func _Ntsd($ProcessName) ;ntsd貌似不支持Win10
	RunWait(@TempDir & "\ntsd.exe -c q -pn " & $ProcessName, "", @SW_HIDE)
EndFunc   ;==>_Ntsd

;https://www.autoitscript.com/forum/topic/60717-process-suspendfreezestop/?do=findComment&comment=456476
;可参考：https://www.autoitscript.com/forum/topic/32975-process-suspendprocess-resume-udf/
Func _ProcessPauseSwitch($iPIDOrName, $iSuspend = True)
	If IsString($iPIDOrName) Then $iPIDOrName = ProcessExists($iPIDOrName)
	If Not $iPIDOrName Then Return SetError(1, 0, 0)
	Local $ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $iPIDOrName)
	If $iSuspend Then
		Local $i_sucess = DllCall("ntdll.dll", "int", "NtSuspendProcess", "int", $ai_Handle[0])
	Else
		Local $i_sucess = DllCall("ntdll.dll", "int", "NtResumeProcess", "int", $ai_Handle[0])
	EndIf
	DllCall('kernel32.dll', 'ptr', 'CloseHandle', 'ptr', $ai_Handle)
	If IsArray($i_sucess) Then Return 1
	Return SetError(2, 0, 0)
EndFunc   ;==>_ProcessPauseSwitch