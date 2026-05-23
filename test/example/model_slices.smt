' ==============================================================================================
' ================================= 模型切片应用

' ================================= 可设置部分开始 :: Config Begin
' ================================= 参数设置

Dim clipWid As Long = 256           ' 切片宽
Dim clipHei As Long = 256           ' 切片高
Dim clipCountWid As Long = 16       ' 切片横向数量
Dim clipCountHei As Long = 16       ' 纵向切片数量

Dim clipAtlasId As Long = 256       ' 图集 id
Dim bitmapIdBegin As Long = 16      ' bitmap 起始 id

Dim posX As Long = -199456          ' 模型绘制位置 x (关卡坐标)
Dim posY As Long = -200440          ' 模型绘制位置 y (关卡坐标)
Dim posZ As Long = 0                ' 模型绘制位置 z (同时受到 lenZ 的限制)
Dim lenZ As Double = 1              ' 模型深度限制
Dim scale As Double = 1.4           ' 模型整体缩放

Dim zposBeg As Double = 0.9         ' 模型 bitmap zpos 起始
Dim zposStep As Double = 0.0001     ' 模型 bitmap zpos 步进

Dim camAsixX As Double = 0          ' 相机 x 向移轴
Dim camAsixY As Double = 0          ' 相机 y 方向移轴
Dim camFov As Double = 0.5          ' 相机视野


' ================================= 模型切片参数的修改

' 设置数据时运行
' @param bitmapId 当前切片的 bitmap Id
' @param factor 当前切片的衰减参数 (值域为[0~1], 随切片 id 线性增长)
Script OnSetData(bitmapId As Long, factor As Double)
    ' do something
    ' Bitmap(bitmapId).forecolor_b = factor * 255
End Script

' 每刷新时运行
' @param bitmapId 当前切片的 bitmap Id
' @param factor 当前切片的衰减参数 (值域为[0~1], 随切片 id 线性增长)
Script OnRefreshModel(bitmapId As Long, factor As Double)
    ' do something
    ' Bitmap(bitmapId).forecolor_b = factor * 255
End Script

' ================================= 可设置部分结束 :: Config End
' ==============================================================================================

' ----------------------------------------------------------------------------------------------
' ==============================================================================================
' ==============================================================================================
' ======================================================== 内部计算 :: Internal Calc
' ==============================================================================================
' ======================================================== !! 别动下面的内容 !!
' ======================================================== !! Don't modify the following code !!
' ========================================================                         -- xiaodou
' ========================================================                         -- 20230422
' ==============================================================================================
' ----------------------------------------------------------------------------------------------

' ==============================================================================================
' ================================= 内部定义和计算
Dim clipCount As Double = clipCountHei * clipCountWid
Dim bitmapIdEnd As Long = bitmapIdBegin + clipCount - 1
Dim pCentre_x As Double = posX + clipWid * scale / 2
Dim pCentre_y As Double = posY + clipHei * scale / 2

Dim tanFov As Double
Dim d_tanFov As Double
If camFov <= 0.000000000001 Then
    tanFov = 0
    d_tanFov = 1000000000000
	lenZ = 1000000000000
    posZ = 1000000000000
ElseIf camFov >= (Pi / 2 - 0.000001) Then
    tanFov = 10000000
	lenZ = 0.0000001
    posZ = 0
    d_tanFov = 0
Else
    tanFov = Tan(camFov)
    d_tanFov = 1 / tanFov
	lenZ = Atn(lenZ) * d_tanFov * 2 / Pi
    posZ = Atn(posZ) * d_tanFov * 2 / Pi
End If
lenZ = (1 - lenZ * tanFov)
posZ = (1 - posZ * tanFov)

Dim clipMinWid As Long = scale * lenZ * clipWid / 2
Dim clipMinHei As Long = scale * lenZ * clipHei / 2
Dim offsetMinX As Long = 0
Dim offsetMinY As Long = 0
Dim offsetMaxX As Long = 0
Dim offsetMaxY As Long = 0

If camAsixX > 0 Then
    offsetMaxX = camAsixX
Else
    offsetMinX = camAsixX
End If

If camAsixY > 0 Then
    offsetMaxY = camAsixY
Else
    offsetMinY = camAsixY
End If

Dim stdIdx  As Long = 0
Dim stdIdx2 As Long = 0
Dim lossFactor As Double = 0.0

Dim delta As Double
Dim offsetX As Long
Dim offsetY As Long

Dim p0_x As Long
Dim p0_y As Long

Dim p0_x_offset As Long
Dim p0_y_offset As Long
' ==============================================================================================
' ==============================================================================================

' 创建模型所需的 Bitmap
Export Script CreateModelBitmap()
    stdIdx2 = 0
    For stdIdx = bitmapIdBegin To bitmapIdEnd - 1 Step 1
        Call BMPCreate(stdIdx, clipAtlasId, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, -1)
        stdIdx2 += 1
    Next
End Script

' 设置模型数据到对应的 Bitmap 上
Export Script SetData()
    stdIdx2 = 0
    For stdIdx = bitmapIdBegin To bitmapIdEnd - 1 Step 1
        lossFactor = stdIdx2 / clipCount
        delta = 1 - ((clipCount - stdIdx2)/ clipCount) * posZ
        delta = ((1 - delta) + delta * lenZ) * scale
        Bitmap(stdIdx).attscreen = 0
        Bitmap(stdIdx).scrId = clipAtlasId
        Bitmap(stdIdx).scrx = (stdIdx2 mod clipCountWid) * clipWid
        Bitmap(stdIdx).scry = (clipCountHei - int(stdIdx2 / clipCountHei) - 1) * clipHei
        Bitmap(stdIdx).scrwidth = clipWid
        Bitmap(stdIdx).scrheight = clipHei
        Bitmap(stdIdx).scalex = delta
        Bitmap(stdIdx).scaley = delta
        Bitmap(stdIdx).rotatx = 0
        Bitmap(stdIdx).rotaty = clipHei
        Bitmap(stdIdx).zpos = zposBeg + zposStep * stdIdx
        Call OnSetData(stdIdx, lossFactor)
        stdIdx2 += 1
    Next
End Script

' 模型是否在屏幕中
' @return 在屏幕中返回 1 否则返回 0
Export Script InScreen(Return Integer)
    p0_x = Sysval(Player1scrX)
    p0_y = Sysval(Player1scrY)
    offsetX = (400 - pCentre_x + p0_x) * (1 -  lenZ)
    ' y 轴的检测待修正
    ' offsetY = (300 - pCentre_y + p0_y) * (1 -  lenZ) - clipHei / 2
    If offsetX + posX - p0_x + clipMinWid + offsetMinX > 805 Or offsetX + posX - p0_x + clipMinWid * 3 + offsetMaxX  < -5 Then
        Return 0
    ' y 轴的检测待修正
    ' ElseIf offsetY + posY - p0_y < clipMinHei Or offsetY + posY - p0_y < 600 Then
    '     Return 0
    Else
        Return 1
    End If
End Script

' 显示并刷新模型
Export Script RefreshModel()
    p0_x = Sysval(Player1scrX)
    p0_y = Sysval(Player1scrY)
    p0_x_offset = 400 - pCentre_x + p0_x
    p0_y_offset = 300 - pCentre_y + p0_y
    stdIdx2 = 0
    For stdIdx = bitmapIdBegin To bitmapIdEnd - 1 Step 1
        lossFactor = stdIdx2 / clipCount
        delta = 1 - ((clipCount - stdIdx2)/ clipCount) * posZ
        offsetX = p0_x_offset - p0_x_offset * ((1 - delta) + delta * lenZ) + delta * camAsixX
        offsetY = p0_y_offset - p0_y_offset * ((1 - delta) + delta * lenZ) + delta * camAsixY - clipHei * delta / 2
        Bitmap(stdIdx).hide = 0
        Bitmap(stdIdx).destx = offsetX + posX + (1 - Bitmap(stdIdx).scalex / scale) * clipWid * scale / 2
        Bitmap(stdIdx).desty = offsetY + posY + (1 - Bitmap(stdIdx).scaley / scale) * clipHei * scale / 2
        Call OnRefreshModel(stdIdx, lossFactor)
        stdIdx2 += 1
    Next
End Script

' 隐藏模型
Export Script HideModel()
    For stdIdx = bitmapIdBegin To bitmapIdEnd - 1 Step 1
        Bitmap(stdIdx).hide = 1
    Next
End Script