' ----------------------------------------------------- config
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

' ------------------------------------------- event

Dim __eventScriptName As String = ""
Dim __eventValue As String = ""
Dim __eventState As Long = 0

Export Script TextboxEvent_OnNext()
    Return __eventState And 1
End Script

Export Script TextboxEvent_OnChangeBox()
    Return __eventState And 2
End Script

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
Dim __animFac As Double = -1

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

Dim __box_tempIA As Long = 0
Dim __box_tempIB As Long = 0
Dim __box_tempIC As Long = 0
Dim __box_tempID As Long = 0
Dim __box_tempIE As Long = 0
Dim __box_tempIF As Long = 0
Dim __box_tempIN As Long = 0
Dim __box_tempDA As Double = 0
Dim __box_tempDB As Double = 0

Dim __isCreated As Integer = 0

' 设置动画参数偏移量
' @param msgBox 对话框的动画参数偏移量
' @param avatar 头像的动画参数偏移量
Export Script Textbox_SetAnimFacOffset(msgBox As Double, avatar As Double)
    __animFacOffset_msgBox = msgBox
    __animFacOffset_avatar = avatar
End Script

' 直接设置九宫格 npc id (可以用于快速修改头像表情, 没有任何过渡动画, 也不支持改变头像大小)
' @param npcId 头像的 npc id
' @param srcX srcX
' @param srcY srcY
Export Script Textbox_SetSet9GridNpcIdImm(npcId As Long, srcX As Integer, srcY As Integer, Return Integer)
    __msg_9Grid_npcId = npcId
    If __isCreated = 0 Then
        Return 0
    End If

    For __box_tempIN = 1 To 9 Step 1
        Bitmap(__msg_bmpIdStart + __box_tempIN).scrid = __msg_9Grid_npcId
        Bitmap(__msg_bmpIdStart + __box_tempIN).scrx = srcX
        Bitmap(__msg_bmpIdStart + __box_tempIN).scry = srcY
    Next
    Return 1
End Script

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

Export Script Textbox_StoreMsgShape(x As Integer, y As Integer, w As Integer, h As Integer)
    __msg_pX_param_cache = x
    __msg_pY_param_cache = y
    __msg_sW_param_cache = w
    __msg_sH_param_cache = h
End Script

Export Script Textbox_StoreMsgFromShape(x As Integer, y As Integer, w As Integer, h As Integer)
    __msg_from_pX_param_cache = x
    __msg_from_pY_param_cache = y
    __msg_from_sW_param_cache = w
    __msg_from_sH_param_cache = h
End Script

Export Script Textbox_StoreAvatar(npcId As Long, srcX As Integer, srcY As Integer, srcW As Integer, srcH As Integer)
    __msg_avatar_npcId_param_cache = npcId
    __msg_avatar_srcX_param_cache = srcX
    __msg_avatar_srcY_param_cache = srcY
    __msg_avatar_srcW_param_cache = srcW
    __msg_avatar_srcH_param_cache = srcH
End Script

Export Script Textbox_StoreAvatarShape(x As Integer, y As Integer, w As Integer, h As Integer)
    __msg_avatar_pX_param_cache = x
    __msg_avatar_pY_param_cache = y
    __msg_avatar_sW_param_cache = w
    __msg_avatar_sH_param_cache = h
End Script

Export Script Textbox_StoreAvatarFromShape(x As Integer, y As Integer, w As Integer, h As Integer)
    __msg_from_avatar_pX_param_cache = x
    __msg_from_avatar_pY_param_cache = y
    __msg_from_avatar_sW_param_cache = w
    __msg_from_avatar_sH_param_cache = h
End Script

Export Script Textbox_Submit(txt As String, animStartFac As Double)
    If txt = "" Then
        Call TextBoxLowLevel_SetWidth(-1)
        Call TextBoxLowLevel_LoadString(txt)
    Else
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

Export Script Textbox_SetAvatarImm(npcId As Long, srcX As Integer, srcY As Integer, srcW As Integer, srcH As Integer)
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

        If __animFac < 0 And __animFac + __msg_animSpeed >= 0 Then
            __eventState = __eventState And 2
            Call __textbox_inner_setAvatar()
            If __eventScriptName <> "" Then
                Call EXEScript(__eventScriptName)
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
        Bitmap(__msg_bmpIdStart).destx = __box_tempIE
        Bitmap(__msg_bmpIdStart).desty = __box_tempIF

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
        Bitmap(__msg_bmpIdStart + __box_tempIN).forecolor_a = __box_tempDB * 255

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

Do
    __eventState = 0
    Call __textbox_inner_refreshBg()
    If __animFac < -2 Then
        Call TextBoxLowLevel_DrawNext()
    End If
    Call Sleep(1)
Loop
