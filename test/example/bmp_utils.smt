' ===================================================
' ================================ bitmap 工具类 v0.1
' ================================== xiaodou 20240101
' ===================================================

' ===================================== 临时变量

' ------------------------ bitmap 定义变量
Dim libbmp_isUseScreenCoord As Byte = 0

Dim libbmp_sw As Long       = 1
Dim libbmp_sh As Long       = 1
Dim libbmp_sx As Long       = 0
Dim libbmp_sy As Long       = 0
Dim libbmp_srcId As Long    = 1

Dim libbmp_destX As Long    = 0
Dim libbmp_destY As Long    = 0

Dim libbmp_scaleW As Double  = 1
Dim libbmp_scaleH As Double  = 1

Dim libbmp_anchorX As Double = 0
Dim libbmp_anchorY As Double = 0

Dim libbmp_animW As Long = 0
Dim libbmp_animH As Long = 0
Dim libbmp_animStartX As Long = 0
Dim libbmp_animStartY As Long = 0

Dim libbmp_animCnt As Long = 1
Dim libbmp_animCeilX As Long = 0
Dim libbmp_animLoopFrameCnt As Long = 0

Dim libbmp_col_r1 As Integer = 0
Dim libbmp_col_g1 As Integer = 0
Dim libbmp_col_b1 As Integer = 0
Dim libbmp_col_a1 As Integer = 0

Dim libbmp_col_r2 As Integer = 0
Dim libbmp_col_g2 As Integer = 0
Dim libbmp_col_b2 As Integer = 0
Dim libbmp_col_a2 As Integer = 0

Dim libbmp_offsetAnimW As Long = 0
Dim libbmp_offsetAnimH As Long = 0
Dim libbmp_offsetAnimStartX As Long = 0
Dim libbmp_offsetAnimStartY As Long = 0
Dim libbmp_offsetAnimIntervalX As Long = 0
Dim libbmp_offsetAnimIntervalY As Long = 0

Dim libbmp_retX As Double = 0
Dim libbmp_retY As Double = 0

' ------------------------ 临时变量
Dim libbmp_temp_i As Double = 0
Dim libbmp_temp_j As Double = 0
Dim libbmp_temp_k As Double = 0
Dim libbmp_temp_l As Double = 0
Dim libbmp_temp_m As Double = 0
Dim libbmp_temp_n As Double = 0
Dim libbmp_temp_o As Double = 0

' ===================================== 创建 bmp

' BMP 创建: 贮存 srcId
' @params srcId 资源 id
Export Script BmpNewStoreSrcId(srcId As Long)
    libbmp_srcId = srcId
End Script

' BMP 创建: 贮存 src 采样偏移和大小
' @params x 采样起始 x 坐标
' @params y 采样起始 y 坐标
' @params w 采样宽度
' @params h 采样高度
Export Script BmpNewStoreSrcOffset(x As Long, y As Long, w As Long, h As Long)
    libbmp_sx = x
    libbmp_sy = y
    libbmp_sh = h
    libbmp_sw = w
End Script

' BMP 创建: 贮存 src 信息
' @params srcId 资源 id
' @params x 采样起始 x 坐标
' @params y 采样起始 y 坐标
' @params w 采样宽度
' @params h 采样高度
Export Script BmpNewStoreSrc(srcId As Long, x As Long, y As Long, w As Long, h As Long)
    Call BmpNewStoreSrcId(srcId)
    Call BmpNewStoreSrcOffset(x, y, w, h)
End Script

' BMP 创建: 贮存 bmp 缩放
' @params w 目标宽度
' @params h 目标高度
Export Script BmpNewStoreScale(w As Double, h As Double)
    libbmp_scaleW = w
    libbmp_scaleH = h
End Script

' BMP 创建: 贮存 bmp 是否使用屏幕坐标
' @params isUse 1 使用屏幕坐标, 0 使用世界坐标
Export Script BmpNewStoreIsUseScreenCoords(isUse As Byte)
    libbmp_isUseScreenCoord = isUse
End Script

' BMP 创建: 贮存 bmp 位置
' @params x 目标 x 坐标
' @params y 目标 y 坐标
Export Script BmpNewStorePos(x As Long, y As Long)
    libbmp_destX = x
    libbmp_destY = y
End Script

' BMP 创建: 创建 bmp
' @params id bmp id
Export Script BmpNew(id As Long)
    Call BMPCreate(id, libbmp_srcId, libbmp_isUseScreenCoord, 1, libbmp_sx, libbmp_sy, libbmp_sw, libbmp_sh, libbmp_destX, libbmp_destY, libbmp_scaleW, libbmp_scaleH, 0, 0, 0, -1)
End Script

' BMP 创建: 销毁 bmp
' @params id bmp id
Export Script BmpDel(id As Long)
    Call BErase(2, id)
End Script

' ===================================== 设置 bmp

' 回复旋转
Script BmpInner_RotateReset(id As Long, Return Integer)
    libbmp_temp_m = Bitmap(id).rotatang
    libbmp_temp_i = Bitmap(id).scrwidth * Bitmap(id).scalex * libbmp_anchorX
    libbmp_temp_j = Bitmap(id).scrheight * Bitmap(id).scaley * libbmp_anchorY
    If libbmp_temp_m = 0 Then
        Return -1
    End If
    libbmp_temp_k = libbmp_temp_i * Cos(libbmp_temp_m) + libbmp_temp_j * Sin(libbmp_temp_m)
    libbmp_temp_l = -libbmp_temp_i * Sin(libbmp_temp_m) + libbmp_temp_j * Cos(libbmp_temp_m)

    Bitmap(id).destx += libbmp_temp_k - libbmp_temp_i
    Bitmap(id).desty += libbmp_temp_l - libbmp_temp_j
    Bitmap(id).rotatang = 0
    Return 0
End Script

' BMP 变换: 贮存相对锚点
' @params x 锚点 x 坐标, 0~1
' @params y 锚点 y 坐标, 0~1
Export Script BmpStoreAnchor(x As Double, y As Double)
    libbmp_anchorX = x
    libbmp_anchorY = y
End Script

' BMP 变换: 设置位置
Export Script BmpPos(id As Long, x As Long, y As Long)
    If (Abs(libbmp_anchorX) > 0.0001 Or Abs(libbmp_anchorY) > 0.0001) And Bitmap(id).scrwidth > 0 And Bitmap(id).scrheight > 0 Then
        libbmp_temp_n = Bitmap(id).rotatang
        Call BmpInner_RotateReset(id)
        Bitmap(id).destx = x - Bitmap(id).scrwidth * Bitmap(id).scalex * libbmp_anchorX
        Bitmap(id).desty = y - Bitmap(id).scrheight * Bitmap(id).scaley * libbmp_anchorY
        Call BmpRotate(id, libbmp_temp_n)
    Else
        Bitmap(id).destx = x
        Bitmap(id).desty = y
    End If
End Script

' BMP 变换: 获取位置
' @params id bmp id
' @return 返回 x 坐标
Export Script BmpGetPos(id As Long, Return Integer)
    If (Abs(libbmp_anchorX) > 0.0001 Or Abs(libbmp_anchorY) > 0.0001) And Bitmap(id).scrwidth > 0 And Bitmap(id).scrheight > 0 Then
        libbmp_temp_m = Bitmap(id).rotatang
        If Abs(libbmp_temp_m) <= 0.00000000001 Then
            libbmp_retX = Bitmap(id).destx + Bitmap(id).scrwidth * Bitmap(id).scalex * libbmp_anchorX
            libbmp_retY = Bitmap(id).desty + Bitmap(id).scrheight * Bitmap(id).scaley * libbmp_anchorY
        Else
            ' reset rotate
            libbmp_temp_n = Cos(libbmp_temp_m)
            libbmp_temp_o = Sin(libbmp_temp_m)
            libbmp_temp_i = Bitmap(id).scrwidth * Bitmap(id).scalex * libbmp_anchorX
            libbmp_temp_j = Bitmap(id).scrheight * Bitmap(id).scaley * libbmp_anchorY

            libbmp_temp_k = libbmp_temp_i * libbmp_temp_n + libbmp_temp_j * libbmp_temp_o
            libbmp_temp_l = -libbmp_temp_i * libbmp_temp_o + libbmp_temp_j * libbmp_temp_n
            libbmp_retX = Bitmap(id).destx + libbmp_temp_k
            libbmp_retY = Bitmap(id).desty + libbmp_temp_l
        End If
    Else
        libbmp_retX = Bitmap(id).destx
        libbmp_retY = Bitmap(id).desty
    End If
    Return 0
End Script

' BMP 变换: 设置旋转
' @params id bmp id
' @return 返回转角
Export Script BmpRotate(id As Long, angle As Double)
    If (Abs(libbmp_anchorX) > 0.0001 Or Abs(libbmp_anchorY) > 0.0001) And Bitmap(id).scrwidth > 0 And Bitmap(id).scrheight > 0 Then
        Call BmpInner_RotateReset(id)
        libbmp_temp_k = libbmp_temp_i * Cos(angle) + libbmp_temp_j * Sin(angle)
        libbmp_temp_l = -libbmp_temp_i * Sin(angle) + libbmp_temp_j * Cos(angle)

        Bitmap(id).destx += libbmp_temp_i - libbmp_temp_k
        Bitmap(id).desty += libbmp_temp_j - libbmp_temp_l
        Bitmap(id).rotatang = angle
    Else
        Bitmap(id).rotatang = angle
    End If
End Script

' BMP 变换: 设置缩放
' @params id bmp id
' @params scaleX x 轴缩放比例
' @params scaleY y 轴缩放比例
Export Script BmpScale(id As Long, scaleX As Double, scaleY As Double)
    If (Abs(libbmp_anchorX) > 0.0001 Or Abs(libbmp_anchorY) > 0.0001) And Bitmap(id).scrwidth > 0 And Bitmap(id).scrheight > 0 Then
        libbmp_temp_n = Bitmap(id).rotatang
        Call BmpInner_RotateReset(id)
        Bitmap(id).destx -= Bitmap(id).scrwidth * (1 - Bitmap(id).scalex) * libbmp_anchorX
        Bitmap(id).desty -= Bitmap(id).scrheight * (1 - Bitmap(id).scaley) * libbmp_anchorY
        Bitmap(id).scalex = scaleX
        Bitmap(id).scaley = scaleY
        Bitmap(id).destx += Bitmap(id).scrwidth * (1 - Bitmap(id).scalex) * libbmp_anchorX
        Bitmap(id).desty += Bitmap(id).scrheight * (1 - Bitmap(id).scaley) * libbmp_anchorY
        Call BmpRotate(id, libbmp_temp_n)
    Else
        Bitmap(id).scalex = scaleX
        Bitmap(id).scaley = scaleY
    End If
End Script

' BMP 变换: 获取缩放
' @params id bmp id
' @return 返回 x 轴缩放比例
' @return 返回 y 轴缩放比例
Export Script BmpGetScale(id As Long, Return Integer)
    libbmp_retX = Bitmap(id).scalex
    libbmp_retY = Bitmap(id).scaley
    Return 0
End Script

' BMP 变换: 获取旋转
' @params id bmp id
' @return 返回转角
Export Script BmpGetRotate(id As Long, Return Double)
    Return Bitmap(id).rotatang
End Script

' BMP 变换: 获取计算结果 x 坐标
' @return 返回 x 坐标
Export Script BmpGetRetX(Return Double)
    Return libbmp_retX
End Script

' BMP 变换: 获取计算结果 y 坐标
' @return 返回 y 坐标
Export Script BmpGetRetY(Return Double)
    Return libbmp_retY
End Script

' ===================================== bmp 动画

' BMP 帧动画: 贮存动画序列帧的起始位置
' 可以直接参考 BmpNewStoreSrc 的后四个参数
' @params startX 起始 x 坐标
' @params startY 起始 y 坐标
' @params w 每帧宽度
' @params h 每帧高度
Export Script BmpStoreAnimPos(startX As Long, startY As Long, w As Long, h As Long)
    libbmp_animW = w
    libbmp_animH = h
    libbmp_animStartX = startX
    libbmp_animStartY = startY
End Script

' BMP 帧动画: 贮存动画序列帧的数量和横轴数量
' @params cnt 帧总数量
' @params cellCntX 横轴帧数量
Export Script BmpStoreAnimInfo(cnt As Long, cellCntX As Long)
    libbmp_animCnt = cnt
    libbmp_animCeilX = cellCntX
End Script

' BMP 帧动画: 贮存动画帧尾循环
' @params cnt 循环帧数量, <=0 表示永远循环
Export Script BmpStoreAnimLoop(cnt As Long)
    libbmp_animLoopFrameCnt = cnt
End Script

' BMP 帧动画: 贮存动画每帧位置偏移
' @params x 每帧 x 轴偏移
' @params y 每帧 y 轴偏移
Export Script BmpStoreAnimInterval(x As Long, y As Long)
    libbmp_offsetAnimIntervalX = x
    libbmp_offsetAnimIntervalY = y
End Script

' BMP 帧动画: 应用动画帧
' @params id bmp id
' @params timeStamp 帧时间戳, 从 0 开始, 可以大于总帧数, 也可以小于 0
Export Script BmpAnim(id As Long, timeStamp As Long)
    If timeStamp < 0 Then
        timeStamp = -timeStamp
    End If

    If libbmp_animLoopFrameCnt > 0 And libbmp_animLoopFrameCnt < libbmp_animCnt And timeStamp >= libbmp_animCnt Then
        timeStamp = (timeStamp mod libbmp_animLoopFrameCnt) + libbmp_animCnt - libbmp_animLoopFrameCnt
    Else
        timeStamp = timeStamp mod libbmp_animCnt
    End If

    libbmp_temp_i = timeStamp mod libbmp_animCeilX
    libbmp_temp_j = timeStamp \ libbmp_animCeilX

    Bitmap(id).scrx = libbmp_animStartX + libbmp_temp_i * libbmp_animW + libbmp_temp_i * libbmp_offsetAnimIntervalX
    Bitmap(id).scry = libbmp_animStartY + libbmp_temp_j * libbmp_animH + libbmp_temp_j * libbmp_offsetAnimIntervalY
End Script

' ===================================== 颜色

' BMP 颜色: 贮存颜色到槽位 1
' rgba 范围 0 ~ 255
Export Script BmpStoreCol1(r As Integer, g As Integer, b As Integer, a As Integer)
    libbmp_col_r1 = r
    libbmp_col_g1 = g
    libbmp_col_b1 = b
    libbmp_col_a1 = a
End Script

' BMP 颜色: 贮存颜色到槽位 2
' rgba 范围 0 ~ 255
Export Script BmpStoreCol2(r As Integer, g As Integer, b As Integer, a As Integer)
    libbmp_col_r2 = r
    libbmp_col_g2 = g
    libbmp_col_b2 = b
    libbmp_col_a2 = a
End Script

' BMP 颜色: 颜色插值, 在槽位 1 和槽位 2 之间插值
' @params t 插值参数, 0 ~ 1
' @return 返回插值后的颜色值
Export Script BmpLerpCol(t As Double, Return Double)
    Return rgba(((1 - t) * libbmp_col_r1 + t * libbmp_col_r2), ((1 - t) * libbmp_col_g1 + t * libbmp_col_g2), ((1 - t) * libbmp_col_b1 + t * libbmp_col_b2), ((1 - t) * libbmp_col_a1 + t * libbmp_col_a2))
End Script

' BMP 颜色: 设置 bmp 颜色
' @params id bmp id
' rgba 范围 0 ~ 255
Export Script BmpCol(id As Long, r As Integer, g As Integer, b As Integer, a As Integer)
    Bitmap(id).forecolor = rgba(r, g, b, a)
End Script

' BMP 颜色: 设置槽位 1 中贮存的颜色到 bmp
' @params id bmp id
Export Script BmpCol1(id As Long)
    Bitmap(id).forecolor = rgba(libbmp_col_r1, libbmp_col_g1, libbmp_col_b1, libbmp_col_a1)
End Script

' BMP 颜色: 设置槽位 2 中贮存的颜色到 bmp
' @params id bmp id
Export Script BmpCol2(id As Long)
    Bitmap(id).forecolor = rgba(libbmp_col_r2, libbmp_col_g2, libbmp_col_b2, libbmp_col_a2)
End Script

' BMP 颜色: 设置槽位 1 和槽位 2 中贮存的颜色插值到 bmp
' @params id bmp id
Export Script BmpColLerp(id As Long, t As Double)
    Bitmap(id).forecolor = rgba(((1 - t) * libbmp_col_r1 + t * libbmp_col_r2), ((1 - t) * libbmp_col_g1 + t * libbmp_col_g2), ((1 - t) * libbmp_col_b1 + t * libbmp_col_b2), ((1 - t) * libbmp_col_a1 + t * libbmp_col_a2))
End Script

' BMP 颜色: 设置 bmp alpha 值
' @params id bmp id
' @params a alpha 值, 0 ~ 1
Export Script BmpAlpha(id As Long, a As Double)
    Bitmap(id).forecolor_a = a * 255
End Script

' ===================================== 偏移动画

' BMP 偏移动画: 贮存偏移动画信息
' @params x 起始 x 坐标
' @params y 起始 y 坐标
' @params w 结束 x 坐标
' @params h 结束 y 坐标
Export Script BmpStoreOffsetAnimInfo(x As Long, y As Long, w As Long, h As Long)
    libbmp_offsetAnimStartX = x
    libbmp_offsetAnimStartY = y
    libbmp_offsetAnimW = w
    libbmp_offsetAnimH = h
End Script

' BMP 偏移动画: 应用偏移动画
' @params id bmp id
' @params t 插值参数, 0 ~ 1
Export Script BmpOffsetAnim(id As Long, t As Double)
    t = t - Int(t)
    Bitmap(id).scrx = (1 - t) * libbmp_offsetAnimStartX + t * libbmp_offsetAnimW
    Bitmap(id).scry = (1 - t) * libbmp_offsetAnimStartY + t * libbmp_offsetAnimH
End Script
