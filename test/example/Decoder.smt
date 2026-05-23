' -----------------------------------------------------------------------
' -----------------------------------------------------------------------
' -----------------------------------------------------------------------
' --------------------------------- 图集文本绘制 - xiaodou 20250524 v2.0.0
' -----------------------------------------------------------------------

' region dim var
    Dim __s As String = ""
    Dim __len As Long = 0
    Dim __lenSrc As Long = 0
    Dim __seek As Long = 0

    Dim __cacheLo As Long = 0
    Dim __cacheHi As Long = 0

    Dim __txt_tempI As Long = 0
    Dim __txt_tempJ As Long = 0

    Dim __txt_tempK As Long = 0
    Dim __txt_tempL As Long = 0
    Dim __txt_tempM As Long = 0
    Dim __txt_tempN As Long = 0
    Dim __txt_tempO As Long = 0
    Dim __txt_tempSI As String = ""
' endregion

' 内部函数 - 用于将装载的高低位字符转换成 id
Script TXT_Inner_CharToId(Return Long)
    If __cacheLo > 96 Then
        __cacheLo -= 1
    End If
    If __cacheLo > 92 Then
        __cacheLo -= 1
    End If
    If __cacheLo > 34 Then
        __cacheLo -= 1
    End If

    If __cacheHi > 96 Then
        __cacheHi -= 1
    End If
    If __cacheHi > 92 Then
        __cacheHi -= 1
    End If
    If __cacheHi > 34 Then
        __cacheHi -= 1
    End If
    Return (__cacheLo - 32) + (__cacheHi - 32) * 92
End Script

' 解码 AscBin 串
' 原始字符串格式为 [len:2char][text:n*2char][e ][flag:m-char], 使用类 base92 编码
' @param 类 base91 编码字符串
' @return utf16 Text 字符串
Export Script D(ss As String, Return String)
    __txt_tempN = Len(ss) ' 原始长度
    If __txt_tempN < 4 Then
        Return ""
    End If

    __txt_tempI = 1
    __txt_tempSI = "" ' content
    __txt_tempJ = 0 ' isCalcCodeSize
    __txt_tempK = 1 ' curCodeSize
    Do While __txt_tempI <= __txt_tempN
        If Asc(Mid(ss, __txt_tempI, 1)) = 96 Then
            If __txt_tempJ = 0 Then
                __txt_tempK = 0
            End If
            __txt_tempK += 1
            __txt_tempJ = 1
            __txt_tempI += 1
            Continue
        End If
        __txt_tempJ = 0

        If __txt_tempK + __txt_tempI - 1 > __txt_tempN Then
            Exit Do
        End If
        __cacheLo = Asc(Mid(ss, __txt_tempI, 1))
        If __txt_tempK > 1 Then
            __cacheHi = Asc(Mid(ss, __txt_tempI + 1, 1))
        Else
            __cacheHi = 32
        End If

        __txt_tempL = TXT_Inner_CharToId()
        If __txt_tempL < 92 Then
            __txt_tempL += 32
            If __txt_tempL >= 34 Then
                __txt_tempL += 1
            End If
            If __txt_tempL >= 92 Then
                __txt_tempL += 1
            End If
            If __txt_tempL >= 96 Then
                __txt_tempL += 1
            End If
            __txt_tempSI = __txt_tempSI & Chr(__txt_tempL)
        Else
            __txt_tempSI = __txt_tempSI & ChrW(__txt_tempL - 92)
        End If
        __txt_tempI += __txt_tempK
    Loop
    Return __txt_tempSI & ""
End Script

' 将 utf16 Text 字符串转换成 id 串
' 原始字符串格式为 [len:1char][text:n*1char][flag:m-char]
' @param 类 utf16 Text 编码字符串
' @return utf16 id 串
Export Script TXT(ss As String, Return String)
    __txt_tempN = Len(ss) ' 原始长度
    If __txt_tempN < 4 Then
        Return ""
    End If
    __txt_tempSI = ""
    __txt_tempK = AscW(Mid(ss, 1, 1)) - 129 ' 字符串长度

    ' 写入正文
    __txt_tempJ = 0 ' 字符码
    __txt_tempM = 0 ' flag 计数
    __txt_tempL = 2
    Do While __txt_tempL - 1 <= __txt_tempK
        ' 更新字符码
        __txt_tempJ = AscW(Mid(ss, __txt_tempL, 1))
        If __txt_tempJ = 0 Then ' 如果下一个字符是 flag 首位
            If __txt_tempL < __txt_tempK Then ' 如果当前字符是 flag
                __txt_tempJ = AscW(Mid(ss, __txt_tempL + 1, 1)) + 10000 - 128
                __txt_tempM += 1
                __txt_tempSI = __txt_tempSI & ChrW(__txt_tempJ)
            End If
            __txt_tempL += 2
            Continue
        End If
        __txt_tempSI = __txt_tempSI & ChrW(__txt_tempJ)
        __txt_tempL += 1
    Loop

    ' 写入 flag
    If __txt_tempM > 0 Then
        ' 第一位写入长度
        Return ChrW(__txt_tempK - __txt_tempM) & __txt_tempSI & Mid(ss, __txt_tempK + 2, __txt_tempN - __txt_tempK) & chrw(-1)
    Else
        ' 第一位写入长度
        Return ChrW(__txt_tempK - __txt_tempM) & __txt_tempSI & chrw(-1)
    End If
End Script

' 加载 id 串
' 该函数负责加载字符串并预先解析计算字符串包含的信息
' @param ss 要加载的字符串 (utf16 id 串)
' @return 当前要加载的字符串
Export Script TXT_LoadStr(ss As String)
    __s = ss
    __lenSrc = len(ss)
    If AscW(Mid(ss, __lenSrc, 1)) <> -1 Then
        __s = ""
        __lenSrc = 0
        __len = 0
    Else
        __len = AscW(Mid(__s, 1, 1))
    End If
    __seek = 1
End Script

' 字符串长度
' @return 字符串长度
Export Script TXT_GetLen(Return Long)
    Return __len
End Script

' 获得探针
' @return 当前探针位置
Export Script TXT_GetSeek(Return Long)
    Return __seek
End Script

' 设置探针
' @param seek 要将探针设置到的目标
Export Script TXT_SetSeek(seek As Long)
    If seek < 1 Then
        __seek = 1
    ElseIf seek >= __len Then
        __seek = __len
    End If
End Script

' 下一个字符
' @return 下一个字符 code, 若已经到字符串尾则返回 -1
Export Script TXT_GetNext(Return Long)
    If __seek > __len Or __seek < 1 Then
        Return -1
    End If
    __seek += 1
    Return AscW(Mid(__s, __seek, 1))
End Script

' 获得字符 id
' @param i 为字符索引
' @return 字符 code
Export Script TXT_GetId(i As Long, Return Long)
    If i > __len Or i < 1 Then
        Return -1
    End If
    Return AscW(Mid(__s, i + 1, 1))
End Script

' 判断是否是 flag 字符
' @param id 字符 code
' @return 为普通字符时返回 0, 为控制字符时返回 1
Export Script TXT_IsFlag(id As Long, Return Integer)
    If id < 10000 Then
        Return 0
    Else
        Return 1
    End If
End Script

' 获得 Flag 字串
' @param id 字符 code
' @return 返回 flag 记录的字串, 如果当前 code 不是控制字符则返回 ""
Export Script TXT_GetFlag(id As Long, Return String)
    If id < 10000 Then
        Return ""
    End If

    id = id - 10000 + 1 + __len
    If id <= 0 Then
        Return ""
    End If

    __txt_tempJ = AscW(Mid(__s, id + 1, 1)) - 40
    If __txt_tempJ <= 0 Or __txt_tempJ + id + 2 > __lenSrc Then
        Return ""
    End If

    Return Mid(__s, id + 2, __txt_tempJ)
End Script

' 根据 id 获得目标 x 坐标
' @param id 字符 code
' @return 返回该字符在字符贴图集中的 x 坐标
Export Script TXT_GetDestX(id As Long, Return Long)
    Return (id Mod 93) * 22
End Script

' 根据 id 获得目标 y 坐标
' @param id 字符 code
' @return 返回该字符在字符贴图集中的 y 坐标
Export Script TXT_GetDestY(id As Long, Return Long)
    Return (id \ 93) * 22
End Script

' 获取字符尺寸
' @return 字符尺寸
Export Script TXT_GetCharSize(id As Long, Return Long)
    If id = 106 Then Return 6
    If id = 116 Then Return 9
    If id < 128 And id >= 0 Then Return 22 / 2
    Return 22
End Script

' 获取贴图集中一行拥有的字符数
' @return 贴图集中一行拥有的字符数
Export Script TXT_GetCntX(Return Long)
    Return 93
End Script

' 获取字符的偏移量
Export Script TXT_GetOffsetY(id As Long, Return Integer)
    If id = 103 Then Return 3
    If id = 113 Then Return 6
    If id = 112 Then Return 6
    If id = 106 Then Return 4
    Return 0
End Script
