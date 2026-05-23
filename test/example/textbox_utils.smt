' -------------------------------------------------------------------
' -------------------------------------------------------------------
' -------------------------------------------------------------------
' ------------------------- smbx 38a 动态文本框实现 - xiaodou 20250606
' ------------------------- 该脚本基于字符贴图集绘制脚本 TXT_ 实现
' ------------------------- 请确保您预先将其导入进关卡环境中并运行了....
' -------------------------------------------------------------------
' ----------------------------------------------------- lite text box config
Dim __lBox_char_npcId As Long = 1           ' 字符素材 npc id
Dim __lBox_bmpIdStart As Long = 20000       ' bmp 起始 id
Dim __lBox_defaultZpos As Double = 0.5      ' 默认 zpos
Dim __lBox_9Grid_npcId As Long = 2          ' 九宫格素材 npc id
Dim __lBox_9Grid_x As Long = 0
Dim __lBox_9Grid_y As Long = 0
Dim __lBox_9Grid_w As Long = 18             '    a   w   c
Dim __lBox_9Grid_h As Long = 18             '  b ┌┬─────┬─┐
Dim __lBox_9Grid_a As Long = 07             '    ├┼─────┼─┤
Dim __lBox_9Grid_b As Long = 07             '    ││     │ │ h
Dim __lBox_9Grid_c As Long = 07             '    ├┼─────┼─┤
Dim __lBox_9Grid_d As Long = 07             '    └┴─────┴─┘ d ---- 九宫格六个参数
Dim __lBox_max_char As Integer = 200        ' 最大字符数

' ----------------------------------------------------- text box config
Dim __msg_bmpIdStart As Long = 10000       ' bmp 起始 id, 该类一共需要申请 10 个 bmp, +1~9 为九宫格, +0 为头像
Dim __msg_defaultZpos As Double = 0.51     ' 默认 zpos
Dim __msg_9Grid_npcId As Long = 2          ' 九宫格素材 npc id
Dim __msg_9Grid_x As Long = 0
Dim __msg_9Grid_y As Long = 0
Dim __msg_9Grid_w As Long = 18             '    a   w   c
Dim __msg_9Grid_h As Long = 18             '  b ┌┬─────┬─┐
Dim __msg_9Grid_a As Long = 07             '    ├┼─────┼─┤
Dim __msg_9Grid_b As Long = 07             '    ││     │ │ h
Dim __msg_9Grid_c As Long = 07             '    ├┼─────┼─┤
Dim __msg_9Grid_d As Long = 07             '    └┴─────┴─┘ d ---- 九宫格六个参数
Dim __msg_animSpeed As Double = 1 / 12     ' 动画参数增量

' ----------------------------------------------------- rich text config
Dim __box_npc As Long = 1                             ' 文本贴图集
Dim __box_bmpStart As Long = __msg_bmpIdStart + 10    ' 文本 bmp 起始 id
Dim __box_bmpZpos As Double = 0.5                     ' 文本 zpos

Dim __box_wid As Integer = 600                        ' 文本框宽度限制, -1 为无限制 [-1, 10000]
Dim __box_hei As Integer = -1                         ' 文本框高度限制, -1 为无限制 [-1, 10000]
Dim __box_posX As Integer = 100                       ' 文本框位置 (屏幕坐标) [-10000, 10000]
Dim __box_posY As Integer = 100                       ' 文本框位置 (屏幕坐标) [-10000, 10000]
Dim __box_size As Integer = 24                        ' 文本基础大小 [0, 10000]
Dim __box_charSpacing As Integer = 0                  ' 字符间距 [-10000, 10000]
Dim __box_lineSpacing As Integer = 2                  ' 行距 [-10000, 10000]
Dim __box_alignType As Integer = 0                    ' 对齐方式 default-left | 1-right | 2-mid

' ----------------------------------------------------- event

Dim __box_eventScriptName As String = ""              ' 事件监听脚本名 (为空时不派发事件)

Dim __eventValue As String = "" ' 事件值
Dim __eventState As Long = 0    ' 事件类型

' 播放下一个字符 (每播放一组可见字符派发一次该事件)
' value 参数: 使用 AscW(TextboxEvent_GetValue()) 可获得具体步进了几个字符 (其中包含 flag 字符)
Export Script TextboxEvent_OnNext(Return Long)
    Return __eventState And 1
End Script

' 切换头像或对话框事件 (在提交新对话后, 当动画播放到新对话框展开前会触发一次该事件)
Export Script TextboxEvent_OnChangeBox(Return Long)
    Return __eventState And 2
End Script

' 获取事件数据
Export Script TextboxEvent_GetValue(Return String)
    Return __eventValue & ""
End Script

Dim __exit As Integer = 0 ' 退出 textbox

' 结束 Textbox 生命周期
Export Script Textbox_Exit()
    __exit = -1
End Script

' -----------------------------------------------------
' -----------------------------------------------------
' -----------------------------------------------------
' -----------------------------------------------------
' ----------------------------------------------------- temp var

Dim __box_tempIA As Long = 0
Dim __box_tempIB As Long = 0
Dim __box_tempIC As Long = 0
Dim __box_tempID As Long = 0
Dim __box_tempIE As Long = 0
Dim __box_tempIF As Long = 0
Dim __box_tempIG As Long = 0
Dim __box_tempIH As Long = 0
Dim __box_tempII As Long = 0
Dim __box_tempIJ As Long = 0
Dim __box_tempIK As Long = 0
Dim __box_tempIL As Long = 0
Dim __box_tempIM As Long = 0
Dim __box_tempIN As Long = 0
Dim __box_tempDA As Double = 0
Dim __box_tempDB As Double = 0
Dim __box_tempSA As String = 0
Dim __box_tempSB As String = 0

' -----------------------------------------------------
' -----------------------------------------------------
' -----------------------------------------------------
' -----------------------------------------------------
' ----------------------------------------------------- content rich text

' ----------------------------------------------------- render var
Dim __s As String = ""
Dim __len As Long = 0

Dim __exSizeX As Integer = 0
Dim __exSizeY As Integer = 0
Dim __posSeekX As Long = 0
Dim __posSeekY As Long = 0

Dim __lineEnd As Integer = 0
Dim __seek As Integer = 0 ' 1 ~ 10000
Dim __seekDelay As Integer = 0

Dim __currBmpCnt As Integer = 0
Dim __currUsedBmpCnt As Integer = 0
Dim __endLineSeek As Integer = 1
Dim __realLineHeight As Integer = 0
Dim __realCharSpacing As Double = 0

Dim __timestamp As Long = 0
Dim __isInDrawToSeek As Integer = 0

Dim __eventInfo As String = ""

' ----------------------------------------------------- state var
Dim __shakeChars As String = 0
Dim __swingChars As String = 0

Dim __page As Integer = 0
Dim __wait As Integer = 0
Dim __shakeOrSwing As Integer = 0

Dim __speed As Integer = 0
Dim __shake As Integer = 0
Dim __swing As Integer = 0
Dim __sizeOffset As Integer = 0

Dim __colR As Integer = -1
Dim __colG As Integer = -1
Dim __colB As Integer = -1
Dim __colA As Integer = 255

' animFac: -4 | [-1, 1]
Dim __animFac As Double = -4

' ----------------------------------------------------- internal function
Script __txtBox_Max(a As Double, b As Double, Return Double)
    If a > b Then
        Return a
    End If
    Return b
End Script

Script __txtBox_Rnd(seed As Double, Return Double)
    seed = sin(seed + 18694.2233) * 0.153
    If seed > 0 Then
        Return seed - Int(seed)
    Else
        Return seed + Int(seed)
    End If
End Script

Script __txtBox_Min(a As Double, b As Double, Return Double)
    If a < b Then
        Return a
    End If
    Return b
End Script

Script __txtBox_ReadFlagVal(c As String, startIdx As Long, Return Integer)
    __box_tempSA = Mid(c, startIdx, 1)
    If __box_tempSA = "+" Then
        __box_tempSA = Mid(c, startIdx + 1, 2)
        startIdx = Ascw(__box_tempSA)
        If startIdx >= 48 And startIdx <= 57 Then
            Return startIdx - 48
        ElseIf startIdx >= 65 And startIdx <= 90 Then
            Return startIdx - 55
        ElseIf startIdx >= 97 And startIdx <= 122 Then
            Return startIdx - 87
        End If
    ElseIf __box_tempSA = "-" Then
        __box_tempSA = Mid(c, startIdx + 1, 2)
        startIdx = Ascw(__box_tempSA)
        If startIdx >= 48 And startIdx <= 57 Then
            Return 48 - startIdx
        ElseIf startIdx >= 65 And startIdx <= 90 Then
            Return 55 - startIdx
        ElseIf startIdx >= 97 And startIdx <= 122 Then
            Return 87 - startIdx
        End If
    End If
    Return -10000
End Script

Script __txtBox_ReadColorFlagVal(c As String, startIdx As Long, Return Integer)
    __box_tempIE = AscW(Mid(c, startIdx, 1))
    startIdx = AscW(Mid(c, startIdx + 1, 1))
    If startIdx >= 48 And startIdx <= 57 Then
        startIdx = __txtBox_Min(startIdx - 48, 16)
    ElseIf startIdx >= 65 And startIdx <= 70 Then
        startIdx = __txtBox_Min(startIdx - 55, 16)
    ElseIf startIdx >= 97 And startIdx <= 102 Then
        startIdx = __txtBox_Min(startIdx - 87, 16)
    Else
        Return -1
    End If
    If __box_tempIE >= 48 And __box_tempIE <= 57 Then
        Return startIdx + __txtBox_Min(__box_tempIE - 48, 16) * 16
    ElseIf __box_tempIE >= 65 And __box_tempIE <= 70 Then
        Return startIdx + __txtBox_Min(__box_tempIE - 55, 16) * 16
    ElseIf __box_tempIE >= 97 And __box_tempIE <= 102 Then
        Return startIdx + __txtBox_Min(__box_tempIE - 87, 16) * 16
    End If
    Return -1
End Script

Script __txtBox_SetupFlag(flag As String, Return Integer)
    __box_tempIE = len(flag)
    If __box_tempIE <= 0 Then
        Return 0
    End If

    ' n
    ' 换行符不修改任何 state

    ' #
    __box_tempSB = Mid(flag, 1, 1)
    If __box_tempSB = "#" Then
        __colA = 255
        If __box_tempIE > 6 Then
            __colR = __txtBox_ReadColorFlagVal(flag, 2)
            __colG = __txtBox_ReadColorFlagVal(flag, 4)
            __colB = __txtBox_ReadColorFlagVal(flag, 6)
            If __box_tempIE > 8 Then
                __colA = __txtBox_ReadColorFlagVal(flag, 8)
            End If
            Return 0
        End If
        __colR = -1
        Return 0
    End If

    ' $
    If __box_tempSB = "$" Then
        If __box_tempIE > 1 And __isInDrawToSeek = 0 Then
            __eventInfo = ""
            For __box_tempIH = 2 To __box_tempIE Step 1
                __box_tempSB = Mid(flag, __box_tempIH, 1)
                If __box_tempSB = ":" Or __box_tempIH = __box_tempIE Then
                    __eventInfo = Mid(flag, __box_tempIH + 1, __box_tempIE - __box_tempIH)
                    __box_tempSB = Mid(flag, 2, __box_tempIH - 2)
                    Exit For
                End If
            Next
            If __box_tempSB <> "" Then
                Call EXEScript(__box_tempSB)
            End If
        End If
        Return 0
    End If

    ' size
    If __box_tempSB = "s" Then
        __sizeOffset = 0
        If __box_tempIE < 3 Then
            Return 0
        End If
        __box_tempIH = __txtBox_ReadFlagVal(flag, 2)
        If __box_tempIH < 40 And __box_tempIH > -40 Then
            __sizeOffset = __box_tempIH
        End If
        Return 0
    End If

    ' wait
    If __box_tempSB = "?" Then
        __wait = 1
        Return 0
    ' page
    ElseIf __box_tempSB = "p" Then
        __page = 1
        Return 0
    End If

    ' shake
    If __box_tempSB = "!" Then
        __shake = 0
        If __box_tempIE < 3 Then
            Return 0
        End If
        __box_tempIH = __txtBox_ReadFlagVal(flag, 2)
        If __box_tempIH < 40 And __box_tempIH > -40 Then
            __shake = __box_tempIH
        End If
        Return 0
    End If

    ' swing
    If __box_tempSB = "~" Then
        __swing = 0
        If __box_tempIE < 3 Then
            Return 0
        End If
        __box_tempIH = __txtBox_ReadFlagVal(flag, 2)
        If __box_tempIH < 40 And __box_tempIH > -40 Then
            __swing = __box_tempIH
        End If
        Return 0
    End If

    ' speed
    If __box_tempSB = ">" Then
        __speed = 0
        __seekDelay = 0
        If __box_tempIE < 3 Then
            Return 0
        End If
        __box_tempIH = __txtBox_ReadFlagVal(flag, 2)
        If __box_tempIH < 40 And __box_tempIH > -40 Then
            If __isInDrawToSeek = 0 Then
                __speed = __box_tempIH
                __seekDelay = __speed
            End If
        End If
        Return 0
    End If

    ' 下面是 2 个字符的 flag
    If __box_tempIE < 2 Then
        Return 0
    End If
    __box_tempSB = Mid(flag, 1, 4)

    ' exsize
    If __box_tempSB = "+s" Then
        __exSizeX = 0
        __exSizeY = 0
        If __box_tempIE < 4 Then
            Return 0
        End If
        __box_tempIH = __txtBox_ReadFlagVal(flag, 3)
        If __box_tempIH < 40 And __box_tempIH > -40 Then
            __exSizeX = __box_tempIH
        End If
        If __box_tempIE < 6 Then
            Return 0
        End If
        __box_tempIH = __txtBox_ReadFlagVal(flag, 5)
        If __box_tempIH < 40 And __box_tempIH > -40 Then
            __exSizeY = __box_tempIH
        End If
        Return 0
    End If
    Return 0
End Script

Script __txtBox_PreProcessingLine()
    __box_tempIB = 0 ' widCnt
    __box_tempID = __sizeOffset ' sizeOffset
    __box_tempIF = __box_lineSpacing + __box_size ' maxHeight
    __realCharSpacing = __box_charSpacing
    __box_tempIL = __exSizeX ' exSizeX
    __box_tempIM = __exSizeY ' exSizeY
    For __box_tempIA = __seek To __len Step 1
        __box_tempIC = TXT_GetId(__box_tempIA)
        __box_tempIE = TXT_IsFlag(__box_tempIC)
        If __box_tempIE <> 0 Then
            If __box_tempIE = 1 Then
                __box_tempSA = TXT_GetFlag(__box_tempIC)
                __box_tempIE = len(__box_tempSA)
                If __box_tempIE <= 0 Then
                    Continue
                End If
                __box_tempSB = Mid(__box_tempSA, 1, 1)
                If __box_tempSB = "n" And __seek <> __box_tempIA Then
                    Exit For
                End If
                If __box_tempSB = "s" Then
                    __box_tempID = 0
                    If __box_tempIE < 3 Then
                        Continue
                    End If
                    __box_tempIH = __txtBox_ReadFlagVal(__box_tempSA, 2)
                    If __box_tempIH < 40 And __box_tempIH > -40 Then
                        __box_tempID = __box_tempIH
                    End If
                    Continue
                End If
                If __box_tempSB = "p" Then
                    If __box_tempIB = 0 Then
                        Continue
                    End If
                    Exit For
                End If
                If __box_tempIE < 2 Then
                    Continue
                End If
                __box_tempSB = Mid(__box_tempSA, 1, 2)
                If __box_tempSB = "+s" Then
                    __box_tempIL = 0
                    __box_tempIM = 0
                    If __box_tempIE < 4 Then
                        Continue
                    End If
                    __box_tempIH = __txtBox_ReadFlagVal(__box_tempSA, 3)
                    If __box_tempIH > -40 And __box_tempIH < 40 Then
                        __box_tempIL = __box_tempIH
                    End If
                    If __box_tempIE < 6 Then
                        Continue
                    End If
                    __box_tempIH = __txtBox_ReadFlagVal(__box_tempSA, 5)
                    If __box_tempIH > -40 And __box_tempIH < 40 Then
                        __box_tempIM = __box_tempIH
                    End If
                End If
            End If
            Continue
        End If
        __box_tempDA = __txtBox_Max(__box_tempID + __box_size, 0.0)
        __box_tempIG = __box_tempIB + (TXT_GetCharSize(__box_tempIC) + __box_charSpacing) * (__box_tempDA / TXT_GetCharSize(-1)) + __box_tempIL * 2
        If __box_wid > 0 And __box_tempIG > __box_wid Then
            Exit For
        End If
        __box_tempIB = __box_tempIG
        If __box_tempDA + __box_tempIM > __box_tempIF Then
            __box_tempIF = __box_tempDA + __box_tempIM
        End If
    Next
    Select Case __box_alignType
        Case 1
            __posSeekX = __box_posX + __box_wid - __box_tempIB
        Case 2
            __posSeekX = __box_posX + (__box_wid - __box_tempIB) / 2
        Case Else
            __posSeekX = __box_posX
    End Select
    __realLineHeight = __box_tempIF
    __posSeekY += __realLineHeight + __box_lineSpacing
    __lineEnd = __box_tempIA - 1
End Script

Script __txtBox_PushShake(bId As Integer, x As Integer, y As Integer, p As Integer, Return Integer)
    If bId > 10000 Or bId < -10000 Then
        Return -1
    End If
    If x > 10000 Or x < -10000 Then
        x = -10000
    End If
    If y > 10000 Or y < -10000 Then
        y = -10000
    End If
    If p > 10000 Or p < -10000 Then
        p = -10000
    End If
    __shakeChars = __shakeChars & ChrW(bId + 10000) & ChrW(x + 10000) & ChrW(y + 10000) & ChrW(p + 10000)
    __shakeOrSwing = 1
    Return 0
End Script

Script __txtBox_PushSwing(bId As Integer, x As Integer, y As Integer, p As Integer, Return Integer)
    If bId > 10000 Or bId < -10000 Then
        Return -1
    End If
    If x > 10000 Or x < -10000 Then
        x = -10000
    End If
    If y > 10000 Or y < -10000 Then
        y = -10000
    End If
    If p > 10000 Or p < -10000 Then
        p = -10000
    End If
    __swingChars = __swingChars & ChrW(bId + 10000) & ChrW(x + 10000) & ChrW(y + 10000) & ChrW(p + 10000)
    __shakeOrSwing = 1
    Return 0
End Script

Script __txtBox_NewBmp()
    For __box_tempIA = 1 To 10 Step 1
        Call BMPCreate(__box_tempIA + __currBmpCnt + __box_bmpStart, __box_npc, 1, 0,     0, 0, 0, 0,     0, 0, 0, 0,     0, 0,     0, -1)
        Bitmap(__box_tempIA + __currBmpCnt + __box_bmpStart).blendmode = 0
    Next
    __currBmpCnt += 10
End Script

Script __txtBox_HideBmp()
    __shakeChars = ""
    __swingChars = ""
    __shakeOrSwing = 0
    For __box_tempIA = 1 To __currBmpCnt Step 1
        Bitmap(__box_tempIA + __box_bmpStart).hide = 1
    Next
    __currUsedBmpCnt = 0
End Script

Script __txtBox_ClearBmp()
    __shakeChars = ""
    __swingChars = ""
    __shakeOrSwing = 0
    For __box_tempIA = 1 To __currBmpCnt Step 1
        Call BErase(2, __box_tempIA + __box_bmpStart)
    Next
    __currBmpCnt = 0
    __currUsedBmpCnt = 0
End Script

Script __txtBox_UpdateShakeAnim(Return Integer)
    If __shakeOrSwing = 0 Then
        Return 0
    End If
    If __shakeChars = "" Then
        Return 0
    End If
    __box_tempIA = Len(__shakeChars) / 4
    If __box_tempIA <= 0 Then
        Return 0
    End If

    For __box_tempIB = 1 To __box_tempIA Step 1
        __box_tempIC = __box_tempIB * 4
        __box_tempID = AscW(Mid(__shakeChars, __box_tempIC - 3, 1)) - 10000 ' bid
        __box_tempIE = AscW(Mid(__shakeChars, __box_tempIC - 2, 1)) - 10000 ' x
        __box_tempIF = AscW(Mid(__shakeChars, __box_tempIC - 1, 1)) - 10000 ' y
        __box_tempIG = AscW(Mid(__shakeChars, __box_tempIC - 0, 1)) - 10000 ' p
        __box_tempID += __box_bmpStart
        Bitmap(__box_tempID).destx = __box_tempIE + Cos(__timestamp * 2 + __txtBox_Rnd(__box_tempIB - __timestamp)) * __box_tempIG * 0.5
        Bitmap(__box_tempID).desty = __box_tempIF + Sin(__timestamp * 2 + __txtBox_Rnd(__box_tempIB + __timestamp)) * __box_tempIG * 0.5
    Next
    Return 0
End Script

Script __txtBox_UpdateSwingAnim(Return Integer)
    If __shakeOrSwing = 0 Then
        Return 0
    End If
    If __swingChars = "" Then
        Return 0
    End If
    __box_tempIA = Len(__swingChars) / 4
    If __box_tempIA <= 0 Then
        Return 0
    End If

    For __box_tempIB = 1 To __box_tempIA Step 1
        __box_tempIC = __box_tempIB * 4
        __box_tempID = AscW(Mid(__swingChars, __box_tempIC - 3, 1)) - 10000 ' bid
        __box_tempIE = AscW(Mid(__swingChars, __box_tempIC - 2, 1)) - 10000 ' x
        __box_tempIF = AscW(Mid(__swingChars, __box_tempIC - 1, 1)) - 10000 ' y
        __box_tempIG = AscW(Mid(__swingChars, __box_tempIC - 0, 1)) - 10000 ' p
        __box_tempID += __box_bmpStart
        Bitmap(__box_tempID).destx = __box_tempIE + Cos(__timestamp * 0.1 + __box_tempIB * 0.4) * __box_tempIG
        Bitmap(__box_tempID).desty = __box_tempIF + Sin(__timestamp * 0.1 + __box_tempIB * 0.4) * __box_tempIG
    Next
    Return 0
End Script

Script __txtBox_InternalForceDrawChar(charCode As Integer, Return Integer)
    __box_tempIB = charCode
    If __currUsedBmpCnt >= __currBmpCnt Then
        Call __txtBox_NewBmp()
    End If

    __currUsedBmpCnt += 1
    __box_tempIA = __currUsedBmpCnt + __box_bmpStart
    Bitmap(__box_tempIA).hide = 0
    Bitmap(__box_tempIA).zpos = __box_bmpZpos
    Bitmap(__box_tempIA).scrwidth = TXT_GetCharSize(__box_tempIB)
    Bitmap(__box_tempIA).scrheight = TXT_GetCharSize(-1)
    Bitmap(__box_tempIA).scrx = TXT_GetDestX(__box_tempIB)
    Bitmap(__box_tempIA).scry = TXT_GetDestY(__box_tempIB)
    Bitmap(__box_tempIA).scalex = __txtBox_Max(__sizeOffset + __box_size, 0.0) / TXT_GetCharSize(-1)
    Bitmap(__box_tempIA).scaley = Bitmap(__box_tempIA).scalex

    If __colB >= 0 And __colR >= 0 And __colG >= 0 Then
        Bitmap(__box_tempIA).forecolor_r = __colR
        Bitmap(__box_tempIA).forecolor_g = __colG
        Bitmap(__box_tempIA).forecolor_b = __colB
        Bitmap(__box_tempIA).forecolor_a = __colA
    Else
        Bitmap(__box_tempIA).forecolor_r = 255
        Bitmap(__box_tempIA).forecolor_g = 255
        Bitmap(__box_tempIA).forecolor_b = 255
        Bitmap(__box_tempIA).forecolor_a = 255
    End If

    Bitmap(__box_tempIA).destx = __posSeekX + __exSizeX
    Bitmap(__box_tempIA).desty = __posSeekY - __txtBox_Max(__sizeOffset + __box_size, 0.0) + (TXT_GetOffsetY(charCode) * Bitmap(__box_tempIA).scalex)

    If __shake <> 0 Then
        Call __txtBox_PushShake(__currUsedBmpCnt, Bitmap(__box_tempIA).destx, Bitmap(__box_tempIA).desty, __shake)
    End If
    If __swing <> 0 Then
        Call __txtBox_PushSwing(__currUsedBmpCnt, Bitmap(__box_tempIA).destx, Bitmap(__box_tempIA).desty, __swing)
    End If

    Return __txtBox_Max(__realCharSpacing + TXT_GetCharSize(__box_tempIB) * __txtBox_Max(__sizeOffset + __box_size, 0.0) / TXT_GetCharSize(-1), 0.0) + __exSizeX * 2
End Script

Script __txtBox_InternalForceDrawNext(Return Integer)
    If __seek > __len Then
        Return -1
    End If

    If __seek <= 0 Then
        __seek += 1
        If __seek <= 0 Then
            Return 0
        End If
    End If

    If __lineEnd < __seek Then
        Call __txtBox_PreProcessingLine()
    End If

    __box_tempIA = TXT_GetId(__seek)
    __box_tempIB = TXT_IsFlag(__box_tempIA)
    If __box_tempIB = 1 Then
        Call __txtBox_SetupFlag(TXT_GetFlag(__box_tempIA))
        __seek += 1
        If __page > 0 Then
            Call __txtBox_HideBmp()
            __posSeekX = __box_posX
            __posSeekY = __box_posY
            __page = 0
            Call __txtBox_PreProcessingLine()
            Return 0
        End If
        If __wait > 0 Then
            Return 2
        End If
        Return 1
    ElseIf __box_tempIB = 2 Then
        __seek += 1
        Return 1
    End If
    __posSeekX += __txtBox_InternalForceDrawChar(__box_tempIA)
    __seek += 1
    Return 0
End Script

Script __txtBox_ResetState()
    __posSeekX = __box_posX
    __posSeekY = __box_posY
    __lineEnd = 0
    __seek = 0
    __seekDelay = 0

    __endLineSeek = 0
    __isInDrawToSeek = 0
    __realCharSpacing = __box_charSpacing
    __realLineHeight = __box_lineSpacing + __box_size

    __shakeChars = ""
    __swingChars = ""
    __shakeOrSwing = 0
    __colR = -1
    __exSizeX = 0
    __exSizeY = 0

    __wait = 0
    __swing = 0
    __shake = 0
    __speed = 0
    __sizeOffset = 0

    If __currUsedBmpCnt > 0 Then
        Call __txtBox_HideBmp()
    End If
End Script

Script __txtBox_ResetStateForDrawToSeek()
    __posSeekX = __box_posX
    __posSeekY = __box_posY
    __lineEnd = 0
    __seek = 0
    __seekDelay = 0

    __endLineSeek = 0
    __isInDrawToSeek = 0
    __realCharSpacing = __box_charSpacing
    __realLineHeight = __box_lineSpacing + __box_size

    __shakeChars = ""
    __swingChars = ""
    __shakeOrSwing = 0
    __colR = -1
    __exSizeX = 0
    __exSizeY = 0

    __swing = 0
    __shake = 0
    __sizeOffset = 0

    If __currUsedBmpCnt > 0 Then
        Call __txtBox_HideBmp()
    End If
End Script

Script __txtBox_Clean()
    __s = ""
    __len = 0
    Call __txtBox_ResetState()
End Script

' ----------------------------------------------------- export function
' 加载 string
' @param ss: 要加载的 string
Export Script TextboxLowLevel_LoadString(ss As String, Return Integer)
    If ss = "" Then
        Call __txtBox_Clean()
        Return -1
    End If

    __s = ss
    Call TXT_LoadStr(__s)
    __len = TXT_GetLen()
    Call __txtBox_ResetState()
    Return 0
End Script

' 无视所有阻拦绘制到目标探针
' @param seek: 绘制目标(若要绘制到结尾则 seek 可以填 10000)
Export Script TextboxLowLevel_DrawToSeek(seek As Long, Return Integer)
    If __box_wid = 0 Or __len = 0 Or __box_hei = 0 Then
        __wait = 0
        Return 0
    End If

    If seek > __len + 1 Then
        seek = __len + 1
    End If
    __box_tempIJ = 0
    __box_tempII = seek
    __box_tempIK = __wait
    Call __txtBox_ResetStateForDrawToSeek()
    __isInDrawToSeek = 1
    Call TXT_LoadStr(__s)
    Do While __seek < __box_tempII And __box_tempIJ >= 0
        __box_tempIJ = __txtBox_InternalForceDrawNext()
    Loop
    __wait = __box_tempIK
    __isInDrawToSeek = 0
    Return 0
End Script

' 绘制下一个字符
Export Script TextboxLowLevel_DrawNext(Return Integer)
    If __box_wid = 0 Or __len = 0 Or __box_hei = 0 Then
        Return 0
    End If

    If __wait > 0 Then
        Return 1
    End If

    If __seekDelay < 0 Then
        __seekDelay += 1
        Return 2
    End If

    __box_tempIA = 0
    Call TXT_LoadStr(__s)
    Do While __box_tempIA = 1 Or (__seekDelay >= 0 And __box_tempIA >= 0)
        __box_tempIA = __txtBox_InternalForceDrawNext()
        __seekDelay -= 1
    Loop
    __seekDelay = __speed
    Return 0
End Script

' 销毁
Export Script TextboxLowLevel_Destroy()
    Call __txtBox_Clean()
    Call __txtBox_ClearBmp()
End Script

' 解除等待
Export Script Textbox_Continue()
    __wait = 0
End Script

' 绘制到下一个 wait flag 处
Export Script Textbox_DrawToWait(Return Integer)
    If __animFac >= -2 Then
        Return 0
    End If

    If __box_wid = 0 Or __len = 0 Or __box_hei = 0 Then
        Return 0
    End If

    __box_tempIJ = 0
    Do While __wait <= 0 And __box_tempIJ >= 0
    __box_tempIJ = __txtBox_InternalForceDrawNext()
    Loop
    Return 0
End Script

' 获取事件信息
Export Script Textbox_GetEventInfo(Return String)
    Return __eventInfo & ""
End Script

' 是否已经到末尾了
Export Script Textbox_IsEnd(Return Integer)
    Return __seek >= __len
End Script

' 是否正在等待
Export Script Textbox_IsWait(Return Integer)
    Return __wait
End Script

' ----------------------------------------------------- atribute setter
' 设置字符贴图集 npc
' @param id: 字符贴图集 npc id
Export Script TextboxLowLevel_SetNpcSrc(id As Long)
    If id <> __box_npc Then
        __box_npc = id
        Call TextboxLowLevel_DrawToSeek(__seek)
    End If
End Script

' 设置字符 zpos
' @param zpos: 字符 zpos
Export Script TextboxLowLevel_SetZpos(zpos As Double)
    If Abs(zpos - __box_bmpZpos) > 0.0000001  Then
        __box_bmpZpos = zpos
        Call TextboxLowLevel_DrawToSeek(__seek)
    End If
End Script

' 设置文本框宽度
' @param wid: 文本框宽度(没有宽度限制可填 -1)
Export Script TextboxLowLevel_SetWidth(wid As Long)
    If wid <> __box_wid Then
        If __box_wid <> 0 And wid = 0 Then
            Call __txtBox_HideBmp()
        End If
        If wid > 10000 Or wid < 0 Then
            wid = -1
        End If
        __box_wid = wid
        Call TextboxLowLevel_DrawToSeek(__seek)
    End If
End Script

' 设置文本框高度
' @param hei: 文本框高度(没有高度限制可填 -1)
Export Script TextboxLowLevel_SetHeight(hei As Integer)
    If hei <> __box_hei Then
        If __box_hei <> 0 And hei = 0 Then
            Call __txtBox_HideBmp()
        End If
        If hei > 10000 Or hei < 0 Then
            hei = -1
        End If
        __box_hei = hei
        Call TextboxLowLevel_DrawToSeek(__seek)
    End If
End Script

' 获得文本框宽度
' @return 文本框宽
Export Script TextboxLowLevel_GetWidth(Return Integer)
    If __box_wid < 0 Or __box_wid = 10000 Then
        Return __posSeekX - __box_posX
    End If
    Return __box_wid
End Script

' 获得文本框高度
' @return 文本框高
Export Script TextboxLowLevel_GetHeight(Return Integer)
    If __box_hei < 0 Or __box_hei = 10000 Then
        Return __posSeekY - __box_posY
    End If
    Return __box_hei
End Script

' 设置文本框坐标(左上角点)
' @param x: x 坐标值
Export Script TextboxLowLevel_SetPosX(x As Integer)
    If x <> __box_posX Then
        __box_posX = x
        Call TextboxLowLevel_DrawToSeek(__seek)
    End If
End Script

' 设置文本框坐标(左上角点)
' @param y: y 坐标值
Export Script TextboxLowLevel_SetPosY(y As Integer)
    If y <> __box_posY Then
        __box_posY = y
        Call TextboxLowLevel_DrawToSeek(__seek)
    End If
End Script

' 获得文本框坐标(左上角点)
' @return x 坐标值
Export Script TextboxLowLevel_GetPosX(Return Integer)
    Return __box_posX
End Script

' 获得文本框坐标(左上角点)
' @return y 坐标值
Export Script TextboxLowLevel_GetPosY(Return Integer)
    Return __box_posY
End Script

' 设置文本字符大小(像素数)
' @param size: 字符大小
Export Script TextboxLowLevel_SetSize(size As Integer)
    If size <> __box_size Then
        If __box_size <> 0 And size = 0 Then
            Call __txtBox_HideBmp()
        End If
        __box_size = size
        Call TextboxLowLevel_DrawToSeek(__seek)
    End If
End Script

' 设置文本字符间距
' @param spc: 字符间距(要求大于零)
Export Script TextboxLowLevel_SetCharSpacing(spc As Integer)
    If spc <> __box_charSpacing Then
        __box_charSpacing = __txtBox_Max(spc, 0.0)
        Call TextboxLowLevel_DrawToSeek(__seek)
    End If
End Script

' 设置文本行距
' @param spc: 行距(要求大于零)
Export Script TextboxLowLevel_SetLineSpacing(spc As Integer)
    If spc <> __box_lineSpacing Then
        __box_lineSpacing = __txtBox_Max(spc, 0.0)
        Call TextboxLowLevel_DrawToSeek(__seek)
    End If
End Script

' 设置字符 bitmap 申请的起始 id
' @param id: 起始 id
Export Script TextboxLowLevel_SetBmpIdStart(id As Integer)
    If id <> __box_bmpStart Then
        Call __txtBox_ClearBmp()
        __box_bmpStart = id
        Call TextboxLowLevel_DrawToSeek(__seek)
    End If
End Script

' 设置文本框对其方案
' @param typ: 0-左对齐 | 1-右对齐 | 2-居中对齐
Export Script TextboxLowLevel_SetAlign(typ As Integer)
    If typ <> __box_alignType Then
        __box_alignType = typ
        Call TextboxLowLevel_DrawToSeek(__seek)
    End If
End Script

' -----------------------------------------------------
' -----------------------------------------------------
' -----------------------------------------------------
' -----------------------------------------------------
' ----------------------------------------------------- content msg box

' ------------------------------------------- var
' ---- text box bg
Dim __msg_a As Double = 0
Dim __msg_from_a As Double = 0
Dim __msg_old_a As Double = 0
Dim __msg_old_from_a As Double = 0

Dim __msg_avatar_a As Double = 0
Dim __msg_from_avatar_a As Double = 0
Dim __msg_old_avatar_a As Double = 0
Dim __msg_old_from_avatar_a As Double = 0

Dim __msg_pX As Integer = 0
Dim __msg_pY As Integer = 0
Dim __msg_sW As Integer = 0
Dim __msg_sH As Integer = 0

Dim __msg_from_pX As Integer = 0
Dim __msg_from_pY As Integer = 0
Dim __msg_from_sW As Integer = 0
Dim __msg_from_sH As Integer = 0

Dim __msg_old_pX As Integer = 0
Dim __msg_old_pY As Integer = 0
Dim __msg_old_sW As Integer = 0
Dim __msg_old_sH As Integer = 0

Dim __msg_old_from_pX As Integer = 0
Dim __msg_old_from_pY As Integer = 0
Dim __msg_old_from_sW As Integer = 0
Dim __msg_old_from_sH As Integer = 0

' ---- avatar
Dim __msg_avatar_pX As Integer = 0
Dim __msg_avatar_pY As Integer = 0
Dim __msg_avatar_sW As Integer = 0
Dim __msg_avatar_sH As Integer = 0

Dim __msg_avatar_from_pX As Integer = 0
Dim __msg_avatar_from_pY As Integer = 0
Dim __msg_avatar_from_sW As Integer = 0
Dim __msg_avatar_from_sH As Integer = 0

Dim __msg_old_avatar_pX As Integer = 0
Dim __msg_old_avatar_pY As Integer = 0
Dim __msg_old_avatar_sW As Integer = 0
Dim __msg_old_avatar_sH As Integer = 0

Dim __msg_old_avatar_from_pX As Integer = 0
Dim __msg_old_avatar_from_pY As Integer = 0
Dim __msg_old_avatar_from_sW As Integer = 0
Dim __msg_old_avatar_from_sH As Integer = 0

Dim __msg_avatar_npcId As Long = 0
Dim __msg_avatar_srcX As Integer = 0
Dim __msg_avatar_srcY As Integer = 0
Dim __msg_avatar_srcW As Integer = 0
Dim __msg_avatar_srcH As Integer = 0


' anim factor: [0, 1]
Dim __animFacOffset_msgBox As Double = 0
Dim __animFacOffset_avatar As Double = 0

' ------------------------------------------- params
Dim __msg_lastHight As Integer = -1
Dim __msg_pX_param_cache As Integer = 100
Dim __msg_pY_param_cache As Integer = 100
Dim __msg_sW_param_cache As Integer = 600
Dim __msg_sH_param_cache As Integer = 100
Dim __msg_from_pX_param_cache As Integer = 100
Dim __msg_from_pY_param_cache As Integer = 100
Dim __msg_from_sW_param_cache As Integer = 0
Dim __msg_from_sH_param_cache As Integer = 0

Dim __msg_avatar_pX_param_cache As Integer = 0
Dim __msg_avatar_pY_param_cache As Integer = 0
Dim __msg_avatar_sW_param_cache As Integer = 0
Dim __msg_avatar_sH_param_cache As Integer = 0
Dim __msg_from_avatar_pX_param_cache As Integer = 0
Dim __msg_from_avatar_pY_param_cache As Integer = 0
Dim __msg_from_avatar_sW_param_cache As Integer = 0
Dim __msg_from_avatar_sH_param_cache As Integer = 0

Dim __msg_avatar_npcId_param_cache As Long = 0
Dim __msg_avatar_srcX_param_cache As Integer = 0
Dim __msg_avatar_srcY_param_cache As Integer = 0
Dim __msg_avatar_srcW_param_cache As Integer = 0
Dim __msg_avatar_srcH_param_cache As Integer = 0

Dim __msg_a_param_cache As Double = 1
Dim __msg_from_a_param_cache As Double = 0
Dim __msg_avatar_a_param_cache As Double = 1
Dim __msg_from_avatar_a_param_cache As Double = 0

Dim __isCreated As Integer = 0
Dim __isDestroy As Integer = 0

' 设置对话框透明度
' @param a 透明度
' @param aFrom 原透明度
Export Script Textbox_StoreMsgAlpha(a As Double, aFrom As Double)
    __msg_a_param_cache = a
    __msg_from_a_param_cache = aFrom
End Script

' 设置头像透明度
' @param a 透明度
' @param aFrom 原透明度
Export Script Textbox_StoreAvatarAlpha(a As Double, aFrom As Double)
    __msg_avatar_a_param_cache = a
    __msg_from_avatar_a_param_cache = aFrom
End Script

' 设置对话框位置 (屏幕坐标)
' @param x x 位置
' @param y y 位置
' @param w 宽
' @param h 高
Export Script Textbox_StoreMsgShape(x As Integer, y As Integer, w As Integer, h As Integer)
    __msg_pX_param_cache = x
    __msg_pY_param_cache = y
    __msg_sW_param_cache = w
    __msg_sH_param_cache = h
End Script

' 设置对话框初始位置 (屏幕坐标)
' @param x x 位置
' @param y y 位置
' @param w 宽
' @param h 高
Export Script Textbox_StoreMsgFromShape(x As Integer, y As Integer, w As Integer, h As Integer)
    __msg_from_pX_param_cache = x
    __msg_from_pY_param_cache = y
    __msg_from_sW_param_cache = w
    __msg_from_sH_param_cache = h
End Script

' 设置对话框头像
' @param npcId 头像的 npc id
' @param srcX 头像在 npc 贴图中的 x 位置
' @param srcY 头像在 npc 贴图中的 y 位置
' @param srcW 头像在 npc 贴图中的宽
' @param srcH 头像在 npc 贴图中的高
Export Script Textbox_StoreAvatar(npcId As Long, srcX As Integer, srcY As Integer, srcW As Integer, srcH As Integer)
    __msg_avatar_npcId_param_cache = npcId
    __msg_avatar_srcX_param_cache = srcX
    __msg_avatar_srcY_param_cache = srcY
    __msg_avatar_srcW_param_cache = srcW
    __msg_avatar_srcH_param_cache = srcH
End Script

' 设置头像位置 (屏幕坐标)
' @param x x 位置
' @param y y 位置
' @param w 宽
' @param h 高
Export Script Textbox_StoreAvatarShape(x As Integer, y As Integer, w As Integer, h As Integer)
    __msg_avatar_pX_param_cache = x
    __msg_avatar_pY_param_cache = y
    __msg_avatar_sW_param_cache = w
    __msg_avatar_sH_param_cache = h
End Script

' 设置头像初始位置 (屏幕坐标)
' @param x x 位置
' @param y y 位置
' @param w 宽
' @param h 高
Export Script Textbox_StoreAvatarFromShape(x As Integer, y As Integer, w As Integer, h As Integer)
    __msg_from_avatar_pX_param_cache = x
    __msg_from_avatar_pY_param_cache = y
    __msg_from_avatar_sW_param_cache = w
    __msg_from_avatar_sH_param_cache = h
End Script

' 设置动画参数偏移量
' @param msgBox 对话框的动画参数偏移量
' @param avatar 头像的动画参数偏移量
Export Script Textbox_SetAnimFacOffset(msgBox As Double, avatar As Double)
    __animFacOffset_msgBox = msgBox
    __animFacOffset_avatar = avatar
End Script

' 直接设置头像 (可以用于快速修改头像表情, 没有任何过渡动画, 也不支持改变头像大小)
' @param npcId 头像的 npc id
' @param srcX 头像在 npc 贴图中的 x 位置
' @param srcY 头像在 npc 贴图中的 y 位置
' @param srcW 头像在 npc 贴图中的宽
' @param srcH 头像在 npc 贴图中的高
Export Script Textbox_SetAvatarImm(npcId As Long, srcX As Integer, srcY As Integer, srcW As Integer, srcH As Integer, Return Integer)
    If __isCreated = 0 Then
        Return 0
    End If
    __msg_avatar_npcId = npcId
    __msg_avatar_srcX = srcX
    __msg_avatar_srcY = srcY
    __msg_avatar_srcW = srcW
    __msg_avatar_srcH = srcH

    If __msg_avatar_srcW = 0 Then
        Bitmap(__msg_bmpIdStart).hide = 1
        Bitmap(__msg_bmpIdStart).scrwidth = 0
    Else
        Bitmap(__msg_bmpIdStart).hide = 0
        Bitmap(__msg_bmpIdStart).scrid = __msg_avatar_npcId
        Bitmap(__msg_bmpIdStart).scrx = __msg_avatar_srcX
        Bitmap(__msg_bmpIdStart).scry = __msg_avatar_srcY
        Bitmap(__msg_bmpIdStart).scrwidth = __msg_avatar_srcW
        Bitmap(__msg_bmpIdStart).scrheight = __msg_avatar_srcH
    End If
    Return 1
End Script

' 直接设置九宫格 npc id (可以用于快速修改头像表情, 没有任何过渡动画, 也不支持改变头像大小)
' @param npcId 头像的 npc id
' @param srcX srcX
' @param srcY srcY
Export Script Textbox_Set9GridNpcIdImm(npcId As Long, srcX As Integer, srcY As Integer, Return Integer)
    __msg_9Grid_npcId = npcId
    If __isCreated = 0 Then
        Return 0
    End If

    For __box_tempIN = 1 To 9 Step 1
        Bitmap(__msg_bmpIdStart + __box_tempIN).scrid = __msg_9Grid_npcId
    Next
    Bitmap(__msg_bmpIdStart + 1).scrx = srcX
    Bitmap(__msg_bmpIdStart + 1).scry = srcY
    Bitmap(__msg_bmpIdStart + 2).scrx = srcX + __msg_9Grid_a + __msg_9Grid_w
    Bitmap(__msg_bmpIdStart + 2).scry = srcY
    Bitmap(__msg_bmpIdStart + 3).scrx = srcX
    Bitmap(__msg_bmpIdStart + 3).scry = srcY + __msg_9Grid_b + __msg_9Grid_h
    Bitmap(__msg_bmpIdStart + 4).scrx = srcX + __msg_9Grid_a + __msg_9Grid_w
    Bitmap(__msg_bmpIdStart + 4).scry = srcY + __msg_9Grid_b + __msg_9Grid_h

    Bitmap(__msg_bmpIdStart + 5).scrx = srcX
    Bitmap(__msg_bmpIdStart + 5).scry = srcY + __msg_9Grid_b
    Bitmap(__msg_bmpIdStart + 6).scrx = srcX + __msg_9Grid_a + __msg_9Grid_w
    Bitmap(__msg_bmpIdStart + 6).scry = srcY + __msg_9Grid_b
    Bitmap(__msg_bmpIdStart + 7).scrx = srcX + __msg_9Grid_a
    Bitmap(__msg_bmpIdStart + 7).scry = srcY
    Bitmap(__msg_bmpIdStart + 8).scrx = srcX + __msg_9Grid_a
    Bitmap(__msg_bmpIdStart + 8).scry = srcY + __msg_9Grid_b + __msg_9Grid_h

    Bitmap(__msg_bmpIdStart + 9).scrx = srcX + __msg_9Grid_a
    Bitmap(__msg_bmpIdStart + 9).scry = srcY + __msg_9Grid_b
    Return 1
End Script

' 提交对话文本 (T 串)
' @param txt T 串文本
' @param animStartFac 过渡动画设置 -1: 退场和入场; 0: 仅入场; 1: 硬切无动画
Export Script Textbox_Submit(txt As String, animStartFac As Double)
    If txt = "" Then
        __isDestroy = 1
        Call TextBoxLowLevel_SetWidth(-1)
        Call TextBoxLowLevel_LoadString(txt)
    Else
        __isDestroy = 0
        Call TextboxLowLevel_SetPosX(__msg_pX_param_cache + __msg_9Grid_a)
        Call TextboxLowLevel_SetPosY(__msg_pY_param_cache + __msg_9Grid_b)
        Call TextBoxLowLevel_SetWidth(__msg_sW_param_cache - __msg_9Grid_a - __msg_9Grid_c)
        Call TextBoxLowLevel_LoadString(txt)
    End If

    ' 创建文本框
    If __isCreated = 0 Then
        If animStartFac < 0 Then
            animStartFac = 0
        End If
        Call __textbox_inner_create()
    End If

    __msg_old_a = __msg_a
    __msg_old_from_a = __msg_from_a
    __msg_old_avatar_a = __msg_avatar_a
    __msg_old_from_avatar_a = __msg_from_avatar_a

    __msg_a = __msg_a_param_cache
    __msg_from_a = __msg_from_a_param_cache
    __msg_avatar_a = __msg_avatar_a_param_cache
    __msg_from_avatar_a = __msg_from_avatar_a_param_cache

    __msg_old_pX = __msg_pX
    __msg_old_pY = __msg_pY
    __msg_old_sH = __msg_sH
    __msg_old_sW = __msg_sW
    __msg_old_from_pX = __msg_from_pX
    __msg_old_from_pY = __msg_from_pY
    __msg_old_from_sH = __msg_from_sH
    __msg_old_from_sW = __msg_from_sW

    __msg_old_avatar_pX = __msg_avatar_pX
    __msg_old_avatar_pY = __msg_avatar_pY
    __msg_old_avatar_sH = __msg_avatar_sH
    __msg_old_avatar_sW = __msg_avatar_sW
    __msg_old_avatar_from_pX = __msg_avatar_from_pX
    __msg_old_avatar_from_pY = __msg_avatar_from_pY
    __msg_old_avatar_from_sH = __msg_avatar_from_sH
    __msg_old_avatar_from_sW = __msg_avatar_from_sW

    __msg_pX = __msg_pX_param_cache
    __msg_pY = __msg_pY_param_cache
    __msg_sW = __msg_sW_param_cache
    __msg_sH = __msg_sH_param_cache
    __msg_from_pX = __msg_from_pX_param_cache
    __msg_from_pY = __msg_from_pY_param_cache
    __msg_from_sW = __msg_from_sW_param_cache
    __msg_from_sH = __msg_from_sH_param_cache

    __msg_avatar_pX = __msg_avatar_pX_param_cache
    __msg_avatar_pY = __msg_avatar_pY_param_cache
    __msg_avatar_sH = __msg_avatar_sH_param_cache
    __msg_avatar_sW = __msg_avatar_sW_param_cache
    __msg_avatar_from_pX = __msg_from_avatar_pX_param_cache
    __msg_avatar_from_pY = __msg_from_avatar_pY_param_cache
    __msg_avatar_from_sH = __msg_from_avatar_sH_param_cache
    __msg_avatar_from_sW = __msg_from_avatar_sW_param_cache
    __msg_avatar_npcId = __msg_avatar_npcId_param_cache
    __msg_avatar_srcX = __msg_avatar_srcX_param_cache
    __msg_avatar_srcY = __msg_avatar_srcY_param_cache
    __msg_avatar_srcH = __msg_avatar_srcH_param_cache
    __msg_avatar_srcW = __msg_avatar_srcW_param_cache

    ' 重置缓存的参数
    __msg_pX_param_cache = 100
    __msg_pY_param_cache = 100
    __msg_sW_param_cache = 600
    __msg_sH_param_cache = 100
    __msg_from_pX_param_cache = 100
    __msg_from_pY_param_cache = 100
    __msg_from_sW_param_cache = 0
    __msg_from_sH_param_cache = 0

    __msg_avatar_pX_param_cache = 0
    __msg_avatar_pY_param_cache = 0
    __msg_avatar_sW_param_cache = 0
    __msg_avatar_sH_param_cache = 0
    __msg_avatar_npcId_param_cache = 0
    __msg_avatar_srcX_param_cache = 0
    __msg_avatar_srcY_param_cache = 0
    __msg_avatar_srcW_param_cache = 0
    __msg_avatar_srcH_param_cache = 0
    __msg_from_avatar_pX_param_cache = 0
    __msg_from_avatar_pY_param_cache = 0
    __msg_from_avatar_sW_param_cache = 0
    __msg_from_avatar_sH_param_cache = 0

    __msg_a_param_cache = 1
    __msg_from_a_param_cache = 0
    __msg_avatar_a_param_cache = 1
    __msg_from_avatar_a_param_cache = 0

    ' 阈值
    If animStartFac < -1 Then
        animStartFac = -1
    ElseIf animStartFac > 1 Then
        animStartFac = 1
    End If
    __animFac = animStartFac
End Script

' 创建文本框
Script __textbox_inner_create(Return Integer)
    If __isCreated Then
        Return 0
    End If
    __isCreated = -1

    ' avatar 初始化
    Call BMPCreate(__msg_bmpIdStart, __msg_avatar_npcId, 1, 0,     0, 0, 0, 0,     0, 0, 0, 0,     0, 0,     0, -1)

    ' 九宫格初始化
    ' 左上 右上 左下 右下
    Call BMPCreate(__msg_bmpIdStart + 1, __msg_9Grid_npcId, 1, 1,     __msg_9Grid_x, __msg_9Grid_y, __msg_9Grid_a, __msg_9Grid_b,     0, 0, 0, 0,     0, 0,     0, -1)
    Call BMPCreate(__msg_bmpIdStart + 2, __msg_9Grid_npcId, 1, 1,     __msg_9Grid_x + __msg_9Grid_a + __msg_9Grid_w, __msg_9Grid_y, __msg_9Grid_c, __msg_9Grid_b,     0, 0, 0, 0,     0, 0,     0, -1)
    Call BMPCreate(__msg_bmpIdStart + 3, __msg_9Grid_npcId, 1, 1,     __msg_9Grid_x, __msg_9Grid_y + __msg_9Grid_b + __msg_9Grid_h, __msg_9Grid_a, __msg_9Grid_d,     0, 0, 0, 0,     0, 0,     0, -1)
    Call BMPCreate(__msg_bmpIdStart + 4, __msg_9Grid_npcId, 1, 1,     __msg_9Grid_x + __msg_9Grid_a + __msg_9Grid_w, __msg_9Grid_y + __msg_9Grid_b + __msg_9Grid_h, __msg_9Grid_c, __msg_9Grid_d,     0, 0, 0, 0,     0, 0,     0, -1)

    ' 左中 右中 上中 下中
    Call BMPCreate(__msg_bmpIdStart + 5, __msg_9Grid_npcId, 1, 1,     __msg_9Grid_x, __msg_9Grid_y + __msg_9Grid_b, __msg_9Grid_a, __msg_9Grid_h,     0, 0, 0, 0,     0, 0,     0, -1)
    Call BMPCreate(__msg_bmpIdStart + 6, __msg_9Grid_npcId, 1, 1,     __msg_9Grid_x + __msg_9Grid_a + __msg_9Grid_w, __msg_9Grid_y + __msg_9Grid_b, __msg_9Grid_c, __msg_9Grid_h,     0, 0, 0, 0,     0, 0,     0, -1)
    Call BMPCreate(__msg_bmpIdStart + 7, __msg_9Grid_npcId, 1, 1,     __msg_9Grid_x + __msg_9Grid_a, __msg_9Grid_y, __msg_9Grid_w, __msg_9Grid_b,     0, 0, 0, 0,     0, 0,     0, -1)
    Call BMPCreate(__msg_bmpIdStart + 8, __msg_9Grid_npcId, 1, 1,     __msg_9Grid_x + __msg_9Grid_a, __msg_9Grid_y + __msg_9Grid_b + __msg_9Grid_h, __msg_9Grid_w, __msg_9Grid_d,     0, 0, 0, 0,     0, 0,     0, -1)

    ' 中
    Call BMPCreate(__msg_bmpIdStart + 9, __msg_9Grid_npcId, 1, 1,     __msg_9Grid_x + __msg_9Grid_a, __msg_9Grid_y + __msg_9Grid_b, __msg_9Grid_w, __msg_9Grid_h,     0, 0, 0, 0,     0, 0,     0, -1)
    Bitmap(__msg_bmpIdStart).zpos = __msg_defaultZpos
    Bitmap(__msg_bmpIdStart + 1).zpos = __msg_defaultZpos
    Bitmap(__msg_bmpIdStart + 2).zpos = __msg_defaultZpos
    Bitmap(__msg_bmpIdStart + 3).zpos = __msg_defaultZpos
    Bitmap(__msg_bmpIdStart + 4).zpos = __msg_defaultZpos
    Bitmap(__msg_bmpIdStart + 5).zpos = __msg_defaultZpos
    Bitmap(__msg_bmpIdStart + 6).zpos = __msg_defaultZpos
    Bitmap(__msg_bmpIdStart + 7).zpos = __msg_defaultZpos
    Bitmap(__msg_bmpIdStart + 8).zpos = __msg_defaultZpos
    Bitmap(__msg_bmpIdStart + 9).zpos = __msg_defaultZpos
    Bitmap(__msg_bmpIdStart).blendmode = 0
    Bitmap(__msg_bmpIdStart + 1).blendmode = 0
    Bitmap(__msg_bmpIdStart + 2).blendmode = 0
    Bitmap(__msg_bmpIdStart + 3).blendmode = 0
    Bitmap(__msg_bmpIdStart + 4).blendmode = 0
    Bitmap(__msg_bmpIdStart + 5).blendmode = 0
    Bitmap(__msg_bmpIdStart + 6).blendmode = 0
    Bitmap(__msg_bmpIdStart + 7).blendmode = 0
    Bitmap(__msg_bmpIdStart + 8).blendmode = 0
    Bitmap(__msg_bmpIdStart + 9).blendmode = 0
    Return 1
End Script

' 设置头像 bmp 参数
Script __textbox_inner_setAvatar()
    If __msg_avatar_srcW <= 0 Or __msg_avatar_srcH <= 0 Then
        Bitmap(__msg_bmpIdStart).hide = 1
        Bitmap(__msg_bmpIdStart).scrwidth = 0
    Else
        Bitmap(__msg_bmpIdStart).hide = 0
        Bitmap(__msg_bmpIdStart).scrid = __msg_avatar_npcId
        Bitmap(__msg_bmpIdStart).scrx = __msg_avatar_srcX
        Bitmap(__msg_bmpIdStart).scry = __msg_avatar_srcY
        Bitmap(__msg_bmpIdStart).scrwidth = __msg_avatar_srcW
        Bitmap(__msg_bmpIdStart).scrheight = __msg_avatar_srcH
    End If
End Script

Script __textbox_inner_cleanBg(Return Integer)
    __animFac = -4
    If __isCreated = 0 Then
        Return 0
    End If
    __isCreated = 0

    Call BErase(2, __msg_bmpIdStart + 0)

    Call BErase(2, __msg_bmpIdStart + 1)
    Call BErase(2, __msg_bmpIdStart + 2)
    Call BErase(2, __msg_bmpIdStart + 3)
    Call BErase(2, __msg_bmpIdStart + 4)

    Call BErase(2, __msg_bmpIdStart + 5)
    Call BErase(2, __msg_bmpIdStart + 6)
    Call BErase(2, __msg_bmpIdStart + 7)
    Call BErase(2, __msg_bmpIdStart + 8)

    Call BErase(2, __msg_bmpIdStart + 9)

    ' 销毁文本内容
    Call TextboxLowLevel_Destroy()
    Return 1
End Script

Script __textbox_inner_trans(x As Double, Return Double)
    If x < 0 Then
        x = 0
    ElseIf x > 1 Then
        x = 1
    End If
    return sin((x - 0.5) * 3.14159265359) * 0.5 + 0.5
End Script

' 刷新文本框背景
Script __textbox_inner_refreshBg(Return Integer)
    If __isCreated = 0 Then
        Return 0
    End If

    ' anim fac 小于 0.5 时表明当前不在动画中
    ' 不在动画中时只刷 y 轴向的高度
    If __animFac < -2 Then
        ' __msg_sW 为 0 时销毁
        If __msg_sW <= 0.00001 Then
            Call __textbox_inner_cleanBg()
            Return 0
        End If

        __box_tempIC = __msg_pX
        __box_tempID = __msg_pY
        __box_tempIB = __msg_sH
        __box_tempIA = __msg_sW
        If __msg_sH >= TextboxLowLevel_GetHeight() + __msg_9Grid_b + __msg_9Grid_d Then
            __box_tempIB = __msg_sH
        Else
            __box_tempIB = TextboxLowLevel_GetHeight() + __msg_9Grid_b + __msg_9Grid_d
        End If

        If __msg_lastHight = __box_tempIB Then
            Return 0
        End If
        __msg_lastHight = __box_tempIB
    Else
        __msg_lastHight = -1
        ' 阈值
        If __animFac > 1 Then
            __box_tempDA = 1
        ElseIf __animFac < -1 Then
            __box_tempDA = 1
        Else
            If __animFac >= 0 Then
                __box_tempDA = __textbox_inner_trans(abs(__animFac + __animFacOffset_msgBox))
            Else
                __box_tempDA = __textbox_inner_trans(abs(__animFac))
            End If
        End If

        ' 计算位置
        If __animFac < 0 Then
            __box_tempIC = (1 - __box_tempDA) * __msg_old_from_pX + __box_tempDA * __msg_old_pX ' real x
            __box_tempID = (1 - __box_tempDA) * __msg_old_from_pY + __box_tempDA * __msg_old_pY ' real y
            __box_tempIA = (1 - __box_tempDA) * __msg_old_from_sW + __box_tempDA * __msg_old_sW ' real w
            __box_tempIB = (1 - __box_tempDA) * __msg_old_from_sH + __box_tempDA * __msg_old_sH ' real h
            __box_tempDB = (1 - __box_tempDA) * __msg_old_from_a + __box_tempDA * __msg_old_a ' alpha
        Else
            __box_tempIC = (1 - __box_tempDA) * __msg_from_pX + __box_tempDA * __msg_pX ' real x
            __box_tempID = (1 - __box_tempDA) * __msg_from_pY + __box_tempDA * __msg_pY ' real y
            __box_tempIA = (1 - __box_tempDA) * __msg_from_sW + __box_tempDA * __msg_sW ' real w
            __box_tempIB = (1 - __box_tempDA) * __msg_from_sH + __box_tempDA * __msg_sH ' real h
            __box_tempDB = (1 - __box_tempDA) * __msg_from_a + __box_tempDA * __msg_a ' alpha
        End If

        If __animFac <= 0 And __animFac + __msg_animSpeed > 0 Then
            ' __msg_sW 为 0 时销毁
            If __isDestroy Then
                __animFac = -4
                Call __textbox_inner_cleanBg()
                Return 0
            End If

            Call __textbox_inner_setAvatar()
            If __box_eventScriptName <> "" Then
                __eventState = 2
                __eventValue = ""
                Call EXEScript(__box_eventScriptName)
                __eventState = 0
            End If
        End If
        __box_tempIA = Abs(__box_tempIA)
        __box_tempIB = Abs(__box_tempIB)

        ' 左上角点
        Bitmap(__msg_bmpIdStart + 1).destx = __box_tempIC
        Bitmap(__msg_bmpIdStart + 1).desty = __box_tempID
    End If

    ' 计算剩余片坐标
    ' y 轴向
    __box_tempDA = __box_tempIB / (__msg_9Grid_b + __msg_9Grid_h + __msg_9Grid_d)
    If __box_tempDA < 1 Then
        ' 位置 右上 左下 右下 - 左中 右中 上中 下中 - 中
        Bitmap(__msg_bmpIdStart + 2).desty = __box_tempID
        Bitmap(__msg_bmpIdStart + 3).desty = __box_tempID + (__msg_9Grid_h + __msg_9Grid_b) * __box_tempDA
        Bitmap(__msg_bmpIdStart + 4).desty = Bitmap(__msg_bmpIdStart + 3).desty

        Bitmap(__msg_bmpIdStart + 5).desty = __box_tempID + __msg_9Grid_b * __box_tempDA
        Bitmap(__msg_bmpIdStart + 6).desty = Bitmap(__msg_bmpIdStart + 5).desty
        Bitmap(__msg_bmpIdStart + 7).desty = __box_tempID
        Bitmap(__msg_bmpIdStart + 8).desty = Bitmap(__msg_bmpIdStart + 3).desty

        Bitmap(__msg_bmpIdStart + 9).desty = Bitmap(__msg_bmpIdStart + 5).desty

        ' 尺寸: 左上 右上 左下 右下 - 左中 右中 上中 下中 - 中
        Bitmap(__msg_bmpIdStart + 1).scaley = __box_tempDA
        Bitmap(__msg_bmpIdStart + 2).scaley = __box_tempDA
        Bitmap(__msg_bmpIdStart + 3).scaley = __box_tempDA
        Bitmap(__msg_bmpIdStart + 4).scaley = __box_tempDA

        Bitmap(__msg_bmpIdStart + 5).scaley = __box_tempDA
        Bitmap(__msg_bmpIdStart + 6).scaley = __box_tempDA
        Bitmap(__msg_bmpIdStart + 7).scaley = __box_tempDA
        Bitmap(__msg_bmpIdStart + 8).scaley = __box_tempDA

        Bitmap(__msg_bmpIdStart + 9).scaley = __box_tempDA
    Else
        __box_tempDA = (__box_tempIB - __msg_9Grid_b - __msg_9Grid_d) / __msg_9Grid_h
        ' 位置 右上 左下 右下 - 左中 右中 上中 下中 - 中
        Bitmap(__msg_bmpIdStart + 2).desty = __box_tempID
        Bitmap(__msg_bmpIdStart + 3).desty = __box_tempID + __msg_9Grid_b + __msg_9Grid_h * __box_tempDA
        Bitmap(__msg_bmpIdStart + 4).desty = Bitmap(__msg_bmpIdStart + 3).desty

        Bitmap(__msg_bmpIdStart + 5).desty = __box_tempID + __msg_9Grid_b
        Bitmap(__msg_bmpIdStart + 6).desty = Bitmap(__msg_bmpIdStart + 5).desty
        Bitmap(__msg_bmpIdStart + 7).desty = __box_tempID
        Bitmap(__msg_bmpIdStart + 8).desty = Bitmap(__msg_bmpIdStart + 3).desty

        Bitmap(__msg_bmpIdStart + 9).desty = Bitmap(__msg_bmpIdStart + 5).desty

        ' 尺寸: 左上 右上 左下 右下 - 左中 右中 上中 下中 - 中
        Bitmap(__msg_bmpIdStart + 1).scaley = 1
        Bitmap(__msg_bmpIdStart + 2).scaley = 1
        Bitmap(__msg_bmpIdStart + 3).scaley = 1
        Bitmap(__msg_bmpIdStart + 4).scaley = 1

        Bitmap(__msg_bmpIdStart + 5).scaley = __box_tempDA
        Bitmap(__msg_bmpIdStart + 6).scaley = __box_tempDA
        Bitmap(__msg_bmpIdStart + 7).scaley = 1
        Bitmap(__msg_bmpIdStart + 8).scaley = 1

        Bitmap(__msg_bmpIdStart + 9).scaley = __box_tempDA
    End If

    ' 如果没在动画中, 就只刷文本框 y 轴向的高度
    If __animFac < -2 Then
        Return 0
    End If

    ' x 轴向
    __box_tempDA = __box_tempIA / (__msg_9Grid_a + __msg_9Grid_w + __msg_9Grid_c)
    If __box_tempDA < 1 Then
        ' 位置 右上 左下 右下 - 左中 右中 上中 下中 - 中
        Bitmap(__msg_bmpIdStart + 2).destx = __box_tempIC + (__msg_9Grid_a + __msg_9Grid_w) * __box_tempDA
        Bitmap(__msg_bmpIdStart + 3).destx = __box_tempIC
        Bitmap(__msg_bmpIdStart + 4).destx = Bitmap(__msg_bmpIdStart + 2).destx

        Bitmap(__msg_bmpIdStart + 5).destx = Bitmap(__msg_bmpIdStart + 3).destx
        Bitmap(__msg_bmpIdStart + 6).destx = Bitmap(__msg_bmpIdStart + 2).destx
        Bitmap(__msg_bmpIdStart + 7).destx = __box_tempIC + __msg_9Grid_a * __box_tempDA
        Bitmap(__msg_bmpIdStart + 8).destx = Bitmap(__msg_bmpIdStart + 7).destx

        Bitmap(__msg_bmpIdStart + 9).destx = Bitmap(__msg_bmpIdStart + 7).destx

        ' 尺寸: 左上 右上 左下 右下 - 左中 右中 上中 下中 - 中
        Bitmap(__msg_bmpIdStart + 1).scalex = __box_tempDA
        Bitmap(__msg_bmpIdStart + 2).scalex = __box_tempDA
        Bitmap(__msg_bmpIdStart + 3).scalex = __box_tempDA
        Bitmap(__msg_bmpIdStart + 4).scalex = __box_tempDA

        Bitmap(__msg_bmpIdStart + 5).scalex = __box_tempDA
        Bitmap(__msg_bmpIdStart + 6).scalex = __box_tempDA
        Bitmap(__msg_bmpIdStart + 7).scalex = __box_tempDA
        Bitmap(__msg_bmpIdStart + 8).scalex = __box_tempDA

        Bitmap(__msg_bmpIdStart + 9).scalex = __box_tempDA
    Else
        __box_tempDA = (__box_tempIA - __msg_9Grid_a - __msg_9Grid_c) / __msg_9Grid_w
        ' 位置 右上 左下 右下 - 左中 右中 上中 下中 - 中
        Bitmap(__msg_bmpIdStart + 2).destx = __box_tempIC + __msg_9Grid_w * __box_tempDA + __msg_9Grid_a
        Bitmap(__msg_bmpIdStart + 3).destx = __box_tempIC
        Bitmap(__msg_bmpIdStart + 4).destx = Bitmap(__msg_bmpIdStart + 2).destx

        Bitmap(__msg_bmpIdStart + 5).destx = Bitmap(__msg_bmpIdStart + 3).destx
        Bitmap(__msg_bmpIdStart + 6).destx = Bitmap(__msg_bmpIdStart + 2).destx
        Bitmap(__msg_bmpIdStart + 7).destx = __box_tempIC + __msg_9Grid_a
        Bitmap(__msg_bmpIdStart + 8).destx = Bitmap(__msg_bmpIdStart + 7).destx

        Bitmap(__msg_bmpIdStart + 9).destx = Bitmap(__msg_bmpIdStart + 7).destx

        ' 尺寸: 左上 右上 左下 右下 - 左中 右中 上中 下中 - 中
        Bitmap(__msg_bmpIdStart + 1).scalex = 1
        Bitmap(__msg_bmpIdStart + 2).scalex = 1
        Bitmap(__msg_bmpIdStart + 3).scalex = 1
        Bitmap(__msg_bmpIdStart + 4).scalex = 1

        Bitmap(__msg_bmpIdStart + 5).scalex = 1
        Bitmap(__msg_bmpIdStart + 6).scalex = 1
        Bitmap(__msg_bmpIdStart + 7).scalex = __box_tempDA
        Bitmap(__msg_bmpIdStart + 8).scalex = __box_tempDA

        Bitmap(__msg_bmpIdStart + 9).scalex = __box_tempDA
    End If

    ' alpha
    For __box_tempIN = 1 To 9 Step 1
        Bitmap(__msg_bmpIdStart + __box_tempIN).forecolor_a = __box_tempDB * 255
    Next

    ' 如果 avatar 存在的话
    ' 计算 avatar 位置和大小
    If Bitmap(__msg_bmpIdStart).scrwidth > 0.001 And Bitmap(__msg_bmpIdStart).scrheight > 0.001 Then
        ' 重新赋值一遍 __animFac 到 __box_tempDA
        ' 阈值
        If __animFac > 1 Then
            __box_tempDA = 1
        ElseIf __animFac < -1 Then
            __box_tempDA = 1
        Else
            If __animFac >= 0 Then
                __box_tempDA = __textbox_inner_trans(abs(__animFac + __animFacOffset_avatar))
                __box_tempDB = (1 - __box_tempDA) * __msg_from_avatar_a + __box_tempDA * __msg_avatar_a ' alpha
            Else
                __box_tempDA = __textbox_inner_trans(abs(__animFac))
                __box_tempDB = (1 - __box_tempDA) * __msg_old_from_avatar_a + __box_tempDA * __msg_old_avatar_a ' alpha
            End If
        End If

        ' alpha
        Bitmap(__msg_bmpIdStart).forecolor_a = __box_tempDB * 255

        ' 计算位置
        If __animFac < 0 Then
            __box_tempIE = (1 - __box_tempDA) * __msg_old_avatar_from_pX + __box_tempDA * __msg_old_avatar_pX ' real avatar x
            __box_tempIF = (1 - __box_tempDA) * __msg_old_avatar_from_pY + __box_tempDA * __msg_old_avatar_pY ' real avatar y
        Else
            __box_tempIE = (1 - __box_tempDA) * __msg_avatar_from_pX + __box_tempDA * __msg_avatar_pX ' real avatar x
            __box_tempIF = (1 - __box_tempDA) * __msg_avatar_from_pY + __box_tempDA * __msg_avatar_pY ' real avatar y
        End If
        Bitmap(__msg_bmpIdStart).destx = __box_tempIE
        Bitmap(__msg_bmpIdStart).desty = __box_tempIF

        ' 计算 Size
        If __animFac < 0 Then
            __box_tempIA = (1 - __box_tempDA) * __msg_old_avatar_from_sW + __box_tempDA * __msg_old_avatar_sW ' real avatar w
            __box_tempIB = (1 - __box_tempDA) * __msg_old_avatar_from_sH + __box_tempDA * __msg_old_avatar_sH ' real avatar h
        Else
            __box_tempIA = (1 - __box_tempDA) * __msg_avatar_from_sW + __box_tempDA * __msg_avatar_sW ' real avatar w
            __box_tempIB = (1 - __box_tempDA) * __msg_avatar_from_sH + __box_tempDA * __msg_avatar_sH ' real avatar h
        End If

        Bitmap(__msg_bmpIdStart).scalex = __box_tempIA / Bitmap(__msg_bmpIdStart).scrwidth
        Bitmap(__msg_bmpIdStart).scaley = __box_tempIB / Bitmap(__msg_bmpIdStart).scrheight
    End If

    ' 动画播放完了
    If __animFac >= 1 Then
        __animFac = -4
    End If
    __animFac += __msg_animSpeed
    Return 1
End Script

' -----------------------------------------------------
' -----------------------------------------------------
' -----------------------------------------------------
' -----------------------------------------------------
' ----------------------------------------------------- content lite text box

' ----------------------------------------------------- bubbles data
' 气泡数据的格式: [28 char](这里 1 char == 2 byte)
'     |[1 ]: posX[2char]            |[3 ]: posY[2char]                |
'     |[5 ]: upPushingHeight[1char] |[6 ]: lastUpPushingHeight[1char] |
'     |[7 ]: _unused[4char]         |[11]: _unused[2char]             |
'     |[13]: width[1char]           |
'     |[14]: time[1char]            | // 持续时间
'     |[15]: colorRGB[3char]        |
'     |[18]: offsetTargetId[2char]  |[20:] id[char]                   |
'     |[21]: bmpIdStart[2char]      | // bmpId 只保存相对于 __lBox_bmpIdStart 的偏移量
'     |[23]: bmpIdEnd[2char]        |
'     |[25]: height[1char]          |
'     |[26]: createTime[2char]      |
'     |[28]: exFlag[1char]          | // [是否跟随[111], 是否显示指针[1], 是否可被排挤[1], 是否排挤[1]]
Dim __bubbleShapeData0 As String = ""
Dim __bubbleShapeData1 As String = ""
Dim __bubbleShapeData2 As String = ""
Dim __bubbleShapeData3 As String = ""
Dim __bubbleShapeData4 As String = ""
Dim __bubbleShapeData5 As String = ""
Dim __bubbleShapeData6 As String = ""
Dim __bubbleShapeData7 As String = ""

' ----------------------------------------------------- system data
' 自增 id
Dim __idSeed As Long = 0
Dim __dirtyFlag As Long = 0

' string 返回值寄存器
' 可恶的 teaScript 连正常地返回 string 都无法支持
Dim __ret_s As String = ""

' ----------------------------------------------------- basic data op func
Script __readInt_2Char(data As String, offset As Long, Return Long)
    __box_tempIA = ascW(mid(data, offset, 1)) and 65535
    __box_tempIB = ascW(mid(data, offset + 1, 1)) and 65535
    Return __box_tempIA or (__box_tempIB << 16)
End Script

Script __writeInt_2Char(data As String, offset As Long, value As Long)
    If data = "" Then
        data = __ret_s
    End If
    __box_tempIA = value and 65535
    __box_tempIB = value >> 16 and 65535
    __box_tempIC = len(data) - offset - 1
    If offset <= 1 and __box_tempIC < 1 Then
        __ret_s = chrW(__box_tempIA) & chrW(__box_tempIB)
    ElseIf offset <= 1 Then
        __ret_s = chrW(__box_tempIA) & chrW(__box_tempIB) & right(data, __box_tempIC)
    ElseIf __box_tempIC < 1 Then
        __ret_s = left(data, offset - 1) & chrW(__box_tempIA) & chrW(__box_tempIB)
    Else
        __ret_s = left(data, offset - 1) & chrW(__box_tempIA) & chrW(__box_tempIB) & right(data, len(data) - offset - 1)
    End If
End Script

Script __readInt_char(data As String, offset As Long, Return Integer)
    Return ascW(mid(data, offset, 1))
End Script

Script __writeInt_char(data As String, offset As Long, value As Integer, Return Integer)
    If data = "" Then
        data = __ret_s
    End If
    If offset <= 1 or len(data) <= 1 Then
        __ret_s = chrW(value)
        Return 1
    ElseIf offset <= 1 Then
        __ret_s = chrW(value) & right(data, len(data) - 1)
        Return 2
    Else
        __ret_s = left(data, offset - 1) & chrW(value) & right(data, len(data) - offset)
        Return 3
    End If
    __ret_s = ascW(mid(data, offset, 1))
    Return 4
End Script

' ----------------------------------------------------- getter and setter
Script __set_bubbleShapeData(idx As Integer, data As String)
    If idx <= 4 Then
        If idx <= 2 Then
            If idx = 1 Then
                __bubbleShapeData0 = data
            Else
                __bubbleShapeData1 = data
            End If
        Else
            If idx = 3 Then
                __bubbleShapeData2 = data
            Else
                __bubbleShapeData3 = data
            End If
        End If
    Else
        If idx <= 6 Then
            If idx = 5 Then
                __bubbleShapeData4 = data
            Else
                __bubbleShapeData5 = data
            End If
        Else
            If idx = 7 Then
                __bubbleShapeData6 = data
            Else
                __bubbleShapeData7 = data
            End If
        End If
    End If
End Script

Script __get_bubbleShapeData(idx As Integer)
    If idx <= 4 Then
        If idx <= 2 Then
            If idx = 1 Then
                __ret_s = __bubbleShapeData0
            Else
                __ret_s = __bubbleShapeData1
            End If
        Else
            If idx = 3 Then
                __ret_s = __bubbleShapeData2
            Else
                __ret_s =  __bubbleShapeData3
            End If
        End If
    Else
        If idx <= 6 Then
            If idx = 5 Then
                __ret_s = __bubbleShapeData4
            Else
                __ret_s = __bubbleShapeData5
            End If
        Else
            If idx = 7 Then
                __ret_s = __bubbleShapeData6
            Else
                __ret_s = __bubbleShapeData7
            End If
        End If
    End If
End Script

' ----------------------------------------------------- 内部函数

Dim __bubbleShapeDataDefault As String = "----------------------------"
__ret_s = __bubbleShapeDataDefault
Call __writeInt_char("", 13, 0)
Call __writeInt_char("", 14, 240)
Call __writeInt_char("", 15, 255)
Call __writeInt_char("", 16, 255)
Call __writeInt_char("", 17, 255)
Call __writeInt_char("", 20, 0)
Call __writeInt_char("", 25, 0)
Call __writeInt_char("", 28, 7) ' 0b000111
Call __writeInt_2Char("", 1, 0)
Call __writeInt_2Char("", 3, 0)
Call __writeInt_char("", 5, 0)
Call __writeInt_char("", 6, 0)
Call __writeInt_2Char("", 7, 0)
Call __writeInt_2Char("", 9, 0)
Call __writeInt_2Char("", 11, 0)
Call __writeInt_2Char("", 18, 0)
Call __writeInt_2Char("", 21, -1)
Call __writeInt_2Char("", 23, -1)
Call __writeInt_2Char("", 26, 0)
__bubbleShapeDataDefault = __ret_s

Dim __color_cache_r As Integer = 255
Dim __color_cache_g As Integer = 255
Dim __color_cache_b As Integer = 255
Dim __offset_cache_x As Integer = 0
Dim __offset_cache_y As Integer = 0
Dim __anchor_cache_x As Double = 0
Dim __anchor_cache_y As Double = 0
Dim __wid_cache As Integer = 0
Dim __size_cache As Double = 0
Dim __zpos_cache As Double = 0.5
Dim __lBox_9Grid_cache_x As Integer = __lBox_9Grid_x
Dim __lBox_9Grid_cache_y As Integer = __lBox_9Grid_y
Dim __lBox_9Grid_cache_npcId As Long = __lBox_9Grid_npcId
Dim __bubbleAllocateQueue_s As String = ""
Dim __bubbleShapeData_cache As String = __bubbleShapeDataDefault

Script __pushQueue(id As Integer, Return Integer)
    If id > 8 or id < 1 Then
        Return 0
    End If
    __bubbleAllocateQueue_s = __bubbleAllocateQueue_s & chrW(id)
End Script

Script __popQueue(Return Integer)
    If __bubbleAllocateQueue_s = "" Then
        Return 0
    End If
    If Len(__bubbleAllocateQueue_s) = 1 Then
        __bubbleAllocateQueue_s = ""
    Else
        __bubbleAllocateQueue_s = right(__bubbleAllocateQueue_s, -1)
    End If
    Return 1
End Script

Script __peekQueue(Return Integer)
    Return ascW(mid(__bubbleAllocateQueue_s, 1, 1))
End Script

Script __releaseLast(Return Integer)
    __box_tempIE = __peekQueue()
    Call __popQueue()
    If __box_tempIE = 0 Then
        Return 0
    End If
    Call __get_bubbleShapeData(__box_tempIE)
    __box_tempIF = __readInt_2Char(__ret_s, 21)
    __box_tempIG = __readInt_2Char(__ret_s, 23)
    If __box_tempIF >= 0 and __box_tempIG >= 0 Then
        For __box_tempID = __box_tempIF + __lBox_bmpIdStart To __box_tempIG + __lBox_bmpIdStart Step 1
            Call BErase(2, __box_tempID)
        Next
    End If
    Call __set_bubbleShapeData(__box_tempIE, "")
    Return __box_tempIE
End Script

Script __removeIdx(idx As Integer)
    __box_tempIA = Len(__bubbleAllocateQueue_s)
    For __box_tempII = 1 To __box_tempIA Step 1
        If ascW(mid(__bubbleAllocateQueue_s, __box_tempII, 1)) <> idx Then
            Continue
        End If
        If __box_tempII >= __box_tempIA Then
            __bubbleAllocateQueue_s = left(__bubbleAllocateQueue_s, -1)
        ElseIf __box_tempII = 1 Then
            __bubbleAllocateQueue_s = right(__bubbleAllocateQueue_s, -1)
        Else
            __bubbleAllocateQueue_s = left(__bubbleAllocateQueue_s, __box_tempII - 1) & right(__bubbleAllocateQueue_s, -__box_tempII)
        End If
        Exit For
    Next
    Call __get_bubbleShapeData(idx)
    __box_tempIF = __readInt_2Char(__ret_s, 21)
    __box_tempIG = __readInt_2Char(__ret_s, 23)
    If __box_tempIF >= 0 and __box_tempIG >= 0 Then
        For __box_tempID = __box_tempIF + __lBox_bmpIdStart To __box_tempIG + __lBox_bmpIdStart Step 1
            Call BErase(2, __box_tempID)
        Next
    End If
    Call __set_bubbleShapeData(idx, "")
End Script

Script __allocateBmp(num As Integer, id As Integer, Return Integer)
    If num = 0 Then
        Return 0
    End If
    Call __get_bubbleShapeData(id)
    __box_tempSB = __ret_s
    If __box_tempSB = "" Then
        Return 0
    End If
    __box_tempID = 0       ' 假设 bmpIdStart
    __box_tempIF = 0       ' 是否已经找到了可用的 bmpId 区间
    Do While __box_tempIF = 0
        __box_tempIF = -1
        For __box_tempIE = 1 To 8 Step 1
            If __box_tempIE = id Then
                Continue
            End If
            Call __get_bubbleShapeData(__box_tempIE)
            __box_tempSA = __ret_s
            If __box_tempSA = "" Then
                Continue
            End If
            If num + __box_tempID - 1 >= __readInt_2Char(__box_tempSA, 21) Then
                __box_tempIG = __readInt_2Char(__box_tempSA, 23)
                If __box_tempID <= __box_tempIG Then
                    __box_tempIF = 0
                    __box_tempID = __box_tempIG + 1
                    Exit For
                End If
            End If
        Next
    Loop
    __ret_s = __box_tempSB
    Call __writeInt_2Char("", 21, __box_tempID)
    Call __writeInt_2Char("", 23, __box_tempID + num - 1)
    ' 最后退出到 TextboxLite_Submit 的时候再保存到 idx 对应的字符串中
    Return __box_tempID
End Script

Script __prepareGraphicData_fromCache(content As String, id As Integer)
    ' 准备图形数据
    Call TXT_LoadStr(content)
    __box_tempIE = TXT_GetLen()
    If __box_tempIE > __lBox_max_char Then
        __box_tempIE = __lBox_max_char
    End If
    __box_tempIE = __allocateBmp(__box_tempIE + 10, id) ' 返回申请到的 bmp 起始位

    __box_tempIC = TXT_GetNext()
    __box_tempII = 0 ' 临时 id
    __box_tempIA = 0 ' w
    __box_tempID = 0 ' w-calc
    __box_tempIB = 0 ' h
    __box_tempDA = (TXT_GetCharSize(-1) + __size_cache) / TXT_GetCharSize(-1)
    Do While __box_tempIC >= 0 and __box_tempII <= __lBox_max_char
        If TXT_IsFlag(__box_tempIC) <> 0 Then
            __box_tempII = __box_tempII + 1
            If TXT_GetFlag(__box_tempIC) = "n" Then
                __box_tempID = 0
                __box_tempIB = __box_tempIB + TXT_GetCharSize(-1) * __box_tempDA
            End If
            __box_tempIC = TXT_GetNext()
            Continue
        End If
        If __box_tempID >= __wid_cache and __wid_cache > 0 Then
            __box_tempID = 0
            __box_tempIB = __box_tempIB + TXT_GetCharSize(-1) * __box_tempDA
        End If
        Call BMPCreate(__box_tempIE + __lBox_bmpIdStart, __lBox_char_npcId, 0, 1,     TXT_GetDestX(__box_tempIC), TXT_GetDestY(__box_tempIC), TXT_GetCharSize(-1), TXT_GetCharSize(-1),     __box_tempID + __lBox_9Grid_a + __offset_cache_x, __box_tempIB + __lBox_9Grid_b + __offset_cache_y, __box_tempDA, __box_tempDA,     0, 0,     0, -1)
        Bitmap(__box_tempIE + __lBox_bmpIdStart).zpos = __zpos_cache
        Bitmap(__box_tempIE + __lBox_bmpIdStart).forecolor_a = 255
        Bitmap(__box_tempIE + __lBox_bmpIdStart).forecolor_r = __color_cache_r
        Bitmap(__box_tempIE + __lBox_bmpIdStart).forecolor_g = __color_cache_g
        Bitmap(__box_tempIE + __lBox_bmpIdStart).forecolor_b = __color_cache_b
        Bitmap(__box_tempIE + __lBox_bmpIdStart).blendmode = 0

        __box_tempID = __box_tempID + TXT_GetCharSize(__box_tempIC) * __box_tempDA
        If __box_tempID > __box_tempIA Then
            __box_tempIA = __box_tempID
        End If
        __box_tempII = __box_tempII + 1
        __box_tempIE = __box_tempIE + 1
        __box_tempIC = TXT_GetNext()
    Loop
    If __box_tempID > __box_tempIA Then
        __box_tempIA = __box_tempID
    End If
    __box_tempIB = __box_tempIB + TXT_GetCharSize(-1) * __box_tempDA

    Call __writeInt_char("", 13, __box_tempIA + __lBox_9Grid_a + __lBox_9Grid_c) ' width
    Call __writeInt_char("", 25, __box_tempIB + __lBox_9Grid_b + __lBox_9Grid_d) ' height
    ' 最后退出到 TextboxLite_Submit 的时候再保存到 idx 对应的字符串中

    __box_tempDA = __box_tempIA
    __box_tempDB = __box_tempIB

    ' 九宫格 - 左上 右上 左下 右下
    Call BMPCreate(__box_tempIE + __lBox_bmpIdStart, __lBox_9Grid_npcId, 0, 1,         __lBox_9Grid_x, __lBox_9Grid_y, __lBox_9Grid_a, __lBox_9Grid_b,                                                     __offset_cache_x, __offset_cache_y, 1, 1,                                                         0, 0,     0, -1)
    Call BMPCreate(__box_tempIE + 1 + __lBox_bmpIdStart, __lBox_9Grid_npcId, 0, 1,     __lBox_9Grid_x + __lBox_9Grid_a + __lBox_9Grid_w, __lBox_9Grid_y, __lBox_9Grid_c, __lBox_9Grid_b,                             __lBox_9Grid_a + __box_tempDA + __offset_cache_x, __offset_cache_y, 1, 1,                             0, 0,     0, -1)
    Call BMPCreate(__box_tempIE + 2 + __lBox_bmpIdStart, __lBox_9Grid_npcId, 0, 1,     __lBox_9Grid_x, __lBox_9Grid_y + __lBox_9Grid_b + __lBox_9Grid_h, __lBox_9Grid_a, __lBox_9Grid_d,                             __offset_cache_x, __lBox_9Grid_b + __box_tempDB + __offset_cache_y, 1, 1,                             0, 0,     0, -1)
    Call BMPCreate(__box_tempIE + 3 + __lBox_bmpIdStart, __lBox_9Grid_npcId, 0, 1,     __lBox_9Grid_x + __lBox_9Grid_a + __lBox_9Grid_w, __lBox_9Grid_y + __lBox_9Grid_b + __lBox_9Grid_h, __lBox_9Grid_c, __lBox_9Grid_d,     __lBox_9Grid_a + __box_tempDA + __offset_cache_x, __lBox_9Grid_b + __box_tempDB + __offset_cache_y, 1, 1, 0, 0,     0, -1)
    Bitmap(__box_tempIE + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + 1 + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + 2 + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + 3 + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + __lBox_bmpIdStart).blendmode = 0
    Bitmap(__box_tempIE + 1 + __lBox_bmpIdStart).blendmode = 0
    Bitmap(__box_tempIE + 2 + __lBox_bmpIdStart).blendmode = 0
    Bitmap(__box_tempIE + 3 + __lBox_bmpIdStart).blendmode = 0
    __box_tempIE = __box_tempIE + 4

    ' 九宫格 - 左中 右中 上中 下中
    Call BMPCreate(__box_tempIE + __lBox_bmpIdStart, __lBox_9Grid_npcId, 0, 1,         __lBox_9Grid_x, __lBox_9Grid_y + __lBox_9Grid_b, __lBox_9Grid_a, __lBox_9Grid_h,                             __offset_cache_x, __lBox_9Grid_b + __offset_cache_y, 1, __box_tempDB / __lBox_9Grid_h,                              0, 0,     0, -1)
    Call BMPCreate(__box_tempIE + 1 + __lBox_bmpIdStart, __lBox_9Grid_npcId, 0, 1,     __lBox_9Grid_x + __lBox_9Grid_a + __lBox_9Grid_w, __lBox_9Grid_y + __lBox_9Grid_b, __lBox_9Grid_c, __lBox_9Grid_h,     __lBox_9Grid_a + __box_tempDA + __offset_cache_x, __lBox_9Grid_b + __offset_cache_y, 1, __box_tempDB / __lBox_9Grid_h,  0, 0,     0, -1)
    Call BMPCreate(__box_tempIE + 2 + __lBox_bmpIdStart, __lBox_9Grid_npcId, 0, 1,     __lBox_9Grid_x + __lBox_9Grid_a, __lBox_9Grid_y, __lBox_9Grid_w, __lBox_9Grid_b,                             __lBox_9Grid_a + __offset_cache_x, __offset_cache_y, __box_tempDA / __lBox_9Grid_w, 1,                              0, 0,     0, -1)
    Call BMPCreate(__box_tempIE + 3 + __lBox_bmpIdStart, __lBox_9Grid_npcId, 0, 1,     __lBox_9Grid_x + __lBox_9Grid_a, __lBox_9Grid_y + __lBox_9Grid_b + __lBox_9Grid_h, __lBox_9Grid_w, __lBox_9Grid_d,     __lBox_9Grid_a + __offset_cache_x, __lBox_9Grid_b + __box_tempDB + __offset_cache_y, __box_tempDA / __lBox_9Grid_w, 1,  0, 0,     0, -1)
    Bitmap(__box_tempIE + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + 1 + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + 2 + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + 3 + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + __lBox_bmpIdStart).blendmode = 0
    Bitmap(__box_tempIE + 1 + __lBox_bmpIdStart).blendmode = 0
    Bitmap(__box_tempIE + 2 + __lBox_bmpIdStart).blendmode = 0
    Bitmap(__box_tempIE + 3 + __lBox_bmpIdStart).blendmode = 0
    __box_tempIE = __box_tempIE + 4

    ' 九宫格 - 中
    Call BMPCreate(__box_tempIE + __lBox_bmpIdStart, __lBox_9Grid_npcId, 0, 1,     __lBox_9Grid_a, __lBox_9Grid_b, __lBox_9Grid_w, __lBox_9Grid_h,     __lBox_9Grid_a + __offset_cache_x, __lBox_9Grid_b + __offset_cache_y, __box_tempDA / __lBox_9Grid_w, __box_tempDB / __lBox_9Grid_h,     0, 0,     0, -1)
    Bitmap(__box_tempIE + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + __lBox_bmpIdStart).blendmode = 0
End Script

Script __clearCache()
    __wid_cache = 0
    __size_cache = 0
    __color_cache_r = 255
    __color_cache_g = 255
    __color_cache_b = 255
    __offset_cache_x = 0
    __offset_cache_y = 0
    __anchor_cache_x = 0
    __anchor_cache_y = 0
    __zpos_cache = __lBox_defaultZpos
    __bubbleShapeData_cache = __bubbleShapeDataDefault

    __lBox_9Grid_cache_x = __lBox_9Grid_x
    __lBox_9Grid_cache_y = __lBox_9Grid_y
    __lBox_9Grid_cache_npcId = __lBox_9Grid_npcId
End Script

' ----------------------------------------------------- 外部函数
' 设置跟随目标的 id
' @param id 跟随目标 id
' @param type 跟随目标类型:
'     1 - 跟随 npc
'     2 - 跟随 bitmap
'     3 - 跟随 character
'     4 - 跟随 block
'     5 - 跟随 bgo
Export Script TextboxLite_StoreTargetId(id As Integer, type As Integer)
    __ret_s = __bubbleShapeData_cache
    __box_tempIH = __readInt_char(__ret_s, 28) and -57
    Call __writeInt_2Char("", 18, id)
    Call __writeInt_char("", 28, __box_tempIH or ((type and 7) << 3))
    __bubbleShapeData_cache = __ret_s
End Script

' 设置位置
' @param x x 坐标
' @param y y 坐标
Export Script TextboxLite_StorePos(x As Long, y As Long)
    __ret_s = __bubbleShapeData_cache
    Call __writeInt_2Char("", 1, x)
    Call __writeInt_2Char("", 3, y)
    __bubbleShapeData_cache = __ret_s
End Script

' 设置锚点
' @param x x 轴向锚点 [0, 1]
' @param y y 轴向锚点 [0, 1]
Export Script TextboxLite_StoreAnchor(x As Double, y As Double)
    __anchor_cache_x = x
    __anchor_cache_y = y
End Script

' 设置偏移
' @param x x 轴向偏移
' @param y y 轴向偏移
Export Script TextboxLite_StoreOffset(x As Long, y As Long)
    __offset_cache_x = x
    __offset_cache_y = y
End Script

' 设置宽度限制
' @param x 宽度限制
Export Script TextboxLite_StoreWidth(x As Integer)
    __wid_cache = x
End Script

' 设置最大停留时间
' @param x 最大停留时间
Export Script TextboxLite_StoreTime(x As Integer)
    Call __writeInt_char(__bubbleShapeData_cache, 14, x)
    __bubbleShapeData_cache = __ret_s
End Script

' 设置字体大小
' @param x 字体大小
Export Script TextboxLite_StoreSize(x As Integer)
    __size_cache = x
End Script

' 设置字体颜色
' @param r 字体颜色红色通道
' @param g 字体颜色绿色通道
' @param b 字体颜色蓝色通道
Export Script TextboxLite_StoreColor(r As Integer, g As Integer, b As Integer)
    __color_cache_r = r
    __color_cache_g = g
    __color_cache_b = b
End Script

' 清除所有小对话框
Export Script TextboxLite_Clear()
    Do While __releaseLast() <> 0
    Loop
End Script

' 设置气泡九宫格
' @param npcId npc id
' @param srcX srcX
' @param srcY srcY
Export Script TextboxLite_Store9Grid(npcId As Long, srcX As Integer, srcY As Integer)
    __lBox_9Grid_cache_npcId = npcId
    __lBox_9Grid_cache_x = srcX
    __lBox_9Grid_cache_y = srcY
End Script

' 新增小对话框
' @param content 对话框内容 (已格式化文本)
' @return 是否成功新增
Export Script TextboxLite_Submit(content As String, Return Integer)
    If Len(__bubbleAllocateQueue_s) >= 8 Then
        Call __releaseLast()
    End If
    For __box_tempIH = 1 To 8 Step 1
        Call __get_bubbleShapeData(__box_tempIH)
        If __ret_s = "" Then
            If __idSeed >= 32767 Then
                __idSeed = 0
            End If
            __idSeed = __idSeed + 1
            __dirtyFlag = __dirtyFlag Or (1 << (__box_tempIH - 1))
            Call __pushQueue(__box_tempIH)
            Call __writeInt_char(__bubbleShapeData_cache, 20, __idSeed)
            Call __writeInt_2Char("", 26, __timestamp)
            Call __set_bubbleShapeData(__box_tempIH, __ret_s)
            Call __prepareGraphicData_fromCache(content, __box_tempIH)
            Call __set_bubbleShapeData(__box_tempIH, __ret_s)

            '  初始化位置
            Call __get_bubbleShapeData(__box_tempIH)
            __box_tempID = __readInt_char(__ret_s, 13) * __anchor_cache_x ' anchor offset x
            __box_tempIE = __readInt_char(__ret_s, 25) * __anchor_cache_y ' anchor offset y
            __box_tempID = __readInt_2Char(__ret_s, 1) - __box_tempID ' posX
            __box_tempIE = __readInt_2Char(__ret_s, 3) - __box_tempIE ' posY
            __box_tempIF = __readInt_2Char(__ret_s, 21) + __lBox_bmpIdStart ' start bmp id
            __box_tempIG = __readInt_2Char(__ret_s, 23) + __lBox_bmpIdStart ' end bmp id
            For __box_tempIH = __box_tempIF To __box_tempIG Step 1
                Bitmap(__box_tempIH).hide = 1
                Bitmap(__box_tempIH).destx = Bitmap(__box_tempIH).destx + __box_tempID
                Bitmap(__box_tempIH).desty = Bitmap(__box_tempIH).desty + __box_tempIE
            Next
            Call __clearCache()
            Return __idSeed
        End If
    Next
    Call __clearCache()
    Return 0
End Script

' ----------------------------------------------------- 内部刷新逻辑

Script __refresh_txtBoxLite(id As Long)
    Call __get_bubbleShapeData(id)
    ' 计算跟随
    __box_tempIC = (__readInt_char(__ret_s, 28) and 56) >> 3
    If __box_tempIC <> 0 Then ' 存在跟随
        __box_tempID = __readInt_2Char(__ret_s, 18) ' target id
        __box_tempIE = __readInt_2Char(__ret_s, 1)  ' dx
        __box_tempIF = __readInt_2Char(__ret_s, 3)  ' dy
        __box_tempIG = __readInt_2Char(__ret_s, 21) ' begin
        __box_tempIH = __readInt_2Char(__ret_s, 23) ' end

        __box_tempIJ = __readInt_char(__ret_s, 6) ' oldPushup
        __box_tempIK = __readInt_char(__ret_s, 5) ' curPushup
        __box_tempIJ = __box_tempIJ - __box_tempIK

        If __box_tempIC = 1 Then ' 跟随 bitmap
            __box_tempIE = Bitmap(__box_tempID).destx - __box_tempIE ' dx
            __box_tempIF = Bitmap(__box_tempID).desty - __box_tempIF ' dy
            Call __writeInt_char(__ret_s, 6, __box_tempIK)
            Call __writeInt_2Char(__ret_s, 1, Bitmap(__box_tempID).destx)
            Call __writeInt_2Char(__ret_s, 3, Bitmap(__box_tempID).desty)
            Call __set_bubbleShapeData(id, __ret_s)
        ElseIf __box_tempIC = 2 Then ' 跟随 npc
            __box_tempIE = NPC(__box_tempID).x - __box_tempIE
            __box_tempIF = NPC(__box_tempID).y - __box_tempIF
            Call __writeInt_char(__ret_s, 6, __box_tempIK)
            Call __writeInt_2Char(__ret_s, 1, NPC(__box_tempID).x)
            Call __writeInt_2Char(__ret_s, 3, NPC(__box_tempID).y)
            Call __set_bubbleShapeData(id, __ret_s)
        ElseIf __box_tempIC = 3 Then ' 跟随 char
            __box_tempIE = Char(__box_tempID).x - __box_tempIE
            __box_tempIF = Char(__box_tempID).y - __box_tempIF
            Call __writeInt_char(__ret_s, 6, __box_tempIK)
            Call __writeInt_2Char(__ret_s, 1, Char(__box_tempID).x)
            Call __writeInt_2Char(__ret_s, 3, Char(__box_tempID).y)
            Call __set_bubbleShapeData(id, __ret_s)
        ElseIf __box_tempIC = 4 Then ' 跟随 block
            __box_tempIE = Block(__box_tempID).x - __box_tempIE
            __box_tempIF = Block(__box_tempID).y - __box_tempIF
            Call __writeInt_char(__ret_s, 6, __box_tempIK)
            Call __writeInt_2Char(__ret_s, 1, Block(__box_tempID).x)
            Call __writeInt_2Char(__ret_s, 3, Block(__box_tempID).y)
            Call __set_bubbleShapeData(id, __ret_s)
        ElseIf __box_tempIC = 5 Then ' 跟随 bgo
            __box_tempIE = BGO(__box_tempID).x - __box_tempIE
            __box_tempIF = BGO(__box_tempID).y - __box_tempIF
            Call __writeInt_char(__ret_s, 6, __box_tempIK)
            Call __writeInt_2Char(__ret_s, 1, BGO(__box_tempID).x)
            Call __writeInt_2Char(__ret_s, 3, BGO(__box_tempID).y)
            Call __set_bubbleShapeData(id, __ret_s)
        Else
            __box_tempIE = 0
            __box_tempIF = 0
        End If
        For __box_tempII = __box_tempIG + __lBox_bmpIdStart To __box_tempIH + __lBox_bmpIdStart Step 1
            Bitmap(__box_tempII).hide = 0
            Bitmap(__box_tempII).destx = Bitmap(__box_tempII).destx + __box_tempIE
            Bitmap(__box_tempII).desty = Bitmap(__box_tempII).desty + __box_tempIF + __box_tempIJ
        Next
        __dirtyFlag = __dirtyFlag or (1 << (id - 1))
    Else
        __box_tempIG = __readInt_2Char(__ret_s, 21) ' begin
        __box_tempIH = __readInt_2Char(__ret_s, 23) ' end
        For __box_tempII = __box_tempIG + __lBox_bmpIdStart To __box_tempIH + __lBox_bmpIdStart Step 1
            Bitmap(__box_tempII).hide = 0
        Next
    End If
End Script

' -----------------------------------------------------
' -----------------------------------------------------
' -----------------------------------------------------
' -----------------------------------------------------
' ----------------------------------------------------- main loop

Do
    __eventState = 0

    ' 更新时间戳
    __timestamp += 1
    If __timestamp >= 2147483647 or __timestamp < 0 Then
        __timestamp = 0
    End If

    ' ----------------------------------------------------- text box lite
    If __bubbleAllocateQueue_s = "" Then
        GoTo Flag_EndLitBox
    End If

    ' 计算挤出
    __box_tempIJ = Len(__bubbleAllocateQueue_s)
    For __box_tempIH = 1 To __box_tempIJ Step 1
        __box_tempII = ascW(mid(__bubbleAllocateQueue_s, __box_tempIH, 1))
        If (__dirtyFlag And (1 << (__box_tempII - 1))) = 0 Then
            Continue
        End If

        Call __get_bubbleShapeData(__box_tempII)
        __box_tempIF = (__readInt_char(__ret_s, 28) and 56) >> 3
        If (0 = __box_tempIF) Or ((__readInt_char(__ret_s, 28) and 1) = 0) Then
            Continue ' 不存在跟随, 或不支持被向上挤出, 直接过滤
        End If

        ' 第一个特殊处理
        If 1 = __box_tempIH Then
            Call __writeInt_char("", 5, 0) ' 写入挤出高度
            Call __set_bubbleShapeData(__box_tempII, __ret_s)
            Continue
        End If

        __box_tempIG = 0
        For __box_tempID = __box_tempIH - 1 To 1 Step -1
            __box_tempIE = ascW(mid(__bubbleAllocateQueue_s, __box_tempID, 1))
            If (__dirtyFlag And (1 << (__box_tempIE - 1))) = 0 Then
                Continue
            End If

            Call __get_bubbleShapeData(__box_tempIE)
            If (__box_tempIF <> ((__readInt_char(__ret_s, 28) and 56) >> 3)) Or (((__readInt_char(__ret_s, 28) and 2)) = 0) Then
                Continue ' 跟随模式不同, 或不支持向上挤出, 直接过滤
            End If

            __box_tempIG = 1
            __box_tempIF = __readInt_char(__ret_s, 5) + __readInt_char(__ret_s, 25) ' 加上高度和 pushing height
            Call __get_bubbleShapeData(__box_tempII)
            Call __writeInt_char(__ret_s, 5, __box_tempIF) ' 写入挤出高度
            Call __set_bubbleShapeData(__box_tempII, __ret_s)
            Exit For
        Next

        ' 清空写入的挤出高度
        If 0 = __box_tempIG Then
            Call __get_bubbleShapeData(__box_tempII)
            Call __writeInt_char(__ret_s, 5, 0) ' 写入挤出高度
            Call __set_bubbleShapeData(__box_tempII, __ret_s)
        End If
    Next

    ' 计算刷新
    If __dirtyFlag And 1 Then
        __dirtyFlag = __dirtyFlag and -2
        Call __refresh_txtBoxLite(1)
    End If
    If __dirtyFlag And 2 Then
        __dirtyFlag = __dirtyFlag and -3
        Call __refresh_txtBoxLite(2)
    End If
    If __dirtyFlag And 4 Then
        __dirtyFlag = __dirtyFlag and -5
        Call __refresh_txtBoxLite(3)
    End If
    If __dirtyFlag And 8 Then
        __dirtyFlag = __dirtyFlag and -9
        Call __refresh_txtBoxLite(4)
    End If
    If __dirtyFlag And 16 Then
        __dirtyFlag = __dirtyFlag and -17
        Call __refresh_txtBoxLite(5)
    End If
    If __dirtyFlag And 32 Then
        __dirtyFlag = __dirtyFlag and -33
        Call __refresh_txtBoxLite(6)
    End If
    If __dirtyFlag And 64 Then
        __dirtyFlag = __dirtyFlag and -65
        Call __refresh_txtBoxLite(7)
    End If
    If __dirtyFlag And 128 Then
        __dirtyFlag = __dirtyFlag and -129
        Call __refresh_txtBoxLite(8)
    End If

    For __box_tempIC = 1 To 8 Step 1
        Call __get_bubbleShapeData(__box_tempIC)
        If __ret_s = "" Then
            Continue
        End If
        __box_tempID = __readInt_2Char(__ret_s, 26)
        __box_tempIE = __readInt_char(__ret_s, 14)
        If __timestamp < __box_tempID or  __box_tempIE < __timestamp - __box_tempID Then
            Call __removeIdx(__box_tempIC)
        End If
    Next

Flag_EndLitBox:

    ' ----------------------------------------------------- rich text
    If __shakeOrSwing = 0 Then
        GoTo Flag_EndRichText
    End If
    Call __txtBox_UpdateShakeAnim()
    Call __txtBox_UpdateSwingAnim()
Flag_EndRichText:

    ' ----------------------------------------------------- text box
    If __animFac < -2 Then
        __box_tempIN = __seek
        Call TextBoxLowLevel_DrawNext()
        If __seek > __box_tempIN And __box_eventScriptName <> "" Then
            __eventState = 1
            __eventValue = ChrW(__seek - __box_tempIN)
            Call ExeScript(__box_eventScriptName)
            __eventState = 0
        End If
    End If
    Call __textbox_inner_refreshBg()

    If __exit Then
        Exit Do
    End
    ' ----------------------------------------------------- end loop
    Call Sleep(1)
Loop

__exit = 0
Call TextboxLite_Clear()
Call __textbox_inner_cleanBg()
