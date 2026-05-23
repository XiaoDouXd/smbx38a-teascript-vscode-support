' 风线条脚本 用于实时生成风的风格化表达
' 该脚本依赖 libLine.smt 函数集
'                           ---- 小豆 20230204

' ==================================================================== 线条 id 寄存

Dim bitmapStartIdx As Long = 50000              ' 线条数据用 bitmap 起始 id, 不要与其它 bitmap 重复!
Dim lineCount As Long = 8                       ' 线条数量
Dim vertCount As Long = 40                      ' 每条线顶点数
Dim dustCount As Long = 10                      ' 尘埃数量
Dim lineDuration As Long = 1000                 ' 线条持续时长 (会随机上下波动)

Dim screenPosX As Double = Sysval(Player1scrX)
Dim screenPosY As Double = Sysval(Player1scrY)
Dim globalWindAlpha As Double = 1

' bitmap id 分配策略为 bitmapStartId + [0, lineCount + dustCount - 1]
' bitmap 的一些字段拿来做以下用:
'       bitmap().destx -> 上一终点 x 值
'       bitmap().desty -> 上一终点 y 值
'       bitmap().rotatang -> 透明度
'       bitmap().srcid -> 线条 id
'       bitmap().scaleX -> 线条当前走过的时间帧 (每帧+1)
'       bitmap().scaleY -> 线条当前的随机种子

' ==================================================================== 初始化

Dim stdIdx As Long = 0
Dim stdIdx2 As Long = 0
Dim stdLineIdx As Long = 0
Dim pX As Double = 0
Dim pY As Double = 0

Dim inited As Byte = 0

Do
    If timeMgr_now() = 50 Then
        ' 申请 bitmap
        For stdIdx = bitmapStartIdx To bitmapStartIdx + lineCount - 1
            Call BMPCreate(stdIdx, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, -1)
            Bitmap(stdIdx).hide = 1
            Bitmap(stdIdx).scrid = libLine_allocateLine(vertCount)
			Bitmap(stdIdx).rotatang = -2
            Call libLine_setNpc(Bitmap(stdIdx).scrid, 45)
        Next
        inited = 1
    End If

    If globalWindAlpha > 0 And inited = 1 Then
        screenPosX = Sysval(Player1scrX)
        screenPosY = Sysval(Player1scrY)

        For stdIdx = bitmapStartIdx To bitmapStartIdx + lineCount - 1
            stdLineIdx = Bitmap(stdIdx).scrid
            If Bitmap(stdIdx).rotatang > -1 Then
                pX = Bitmap(stdIdx).destx
                pY = Bitmap(stdIdx).desty

                pY += Bitmap(stdIdx).scaley * sin(Bitmap(stdIdx).scalex * 0.1 + 10 * Bitmap(stdIdx).scaley) * 50
                pX += 20 + sin(Bitmap(stdIdx).scalex * Bitmap(stdIdx).scaley * 5) * 2

                Call libLine_pushPoint(stdLineIdx, pX, pY)
                Call libLine_setWidth(stdLineIdx, 5)
                Call libLine_setSegmentScale(stdLineIdx, 1.5)
				Call libLine_setStep(stdLineIdx, 1)
                Call libLine_setSrcWidth(stdLineIdx, 1)
                Call libLine_setAlpha(stdLineIdx, -32 * (1 - cos(Pi * (1 - abs(Bitmap(stdIdx).rotatang)))))
				Call libLine_setLoss(stdLineIdx, -0.5)
				Call libLine_setLossOffset(stdLineIdx, 0)
				Call libLine_setLossInfMul(stdLineIdx, 1)
                Bitmap(stdIdx).scalex += 1
                Bitmap(stdIdx).rotatang -= 0.02
				Bitmap(stdIdx).destx = pX
            ElseIf rnd > 0.985 Then
                Bitmap(stdIdx).scalex = 0
                Bitmap(stdIdx).scaley = rnd

                pX = screenPosX - rnd * 100 - 300
                pY = screenPosY + 600 * rnd

                For stdIdx2 = 0 To vertCount - 1
                    Call libLine_setPoint(stdLineIdx, stdIdx2, 0, 0)
                Next
                Bitmap(stdIdx).destx = pX
                Bitmap(stdIdx).desty = pY
				Call libLine_setAlpha(stdLineIdx, 0)
                Bitmap(stdIdx).rotatang = 1
			Else
				Call libLine_setAlpha(stdLineIdx, 0)
            End If
        Next
    End If
    Call Sleep(1)
Loop

