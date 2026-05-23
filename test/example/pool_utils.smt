' ====================================================================================
' ================================================================= 内存池相关方法集示例
' 前言:
' 使用该方法集一定要先在变量列表预声明以下两个数组参数:
' 1. PUinstancePool: 用于存放实例  id
' 2. PUidRec: 用于记录一次循环已分配的内存
'                                                                   -- xiaodou 202209

' ====================================================================================
' ================================================================= 方法定义
' ---------------------------------------- 初始化数据
Dim allInstCount As Integer = 0
Dim usedCount As Integer = 0
' ---------------------------------------- 临时变量
Dim tempA As Integer = 0
Dim tempB As Integer = 0
Dim i As Integer = 0
Dim rndId As Integer = 0
Dim tempItrIdx As Integer = 0
Dim tempItrCount As Integer = 0

' 初始化池
' @param count: 池内元素最大量
Export Script PoolUtils_Init(count As Integer)
	allInstCount = count
	
	Call ReDim(0, PUinstancePool, allInstCount)
	Call ReDim(0, PUidRec, allInstCount)
End Script

' 随机获取空闲实例索引
' @return: 随机索引
Export Script PoolUtils_RndIdx(Return Integer)
	Dim o As Integer = Int(Rnd() * allInstCount)
	If o = allInstCount Then
		Return 0
	Else
		Return o
	End If
End Script

' 获取空闲实例
' @return: 实例 id
Export Script PoolUtils_GetInstance(Return Integer)
	rndId = PoolUtils_RndIdx()
	If rndId < 0 Or rndId >= allInstCount Then
		Return -1
	End If
	
	tempA = Array(PUinstancePool(rndId))
	tempB = Array(PUidRec(rndId))
	
	If usedCount = allInstCount Then
		Return tempA
	End If
	
	usedCount += 1
	
	tempB = Array(PUidRec(rndId))
	tempA = Array(PUinstancePool(rndId))
	If tempB < 0 Then
		Array(PUidRec(rndId)) = 1
		Return tempA
	End If
	
	For i = 0 To allInstCount - 1
		If rndId < allInstCount Then
			rndId += 1
		Else
			rndId = 0
		End If
		tempB = Array(PUidRec(rndId))
		tempA = Array(PUinstancePool(rndId))
		If tempB < 0 Then
			Array(PUidRec(rndId)) = 1
			Return tempA
		End If
	Next
	Return -1
End Script

' 回收实例
' @param instId: 要回收的实例 id
Export Script PoolUtils_RecInstance(instId As Integer)
	For i = 0 To allInstCount - 1
		If Array(PUinstancePool(i)) = instId Then
			Array(PUidRec(i)) = -1
			usedCount -= 1
			Return
		End If
	Next
End Script

' 清空实例
' @param instId: 要回收的实例 id
Export Script PoolUtils_ClcInstance()
	usedCount = 0
	For i = 0 To allInstCount - 1
		Array(PUidRec(i)) = -1
	Next
End Script

' 初始化池对象
' @param count: 池内元素最大量
Export Script PoolUtils_InitInst(idx As Integer, instId As Integer)
	If idx < 0 Or idx >= allInstCount Then
		Return
	End If
	Array(PUinstancePool(idx)) = instId
	Call PoolUtils_ClcInstance()
End Script

' 根据索引获取实例 id
' @param idx: 索引
Export Script PoolUtils_GetInstanceByIdx(idx As Integer, Return Integer)
	If idx >= 0 Or idx < allInstCount Then
		Return Array(PUinstancePool(idx))
	End If
	Return -1
End Script

' 根据索引获取实例 id 的使用情况
' @param idx: 索引
Export Script PoolUtils_GetUsageByIdx(idx As Integer, Return Integer)
	If idx >= 0 Or idx < allInstCount Then
		Return Array(PUidRec(idx))
	End If
	Return -1
End Script

' 迭代正在使用的实例
' @return 实例 id 每完成一个迭代循环 会返回一次 -1
Export Script PoolUtils_ItrUsageInstance(Return Integer)
	If usedCount = 0 Then
		tempItrCount = 0
		tempItrIdx = 0
		Return -1
	End If
	
	If tempItrIdx = allInstCount Or tempItrCount = usedCount Then
		tempItrIdx = 0
		tempItrCount = 0
		Return -1
	End If
	
	For i = tempItrIdx To allInstCount
		If i = allInstCount Then
			tempItrIdx = 0
			tempItrCount = 0
			Return -1
		End If
		
		If Array(PUidRec(i)) > 0 Then
			tempItrIdx = i + 1
			tempItrCount += 1
			Return Array(PUinstancePool(i))
		End If
	Next
	
	Return -1
End Script