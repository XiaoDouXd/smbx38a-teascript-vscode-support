' -------------------------------------------------------------------
' -------------------------------------------------------------------
' -------------------------------------------------------------------
' ------------------------- smbx 38a 动态文本框实现 - xiaodou 20240707
' ------------------------- 该脚本基于字符贴图集绘制脚本 TXT_ 实现
' ------------------------- 请确保您预先将其导入进关卡环境中并运行了....
' -------------------------------------------------------------------
' 这里是使用例: 新建一个脚本 A 并用事件触发它
' ※※ 字符串 s 应该是用 FontAtlasGenerator.exe 编码过的字符串而非 smbx 38a 的原生字符字面量 ※※
' Dim s As Double = ""
' Dim w As Double = 200
' Dim t As Double = 0
' Call TextboxLowLevel_LoadString(s)
'
' Call BMPCreate(1, 2, 1, 1,     0, 0, 1, 1,    0, 0, 1, 1,    0, 0, 0, rgba(0, 0, 0, 25))
' Do
' 	w = sin(t* 0.1) * 100 + 500
' 	Call TextboxLowLevel_SetWidth(w)
' 	Call TextboxLowLevel_SetPosX(sin(t*0.1)*50 + 100)
' 	Call TextboxLowLevel_SetPosY(cos(t*0.1)*50 + 100)
' 	Call TextboxLowLevel_DrawNext()
'
' 	Bitmap(1).scalex = TextboxLowLevel_GetWidth()
' 	Bitmap(1).scaleY = TextboxLowLevel_GetHeight()
' 	Bitmap(1).destx = TextboxLowLevel_GetPosX()
' 	Bitmap(1).desty = TextboxLowLevel_GetPosY()
'
' 	t += 1
'     Call Sleep(1)
' 	Call Sleep(1)
' 	Call Sleep(1)
' 	Call Sleep(1)
' Loop
' -------------------------------------------------------------------
' -------------------------------------------------------------------
' -------------------------------------------------------------------
' -------------------------------------------------------------------
' ----------------------------------------------------- config
' MAX_VAL = 10000, MIN_VAL = -10000
Dim __box_npc As Long = 1            ' 文本贴图集
Dim __box_bmpStart As Long = 1000    ' 文本 bmp 起始 id
Dim __box_bmpZpos As Double = 0.5    ' 文本 zpos

Dim __box_wid As Integer = 600       ' 文本框宽度限制, -1 为无限制 [-1, 10000]
Dim __box_hei As Integer = -1        ' 文本框高度限制, -1 为无限制 [-1, 10000]
Dim __box_posX As Integer = 100      ' 文本框位置 (屏幕坐标) [-10000, 10000]
Dim __box_posY As Integer = 100      ' 文本框位置 (屏幕坐标) [-10000, 10000]
Dim __box_size As Integer = 24       ' 文本基础大小 [0, 10000]
Dim __box_charSpacing As Integer = 0 ' 字符间距 [-10000, 10000]
Dim __box_lineSpacing As Integer = 2 ' 行距 [-10000, 10000]
Dim __box_alignType As Integer = 0   ' 对齐方式 default-left | 1-right | 2-mid

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
Dim __box_tempDA As Double = 0
Dim __box_tempDB As Double = 0
Dim __box_tempSA As String = 0
Dim __box_tempSB As String = 0

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

    ' 下面是四个字符的 flag
    If __box_tempIE < 4 Then
        Return 0
    End If
    __box_tempSB = Mid(flag, 1, 4)

    ' wait
    If __box_tempSB = "size" Then
        __sizeOffset = 0
        If __box_tempIE < 6 Then
            Return 0
        End If
        __box_tempIH = __txtBox_ReadFlagVal(flag, 5)
        If __box_tempIH < 40 And __box_tempIH > -40 Then
            __sizeOffset = __box_tempIH
        End If
        Return 0
    End If

    If __box_tempSB = "wait" Then
        __wait = 1
        Return 0
    ElseIf __box_tempSB = "page" Then
        __page = 1
        Return 0
    End If

    ' 下面是五个字符的 flag
    If __box_tempIE < 5 Then
        Return 0
    End If
    __box_tempSB = Mid(flag, 1, 5)

    ' speed
    If __box_tempSB = "speed" Then
        __speed = 0
        __seekDelay = 0
        If __box_tempIE < 6 Then
            Return 0
        End If
        __box_tempIH = __txtBox_ReadFlagVal(flag, 6)
        If __box_tempIH < 40 And __box_tempIH > -40 Then
            If __isInDrawToSeek = 0 Then
                __speed = __box_tempIH
                __seekDelay = __speed
            End If
        End If
        Return 0
    End If

    ' shake
    If __box_tempSB = "shake" Then
        __shake = 0
        If __box_tempIE < 6 Then
            Return 0
        End If
        __box_tempIH = __txtBox_ReadFlagVal(flag, 6)
        If __box_tempIH < 40 And __box_tempIH > -40 Then
            __shake = __box_tempIH
        End If
        Return 0
    End If

    ' swing
    If __box_tempSB = "swing" Then
        __swing = 0
        If __box_tempIE < 6 Then
            Return 0
        End If
        __box_tempIH = __txtBox_ReadFlagVal(flag, 6)
        If __box_tempIH < 40 And __box_tempIH > -40 Then
            __swing = __box_tempIH
        End If
        Return 0
    End If

    ' 下面是六个字符的 flag
    If __box_tempIE < 6 Then
        Return 0
    End If
    __box_tempSB = Mid(flag, 1, 6)

    ' exsize
    If __box_tempSB = "exsize" Then
        __exSizeX = 0
        __exSizeY = 0
        If __box_tempIE < 8 Then
            Return 0
        End If
        __box_tempIH = __txtBox_ReadFlagVal(flag, 7)
        If __box_tempIH < 40 And __box_tempIH > -40 Then
            __exSizeX = __box_tempIH
        End If
        If __box_tempIE < 10 Then
            Return 0
        End If
        __box_tempIH = __txtBox_ReadFlagVal(flag, 9)
        If __box_tempIH < 40 And __box_tempIH > -40 Then
            __exSizeY = __box_tempIH
        End If
        Return 0
    End If
    Return 0
End Script

Script __txtBox_GetWidth(c As Long, Return Integer)
    If c <= 127 Then
        Return TXT_GetCharSize() / 2
    End If
    Return TXT_GetCharSize()
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
                If __box_tempIE < 4 Then
                    If __box_tempIE > 0 Then
                        __box_tempSB = Mid(__box_tempSA, 1, 1)
                        If __box_tempSB = "n" And __seek <> __box_tempIA Then
                            Exit For
                        End If
                    End If
                    Continue
                End If
                __box_tempSB = Mid(__box_tempSA, 1, 4)
                If __box_tempSB = "size" Then
                    __box_tempID = 0
                    If __box_tempIE < 6 Then
                        Continue
                    End If
                    __box_tempIH = __txtBox_ReadFlagVal(__box_tempSA, 5)
                    If __box_tempIH < 40 And __box_tempIH > -40 Then
                        __box_tempID = __box_tempIH
                    End If
                    Continue
                End If
                If __box_tempSB = "page" Then
                    If __box_tempIB = 0 Then
                        Continue
                    End If
                    Exit For
                End If
                If __box_tempIE < 6 Then
                    Continue
                End If
                __box_tempSB = Mid(__box_tempSA, 1, 6)
                If __box_tempSB = "exsize" Then
                    __box_tempIL = 0
                    __box_tempIM = 0
                    If __box_tempIE < 8 Then
                        Continue
                    End If
                    __box_tempIH = __txtBox_ReadFlagVal(__box_tempSA, 7)
                    If __box_tempIH > -40 And __box_tempIH < 40 Then
                        __box_tempIL = __box_tempIH
                    End If
                    If __box_tempIE < 10 Then
                        Continue
                    End If
                    __box_tempIH = __txtBox_ReadFlagVal(__box_tempSA, 9)
                    If __box_tempIH > -40 And __box_tempIH < 40 Then
                        __box_tempIM = __box_tempIH
                    End If
                End If
            End If
            Continue
        End If
        __box_tempDA = __txtBox_Max(__box_tempID + __box_size, 0.0)
        __box_tempIG = __box_tempIB + (__txtBox_GetWidth(__box_tempIC) + __box_charSpacing) * (__box_tempDA / TXT_GetCharSize()) + __box_tempIL * 2
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
    Bitmap(__box_tempIA).scrwidth = __txtBox_GetWidth(__box_tempIB)
    Bitmap(__box_tempIA).scrheight = TXT_GetCharSize()
    Bitmap(__box_tempIA).scrx = TXT_GetDestX(__box_tempIB)
    Bitmap(__box_tempIA).scry = TXT_GetDestY(__box_tempIB)
    Bitmap(__box_tempIA).scalex = __txtBox_Max(__sizeOffset + __box_size, 0.0) / TXT_GetCharSize()
    Bitmap(__box_tempIA).scaley = __txtBox_Max(__sizeOffset + __box_size, 0.0) / TXT_GetCharSize()

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
    Bitmap(__box_tempIA).desty = __posSeekY - __txtBox_Max(__sizeOffset + __box_size, 0.0)

    If __shake <> 0 Then
        Call __txtBox_PushShake(__currUsedBmpCnt, Bitmap(__box_tempIA).destx, Bitmap(__box_tempIA).desty, __shake)
    End If
    If __swing <> 0 Then
        Call __txtBox_PushSwing(__currUsedBmpCnt, Bitmap(__box_tempIA).destx, Bitmap(__box_tempIA).desty, __swing)
    End If

    Return __txtBox_Max(__realCharSpacing + __txtBox_GetWidth(__box_tempIB) * __txtBox_Max(__sizeOffset + __box_size, 0.0) / TXT_GetCharSize(), 0.0) + __exSizeX * 2
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

' ----------------------------------------------------- main loop
Do
    If __shakeOrSwing = 0 Then
        __timestamp = 0
        GoTo EndLoop
    End If

    __timestamp += 1
    Call __txtBox_UpdateShakeAnim()
    Call __txtBox_UpdateSwingAnim()

    EndLoop:
    Call Sleep(1)
Loop
