' ====================================================================================
' ================================================================= SMBX 中的 2D 伪阴影实验
' x 中的 2d 光影的实验
' 由于 x 中相关图形接口的匮乏 制作很完美的 2d 光影是非常困难的
' 这里只是针对一个非常特殊的定制场景做光影效果
' 									---- xiaodou 202209
' ====================================================================================
' ---------------------------------- 向量计算的相关方法
' 向量的模
Export Script Shadow2D_CalcNorm(v_x As Double, v_y As Double, Return Double)
    Return Sqr(v_x * v_x + v_y * v_y)
End Script

' 向量的叉积
Export Script Shadow2D_CalcCross(vA_x As Double, vA_y As Double, vB_x As Double, vB_y As Double, Return Double)
    Return vA_x * vB_y - vB_x * vA_y
End Script

' 向量的点积
Export Script Shadow2D_CalcDot(vA_x As Double, vA_y As Double, vB_x As Double, vB_y As Double, Return Double)
    Return vA_x * vB_x + vA_y * vB_y
End Script

' 三点所构成角的角平分线 x
Export Script Shadow2D_CalcAxis_x(pCP_x As Double, pCP_y As Double, pCP2_x As Double, pCP2_y As Double, pL_x As Double, pL_y As Double, Return Double)
    Dim vA_x As Double = pCP_x - pL_x
    Dim vB_x As Double = pCP2_x - pL_x

    Dim norA As Double = Shadow2D_CalcNorm(vA_x, pCP_y - pL_y)
    Dim norB As Double = Shadow2D_CalcNorm(vB_x, pCP2_y - pL_y)

    Dim disA As Double = Abs(norA)
    Dim disB As Double = Abs(norB)

    If disA < 0.0000000000000001 And disB < 0.0000000000000001 Then
        return 0
    ElseIf disA < 0.0000000000000001 Then
        return vB_x / norB
    ElseIf disB < 0.0000000000000001 Then
        return vA_x / norA
    Else
        Return vA_x / norA  + vB_x / norB
    End If
End Script

' 三点所构成角的角平分线 y
Export Script Shadow2D_CalcAxis_y(pCP_x As Double, pCP_y As Double, pCP2_x As Double, pCP2_y As Double, pL_x As Double, pL_y As Double, Return Double)
    Dim vA_y As Double = pCP_y - pL_y
    Dim vB_y As Double = pCP2_y - pL_y

    Dim norA As Double = Shadow2D_CalcNorm(pCP_x - pL_x, vA_y)
    Dim norB As Double = Shadow2D_CalcNorm(pCP2_x - pL_x, vB_y)

    Dim disA As Double = Abs(norA)
    Dim disB As Double = Abs(norB)

    If disA < 0.0000000000000001 And disB < 0.0000000000000001 Then
        return 1
    ElseIf disA < 0.0000000000000001 Then
        return vB_y / norB
    ElseIf disB < 0.0000000000000001 Then
        return vA_y / norA
    Else
        Return vA_y / norA  + vB_y / norB
    End If
End Script

' 计算两向量的逆时针夹角
Export Script Shadow2D_CalcAngle(vA_x As Double, vA_y As Double, vB_x As Double, vB_y As Double, Return Double)
    Dim d As Double = Shadow2D_CalcDot(vA_x, vA_y, vB_x, vB_y)
    Dim c As Double = Shadow2D_CalcCross(vA_x, vA_y, vB_x, vB_y) 
    If 0.0000000000000001 > Abs(d) Then
        If 0 < c Then
            Return Pi / 2
        Else
            Return -Pi / 2
        End If
    End If
    Return Atn(c / d)
End Script

' 计算两点距离
Export Script Shadow2D_CalcDistance(pA_x As Double, pA_y As Double, pB_x As Double, pB_y As Double, Return Double)
    Return Shadow2D_CalcNorm(pA_x - pB_x, pA_y - pB_y)
End Script

' 计算四个值中的最小值
Export Script Shadow2D_CalcMin(x As Double, y As Double, z As Double, w As Double, Return Double)
    If y < x Then
        x = y
    End If

    If w < z Then
        z = w
    End If

    If x < z Then
        Return x
    Else
        Return z
    End If
End Script

' 阈值到 0~1 之间
Export Script Shadow2D_CalcClamp01(x As Double, Return Double)
	If x > 1 Then
		Return 1
	ElseIf x < 0 Then
		Return 0
	End If
	
	Return x
End Script

' ====================================================================================
' ---------------------------------- 资源管理相关
' 位图唯一 id 的计算方法
' 每个参数都为计算 id 的一部分依据
' @return: 计算结果 id
Script Shadow2D_PRIVATE_BmpId(a As Integer, b As Integer, i As Integer, x As Integer, Return Integer)
    Return a*10000000+ b*1000000 + i*10000 + x
End Script

' 创建阴影图形对象
' @param sid: bitmap 索引 id 第一部分
' @param bid: bitmap 索引 id 第二部分
' @param group: bitmap 索引 id 第三部分
' @param picId: 阴影横纹采样的目标 npcid
' @param count: 阴影横纹条数
' @param sampleJump: 采样偏移
' @param height: 单条阴影横纹宽度
Export Script Shadow2D_BmpShadowCreate(sid As Integer, bid As Integer, group As Integer, picId As Integer, count As Integer, sampleJump As Double, height As Integer)
    Dim i As Integer

    For i = 0 To count - 1
        Call BMPCreate(Shadow2D_PRIVATE_BmpId(sid, bid, i, group), picId,   1, 0,   0, i * sampleJump,   1, 1,   0, 0,   height, 1,   0, 0,   0, -1)
    Next
End Script

' 隐藏阴影图形对象
' @param sid: bitmap 索引 id 第一部分
' @param bid: bitmap 索引 id 第二部分
' @param count: 阴影横纹条数
Export Script Shadow2D_BmpShadowHide(sid As Integer, bid As Integer, group As Integer, count As Integer)
    Dim i As Integer

    For i = 0 To count - 1
        Bitmap(Shadow2D_PRIVATE_BmpId(sid, bid, i, group)).hide = 1
    Next
End Script

' 销毁阴影图形对象
' @param sid: bitmap 索引 id 第一部分
' @param bid: bitmap 索引 id 第二部分
' @param group: bitmap 索引 id 第三部分
' @param count: 阴影横纹条数
Export Script Shadow2D_BmpShadowDestroy(sid As Integer, bid As Integer, group As Integer, count As Integer)
    Dim i As Integer

    For i = 0 To count - 1
        Call BErase(2, Shadow2D_PRIVATE_BmpId(sid, bid, i, group))
    Next
End Script

' ====================================================================================
' ---------------------------------- 阴影生成相关方法
' 碰撞箱为 AABB 矩形的 2D 阴影
' @param sid: bitmap 索引 id 第一部分
' @param bid: bitmap 索引 id 第二部分
' @param group: bitmap 索引 id 第三部分
' @param picSplit: 阴影横纹条数
' @param spacingFac: 阴影间距
' @param pBox_x: 碰撞箱左上角点 x 坐标
' @param pBox_y: 碰撞箱左上角点 y 坐标
' @param pBox_w: 碰撞箱宽
' @param pBox_h: 碰撞箱高
' @param pLightSrc_x: 光源位置 x 坐标
' @param pLightSrc_y: 光源位置 y 坐标
' @param alpha: 阴影透明度乘数
' @param zpos: 阴影横纹 zpos
' @return: 当前阴影透明度 (不受阴影透明度乘数影响的原始值)
Export Script Shadow2D_AABBRect(sid As Integer, bid As Integer, group As Integer, picSplit As Integer, spacingFac As Double, pBox_x As Double, pBox_y As Double, box_w As Double, box_h As Double, pLightSrc_x As Double, pLightSrc_y As Double, alpha As Double, zpos As Double, Return Double)
    ' ====================================================================================
    ' ================================================================= 第一部分: 状态分析
    ' ---------------------------------- 状态定义:
    Dim pCornerPoint_x As Double = 0
    Dim pCornerPoint_y As Double = 0
    Dim vAxis_x As Double = 0
    Dim vAxis_y As Double = 0

    ' ---------------------------------- 判断条件:
    '   对于 2d 的 AABB 矩形框来说 一共有 11 个不同的投影状态 这里粗糙地采用 D2Q9 的方式划分
    '   矩形四个角点的坐标和中点坐标:
    Dim pA_x As Double = pBox_x
    Dim pA_y As Double = pBox_y
    Dim pB_x As Double = pBox_x + box_w
    Dim pB_y As Double = pBox_y
    Dim pC_x As Double = pBox_x + box_w
    Dim pC_y As Double = pBox_y + box_h
    Dim pD_x As Double = pBox_x
    Dim pD_y As Double = pBox_y + box_h
    Dim pCen_x As Double = pBox_x + (box_w * 0.5)
    Dim pCen_y As Double = pBox_y + (box_h * 0.5)
	Dim diameter As Double = Shadow2D_CalcNorm(box_w, box_h)
	
    ' ---------------------------------- 光源与矩形框相对位置分析:
	Dim i As Integer
    Dim inHorPos As Integer = 0
    Dim inVerPos As Integer = 0
    ' 与矩形框的水平相对位置: 1 0 3
    If pLightSrc_x > pB_x Then
        inHorPos = 3
    ElseIf pLightSrc_x < pA_x Then
        inHorPos = 1
    End If
    ' 与矩形框的垂直相对位置: 3 0 1
    If pLightSrc_y > pD_y Then
        inVerPos = 3
    ElseIf pLightSrc_y < pA_y Then
        inVerPos = 1
    End If

    ' ---------------------------------- 状态分析:
    ' 状态分析这里分为 11 种情况
    ' ----------------
    ' 在角落的情况:
    If 1 = inHorPos And 3 = inVerPos Then
        ' AC/C
        vAxis_x = Shadow2D_CalcAxis_x(pA_x, pA_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
        vAxis_y = Shadow2D_CalcAxis_y(pA_x, pA_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
        pCornerPoint_x = pC_x
        pCornerPoint_y = pC_y
    ElseIf 1 = inHorPos And 1 = inVerPos Then
        ' BD/D
        vAxis_x = Shadow2D_CalcAxis_x(pB_x, pB_y, pD_x, pD_y, pLightSrc_x, pLightSrc_y)
        vAxis_y = Shadow2D_CalcAxis_y(pB_x, pB_y, pD_x, pD_y, pLightSrc_x, pLightSrc_y)
        pCornerPoint_x = pD_x
        pCornerPoint_y = pD_y
    ElseIf 3 = inHorPos And 1 = inVerPos Then
        ' AC/C
        vAxis_x = Shadow2D_CalcAxis_x(pA_x, pA_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
        vAxis_y = Shadow2D_CalcAxis_y(pA_x, pA_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
        pCornerPoint_x = pC_x
        pCornerPoint_y = pC_y
    ElseIf inHorPos = 3 And inVerPos = 3 Then
        ' BD/D
        vAxis_x = Shadow2D_CalcAxis_x(pB_x, pB_y, pD_x, pD_y, pLightSrc_x, pLightSrc_y)
        vAxis_y = Shadow2D_CalcAxis_y(pB_x, pB_y, pD_x, pD_y, pLightSrc_x, pLightSrc_y)
        pCornerPoint_x = pD_x
        pCornerPoint_y = pD_y

    ' ----------------
    ' 在边缘的情况:
    ElseIf 0 = inHorPos And 0 <> inVerPos Then
        If inVerPos = 3 Then
            ' DC
            vAxis_x = Shadow2D_CalcAxis_x(pD_x, pD_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
            vAxis_y = Shadow2D_CalcAxis_y(pD_x, pD_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
            If pLightSrc_x < pCen_x Then
                ' C
                pCornerPoint_x = pC_x
                pCornerPoint_y = pC_y
            Else
                ' D
                pCornerPoint_x = pD_x
                pCornerPoint_y = pD_y
            End If
        Else
            ' AB
            vAxis_x = Shadow2D_CalcAxis_x(pA_x, pA_y, pB_x, pB_y, pLightSrc_x, pLightSrc_y)
            vAxis_y = Shadow2D_CalcAxis_y(pA_x, pA_y, pB_x, pB_y, pLightSrc_x, pLightSrc_y)
            If pLightSrc_x < pCen_x Then
                ' B
                pCornerPoint_x = pA_x
                pCornerPoint_y = pA_y
            Else
                ' A
                pCornerPoint_x = pB_x
                pCornerPoint_y = pB_y
            End If
        End If
    ElseIf 0 = inVerPos And 0 <> inHorPos Then
        If inHorPos = 3 Then
            ' BC/C
            vAxis_x = Shadow2D_CalcAxis_x(pB_x, pB_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
            vAxis_y = Shadow2D_CalcAxis_y(pB_x, pB_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
            pCornerPoint_x = pC_x
            pCornerPoint_y = pC_y
        Else
            ' AD/D
            vAxis_x = Shadow2D_CalcAxis_x(pA_x, pA_y, pD_x, pD_y, pLightSrc_x, pLightSrc_y)
            vAxis_y = Shadow2D_CalcAxis_y(pA_x, pA_y, pD_x, pD_y, pLightSrc_x, pLightSrc_y)
            pCornerPoint_x = pD_x
            pCornerPoint_y = pD_y
        End If
        ' ----------------
    ' 在内部的情况
    Else
		For i = 0 To picSplit - 1
			Bitmap(Shadow2D_PRIVATE_BmpId(sid, bid, i, group)).hide = 1
		Next
		Dim dA As Double = Shadow2D_CalcDistance(pA_x, pA_y, pLightSrc_x, pLightSrc_y)
		Dim dB As Double = Shadow2D_CalcDistance(pB_x, pB_y, pLightSrc_x, pLightSrc_y)
		Dim dC As Double = Shadow2D_CalcDistance(pC_x, pC_y, pLightSrc_x, pLightSrc_y)
		Dim dD As Double = Shadow2D_CalcDistance(pD_x, pD_y, pLightSrc_x, pLightSrc_y)
		Dim dCen As Double = Shadow2D_CalcDistance(pCen_x, pCen_y, pLightSrc_x, pLightSrc_y)
		dA = Shadow2D_CalcMin(dA, dB, dC, dD)
		
		If dCen < dA Then
			dA = dCen
		End If

		If dA < (diameter * 1.4) Then
			Return dA / (diameter * 1.4)
		End If

		Return 1
    End If

    ' ====================================================================================
    ' ================================================================= 第二部分: 阴影生成
    ' ---------------------------------- 数据准备:
    ' 归一化中轴线
    Dim dAxis As Double = Shadow2D_CalcNorm(vAxis_x, vAxis_y)
    If 0.0000000000000001 < Abs(dAxis) Then
        vAxis_x = vAxis_x / dAxis
        vAxis_y = vAxis_y / dAxis
    Else
        vAxis_x = 0
        vAxis_y = 1
    End If

    ' 计算中点-光源向量到中轴的投影 vProj 和 角点-光源向量到中轴的投影 vProj2
    Dim vProj_x As Double = (pCen_x - pLightSrc_x) * vAxis_x * vAxis_x + (pCen_y - pLightSrc_y) * vAxis_y * vAxis_x
    Dim vProj_y As Double = (pCen_y - pLightSrc_y) * vAxis_y * vAxis_y + (pCen_x - pLightSrc_x) * vAxis_x * vAxis_y

    Dim vProj2_x As Double = (pCornerPoint_x - pLightSrc_x) * vAxis_x * vAxis_x + (pCornerPoint_y - pLightSrc_y) * vAxis_y * vAxis_x
    Dim vProj2_y As Double = (pCornerPoint_y - pLightSrc_y) * vAxis_y * vAxis_y + (pCornerPoint_x - pLightSrc_x) * vAxis_x * vAxis_y

    Dim dProj2 As Double = Shadow2D_CalcNorm(vProj2_x, vProj2_y)
    Dim dProj As Double = Shadow2D_CalcNorm(vProj_x, vProj_y)

    ' 计算角点-光源向量的单位向量
    Dim dCPL As Double = Shadow2D_CalcNorm(pCornerPoint_x - pLightSrc_x, pCornerPoint_y - pLightSrc_y)
    Dim vNorCPL_x As Double = 0
    Dim vNorCPL_y As Double = 1
    If Abs(dCPL) > 0.0000000000000001 Then
        vNorCPL_x = (pCornerPoint_x - pLightSrc_x) / dCPL
        vNorCPL_y = (pCornerPoint_y - pLightSrc_y) / dCPL
    End If

    Dim dPStartFac As Double = 1
    If Abs(dProj2) > 0.0000000000000001 Then
        dPStartFac = dCPL * dProj / dProj2
    End If

    ' 计算阴影始点和始长
    '   始长是角点-光源向量的模平方减去始点-光源向量的模平方开根号后取两倍
    Dim pStart_x As Double = pLightSrc_x + vNorCPL_x * dPStartFac
    Dim pStart_y As Double = pLightSrc_y + vNorCPL_y * dPStartFac
    Dim dStart As Double = Sqr(dPStartFac * dPStartFac - dProj * dProj) * 2

    ' 计算偏转角度
    Dim angle As Double = Shadow2D_CalcAngle(vAxis_x, vAxis_y, 1, 0)

    ' 计算变位和变长
    Dim cosTheta As Double = Shadow2D_CalcDot(vNorCPL_x, vNorCPL_y, vAxis_x, vAxis_y)
    If Abs(cosTheta) < 0.0000000000000001 Then
        cosTheta = 1
    End If
    Dim vStart_dx As Double = (spacingFac / cosTheta) * vNorCPL_x 
    Dim vStart_dy As Double = (spacingFac / cosTheta) * vNorCPL_y
    Dim dDStart As Double = 0

    If 0.0000000000000001 < Abs(dProj) Then
        dDStart = spacingFac * dStart / dProj
    End If

    ' ---------------------------------- 绘制阴影:
    ' 绘制阴影
	Dim bitmapId As Double

    Dim new_x As Double = 0
    Dim new_y As Double = 0
    Dim new_alpha_x As Double = 1
    Dim new_alpha_y As Double = 1
    Dim new_alpha_dCPL As Double = 1
    Dim new_alpha_bgo As Double = 0

    Dim dA As Double = Shadow2D_CalcDistance(pA_x, pA_y, pLightSrc_x, pLightSrc_y)
    Dim dB As Double = Shadow2D_CalcDistance(pB_x, pB_y, pLightSrc_x, pLightSrc_y)
    Dim dC As Double = Shadow2D_CalcDistance(pC_x, pC_y, pLightSrc_x, pLightSrc_y)
    Dim dD As Double = Shadow2D_CalcDistance(pD_x, pD_y, pLightSrc_x, pLightSrc_y)
	Dim dCen As Double = Shadow2D_CalcDistance(pCen_x, pCen_y, pLightSrc_x, pLightSrc_y)
    dA = Shadow2D_CalcMin(dA, dB, dC, dD)
	
	If dCen < dA Then
		dA = dCen
	End If

    If dA < (diameter * 1.4) Then
        new_alpha_dCPL = dA / (diameter * 1.4)
    End If

    new_alpha_bgo = Shadow2D_CalcClamp01(new_alpha_dCPL * 2)
	
    For i = 0 To picSplit - 1
		new_x = pStart_x + i * vStart_dx
		new_y = pStart_y + i * vStart_dy
		new_alpha_x = 1
		new_alpha_y = 1

		If new_x < 200 Then
			new_alpha_x = new_x / 200
		ElseIf new_x > 600 Then
			new_alpha_x = (800 - new_x) / 200
		End If

		If new_y < 200 Then
			new_alpha_y = new_y / 200
		ElseIf new_y > 400 Then
			new_alpha_y = (600 - new_y) / 200
		End If

		new_alpha_x = Shadow2D_CalcClamp01(new_alpha_x)
		new_alpha_y = Shadow2D_CalcClamp01(new_alpha_y)
		
		bitmapId = Shadow2D_PRIVATE_BmpId(sid, bid, i, group)
		Bitmap(bitmapId).hide = 0
		Bitmap(bitmapId).rotatang = angle + Pi
		Bitmap(bitmapId).attscreen = 1
		Bitmap(bitmapId).destx = new_x
		Bitmap(bitmapId).desty = new_y
		Bitmap(bitmapId).forecolor_a = alpha * new_alpha_dCPL * new_alpha_x * new_alpha_y * 255
		Bitmap(bitmapId).scaley = dStart + i * dDStart
		Bitmap(bitmapId).zpos = zpos
    Next
	
	Return new_alpha_bgo
End Script

' 碰撞箱为圆形的 2D 阴影
' @param sid: bitmap 索引 id 第一部分
' @param bid: bitmap 索引 id 第二部分
' @param group: bitmap 索引 id 第三部分
' @param picSplit: 阴影横纹条数
' @param spacingFac: 阴影间距
' @param pBox_x: 碰撞箱左上角点 x 坐标
' @param pBox_y: 碰撞箱左上角点 y 坐标
' @param radius: 碰撞箱 (圆) 半径
' @param pLightSrc_x: 光源位置 x 坐标
' @param pLightSrc_y: 光源位置 y 坐标
' @param alpha: 阴影透明度乘数
' @param zpos: 阴影横纹 zpos
' @return: 当前阴影透明度 (不受阴影透明度乘数影响的原始值)
Export Script Shadow2D_HalfCircle(sid As Integer, bid As Integer, group As Integer, picSplit As Integer, spacingFac As Double, pBox_x As Double, pBox_y As Double, radius As Double, pLightSrc_x As Double, pLightSrc_y As Double, alpha As Double, zpos As Double, Return Double)
    Dim i As Integer
    radius = Abs(radius)
    If radius < 0.0000000000000001 Then
        For i = 0 To picSplit - 1
            Bitmap(Shadow2D_PRIVATE_BmpId(sid, bid, i, group)).hide = 1
        Next
        Return 1
    End If
    ' ====================================================================================
    ' ================================================================= 第一部分: 状态分析
    ' ---------------------------------- 状态定义:
    Dim vAxis_x As Double = pBox_x + radius - pLightSrc_x
    Dim vAxis_y As Double = pBox_y + radius - pLightSrc_y
    Dim dAxis As Double = Shadow2D_CalcNorm(vAxis_x, vAxis_y)
    If dAxis < radius * 0.66 Then
        For i = 0 To picSplit - 1
            Bitmap(Shadow2D_PRIVATE_BmpId(sid, bid, i, group)).hide = 1
        Next
        Return 0
    End If

    ' 归一化中轴线
    vAxis_x = vAxis_x / dAxis
    vAxis_y = vAxis_y / dAxis

    If vAxis_x < 0 Then
        i = 1
    Else
        i = -1
    End If

    Dim pCornerPoint_x As Double = i * vAxis_y * radius + pBox_x + radius
    Dim pCornerPoint_y As Double = -i *vAxis_x * radius + pBox_y + radius

    ' ====================================================================================
    ' ================================================================= 第二部分: 阴影生成
    ' ---------------------------------- 数据准备:
    ' 计算角点-光源向量的单位向量
    Dim dCPL As Double = Shadow2D_CalcNorm(pCornerPoint_x - pLightSrc_x, pCornerPoint_y - pLightSrc_y)
    Dim vNorCPL_x As Double = 0
    Dim vNorCPL_y As Double = 1
    If Abs(dCPL) > 0.0000000000000001 Then
        vNorCPL_x = (pCornerPoint_x - pLightSrc_x) / dCPL
        vNorCPL_y = (pCornerPoint_y - pLightSrc_y) / dCPL
    End If

    ' 计算阴影始点和始长
    '   始长是角点-光源向量的模平方减去始点-光源向量的模平方开根号后取两倍
    Dim pStart_x As Double = pLightSrc_x + vNorCPL_x * dCPL
    Dim pStart_y As Double = pLightSrc_y + vNorCPL_y * dCPL
    Dim dStart As Double = Sqr(dCPL * dCPL - dAxis * dAxis) * 2

    ' 计算偏转角度
    Dim angle As Double = Shadow2D_CalcAngle(vAxis_x, vAxis_y, 1, 0)

    ' 计算变位和变长
    Dim cosTheta As Double = Shadow2D_CalcDot(vNorCPL_x, vNorCPL_y, vAxis_x, vAxis_y)
    If Abs(cosTheta) < 0.0000000000000001 Then
        cosTheta = 1
    End If
    Dim vStart_dx As Double = (spacingFac / cosTheta) * vNorCPL_x 
    Dim vStart_dy As Double = (spacingFac / cosTheta) * vNorCPL_y
    Dim dDStart As Double = spacingFac * dStart / dAxis

    ' ---------------------------------- 绘制阴影:
    ' 绘制阴影
	Dim bitmapId As Double

    Dim new_x As Double = 0
    Dim new_y As Double = 0
    Dim new_alpha_x As Double = 1
    Dim new_alpha_y As Double = 1
    Dim new_alpha_dCPL As Double = 1
    Dim new_alpha_bgo As Double = 0

    If dAxis <= (radius * 6.66) Then
        new_alpha_dCPL = dAxis / (radius * 6.66)
    End If

    new_alpha_bgo = Shadow2D_CalcClamp01(new_alpha_dCPL * 2)
	
    For i = 0 To picSplit - 1
		new_x = pStart_x + i * vStart_dx
		new_y = pStart_y + i * vStart_dy
		new_alpha_x = 1
		new_alpha_y = 1

		If new_x < 200 Then
			new_alpha_x = new_x / 200
		ElseIf new_x > 600 Then
			new_alpha_x = (800 - new_x) / 200
		End If

		If new_y < 200 Then
			new_alpha_y = new_y / 200
		ElseIf new_y > 400 Then
			new_alpha_y = (600 - new_y) / 200
		End If

		new_alpha_x = Shadow2D_CalcClamp01(new_alpha_x)
		new_alpha_y = Shadow2D_CalcClamp01(new_alpha_y)
		
		bitmapId = Shadow2D_PRIVATE_BmpId(sid, bid, i, group)
		Bitmap(bitmapId).hide = 0
		Bitmap(bitmapId).rotatang = angle + Pi
		Bitmap(bitmapId).attscreen = 1
		Bitmap(bitmapId).destx = new_x
		Bitmap(bitmapId).desty = new_y
		Bitmap(bitmapId).forecolor_a = alpha * new_alpha_dCPL * new_alpha_x * new_alpha_y * 255
		Bitmap(bitmapId).scaley = dStart + i * dDStart
		Bitmap(bitmapId).zpos = zpos
    Next
	
	Return new_alpha_bgo
End Script

' 碰撞箱为 AABB 矩形的 2D 阴影 (带衰减)
' @param sid: bitmap 索引 id 第一部分
' @param bid: bitmap 索引 id 第二部分
' @param group: bitmap 索引 id 第三部分
' @param picSplit: 阴影横纹条数
' @param spacingFac: 阴影间距
' @param pBox_x: 碰撞箱左上角点 x 坐标
' @param pBox_y: 碰撞箱左上角点 y 坐标
' @param pBox_w: 碰撞箱宽
' @param pBox_h: 碰撞箱高
' @param pLightSrc_x: 光源位置 x 坐标
' @param pLightSrc_y: 光源位置 y 坐标,
' @param attenuateStart: 衰减起点
' @param attenuateFac: 衰减因子
' @param alpha: 阴影透明度乘数
' @param zpos: 阴影横纹 zpos
' @return: 当前阴影透明度 (不受阴影透明度乘数影响的原始值) 若返回值小于 -1 则说明当前阴影在光源范围外
Export Script Shadow2D_AABBRect_WithAtten(sid As Integer, bid As Integer, group As Integer, picSplit As Integer, spacingFac As Double, pBox_x As Double, pBox_y As Double, box_w As Double, box_h As Double, pLightSrc_x As Double, pLightSrc_y As Double, attenuateStart As Double, attenuateFac As Double, alpha As Double, zpos As Double, Return Double)
    ' ====================================================================================
    ' ================================================================= 第一部分: 状态分析
    ' ---------------------------------- 状态定义:
    Dim pCornerPoint_x As Double = 0
    Dim pCornerPoint_y As Double = 0
    Dim vAxis_x As Double = 0
    Dim vAxis_y As Double = 0

    ' ---------------------------------- 判断条件:
    '   对于 2d 的 AABB 矩形框来说 一共有 11 个不同的投影状态 这里粗糙地采用 D2Q9 的方式划分
    '   矩形四个角点的坐标和中点坐标:
    Dim pA_x As Double = pBox_x
    Dim pA_y As Double = pBox_y
    Dim pB_x As Double = pBox_x + box_w
    Dim pB_y As Double = pBox_y
    Dim pC_x As Double = pBox_x + box_w
    Dim pC_y As Double = pBox_y + box_h
    Dim pD_x As Double = pBox_x
    Dim pD_y As Double = pBox_y + box_h
    Dim pCen_x As Double = pBox_x + (box_w * 0.5)
    Dim pCen_y As Double = pBox_y + (box_h * 0.5)
	Dim diameter As Double = Shadow2D_CalcNorm(box_w, box_h)
	
    ' ---------------------------------- 光源与矩形框相对位置分析:
	Dim i As Integer
    Dim inHorPos As Integer = 0
    Dim inVerPos As Integer = 0
    ' 与矩形框的水平相对位置: 1 0 3
    If pLightSrc_x > pB_x Then
        inHorPos = 3
    ElseIf pLightSrc_x < pA_x Then
        inHorPos = 1
    End If
    ' 与矩形框的垂直相对位置: 3 0 1
    If pLightSrc_y > pD_y Then
        inVerPos = 3
    ElseIf pLightSrc_y < pA_y Then
        inVerPos = 1
    End If

    ' ---------------------------------- 状态分析:
    ' 状态分析这里分为 11 种情况
    ' ----------------
    ' 在角落的情况:
    If 1 = inHorPos And 3 = inVerPos Then
        ' AC/C
        vAxis_x = Shadow2D_CalcAxis_x(pA_x, pA_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
        vAxis_y = Shadow2D_CalcAxis_y(pA_x, pA_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
        pCornerPoint_x = pC_x
        pCornerPoint_y = pC_y
    ElseIf 1 = inHorPos And 1 = inVerPos Then
        ' BD/D
        vAxis_x = Shadow2D_CalcAxis_x(pB_x, pB_y, pD_x, pD_y, pLightSrc_x, pLightSrc_y)
        vAxis_y = Shadow2D_CalcAxis_y(pB_x, pB_y, pD_x, pD_y, pLightSrc_x, pLightSrc_y)
        pCornerPoint_x = pD_x
        pCornerPoint_y = pD_y
    ElseIf 3 = inHorPos And 1 = inVerPos Then
        ' AC/C
        vAxis_x = Shadow2D_CalcAxis_x(pA_x, pA_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
        vAxis_y = Shadow2D_CalcAxis_y(pA_x, pA_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
        pCornerPoint_x = pC_x
        pCornerPoint_y = pC_y
    ElseIf inHorPos = 3 And inVerPos = 3 Then
        ' BD/D
        vAxis_x = Shadow2D_CalcAxis_x(pB_x, pB_y, pD_x, pD_y, pLightSrc_x, pLightSrc_y)
        vAxis_y = Shadow2D_CalcAxis_y(pB_x, pB_y, pD_x, pD_y, pLightSrc_x, pLightSrc_y)
        pCornerPoint_x = pD_x
        pCornerPoint_y = pD_y

    ' ----------------
    ' 在边缘的情况:
    ElseIf 0 = inHorPos And 0 <> inVerPos Then
        If inVerPos = 3 Then
            ' DC
            vAxis_x = Shadow2D_CalcAxis_x(pD_x, pD_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
            vAxis_y = Shadow2D_CalcAxis_y(pD_x, pD_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
            If pLightSrc_x < pCen_x Then
                ' C
                pCornerPoint_x = pC_x
                pCornerPoint_y = pC_y
            Else
                ' D
                pCornerPoint_x = pD_x
                pCornerPoint_y = pD_y
            End If
        Else
            ' AB
            vAxis_x = Shadow2D_CalcAxis_x(pA_x, pA_y, pB_x, pB_y, pLightSrc_x, pLightSrc_y)
            vAxis_y = Shadow2D_CalcAxis_y(pA_x, pA_y, pB_x, pB_y, pLightSrc_x, pLightSrc_y)
            If pLightSrc_x < pCen_x Then
                ' B
                pCornerPoint_x = pA_x
                pCornerPoint_y = pA_y
            Else
                ' A
                pCornerPoint_x = pB_x
                pCornerPoint_y = pB_y
            End If
        End If
    ElseIf 0 = inVerPos And 0 <> inHorPos Then
        If inHorPos = 3 Then
            ' BC/C
            vAxis_x = Shadow2D_CalcAxis_x(pB_x, pB_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
            vAxis_y = Shadow2D_CalcAxis_y(pB_x, pB_y, pC_x, pC_y, pLightSrc_x, pLightSrc_y)
            pCornerPoint_x = pC_x
            pCornerPoint_y = pC_y
        Else
            ' AD/D
            vAxis_x = Shadow2D_CalcAxis_x(pA_x, pA_y, pD_x, pD_y, pLightSrc_x, pLightSrc_y)
            vAxis_y = Shadow2D_CalcAxis_y(pA_x, pA_y, pD_x, pD_y, pLightSrc_x, pLightSrc_y)
            pCornerPoint_x = pD_x
            pCornerPoint_y = pD_y
        End If
        ' ----------------
    ' 在内部的情况
    Else
		For i = 0 To picSplit - 1
			Bitmap(Shadow2D_PRIVATE_BmpId(sid, bid, i, group)).hide = 1
		Next
		Dim dA As Double = Shadow2D_CalcDistance(pA_x, pA_y, pLightSrc_x, pLightSrc_y)
		Dim dB As Double = Shadow2D_CalcDistance(pB_x, pB_y, pLightSrc_x, pLightSrc_y)
		Dim dC As Double = Shadow2D_CalcDistance(pC_x, pC_y, pLightSrc_x, pLightSrc_y)
		Dim dD As Double = Shadow2D_CalcDistance(pD_x, pD_y, pLightSrc_x, pLightSrc_y)
		Dim dCen As Double = Shadow2D_CalcDistance(pCen_x, pCen_y, pLightSrc_x, pLightSrc_y)
		dA = Shadow2D_CalcMin(dA, dB, dC, dD)
		
		If dCen < dA Then
			dA = dCen
		End If

		If dA < (diameter * 1.4) Then
			Return dA / (diameter * 1.4)
		End If

		Return 1
    End If

    ' ====================================================================================
    ' ================================================================= 第二部分: 阴影生成
    ' ---------------------------------- 数据准备:
    ' 归一化中轴线
    Dim dAxis As Double = Shadow2D_CalcNorm(vAxis_x, vAxis_y)
    If 0.0000000000000001 < Abs(dAxis) Then
        vAxis_x = vAxis_x / dAxis
        vAxis_y = vAxis_y / dAxis
    Else
        vAxis_x = 0
        vAxis_y = 1
    End If

    ' 计算中点-光源向量到中轴的投影 vProj 和 角点-光源向量到中轴的投影 vProj2
    Dim vProj_x As Double = (pCen_x - pLightSrc_x) * vAxis_x * vAxis_x + (pCen_y - pLightSrc_y) * vAxis_y * vAxis_x
    Dim vProj_y As Double = (pCen_y - pLightSrc_y) * vAxis_y * vAxis_y + (pCen_x - pLightSrc_x) * vAxis_x * vAxis_y

    Dim vProj2_x As Double = (pCornerPoint_x - pLightSrc_x) * vAxis_x * vAxis_x + (pCornerPoint_y - pLightSrc_y) * vAxis_y * vAxis_x
    Dim vProj2_y As Double = (pCornerPoint_y - pLightSrc_y) * vAxis_y * vAxis_y + (pCornerPoint_x - pLightSrc_x) * vAxis_x * vAxis_y

    Dim dProj2 As Double = Shadow2D_CalcNorm(vProj2_x, vProj2_y)
    Dim dProj As Double = Shadow2D_CalcNorm(vProj_x, vProj_y)

    ' 计算角点-光源向量的单位向量
    Dim dCPL As Double = Shadow2D_CalcNorm(pCornerPoint_x - pLightSrc_x, pCornerPoint_y - pLightSrc_y)
    Dim vNorCPL_x As Double = 0
    Dim vNorCPL_y As Double = 1
    If Abs(dCPL) > 0.0000000000000001 Then
        vNorCPL_x = (pCornerPoint_x - pLightSrc_x) / dCPL
        vNorCPL_y = (pCornerPoint_y - pLightSrc_y) / dCPL
    End If

    Dim dPStartFac As Double = 1
    If Abs(dProj2) > 0.0000000000000001 Then
        dPStartFac = dCPL * dProj / dProj2
    End If

    ' 计算阴影始点和始长
    '   始长是角点-光源向量的模平方减去始点-光源向量的模平方开根号后取两倍
    Dim pStart_x As Double = pLightSrc_x + vNorCPL_x * dPStartFac
    Dim pStart_y As Double = pLightSrc_y + vNorCPL_y * dPStartFac
    Dim dStart As Double = Sqr(dPStartFac * dPStartFac - dProj * dProj) * 2

    ' 计算偏转角度
    Dim angle As Double = Shadow2D_CalcAngle(vAxis_x, vAxis_y, 1, 0)

    ' 计算变位和变长
    Dim cosTheta As Double = Shadow2D_CalcDot(vNorCPL_x, vNorCPL_y, vAxis_x, vAxis_y)
    If Abs(cosTheta) < 0.0000000000000001 Then
        cosTheta = 1
    End If
    Dim vStart_dx As Double = (spacingFac / cosTheta) * vNorCPL_x 
    Dim vStart_dy As Double = (spacingFac / cosTheta) * vNorCPL_y
    Dim dDStart As Double = 0

    If 0.0000000000000001 < Abs(dProj) Then
        dDStart = spacingFac * dStart / dProj
    End If

    ' ---------------------------------- 绘制阴影:
    ' 绘制阴影
	Dim bitmapId As Double

    Dim new_x As Double = 0
    Dim new_y As Double = 0
    Dim new_alpha_x As Double = 1
    Dim new_alpha_y As Double = 1
    Dim new_alpha_dCPL As Double = 1
    Dim new_alpha_bgo As Double = 0

    Dim dA As Double = Shadow2D_CalcDistance(pA_x, pA_y, pLightSrc_x, pLightSrc_y)
    Dim dB As Double = Shadow2D_CalcDistance(pB_x, pB_y, pLightSrc_x, pLightSrc_y)
    Dim dC As Double = Shadow2D_CalcDistance(pC_x, pC_y, pLightSrc_x, pLightSrc_y)
    Dim dD As Double = Shadow2D_CalcDistance(pD_x, pD_y, pLightSrc_x, pLightSrc_y)
	Dim dCen As Double = Shadow2D_CalcDistance(pCen_x, pCen_y, pLightSrc_x, pLightSrc_y)
    dA = Shadow2D_CalcMin(dA, dB, dC, dD)
	
	If dCen < dA Then
		dA = dCen
	End If

    If dA < (diameter * 1.4) Then
        new_alpha_dCPL = dA / (diameter * 1.4)
    End If

    new_alpha_bgo = Shadow2D_CalcClamp01(new_alpha_dCPL * 2)
	
    For i = 0 To picSplit - 1
		new_x = pStart_x + i * vStart_dx
		new_y = pStart_y + i * vStart_dy
		new_alpha_x = 1
		new_alpha_y = 1

		If new_x < 200 Then
			new_alpha_x = new_x / 200
		ElseIf new_x > 600 Then
			new_alpha_x = (800 - new_x) / 200
		End If

		If new_y < 200 Then
			new_alpha_y = new_y / 200
		ElseIf new_y > 400 Then
			new_alpha_y = (600 - new_y) / 200
		End If

        dCen = -attenuateFac * (spacingFac * i + dProj - attenuateStart) 
        dCen = Shadow2D_CalcClamp01(1 + dCen)

        If i = 0 And dCen < 0.0000000000000001 Then
            For i = 0 To picSplit - 1
                Bitmap(Shadow2D_PRIVATE_BmpId(sid, bid, i, group)).hide = 1
            Next
            Return -10
        End If

		new_alpha_x = Shadow2D_CalcClamp01(new_alpha_x)
		new_alpha_y = Shadow2D_CalcClamp01(new_alpha_y)
		
		bitmapId = Shadow2D_PRIVATE_BmpId(sid, bid, i, group)
		Bitmap(bitmapId).hide = 0
		Bitmap(bitmapId).rotatang = angle + Pi
		Bitmap(bitmapId).attscreen = 1
		Bitmap(bitmapId).destx = new_x
		Bitmap(bitmapId).desty = new_y
		Bitmap(bitmapId).forecolor_a = alpha * new_alpha_dCPL * new_alpha_x * new_alpha_y * dCen * 255
		Bitmap(bitmapId).scaley = dStart + i * dDStart
		Bitmap(bitmapId).zpos = zpos
    Next

	Return new_alpha_bgo
End Script

' 碰撞箱为圆形的 2D 阴影 (带衰减)
' @param sid: bitmap 索引 id 第一部分
' @param bid: bitmap 索引 id 第二部分
' @param group: bitmap 索引 id 第三部分
' @param picSplit: 阴影横纹条数
' @param spacingFac: 阴影间距
' @param pBox_x: 碰撞箱左上角点 x 坐标
' @param pBox_y: 碰撞箱左上角点 y 坐标
' @param radius: 碰撞箱 (圆) 半径
' @param pLightSrc_x: 光源位置 x 坐标
' @param pLightSrc_y: 光源位置 y 坐标
' @param attenuateStart: 衰减起点
' @param attenuateFac: 衰减因子
' @param alpha: 阴影透明度乘数
' @param zpos: 阴影横纹 zpos
' @return: 当前阴影透明度 (不受阴影透明度乘数影响的原始值) 若返回值小于 -1 则说明当前阴影在光源范围外
Export Script Shadow2D_HalfCircle_WithAtten(sid As Integer, bid As Integer, group As Integer, picSplit As Integer, spacingFac As Double, pBox_x As Double, pBox_y As Double, radius As Double, pLightSrc_x As Double, pLightSrc_y As Double, attenuateStart As Double, attenuateFac As Double, alpha As Double, zpos As Double, Return Double)
    Dim i As Integer
    radius = Abs(radius)
    If radius < 0.0000000000000001 Then
        For i = 0 To picSplit - 1
            Bitmap(Shadow2D_PRIVATE_BmpId(sid, bid, i, group)).hide = 1
        Next
        Return 1
    End If
    ' ====================================================================================
    ' ================================================================= 第一部分: 状态分析
    ' ---------------------------------- 状态定义:
    Dim vAxis_x As Double = pBox_x + radius - pLightSrc_x
    Dim vAxis_y As Double = pBox_y + radius - pLightSrc_y
    Dim dAxis As Double = Shadow2D_CalcNorm(vAxis_x, vAxis_y)
    If dAxis < radius * 0.66 Then
        For i = 0 To picSplit - 1
            Bitmap(Shadow2D_PRIVATE_BmpId(sid, bid, i, group)).hide = 1
        Next
        Return 0
    End If

    ' 归一化中轴线
    vAxis_x = vAxis_x / dAxis
    vAxis_y = vAxis_y / dAxis

    If vAxis_x < 0 Then
        i = 1
    Else
        i = -1
    End If

    Dim pCornerPoint_x As Double = i * vAxis_y * radius + pBox_x + radius
    Dim pCornerPoint_y As Double = -i *vAxis_x * radius + pBox_y + radius

    ' ====================================================================================
    ' ================================================================= 第二部分: 阴影生成
    ' ---------------------------------- 数据准备:
    ' 计算角点-光源向量的单位向量
    Dim dCPL As Double = Shadow2D_CalcNorm(pCornerPoint_x - pLightSrc_x, pCornerPoint_y - pLightSrc_y)
    Dim vNorCPL_x As Double = 0
    Dim vNorCPL_y As Double = 1
    If Abs(dCPL) > 0.0000000000000001 Then
        vNorCPL_x = (pCornerPoint_x - pLightSrc_x) / dCPL
        vNorCPL_y = (pCornerPoint_y - pLightSrc_y) / dCPL
    End If

    ' 计算阴影始点和始长
    '   始长是角点-光源向量的模平方减去始点-光源向量的模平方开根号后取两倍
    Dim pStart_x As Double = pLightSrc_x + vNorCPL_x * dCPL
    Dim pStart_y As Double = pLightSrc_y + vNorCPL_y * dCPL
    Dim dStart As Double = Sqr(dCPL * dCPL - dAxis * dAxis) * 2

    ' 计算偏转角度
    Dim angle As Double = Shadow2D_CalcAngle(vAxis_x, vAxis_y, 1, 0)

    ' 计算变位和变长
    Dim cosTheta As Double = Shadow2D_CalcDot(vNorCPL_x, vNorCPL_y, vAxis_x, vAxis_y)
    If Abs(cosTheta) < 0.0000000000000001 Then
        cosTheta = 1
    End If
    Dim vStart_dx As Double = (spacingFac / cosTheta) * vNorCPL_x 
    Dim vStart_dy As Double = (spacingFac / cosTheta) * vNorCPL_y
    Dim dDStart As Double = spacingFac * dStart / dAxis

    ' ---------------------------------- 绘制阴影:
    ' 绘制阴影
	Dim bitmapId As Double

    Dim new_x As Double = 0
    Dim new_y As Double = 0
    Dim new_alpha_x As Double = 1
    Dim new_alpha_y As Double = 1
    Dim new_alpha_dCPL As Double = 1
    Dim new_alpha_bgo As Double = 0

    If dAxis <= (radius * 6.66) Then
        new_alpha_dCPL = dAxis / (radius * 6.66)
    End If

    new_alpha_bgo = Shadow2D_CalcClamp01(new_alpha_dCPL * 2)
	
    For i = 0 To picSplit - 1
		new_x = pStart_x + i * vStart_dx
		new_y = pStart_y + i * vStart_dy
		new_alpha_x = 1
		new_alpha_y = 1

		If new_x < 200 Then
			new_alpha_x = new_x / 200
		ElseIf new_x > 600 Then
			new_alpha_x = (800 - new_x) / 200
		End If

		If new_y < 200 Then
			new_alpha_y = new_y / 200
		ElseIf new_y > 400 Then
			new_alpha_y = (600 - new_y) / 200
		End If

        dAxis = -attenuateFac * (spacingFac * i + dAxis - attenuateStart) 
        dAxis = Shadow2D_CalcClamp01(1 + dAxis)

        If i = 0 And dAxis < 0.0000000000000001 Then
            For i = 0 To picSplit - 1
                Bitmap(Shadow2D_PRIVATE_BmpId(sid, bid, i, group)).hide = 1
            Next
            Return -10
        End If

		new_alpha_x = Shadow2D_CalcClamp01(new_alpha_x)
		new_alpha_y = Shadow2D_CalcClamp01(new_alpha_y)
		
		bitmapId = Shadow2D_PRIVATE_BmpId(sid, bid, i, group)
		Bitmap(bitmapId).hide = 0
		Bitmap(bitmapId).rotatang = angle + Pi
		Bitmap(bitmapId).attscreen = 1
		Bitmap(bitmapId).destx = new_x
		Bitmap(bitmapId).desty = new_y
		Bitmap(bitmapId).forecolor_a = alpha * new_alpha_dCPL * new_alpha_x * new_alpha_y * dAxis * 255
		Bitmap(bitmapId).scaley = dStart + i * dDStart
		Bitmap(bitmapId).zpos = zpos
    Next
	
	Return new_alpha_bgo
End Script
' ====================================================================================