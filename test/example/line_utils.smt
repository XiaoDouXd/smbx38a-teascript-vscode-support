' 该脚本用于画线
' 在使用该脚本前请先在全局变量中申请:
'   libLineList
' 数组用于保存线的数据结构
'                                            -- 小豆 20230131

' ==================================================================== 预设值

Dim bitmapStartIdx As Long = 80000       ' bitmap 起始 id (注意不要使该库的 bitmap 和其它管理器的重复)
Dim maxVertCount As Long = 256           ' 最大顶点数 (在初始化画线库时会预先申请与顶点数相同数量的 bitmap, 请注意性能问题)
Dim maxLineCount As Long = 16            ' 最大线数
Dim lineVDataSize As Long = 12           ' 线视图占用几个 Double [npcId, step, alpha, color, width, srcWidth, len, zpos, loss, lossOffset, lossInfMul, lossInfMin]

' 线条的数据保存在 libLineList 库中, 具体结构在下文 reset 函数中有详细注释
' 线条的 bitmap 下标从 bitmapStartIdx 开始, 到 bitmapStartIdx + maxVertCount - 1 结束
' bitmap 的 hide 字段用于标识是否被引用, 若被引用则为 1, 否则为 0
' 线条到 bitmap 的保有关系同样存在 libLineList 中

' 由于一个线条的 bitmap 实际数量为其顶点数量减一, 多出来的一个数据位用于保存脏数据的 flag
' flag > 0.5 时为脏数据 flag < 0.5 时为 none

' 为了减少浮点数精度带来的问题 在下面代码中所有取数组 idx 处都加了 0.5
' 并回避直接使用 "=" 判断两数相等, 而是使用 abs(a - b) < 0.00000000001

' ==================================================================== 一些临时寄存变量

Dim tempVal As Double = 0
Dim tempVal2 As Double = 0
Dim tempVal3 As Double = 0

Dim stdIdx As Long = 0
Dim stdIdx2 As Long = 0
Dim tempInt As Long = 0
Dim tempInt2 As Long = 0
Dim tempInt3 As Long = 0

Dim disA As Double
Dim disB As Double

Dim p1x As Double
Dim p1y As Double
Dim p2x As Double
Dim p2y As Double

Dim v1x As Double
Dim v1y As Double
Dim nor1 As Double

' Bitmap 参数寄存变量 用于保存 p_libLine_calcLineFactor 计算结果
Dim b_posX As Double
Dim b_posY As Double
Dim b_scaleX As Double
Dim b_scaleY As Double
Dim b_srcW As Double
Dim b_srcH As Double
Dim b_srcOffsetX As Double
Dim b_color As Double
Dim b_alpha As Double
Dim b_zpos As Double
Dim b_npc As Double
Dim b_angle As Double
Dim b_hide As Byte

' ==================================================================== 数据结构定义和初始化

' ---------- 线视图字段 - id 映射 Start
    Dim f_npcId As Long = 0          ' npcId
    Dim f_step As Long = 1           ' 采样增量步长
    Dim f_alpha As Long = 2          ' 总透明度 (当应用衰减时值为负数)
    Dim f_color As Long = 3          ' 总前景色
    Dim f_width As Long = 4          ' 总线宽 (同时也是素材宽) (当应用衰减时值为负数)
    Dim f_srcWidth As Long = 5       ' 总素材长
    Dim f_len As Long = 6            ' 片段长缩放比 (当应用衰减时值为负数)
    Dim f_zpos As Long = 7           ' zpos
    Dim f_loss As Long = 8           ' 衰减参数
    Dim f_lossOffset As Long = 9     ' 衰减偏移
    Dim f_lossInfMul As Long = 10    ' 衰减影响乘数
    Dim f_lossInfMin As Long = 11    ' 衰减影响减数
' ---------- 线视图字段 - id 映射 End

Dim bmpStartIdx As Long = maxVertCount * 2                           ' bitmap 列表起始索引
Dim lineStartIdx As Long = maxVertCount * 3                          ' 线列表起始索引
Dim linePCountStartIdx As Long = lineStartIdx + maxLineCount         ' 线顶点数列表起始索引
Dim lineVDataStartIdx As Long = linePCountStartIdx + maxLineCount    ' 线视图列表起始索引

Dim inited As Byte = 0                   ' 是否已初始化
Dim vertWritePtr As Long = 0             ' 顶点列表第一个空项的索引
Dim lineWritePtr As Long = 0             ' 线列表上一次分配时的写指针
Dim curVertCount As Long = 0             ' 当前顶点数
Dim curLineCount As Long = 0             ' 当前线数

Dim bmpGetterPtr As Long = 0             ' bitmap 列表写指针
Dim freeBmpCount As Long = maxVertCount  ' 空闲 bitmap 数量
Dim dirtyCount As Long = 0               ' 脏线条数量

' 销毁画线库
Export Script libLine_destoryLibLine(Return Long)
    If inited = 0 Then
        Return -1
    End If

    Call ReDim(0, libLineList, 0)

    ' 初始化状态数据
    vertWritePtr = 0
    lineWritePtr = 0
    curVertCount = 0
    curLineCount = 0
    bmpGetterPtr = 0
    freeBmpCount = maxVertCount
    dirtyCount = 0

    ' 销毁 bitmap
    For stdIdx = bitmapStartIdx To bitmapStartIdx + maxVertCount - 1
        call BErase(2, stdIdx)
    Next

    ' 置状态为未初始化
    inited = 0

    Return 0
End Script

' 重设或初始化画线库
Export Script libLine_resetLibLine()
    If inited <> 0 Then
        Call libLine_destoryLibLine()
    End If

    ' libLineList 列表数据结构如下:
    ' [0 ...                     maxVertCount*3][lineStartIdx     ...][linePCountStartIdx         ...][lineVDataStartIdx                ...]
    ' |←            maxVertCount*3            →||←   maxLineCount   →||←        maxLineCount        →||←    maxLineCount*lineVDataSize    →|
    ' | verts [x1x2..., y1y2..., bmp1,bmp2...] ||     lines (p0)     ||        lines (pCount)        ||            lineViewDatas           |
    Call ReDim(0, libLineList, lineStartIdx + maxLineCount * 2 + maxLineCount * lineVDataSize)

    ' 初始化所有线为空
    For stdIdx = lineStartIdx to lineStartIdx + maxLineCount - 1
        If stdIdx > 0 Then
            Array(libLineList(stdIdx)) = maxVertCount + 1
        End If
    Next

    ' 申请 bitmap
    For stdIdx = bitmapStartIdx To bitmapStartIdx + maxVertCount - 1
        Call BMPCreate(stdIdx, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, -1)
    Next

    ' 初始化结束
    inited = -1
End Script
Call libLine_resetLibLine()

' ==================================================================== 存取整理方法

' 设置线的标签字段
' 使用了 tempVal
' @param lineId 线 id
' @param value 要设置的值
Script p_libLine_setFlag(lineId As Long, value As Double)
    tempVal = Array(libLineList(Array(libLineList(lineId + lineStartIdx)) + bmpStartIdx))
    Array(libLineList(Array(libLineList(lineId + lineStartIdx)) + bmpStartIdx)) = value

    If tempVal < 0.5 And value > 0.5 Then
        dirtyCount += 1
    End If
End Script

' 获取线的标签字段 (1-脏数据 0-非脏数据)
' @param lineId 线 id
' @return 线的标签字段值
Script p_libLine_getFlag(lineId As Long, Return Double)
    Return Array(libLineList(Array(libLineList(lineId + lineStartIdx)) + bmpStartIdx))
End Script

' 交换顶点
' 使用了 tempVal
' @param a 顶点 id
' @param b 顶点 id
Script p_libLine_swapPoint(a As Long, b As Long)
    tempVal = Array(libLineList(b))
    Array(libLineList(b)) = Array(libLineList(a))
    Array(libLineList(a)) = tempVal

    tempVal = Array(libLineList(b + maxVertCount))
    Array(libLineList(b + maxVertCount)) = Array(libLineList(a + maxVertCount))
    Array(libLineList(a + maxVertCount)) = tempVal

    tempVal = Array(libLineList(b + bmpStartIdx))
    Array(libLineList(b + bmpStartIdx)) = Array(libLineList(a + bmpStartIdx))
    Array(libLineList(a + bmpStartIdx)) = tempVal
End Script

' 交换顶点 不交换 bitmap
' 使用了 tempVal
' @param a 顶点 id
' @param b 顶点 id
Script p_libLine_swapPointWithoutBmp(a As Long, b As Long)
    tempVal = Array(libLineList(b))
    Array(libLineList(b)) = Array(libLineList(a))
    Array(libLineList(a)) = tempVal

    tempVal = Array(libLineList(b + maxVertCount))
    Array(libLineList(b + maxVertCount)) = Array(libLineList(a + maxVertCount))
    Array(libLineList(a + maxVertCount)) = tempVal
End Script

' 设置线条数据
Script p_libLine_setLineData(lineId As Long, fieldId As Long, value As Double)
    Array(libLineList(lineId * lineVDataSize + lineVDataStartIdx + fieldId)) = value
End Script

' ==================================================================== bmp 操作

' 申请一条 bitmap
' @return bitmap id or -1
Script p_libLine_allocateBmp(Return Long)
    If inited = 0 Or freeBmpCount <= 0 Then
        Return -1
    End If

    stdIdx = bmpGetterPtr
    Do
        If stdIdx >= maxVertCount Then
            stdIdx = 0
        End If

        If Bitmap(stdIdx + bitmapStartIdx).hide = 1 Then
            freeBmpCount -= 1
            bmpGetterPtr = stdIdx
            Bitmap(stdIdx + bitmapStartIdx).hide = 0
            Return stdIdx + bitmapStartIdx
        End If
        stdIdx += 1
    Loop
End Script

' 释放 bitmap
' @param id bitmap id
' @return bitmap 1 or -1
Script p_libLine_releaseBmp(id As Long, Return Long)
    If inited = 0 Or id < bitmapStartIdx Or id >= bitmapStartIdx + maxVertCount Then
        Return -1
    End If

    Bitmap(id).hide = 1
    bmpGetterPtr = id - bitmapStartIdx
    freeBmpCount += 1
    Return 1
End Script

' ==================================================================== 外部接口

' ----------------------------------- 申请

' 申请一条线
' @param vertCount 顶点数
' @return 线 id, 返回值小于零时申请失败
Export Script libLine_allocateLine(vertCount As Long, Return Long)
    If inited = 0 Then
        Return -1
    End If
    If vertCount + curVertCount > maxVertCount Or vertCount <= 1 Or curLineCount = maxLineCount Then
        Return -1
    End If

    Dim newIdx As Long = -1
    If lineWritePtr >= maxLineCount Then
        lineWritePtr = 0
    End If

    Dim startPtr As Long = lineWritePtr
    Do
        If Array(libLineList(lineStartIdx + lineWritePtr)) >= maxVertCount Then
            newIdx = lineWritePtr
            Exit Do
        End If

        lineWritePtr += 1
        If lineWritePtr >= maxLineCount Then
            lineWritePtr = 0
        End If
        If lineWritePtr = startPtr Then
            Return -1
        End If
    Loop

    Array(libLineList(lineStartIdx + newIdx)) = vertWritePtr
    Array(libLineList(linePCountStartIdx + newIdx)) = vertCount

    ' 初始化视图数据区
    For stdIdx = lineVDataStartIdx + newIdx * lineVDataSize To lineVDataStartIdx + newIdx * lineVDataSize + lineVDataSize - 1
        Array(libLineList(stdIdx)) = 0
    Next
    Array(libLineList(lineVDataStartIdx + newIdx * lineVDataSize + f_len)) = 1
    Array(libLineList(lineVDataStartIdx + newIdx * lineVDataSize + f_color)) = -1
    Array(libLineList(lineVDataStartIdx + newIdx * lineVDataSize + f_alpha)) = 255
    Array(libLineList(lineVDataStartIdx + newIdx * lineVDataSize + f_zpos)) = 0.5
    ' 初始化 bitmap
    For stdIdx = maxVertCount * 2 + vertWritePtr To maxVertCount * 2 + vertWritePtr + vertCount - 1
        Array(libLineList(stdIdx)) = -1
    Next

    vertWritePtr += vertCount
    curVertCount += vertCount
    curLineCount += 1
    Return newIdx
End Script

' 释放一条线
' 使用了 tempInt tempInt2
' @param lineId 线 id
Export Script libLine_releaseLine(lineId As Long, Return Long)
    If inited = 0 Then
        Return 0
    End If
    If lineId >= maxLineCount Then
        Return 0
    End If
    If Array(libLineList(lineStartIdx + lineId)) >= maxVertCount Then
        Return 0
    End If
    tempInt = Array(libLineList(lineStartIdx + lineId))          ' 顶点起始索引
    tempInt2 = Array(libLineList(linePCountStartIdx + lineId))   ' 顶点数

    ' 清空自己的 bitmap 使用记录
    For stdIdx = tempInt + bmpStartIdx To bmpStartIdx + tempInt + tempInt2 - 1
        Call p_libLine_releaseBmp(Array(libLineList(stdIdx)))
    Next

    ' 从顶点列表中删除顶点
    For stdIdx = tempInt To vertWritePtr - tempInt2 - 1
        Call p_libLine_swapPoint(stdIdx, stdIdx + tempInt2)
    Next
    For stdIdx = 0 To maxLineCount - 1
        If Array(libLineList(lineStartIdx + stdIdx)) > tempInt Then
            Array(libLineList(lineStartIdx + stdIdx)) = Array(libLineList(lineStartIdx + stdIdx)) - tempInt2
        End If
    Next
    vertWritePtr -= tempInt2

    ' 清空数据
    For stdIdx = 0 To lineVDataSize - 1
        Array(libLineList(lineVDataStartIdx + lineVDataSize * lineId + stdIdx)) = 0
    Next
    Array(libLineList(lineStartIdx + lineId)) = maxVertCount + 1
    curLineCount -= 1
    curVertCount -= tempInt2

    Return -1
End Script

' ----------------------------------- 参数设置

' 设置 alpha 值 value 范围是 [-1, 1]
' 使用了 disA
' 当 value < 0 时表示收到 loss 的影响
' @return 1-设置成功 0-设置失败
Export Script libLine_setAlpha(lineId As Long, value As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If
    If value > 255 Then
        disA = 255
    ElseIf value < -255 Then
        disA = -255
    Else
        disA = value
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Call p_libLine_setLineData(lineId, f_alpha, disA)
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' 设置 npc 值
' @return 1-设置成功 0-设置失败
Export Script libLine_setNpc(lineId As Long, value As Long, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Call p_libLine_setLineData(lineId, f_npcId, value)
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' 设置 step 值
' @return 1-设置成功 0-设置失败
Export Script libLine_setStep(lineId As Long, value As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Call p_libLine_setLineData(lineId, f_step, value)
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' 设置 color 值
' @return 1-设置成功 0-设置失败
Export Script libLine_setColor(lineId As Long, value As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Call p_libLine_setLineData(lineId, f_color, value)
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' 设置 width 值
' @return 1-设置成功 0-设置失败
Export Script libLine_setWidth(lineId As Long, value As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Call p_libLine_setLineData(lineId, f_width, value)
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' 设置 srcWidth 值
' @return 1-设置成功 0-设置失败
Export Script libLine_setSrcWidth(lineId As Long, value As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Call p_libLine_setLineData(lineId, f_srcWidth, value)
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' 设置 segmentScale 值
' @return 1-设置成功 0-设置失败
Export Script libLine_setSegmentScale(lineId As Long, value As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Call p_libLine_setLineData(lineId, f_len, value)
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' 设置 zpos 值
' @return 1-设置成功 0-设置失败
Export Script libLine_setZpos(lineId As Long, value As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Call p_libLine_setLineData(lineId, f_zpos, value)
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' 设置 loss 值
' @return 1-设置成功 0-设置失败
Export Script libLine_setLoss(lineId As Long, value As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Call p_libLine_setLineData(lineId, f_loss, value)
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' 设置 lossOffset 值
' @return 1-设置成功 0-设置失败
Export Script libLine_setLossOffset(lineId As Long, value As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Call p_libLine_setLineData(lineId, f_lossOffset, value)
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' 设置 lossInfoMul 值
' @return 1-设置成功 0-设置失败
Export Script libLine_setLossInfMul(lineId As Long, value As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Call p_libLine_setLineData(lineId, f_lossInfMul, value)
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' 设置 lossInfoMul 值
' @return 1-设置成功 0-设置失败
Export Script libLine_setLossInfMin(lineId As Long, value As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Call p_libLine_setLineData(lineId, f_lossInfMin, value)
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' ----------------------------------- 顶点设置

' 设置顶点
' @param lineId 线 id
' @param pId 顶点 id
' @param pX 顶点 x 值
' @param pY 顶点 y 值
' @return 1-设置成功 0-设置失败
Export Script libLine_setPoint(lineId As Long, pId As Long, pX As Double, pY As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Or Array(libLineList(lineId + linePCountStartIdx)) - pId <= 0.00000000001 Then
        Return 0
    End If

    Array(libLineList(Array(libLineList(lineId + lineStartIdx)) + pId)) = pX
    Array(libLineList(Array(libLineList(lineId + lineStartIdx)) + maxVertCount + pId)) = pY
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' 入队顶点(第一个顶点出队并将剩余的顶点前移)
' 使用了 tempInt tempInt2
' @param lineId 线 id
' @param pX 顶点 x 值
' @param pY 顶点 y 值
' @return 1-设置成功 0-设置失败
Export Script libLine_pushPoint(lineId As Long, pX As Double, pY As Double, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    tempInt = Array(libLineList(lineId + lineStartIdx))
    tempInt2 = Array(libLineList(lineId + linePCountStartIdx))
    For stdIdx = 0 To tempInt2 - 2
        Call p_libLine_swapPointWithoutBmp(tempInt + stdIdx, tempInt + stdIdx + 1)
    Next
    Array(libLineList(tempInt + tempInt2 - 1)) = pX
    Array(libLineList(tempInt + tempInt2 + maxVertCount - 1)) = pY
    Call p_libLine_setFlag(lineId, 1)
    Return 1
End Script

' ----------------------------------- 参数获取

' 获取线条顶点数量
' @param lineId 线条 id
' @return vertCount
Export Script libLine_getLineVertCount(lineId As Long, Return Long)
    If inited = 0 Or lineId < 0 Or lineId >= maxLineCount Then
        Return 0
    End If

    If Array(libLineList(lineId + lineStartIdx)) >= maxVertCount Then
        Return 0
    End If

    Return Array(libLineList(lineId + linePCountStartIdx))
End Script

' ==================================================================== 一些数学计算函数

' 向量的点积
Script p_libLine_calcDot(vA_x As Double, vA_y As Double, vB_x As Double, vB_y As Double, Return Double)
    Return vA_x * vB_x + vA_y * vB_y
End Script

' 向量的叉积
Script p_libLine_calcCross(vA_x As Double, vA_y As Double, vB_x As Double, vB_y As Double, Return Double)
    Return vA_x * vB_y - vB_x * vA_y
End Script

' 计算两向量的逆时针夹角
' 使用了 disA disB
Script p_libLine_calcAngle(vA_x As Double, vA_y As Double, vB_x As Double, vB_y As Double, Return Double)
    disA = p_libLine_calcDot(vA_x, vA_y, vB_x, vB_y)
    disB = p_libLine_calcCross(vA_x, vA_y, vB_x, vB_y)
    If 0.0000000000000001 > Abs(disA) Then
        If 0 < disB Then
            Return Pi / 2
        Else
            Return -Pi / 2
        End If
    End If
    Return Atn(disB / disA)
End Script

' 向量的模
Script p_libLine_calcNorm(v_x As Double, v_y As Double, Return Double)
    Return Sqr(v_x * v_x + v_y * v_y)
End Script

' 计算衰减参数
' 使用了 tempVal tempVal2 tempVal3
' @param lineId 线 id
' @param segmentId 片段 id [1, vertCount - 1]
' @return 衰减参数 [0, 1]
Script p_libLine_calcLoss(lineId As Long, segmentId As Long, Return Double)
    tempVal = Array(libLineList(lineId + linePCountStartIdx)) - 1                               ' segmentCount
    If tempVal <= 1 Then
        tempVal = 0                                                                             ' x factor
    Else
        tempVal = (segmentId - 1 / tempVal - 1) - 0.5 * 2                                       ' x factor
    End If
    tempVal2 = Array(libLineList(lineId * lineVDataSize + lineVDataStartIdx + f_loss))          ' loss factor
    tempVal3 = Array(libLineList(lineId * lineVDataSize + lineVDataStartIdx + f_lossOffset))    ' lossOffset factor
    tempVal = abs(tempVal - tempVal3)

    If tempVal2 = 0 Then
        Return 0
    ElseIf tempVal2 > 0 Then
        If tempVal2 < 1 Then
            If tempVal <= 1 - tempVal2 Then
                Return 0
            Else
                Return 1 - cos(Pi * (tempVal + 1)) * 0.5 - 0.5
            End If
        Else
            If tempVal < (tempVal2 - 1) Then
                Return 0
            Else
                Return 1
            End If
        End
    ElseIf tempVal2 < 0 Then
        If tempVal <= 1 + tempVal2 Then
            If tempVal <= 1 - tempVal2 Then
                Return 1
            Else
                Return cos(Pi * (tempVal + 1)) * 0.5 + 0.5
            End If
        Else
            If tempVal < (tempVal2 - 1) Then
                Return 1
            Else
                Return 0
            End If
        End If
    End If
    Return 0
End Script

' 应用衰减到参数
' 使用了 tempVal
' @param lineId 线 id
' @param value 目标参数值
' @param loss 衰减值
' @return 计算结果 [0, ∞)
Script p_libLine_calcApplyLoss(lineId As Long, value As Double, loss As Double, Return Double)
    If value >= 0 Then
        Return value
    End If

    value = abs(value)
    tempVal = value * (1 - loss * abs(Array(libLineList(lineVDataStartIdx + (lineId * lineVDataSize) + f_lossInfMul)))) - ((loss * abs(Array(libLineList(lineVDataStartIdx + (lineId * lineVDataSize) + f_lossInfMin)))))
    If tempVal <= 0 Then
        Return 0
    Else
        Return tempVal
    End If
End Script

' 计算线段 bitmap 的各个参数 并存到对应全局变量(类似于寄存器的用法)中
' 使用了 tempVal tempVal2 tempVal3 disA disB
' @param lineId 线 id
' @param segmentId 线段 id [1, vertCount - 1]
Script p_libLine_calcLineFactor(lineId As Long, segmentId As Long)
    ' 变换中心点为 bitmap 左上角点

    p1x = Array(libLineList(Array(libLineList(lineId + lineStartIdx)) + segmentId - 1))
    p1y = Array(libLineList(Array(libLineList(lineId + lineStartIdx)) + segmentId + maxVertCount - 1))
    p2x = Array(libLineList(Array(libLineList(lineId + lineStartIdx)) + segmentId))
    p2y = Array(libLineList(Array(libLineList(lineId + lineStartIdx)) + segmentId + maxVertCount))

    v1x = p2x - p1x
    v1y = p2y - p1y

    If p1x = 0 And p1y = 0 Then
        b_hide = 1
    Else
        b_hide = 0
    End If

    ' ------------------------------ 角度
    If v1x > 0 Then
        b_angle = p_libLine_calcAngle(v1x, v1y, 1, 0)
    Else
        b_angle = p_libLine_calcAngle(v1x, v1y, 1, 0) + Pi
    End If

    nor1 = p_libLine_calcNorm(v1x, v1y)
    tempVal2 = p_libLine_calcLoss(lineId, segmentId)                                                                                  ' loss factor
    tempVal = p_libLine_calcApplyLoss(lineId, Array(libLineList(lineVDataStartIdx + (lineId * lineVDataSize) + f_width)), tempVal2)   ' 加参线宽

    ' ----------------------------- 偏移计算
    If 0.0000000000000001 > Abs(nor1) Then
        b_posX = p1x
        b_posY = p1y
    Else
        b_posX = p1x + v1y * (tempVal / 2) / nor1
        b_posY = p1y - v1x * (tempVal / 2) / nor1
    End If
    ' ----------------------------- 素材高
    b_srcH = Array(libLineList(lineVDataStartIdx + (lineId * lineVDataSize) + f_width))
    ' ------------------------------ 素材长
    b_srcW = Array(libLineList(lineVDataStartIdx + (lineId * lineVDataSize) + f_srcWidth))
    ' ------------------------------ 片段宽放缩比
    If abs(b_srcH) < 0.00000000001 Then
        b_scaleY = 0
    Else
        b_scaleY = tempVal / Array(libLineList(lineVDataStartIdx + (lineId * lineVDataSize) + f_width))
    End If
    ' ------------------------------ 片段长放缩比
    If abs(b_srcW) < 0.00000000001 Then
        b_scaleX = 0
    Else
        b_scaleX = p_libLine_calcApplyLoss(lineId, Array(libLineList(lineVDataStartIdx + (lineId * lineVDataSize) + f_len)), tempVal2) * (nor1 / b_srcW)
    End If
    ' ------------------------------ 素材原点 x 方向偏移量
    b_srcOffsetX = Array(libLineList(lineVDataStartIdx + (lineId * lineVDataSize) + f_step)) * (segmentId - 1)
    ' ------------------------------ 透明度
    b_alpha = p_libLine_calcApplyLoss(lineId, Array(libLineList(lineVDataStartIdx + (lineId * lineVDataSize) + f_alpha)), tempVal2)
    ' ------------------------------ 颜色
    b_color = Array(libLineList(lineVDataStartIdx + (lineId * lineVDataSize) + f_color))
    ' ------------------------------ zpos
    b_zpos = Array(libLineList(lineVDataStartIdx + (lineId * lineVDataSize) + f_zpos))
    ' ------------------------------ npc
    b_npc = Array(libLineList(lineVDataStartIdx + (lineId * lineVDataSize) + f_npcId))
End Script

' ==================================================================== 线条更新

' 更新线条
' 使用了 tempInt3
Script p_libLine_updateLibLine_line(lineId As Long, Return Long)
    For stdIdx2 = 1 To int(Array(libLineList(lineId + linePCountStartIdx))) - 1
        If Array(libLineList(Array(libLineList(lineId + lineStartIdx)) + bmpStartIdx + stdIdx2)) < 0.5 Then
            tempInt3 = p_libLine_allocateBmp()
            Array(libLineList(Array(libLineList(lineId + lineStartIdx)) + bmpStartIdx + stdIdx2)) = tempInt3
        End If

        tempInt3 = Array(libLineList(Array(libLineList(lineId + lineStartIdx)) + bmpStartIdx + stdIdx2)) ' bitmap id
        If tempInt3 < 0.5 Then
            Call p_libLine_setFlag(lineId, 0)
            Return -1
        End If
        Call p_libLine_calcLineFactor(lineId, stdIdx2)

        ' 设置 bitmap
        Bitmap(tempInt3).destx = b_posX
        Bitmap(tempInt3).desty = b_posY
        Bitmap(tempInt3).scrwidth = b_srcW
        Bitmap(tempInt3).scrheight = b_srcH
        Bitmap(tempInt3).scrx = b_srcOffsetX
        Bitmap(tempInt3).scrid = b_npc
        Bitmap(tempInt3).scalex = b_scaleX
        Bitmap(tempInt3).scaley = b_scaleY
        Bitmap(tempInt3).rotatang = b_angle
        Bitmap(tempInt3).color = b_color
        Bitmap(tempInt3).zpos = b_zpos
        Bitmap(tempInt3).forecolor_a = b_alpha

        If b_hide = 1 Then
            Bitmap(tempInt3).forecolor_a = 0
        End If
    Next
    Call p_libLine_setFlag(lineId, 0)
    Return 0
End Script

' 更新画线函数库
Script p_libLine_updatelibLine(Return Long)
    ' 未初始化或没有脏线条
    If inited = 0 Or dirtyCount = 0 Then
        Return -1
    End If

    For stdIdx = 0 To maxLineCount - 1
        If dirtyCount = 0 Then
            Return 1
        End If

        If Array(libLineList(stdIdx + lineStartIdx)) < maxVertCount And p_libLine_getFlag(stdIdx) > 0.5 Then
            Call p_libLine_updateLibLine_line(stdIdx)
            dirtyCount -= 1
        End If
    Next
End Script

Do
    Call p_libLine_updatelibLine()
    Call Sleep(1)
Loop