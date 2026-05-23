' ----------------------------------------------------- config
Dim __lBox_char_npcId As Long = 1           ' 字符素材 npc id
Dim __lBox_bmpIdStart As Long = 1000        ' bmp 起始 id
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
Dim __timestamp As Long = 0

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

Dim __box_tempDA As Double = 0
Dim __box_tempDB As Double = 0

Dim __box_tempSA As String = ""
Dim __box_tempSB As String = ""

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

Script __getWidth(c As Long, Return Integer)
    If c <= 127 Then
        Return TXT_GetCharSize() / 2
    End If
    Return TXT_GetCharSize()
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
    __box_tempDA = (TXT_GetCharSize() + __size_cache) / TXT_GetCharSize()
    Do While __box_tempIC >= 0 and __box_tempII <= __lBox_max_char
        If TXT_IsFlag(__box_tempIC) <> 0 Then
            __box_tempII = __box_tempII + 1
            If TXT_GetFlag(__box_tempIC) = "n" Then
                __box_tempID = 0
                __box_tempIB = __box_tempIB + TXT_GetCharSize() * __box_tempDA
            End If
            __box_tempIC = TXT_GetNext()
            Continue
        End If
        If __box_tempID >= __wid_cache and __wid_cache > 0 Then
            __box_tempID = 0
            __box_tempIB = __box_tempIB + TXT_GetCharSize() * __box_tempDA
        End If
        Call BMPCreate(__box_tempIE + __lBox_bmpIdStart, __lBox_char_npcId, 0, 1,     TXT_GetDestX(__box_tempIC), TXT_GetDestY(__box_tempIC), TXT_GetCharSize(), TXT_GetCharSize(),     __box_tempID + __lBox_9Grid_a + __offset_cache_x, __box_tempIB + __lBox_9Grid_b + __offset_cache_y, __box_tempDA, __box_tempDA,     0, 0,     0, -1)
        Bitmap(__box_tempIE + __lBox_bmpIdStart).zpos = __zpos_cache
        Bitmap(__box_tempIE + __lBox_bmpIdStart).forecolor_a = 255
        Bitmap(__box_tempIE + __lBox_bmpIdStart).forecolor_r = __color_cache_r
        Bitmap(__box_tempIE + __lBox_bmpIdStart).forecolor_g = __color_cache_g
        Bitmap(__box_tempIE + __lBox_bmpIdStart).forecolor_b = __color_cache_b

        __box_tempID = __box_tempID + __getWidth(__box_tempIC) * __box_tempDA
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
    __box_tempIB = __box_tempIB + TXT_GetCharSize() * __box_tempDA

    Call __writeInt_char("", 13, __box_tempIA + __lBox_9Grid_a + __lBox_9Grid_c) ' width
    Call __writeInt_char("", 25, __box_tempIB + __lBox_9Grid_b + __lBox_9Grid_d) ' height
    ' 最后退出到 TextboxLite_Submit 的时候再保存到 idx 对应的字符串中

    __box_tempDA = __box_tempIA
    __box_tempDB = __box_tempIB

    ' 九宫格 - 左上 右上 左下 右下
    Call BMPCreate(__box_tempIE + __lBox_bmpIdStart, __lBox_9Grid_cache_npcId, 0, 1,         __lBox_9Grid_cache_x, __lBox_9Grid_cache_y, __lBox_9Grid_a, __lBox_9Grid_b,                                                     __offset_cache_x, __offset_cache_y, 1, 1,                                                         0, 0,     0, -1)
    Call BMPCreate(__box_tempIE + 1 + __lBox_bmpIdStart, __lBox_9Grid_cache_npcId, 0, 1,     __lBox_9Grid_cache_x + __lBox_9Grid_a + __lBox_9Grid_w, __lBox_9Grid_cache_y, __lBox_9Grid_c, __lBox_9Grid_b,                             __lBox_9Grid_a + __box_tempDA + __offset_cache_x, __offset_cache_y, 1, 1,                             0, 0,     0, -1)
    Call BMPCreate(__box_tempIE + 2 + __lBox_bmpIdStart, __lBox_9Grid_cache_npcId, 0, 1,     __lBox_9Grid_cache_x, __lBox_9Grid_cache_y + __lBox_9Grid_b + __lBox_9Grid_h, __lBox_9Grid_a, __lBox_9Grid_d,                             __offset_cache_x, __lBox_9Grid_b + __box_tempDB + __offset_cache_y, 1, 1,                             0, 0,     0, -1)
    Call BMPCreate(__box_tempIE + 3 + __lBox_bmpIdStart, __lBox_9Grid_cache_npcId, 0, 1,     __lBox_9Grid_cache_x + __lBox_9Grid_a + __lBox_9Grid_w, __lBox_9Grid_cache_y + __lBox_9Grid_b + __lBox_9Grid_h, __lBox_9Grid_c, __lBox_9Grid_d,     __lBox_9Grid_a + __box_tempDA + __offset_cache_x, __lBox_9Grid_b + __box_tempDB + __offset_cache_y, 1, 1, 0, 0,     0, -1)
    Bitmap(__box_tempIE + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + 1 + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + 2 + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + 3 + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    __box_tempIE = __box_tempIE + 4

    ' 九宫格 - 左中 右中 上中 下中
    Call BMPCreate(__box_tempIE + __lBox_bmpIdStart, __lBox_9Grid_cache_npcId, 0, 1,         __lBox_9Grid_cache_x, __lBox_9Grid_cache_y + __lBox_9Grid_b, __lBox_9Grid_a, __lBox_9Grid_h,                             __offset_cache_x, __lBox_9Grid_b + __offset_cache_y, 1, __box_tempDB / __lBox_9Grid_h,                              0, 0,     0, -1)
    Call BMPCreate(__box_tempIE + 1 + __lBox_bmpIdStart, __lBox_9Grid_cache_npcId, 0, 1,     __lBox_9Grid_cache_x + __lBox_9Grid_a + __lBox_9Grid_w, __lBox_9Grid_cache_y + __lBox_9Grid_b, __lBox_9Grid_c, __lBox_9Grid_h,     __lBox_9Grid_a + __box_tempDA + __offset_cache_x, __lBox_9Grid_b + __offset_cache_y, 1, __box_tempDB / __lBox_9Grid_h,  0, 0,     0, -1)
    Call BMPCreate(__box_tempIE + 2 + __lBox_bmpIdStart, __lBox_9Grid_cache_npcId, 0, 1,     __lBox_9Grid_cache_x + __lBox_9Grid_a, __lBox_9Grid_cache_y, __lBox_9Grid_w, __lBox_9Grid_b,                             __lBox_9Grid_a + __offset_cache_x, __offset_cache_y, __box_tempDA / __lBox_9Grid_w, 1,                              0, 0,     0, -1)
    Call BMPCreate(__box_tempIE + 3 + __lBox_bmpIdStart, __lBox_9Grid_cache_npcId, 0, 1,     __lBox_9Grid_cache_x + __lBox_9Grid_a, __lBox_9Grid_cache_y + __lBox_9Grid_b + __lBox_9Grid_h, __lBox_9Grid_w, __lBox_9Grid_d,     __lBox_9Grid_a + __offset_cache_x, __lBox_9Grid_b + __box_tempDB + __offset_cache_y, __box_tempDA / __lBox_9Grid_w, 1,  0, 0,     0, -1)
    Bitmap(__box_tempIE + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + 1 + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + 2 + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    Bitmap(__box_tempIE + 3 + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
    __box_tempIE = __box_tempIE + 4

    ' 九宫格 - 中
    Call BMPCreate(__box_tempIE + __lBox_bmpIdStart, __lBox_9Grid_cache_npcId, 0, 1,     __lBox_9Grid_a, __lBox_9Grid_b, __lBox_9Grid_w, __lBox_9Grid_h,     __lBox_9Grid_a + __offset_cache_x, __lBox_9Grid_b + __offset_cache_y, __box_tempDA / __lBox_9Grid_w, __box_tempDB / __lBox_9Grid_h,     0, 0,     0, -1)
    Bitmap(__box_tempIE + __lBox_bmpIdStart).zpos = __zpos_cache + 0.00001
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

' 设置气泡九宫格
' @param npcId npc id
' @param srcX srcX
' @param srcY srcY
Export Script TextboxLite_Store9Grid(npcId As Long, srcX As Integer, srcY As Integer)
    __lBox_9Grid_cache_npcId = npcId
    __lBox_9Grid_cache_x = srcX
    __lBox_9Grid_cache_y = srcY
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

Do
    ' 更新时间戳
    __timestamp += 1
    If __timestamp >= 2147483647 or __timestamp < 0 Then
        __timestamp = 0
    End If
    If __bubbleAllocateQueue_s = "" Then
        GoTo Flag_EndLoop
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

Flag_EndLoop:
    Call Sleep(1)
Loop
