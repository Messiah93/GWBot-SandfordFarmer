Local $M93_RENDERINGENABLED = true

Func M93_CountFreeSlots ($NumOfBags = 4)
   Local $FreeSlots, $Slots

   For $Bag = 1 to $NumOfBags
	  $Slots += DllStructGetData(GetBag($Bag), 'Slots')
	  $Slots -= DllStructGetData(GetBag($Bag), 'ItemsCount')
   Next

   Return $Slots
EndFunc

; func M93_GetNumberOfFoesInRangeOfAgent ($aAgent = -2, $aRange = 1000, $Other = false)
    ; local $lAgent, $lDistance
    ; local $lCount = 0, $lAgentArray = GetAgentArray(0xDB)
    ; if not IsDllStruct($aAgent) then $aAgent = GetAgentByID($aAgent)
    ; for $i = 1 to $lAgentArray[0]
        ; $lAgent = $lAgentArray[$i]
        ; if BitAND(DllStructGetData($lAgent, 'typemap'), 262144) then continueloop
        ; if DllStructGetData($lAgent, 'Allegiance') <> 3 then continueloop
        ; if DllStructGetData($lAgent, 'HP') <= 0 then continueloop
        ; if BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 then continueloop
        
        ; local $AgentName = GetAgentName($lAgent)
        
        ; if StringInStr($AgentName, "Spirit") <> 0 Then ContinueLoop
        
        ; if not $Other then
            ; if StringInStr($AgentName, "Yeti") <> 0 Then ContinueLoop
            ; if GetIsBoss($lAgent) then continueloop
            ; if StringInStr($AgentName, "Oni") <> 0 Then ContinueLoop
        ; endif
        
        ; $lDistance = GetDistance($lAgent)
        ; if $lDistance > $aRange then continueloop
      
        ; $lCount += 1
    ; next
    
    ; return $lCount
; endfunc

Func M93_GetNumberOfFoesInRangeOfAgent ($aAgent = -2, $aRange = 1250)
	Local $lAgent, $lDistance
	Local $lCount = 0

	If Not IsDllStruct($aAgent) Then $aAgent = GetAgentByID($aAgent)

	For $i = 1 To GetMaxAgents()
		$lAgent = GetAgentByID($i)
		; If BitAND(DllStructGetData($lAgent, 'typemap'), 262144) Then ContinueLoop
		If DllStructGetData($lAgent, 'Type') <> 0xDB Then ContinueLoop
		If DllStructGetData($lAgent, 'Allegiance') <> 3 Then ContinueLoop

		If DllStructGetData($lAgent, 'HP') <= 0 Then ContinueLoop
		If BitAND(DllStructGetData($lAgent, 'Effects'), 0x0010) > 0 Then ContinueLoop
		$lDistance = GetDistance($lAgent)

		If $lDistance > $aRange Then ContinueLoop
		$lCount += 1
	Next
	Return $lCount
 EndFunc
 
func M93_GetMaxHealth ($Agent = -2)
    if IsDllStruct($Agent) = 0 then
        $Agent = GetAgentByID($Agent)
    endif
    
    return DllStructGetData($Agent, 'MaxHP')
endfunc

func M93_GetHealthPercentage ($Agent = -2)
    $AgentMaxHealth = M93_GetMaxHealth($Agent)
    $AgentHealth = GetHealth($Agent)
    
    return Floor(($AgentHealth / $AgentMaxHealth) * 100)
endfunc

func M93_PickUpLoot ($Distance = 2500)
    local $lMe
    local $lBlockedTimer
    local $lBlockedCount = 0
    local $lItemExists = true
    local $lItemCount = 0
   
    for $i = 1 to GetMaxAgents()
        $lMe = GetAgentByID(-2)
        if DllStructGetData($lMe, 'HP') <= 0.0 then return
        $lAgent = GetAgentByID($i)
        if not GetIsMovable($lAgent) then continueloop
        if not GetCanPickUp($lAgent) then continueloop
        $lItem = GetItemByAgentID($i)
        if CanPickUp($lItem) then
            if GetDistance($lAgent) <= $Distance then
                do
                    if GetIsDead(-2) then return 
                    PickUpItem($lItem)
                    $lItemCount += 1
                    Sleep(GetPing())
                    do
                        Sleep(100)
                        $lMe = GetAgentByID(-2)
                    until DllStructGetData($lMe, 'MoveX') == 0 and DllStructGetData($lMe, 'MoveY') == 0
                    
                    $lBlockedTimer = TimerInit()
                    do
                        Sleep(3)
                        $lItemExists = IsDllStruct(GetAgentByID($i))
                    until not $lItemExists or TimerDiff($lBlockedTimer) > Random(5000, 7500, 1)
                    
                    if $lItemExists then $lBlockedCount += 1
                until not $lItemExists or $lBlockedCount > 5
            endif
        endif
    next
   
    if $lItemCount > 0 then
        return true
    else
        return false
    endif
endfunc

Func M93_UseSkillEx ($lSkill, $lTgt = -2, $aTimeout = 3000)
    If GetIsDead(-2) Then Return
    If Not IsRecharged($lSkill) Then Return
    Local $Skill = GetSkillByID(GetSkillBarSkillID($lSkill, 0))
    Local $Energy = StringReplace(StringReplace(StringReplace(StringMid(DllStructGetData($Skill, 'Unknown4'), 6, 1), 'C', '25'), 'B', '15'), 'A', '10')
    If GetEnergy(-2) < $Energy Then Return
    Local $lAftercast = DllStructGetData($Skill, 'Aftercast')
    Local $lDeadlock = TimerInit()
    UseSkill($lSkill, $lTgt)
    Do
	    Sleep(50)
	    If GetIsDead(-2) = 1 Then Return
	    Until (Not IsRecharged($lSkill)) Or (TimerDiff($lDeadlock) > $aTimeout)
    Sleep($lAftercast * 1000)
EndFunc

Func M93_PurgeEngineHook ()
   If $M93_RENDERINGENABLED = False Then
	  M93_EnableRendering()
	  Sleep(Random(2000, 2500))
	  M93_DisableRendering()
	  M93_ClearMemory()
   EndIf
EndFunc

Func M93_ToggleRendering()
	If $M93_RENDERINGENABLED Then
		M93_DisableRendering()
		M93_ClearMemory()
	Else
        M93_EnableRendering()
	EndIf
EndFunc

Func M93_EnableRendering ()
	MemoryWrite($mDisableRendering, 0)
    WinSetState(GetWindowHandle(), "", @SW_SHOW)
    
    $M93_RENDERINGENABLED = true
EndFunc

Func M93_DisableRendering ()
	MemoryWrite($mDisableRendering, 1)
    WinSetState(GetWindowHandle(), "", @SW_HIDE)
    
    $M93_RENDERINGENABLED = false
EndFunc

Func M93_ClearMemory ()
	DllCall($mKernelHandle, 'int', 'SetProcessWorkingSetSize', 'int', $mGWProcHandle, 'int', -1, 'int', -1)
EndFunc

Func M93_ReduceMemory ()
	If $GWPID <> -1 Then
		Local $AI_HANDLE = DllCall("kernel32.dll", "int", "OpenProcess", "int", 2035711, "int", False, "int", $GWPID)
		Local $AI_RETURN = DllCall("psapi.dll", "int", "EmptyWorkingSet", "long", $AI_HANDLE[0])
		DllCall("kernel32.dll", "int", "CloseHandle", "int", $AI_HANDLE[0])
	Else
		Local $AI_RETURN = DllCall("psapi.dll", "int", "EmptyWorkingSet", "long", -1)
	EndIf
	Return $AI_RETURN[0]
EndFunc

Func M93_UseItemByBagSlotID ($bagslotid)
    for $BagID = 1 to 4
        $BagHandle = GetBag($BagID)
        for $BagSlot = 1 to DllStructGetData($BagHandle, "Slots")
            $BagItem = GetItemBySlot($BagHandle, $BagSlot)
            if DllStructGetData($BagItem, "ModelID") == $bagslotid then
                UseItem($BagItem)
                return
            else
                continueLoop
            endif
        next
    next
endfunc