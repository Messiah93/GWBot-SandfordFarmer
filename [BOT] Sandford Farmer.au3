#NoTrayIcon

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GuiComboBox.au3>
#include <GuiEdit.au3>
#include <ScrollBarsConstants.au3>
#include <Array.au3>
#include "lib/GWA2.au3"
#include "lib/GWC_M93_API.au3"


global $BOTVersion = "v0.06"

global $AscalonMapID = 148
global $AshfordMapID = 164
global $FoiblesFairMapID = 165
global $BarradinMapID = 163
global $FortRanikMapID = 166

global $LakeSideMapID = 146
global $GreenHillsMapID = 160
global $RegentValleyMapID = 162
global $WizzardFollyMapID = 161
global $CatacombsMapID = 145

global $MapRegionIDList = [2, 2, 2, 2, 2, 2, 2, -2, 1, 3, 4]
global $MapLanguageIDList = [0, 2, 3, 4, 5, 9, 10, 0, 0, 0, 0]

global $GoldsID = 2511
global $RedIrisID = 2994
global $SummoningStoneModelID = 30847

global $SandFordIDs = [422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433]
global $ExtraConsumablesIDs = [31145, 21809, 21810, 31149, 26784, 910, 31150, 21813]
global $ExtraEventIDs = [36682, 22269, 36681, 28435, 35124, 36683, 21812, 18345]
global $HalloweenIDs = [28431, 28432, 6368, 28433, 6369, 15837, 28434, 6367, 6049]
global $LuckyIDs = [22191, 22190]
global $PirateIDs = [30855]
global $SpecialIDs = [28435, 28436]
global $SweetIDs = [22644, 22752]
global $WayfarerIDs = [37765]
global $WintersdayIDs = [556, 6375, 30648, 21492, 31022, 6376]
global $ExtraItemsIDs = [2511, 146, 18721, 16453]


global $CharacterName = ""
global $CurrentFarm = ""
global $LootRedIris = false
global $BOTRunning = false
global $FarmTimeoutReference = 0
global $CurrentFarmTimer


func GUI_Setup ()
    AutoItSetOption("TrayMenuMode", 3)
    AutoItSetOption("TrayAutoPause", 0)
    AutoItSetOption("TrayOnEventMode", 1)
    
    Opt("GUIOnEventMode", true)
    Opt("GUICloseOnESC", false)
    
    global $MainForm = GUICreate("SandFord Farmer " & $BOTVersion & " by Messiah93", 368, 280, 431, 221)
    
    global $CharacterList = GUICtrlCreateCombo("", 16, 16, 337, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
    GUICtrlSetData(-1, GetLoggedCharNames())
    
    global $FarmList = GUICtrlCreateCombo("", 16, 48, 337, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
    GUICtrlSetData(-1, "Red Iris Flower|Grawl Necklaces|Unnatural Seeds|Baked Husks|Spider Legs|Icy Lodestones|Skeletal Limbs|Dull Carapaces|Enchanted Lodestones|Worn Belts|Gargoyle Skulls|Charr Carvings|Skale Fins")
    
    global $StartPauseButton = GUICtrlCreateButton("Start", 16, 80, 163, 25)
    GUICtrlSetOnEvent(-1, "GUI_OnStartPause")
    
    global $ToggleRenderingButton = GUICtrlCreateButton("Toggle Rendering", 192, 80, 163, 25)
    GUICtrlSetOnEvent(-1, "GUI_OnToggleRendering")
    
    global $Console = GUICtrlCreateEdit("", 16, 120, 337, 145, BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_REAdoNLY,$ES_WANTreturn,$WS_VSCROLL))
    
    GUISetOnEvent($GUI_EVENT_CLOSE, "GUI_OnExit")
    
    GUI_ConsoleAppend("Choose a character and farm and hit 'start' button.")
    
    GUISetState(@SW_SHOW)
endfunc

func GUI_OnStartPause ()
    $CharacterName = GUICtrlRead($CharacterList)
    $CurrentFarm = GUICtrlRead($FarmList)
    
    GUICtrlSetState($CharacterList, $GUI_DISABLE)
    GUICtrlSetState($FarmList, $GUI_DISABLE)
    
    if $BOTRunning == false then
        $BOTRunning = true
        
        GUICtrlSetData($StartPauseButton, "Pause")
    else
        $BOTRunning = false
        
        GUICtrlSetData($StartPauseButton, "UnPause")
    endif
endfunc

func GUI_ConsoleAppend ($txt)
    GUICtrlSetData($Console, GUICtrlRead($Console) & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "]" & " " & $txt & @CRLF)
    _GUICtrlEdit_Scroll($Console, $SB_SCROLLCARET)
    _GUICtrlEdit_Scroll($Console, $SB_LINEUP)
endfunc

func GUI_OnToggleRendering ()
    M93_ToggleRendering()
endfunc

func GUI_OnExit ()
    exit
endfunc

func Main ()
    GUI_Setup()
    
    while not $BOTRunning
        RandomSleep(350, 650)
    wend
    
    if not Initialize($CharacterName, true) then
        MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $CharacterName & "'.")
        exit
    endif
    
    if M93_GetInventoryItemByModelID($SummoningStoneModelID) == null then
        if $CurrentFarm <> "Red Iris Flower" then
            SendChat("bonus", "/")
            RandomSleep(750, 1250)
            
            if not M93_GetInventoryItemByModelID($SummoningStoneModelID) == null then
                MsgBox(0, "Warning", "You do not seem to own Summoning Stone for help you, the farm can become very hard without it and can fail. Try to hit /bonus for retrieve it if you have it on your account.")
            endif
        endif
    endif
    
    MainLoop()
endfunc

func MainLoop ()
    while true
        while not $BOTRunning
            RandomSleep(450, 550)
        wend
        
        switch $CurrentFarm
            case "Red Iris Flower"
                $LootRedIris = true
                $FarmTimeoutReference = 0
                
                GoToAshford()
                
                $LeavedOutpost = LeaveAshfordToLakeSide()
                if not $LeavedOutpost then
                    continueloop
                endif
                
                $CurrentFarmTimer = TimerInit()
                
                FarmingRedIris()
                
                GoToAshford()
            case "Gargoyle Skulls"
                $LootRedIris = false
                $FarmTimeoutReference = 600000
                
                GoToAshford()
                
                $LeavedOutpost = LeaveAshfordToCatacombs()
                if not $LeavedOutpost then
                    continueloop
                endif
                
                $CurrentFarmTimer = TimerInit()
                
                FarmingGargoyleSkulls()
                
                GoToAshford()
            case "Icy Lodestones"
                $LootRedIris = false
                $FarmTimeoutReference = 900000
                
                GoToFoiblesFair()
                
                $LeavedOutpost = LeaveFoiblesFair()
                if not $LeavedOutpost then
                    continueloop
                endif
                
                $CurrentFarmTimer = TimerInit()
                
                FarmingIcyLodestones()
                
                GoToFoiblesFair()
            case "Worn Belts"
                $LootRedIris = false
                $FarmTimeoutReference = 600000
                
                GoToAshford()
                
                $LeavedOutpost = LeaveAshfordToLakeSide()
                if not $LeavedOutpost then
                    continueloop
                endif
                
                $CurrentFarmTimer = TimerInit()
                
                FarmingWornBelts()
                
                GoToAshford()
            case "Unnatural Seeds"
                $LootRedIris = false
                $FarmTimeoutReference = 900000
                
                GoToBarradin()
                
                $LeavedOutpost = LeaveBarradin()
                if not $LeavedOutpost then
                    continueloop
                endif
                
                $CurrentFarmTimer = TimerInit()
                
                FarmingUnnaturalSeedsAndEnchantedLodestones()
                
                GoToBarradin()
            case "Enchanted Lodestones"
                $LootRedIris = false
                $FarmTimeoutReference = 900000
                
                GoToBarradin()
                
                $LeavedOutpost = LeaveBarradin()
                if not $LeavedOutpost then
                    continueloop
                endif
                
                $CurrentFarmTimer = TimerInit()
                
                FarmingUnnaturalSeedsAndEnchantedLodestones()
                
                GoToBarradin()
            case "Spider Legs"
                $LootRedIris = false
                $FarmTimeoutReference = 900000
                
                GoToFortRanik()
                
                $LeavedOutpost = LeaveFortRanik()
                if not $LeavedOutpost then
                    continueloop
                endif
                
                $CurrentFarmTimer = TimerInit()
                
                FarmingSpiderLegs()
                
                GoToFortRanik()
            case "Skale Fins"
                $LootRedIris = false
                $FarmTimeoutReference = 900000
                
                GoToAscalon()
                
                $LeavedOutpost = LeaveAscalon()
                if not $LeavedOutpost then
                    continueloop
                endif
                
                $CurrentFarmTimer = TimerInit()
                
                FarmingSkaleFins()
                
                GoToAscalon()
            case "Skeletal Limbs"
                $LootRedIris = false
                $FarmTimeoutReference = 600000
                
                GoToAshford()
                
                $LeavedOutpost = LeaveAshfordToCatacombs()
                if not $LeavedOutpost then
                    continueloop
                endif
                
                $CurrentFarmTimer = TimerInit()
                
                FarmingSkeletalLimbs()
                
                GoToAshford()
            case "Baked Husks"
                $LootRedIris = false
                $FarmTimeoutReference = 600000
                
                GoToAshford()
                
                $LeavedOutpost = LeaveAshfordToLakeSide()
                if not $LeavedOutpost then
                    continueloop
                endif
                
                $CurrentFarmTimer = TimerInit()
                
                FarmingBakedHusks()
                
                GoToAshford()
            case "Grawl Necklaces"
                $LootRedIris = false
                $FarmTimeoutReference = 600000
                
                GoToAscalon()
                
                $LeavedOutpost = LeaveAscalon()
                if not $LeavedOutpost then
                    continueloop
                endif
                
                $CurrentFarmTimer = TimerInit()
                
                FarmingGrawlNecklaces()
                
                GoToAscalon()
            case "Dull Carapaces"
                $LootRedIris = false
                $FarmTimeoutReference = 900000
                
                GoToAscalon()
                
                $LeavedOutpost = LeaveAscalon()
                if not $LeavedOutpost then
                    continueloop
                endif
                
                $CurrentFarmTimer = TimerInit()
                
                FarmingDullCarapaces()
                
                GoToAscalon()
            case else
                MsgBox(0, "Error", "Sorry, the farm '" & $CurrentFarm & "' is not yet scripted.")
                exitloop
        endswitch
    wend
endfunc

func GoToAscalon ()
    if GetMapID() == $AscalonMapID then
        return
    endif
    
    RandomTravelTo($AscalonMapID)
    
    RandomSleep(2000, 3000)
endfunc

func GoToAshford ()
    if GetMapID() == $AshfordMapID then
        return
    endif
    
    RandomTravelTo($AshfordMapID)
    
    RandomSleep(2000, 3000)
endfunc

func GoToFoiblesFair ()
    if GetMapID() == $FoiblesFairMapID then
        return
    endif
    
    RandomTravelTo($FoiblesFairMapID)
    
    RandomSleep(2000, 3000)
endfunc

func GoToBarradin ()
    if GetMapID() == $BarradinMapID then
        return
    endif
    
    RandomTravelTo($BarradinMapID)
    
    RandomSleep(2000, 3000)
endfunc

func GoToFortRanik ()
    if GetMapID() == $FortRanikMapID then
        return
    endif
    
    RandomTravelTo($FortRanikMapID)
    
    RandomSleep(2000, 3000)
endfunc

func LeaveAscalon ()
    if GetMapID() <> $AscalonMapID then
        return false
    endif
    
    MoveTo(8000, 6330)
    Move(7100, 5400)
    
    $LeavingTimeoutTimer = TimerInit()
    while GetMapID() <> $LakeSideMapID
        Sleep(500)
        
        if TimerDiff($LeavingTimeoutTimer) > 10000 then
            return false
        endif
    wend
    
    RandomSleep(2500, 7500)
    
    return true
endfunc

func LeaveAshfordToLakeSide ()
    if GetMapID() <> $AshfordMapID then
        return false
    endif
    
    MoveTo(-11594, -6291)
    Move(-11005, -6210)
    
    $LeavingTimeoutTimer = TimerInit()
    while GetMapID() <> $LakeSideMapID
        Sleep(500)
        
        if TimerDiff($LeavingTimeoutTimer) > 10000 then
            return false
        endif
    wend
    
    RandomSleep(2500, 7500)
    
    return true
endfunc

func LeaveAshfordToCatacombs ()
    if GetMapID() <> $AshfordMapID then
        return false
    endif
    
    MoveTo(-12973, -7077)
    Move(-14000, -7000)
    
    $LeavingTimeoutTimer = TimerInit()
    while GetMapID() <> $CatacombsMapID
        Sleep(500)
        
        if TimerDiff($LeavingTimeoutTimer) > 10000 then
            return false
        endif
    wend
    
    RandomSleep(2500, 7500)
    
    return true
endfunc

func LeaveFoiblesFair ()
    if GetMapID() <> $FoiblesFairMapID then
        return false
    endif
    
    MoveTo(164, 8307)
    Move(500, 7500)
    
    $LeavingTimeoutTimer = TimerInit()
    while GetMapID() <> $WizzardFollyMapID
        Sleep(500)
        
        if TimerDiff($LeavingTimeoutTimer) > 10000 then
            return false
        endif
    wend
    
    RandomSleep(2500, 7500)
    
    return true
endfunc

func LeaveBarradin ()
    if GetMapID() <> $BarradinMapID then
        return false
    endif
    
    MoveTo(-6525, 1372)
    Move(-7500, 1450)
    
    $LeavingTimeoutTimer = TimerInit()
    while GetMapID() <> $GreenHillsMapID
        Sleep(500)
        
        if TimerDiff($LeavingTimeoutTimer) > 10000 then
            return false
        endif
    wend
    
    RandomSleep(2500, 7500)
    
    return true
endfunc

func LeaveFortRanik ()
    if GetMapID() <> $FortRanikMapID then
        return false
    endif
    
    MoveTo(23035, 11802)
    MoveTo(22742, 9999)
    Move(22555, 7400)
    
    $LeavingTimeoutTimer = TimerInit()
    while GetMapID() <> $RegentValleyMapID
        Sleep(500)
        
        if TimerDiff($LeavingTimeoutTimer) > 10000 then
            return false
        endif
    wend
    
    RandomSleep(2500, 7500)
    
    return true
endfunc

func RandomTravelTo ($mapid)
    $RandomRL = Random(0, 10, 1)
    
    MoveMap($mapid, $MapRegionIDList[$RandomRL], 0, $MapLanguageIDList[$RandomRL])
    
    WaitMapLoading($mapid, 30000)
endfunc

func RandomSleep ($min, $max)
    $Random = Random($min, $max, 1)
    
    Sleep($Random)
endfunc

func UseSummoningStone ()
    M93_UseItemByModelID($SummoningStoneModelID)
endfunc

func MoveAndLoot ($x, $y)
    if GetIsDead() or TimerDiff($CurrentFarmTimer) > $FarmTimeoutReference then
        return false
    endif
    
    MoveTo($x, $y)
    
    RandomSleep(350, 650)
    
    $WaitTimeout = TimerInit()
    
    while M93_GetNumberOfFoesInRangeOfAgent(-2, 1000) > 0
        $WaitTimer = TimerInit()
        
        while TimerDiff($WaitTimer) < 5000
            $NearestEnemy = GetNearestEnemyToAgent()
            
            if GetDistance($NearestEnemy) < 1000 then
                Attack($NearestEnemy)
            else
                Move($x, $y)
            endif
            
            RandomSleep(200, 300)
        wend
        
        $NearestEnemy = GetNearestEnemyToAgent()
        
        if TimerDiff($WaitTimeout) > 80000 then
            GoPlayer($NearestEnemy)
        elseif TimerDiff($WaitTimeout) > 120000 then
            exitloop
        endif
        
        if GetIsDead() or TimerDiff($CurrentFarmTimer) > $FarmTimeoutReference then
            return false
        endif
    wend
    
    $Looted = false
    
    $AgentList = GetMaxAgents()
    
    for $Agent = 1 to $AgentList
        $AgentID = GetAgentByID($Agent)
        
		if DllStructGetData($AgentID, 'Type') <> 0x400 then continueloop
        
        if GetIsDead() or TimerDiff($CurrentFarmTimer) > $FarmTimeoutReference then
            return false
        endif
        
        if not CanPickup($Agent) then
            continueloop
        endif
        
        PickUpItem($Agent)
        
        $Looted = true
        
        while GetAgentExists($Agent)
            RandomSleep(750, 1250)
            if GetIsDead() or TimerDiff($CurrentFarmTimer) > $FarmTimeoutReference then
                return false
            endif
        wend
    next
    
    if GetIsDead() or TimerDiff($CurrentFarmTimer) > $FarmTimeoutReference then
        return false
    endif
    
    while M93_GetHealthPercentage() < 80 and not GetIsDead()
        RandomSleep(250, 750)
    wend
    
    if $Looted then
        return MoveAndLoot($x, $y)
    else
        return true
    endif
endfunc

func CanPickup ($agent)
    $AgentModelID = DllStructGetData(GetItemByAgentID($agent), "ModelID")
    
    if $AgentModelID == $RedIrisID then
        if $LootRedIris then
            return true
        else
            return false
        endif
    elseif $AgentModelID == $GoldsID then
        if GetDistance($agent) > 2000 then
            return false
        endif
        
        if GetGoldCharacter() < 99000 then
            return true
        else
            return false
        endif
    elseif _ArraySearch($SandFordIDs, $AgentModelID) > -1 then
        return true
    elseif _ArraySearch($ExtraConsumablesIDs, $AgentModelID) > -1 then
        return true
    elseif _ArraySearch($ExtraEventIDs, $AgentModelID) > -1 then
        return true
    elseif _ArraySearch($HalloweenIDs, $AgentModelID) > -1 then
        return true
    elseif _ArraySearch($LuckyIDs, $AgentModelID) > -1 then
        return true
    elseif _ArraySearch($PirateIDs, $AgentModelID) > -1 then
        return true
    elseif _ArraySearch($SpecialIDs, $AgentModelID) > -1 then
        return true
    elseif _ArraySearch($SweetIDs, $AgentModelID) > -1 then
        return true
    elseif _ArraySearch($WayfarerIDs, $AgentModelID) > -1 then
        return true
    elseif _ArraySearch($WintersdayIDs, $AgentModelID) > -1 then
        return true
    elseif _ArraySearch($ExtraItemsIDs, $AgentModelID) > -1 then
        return true
    else
        return false
    endif
endfunc

func FarmingRedIris ()
    UseSummoningStone()
    
    Move(-11934, -13346, 50)
    
    GUI_ConsoleAppend("We are seeking an Red Iris Flower...")
    
    $TimeoutTimer = TimerInit()
    
    while true
        if TimerDiff($TimeoutTimer) > 30000 then
            GUI_ConsoleAppend("No Red Iris Flower found...")
            
            exitloop
        endif
        
        if GetMaxAgents() <= 0 then
            continueloop
        endif
        
        $NearestAgent = DllStructGetData(GetNearestItemToAgent(-2), "ID")
        $NearestAgentModelID = DllStructGetData(GetItemByAgentID($NearestAgent), "ModelID")
        
        if $NearestAgentModelID <> $RedIrisID then
            continueloop
        endif
        
        GUI_ConsoleAppend("Red Iris Found... Pickup it...")
        
        PickUpItem($NearestAgent)
        
        $PickupTimeoutTimer = TimerInit()
        
        while GetAgentExists($NearestAgent)
            RandomSleep(250, 750)
            
            if TimerDiff($PickupTimeoutTimer) > 30000 then
                exitloop
            endif
        wend
        
        if GetAgentExists($NearestAgent) then
            GUI_ConsoleAppend("Red Iris Flower lost???")
        else
            GUI_ConsoleAppend("Red Iris Flower picked up!")
        endif
        
        GUI_ConsoleAppend("Return to Ashford...")
        
        exitloop
    wend
endfunc

func FarmingGargoyleSkulls ()
    GUI_ConsoleAppend("Go to farming spot...")
    
    MoveTo(14271, 2333)
    MoveTo(14366, 4369)
    MoveTo(12173, 4671)
    MoveTo(10062, 6225)
    
    GUI_ConsoleAppend("Summoning Igneous...")
    
    UseSummoningStone()
    
    GUI_ConsoleAppend("Farming...")
    
    MoveAndLoot(10062, 6225)
    MoveAndLoot(10196, 6789)
    MoveAndLoot(10398, 7557)
    MoveAndLoot(11015, 7905)
    MoveAndLoot(11517, 8519)
    MoveAndLoot(12072, 9098)
    MoveAndLoot(12559, 9594)
    MoveAndLoot(11597, 8623)
    
    GUI_ConsoleAppend("Return to Ashford...")
endfunc

func FarmingIcyLodestones ()
    GUI_ConsoleAppend("Go to farming spot...")
    
    MoveTo(790, 6037)
    MoveTo(1315, 5180)
    MoveTo(1894, 4813)
    
    GUI_ConsoleAppend("Summoning Igneous...")
    
    UseSummoningStone()
    
    GUI_ConsoleAppend("Farming...")
    
    MoveAndLoot(1894, 4813)
    MoveAndLoot(2630, 4867)
    MoveAndLoot(2639, 4161)
    MoveAndLoot(2808, 3145)
    MoveAndLoot(2318, 2538)
    MoveAndLoot(1486, 2321)
    MoveAndLoot(704, 2435)
    MoveAndLoot(35, 3018)
    MoveAndLoot(-577, 3644)
    MoveAndLoot(-1257, 4101)
    MoveAndLoot(-2608, 4898)
    MoveAndLoot(-3444, 4633)
    MoveAndLoot(-3791, 4012)
    MoveAndLoot(-3767, 3387)
    MoveAndLoot(-3833, 2487)
    MoveAndLoot(-4527, 1999)
    MoveAndLoot(-5359, 1692)
    MoveAndLoot(-5576, 845)
    MoveAndLoot(-5724, 21)
    MoveAndLoot(-6189, -730)
    MoveAndLoot(-6065, -1541)
    MoveAndLoot(-5979, -2282)
    MoveAndLoot(-5884, -3196)
    MoveAndLoot(-5853, -3879)
    MoveAndLoot(-5850, -4456)
    MoveAndLoot(-5758, -5074)
    MoveAndLoot(-5067, -5502)
    MoveAndLoot(-4361, -5813)
    MoveAndLoot(-4126, -6583)
    MoveAndLoot(-3994, -7355)
    MoveAndLoot(-4062, -8261)
    MoveAndLoot(-4772, -8810)
    MoveAndLoot(-5398, -9371)
    MoveAndLoot(-5819, -10071)
    MoveAndLoot(-6570, -10588)
    MoveAndLoot(-7393, -10848)
    MoveAndLoot(-8220, -10856)
    MoveAndLoot(-9040, -10704)
    MoveAndLoot(-9985, -10540)
    MoveAndLoot(-10706, -9935)
    
    GUI_ConsoleAppend("Return to FoibleFair...")
endfunc

func FarmingWornBelts ()
    GUI_ConsoleAppend("Go to farming spot...")
    
    MoveTo(-8415, -6328)
    MoveTo(-7155, -3939)
    MoveTo(-5994, -3545)
    MoveTo(-5758, -3117)
    
    GUI_ConsoleAppend("Summoning Igneous...")
    
    UseSummoningStone()
    
    GUI_ConsoleAppend("Farming...")
    
    MoveAndLoot(-5758, -3117)
    MoveAndLoot(-5600, -2583)
    MoveAndLoot(-6463, -2132)
    MoveAndLoot(-5981, -1680)
    MoveAndLoot(-5444, -1195)
    
    GUI_ConsoleAppend("Return to Ashford...")
endfunc

func FarmingUnnaturalSeedsAndEnchantedLodestones ()
    GUI_ConsoleAppend("Go to farming spot...")
    
    MoveTo(-8109, 1434)
    MoveTo(-9454, 1424)
    MoveTo(-10284, 1199)
    
    GUI_ConsoleAppend("Summoning Igneous...")
    
    UseSummoningStone()
    
    GUI_ConsoleAppend("Farming...")
    
    MoveAndLoot(-10284, 1199)
    MoveAndLoot(-11026, 947)
    MoveAndLoot(-11542, 383)
    MoveAndLoot(-11401, -601)
    MoveAndLoot(-11680, -1403)
    MoveAndLoot(-10780, -1615)
    MoveAndLoot(-9974, -2300)
    MoveAndLoot(-9771, -2903)
    MoveAndLoot(-9307, -3276)
    MoveAndLoot(-9945, -3552)
    MoveAndLoot(-10654, -3938)
    MoveAndLoot(-11298, -4260)
    MoveAndLoot(-11432, -5039)
    MoveAndLoot(-11836, -5830)
    MoveAndLoot(-11437, -6571)
    MoveAndLoot(-10539, -6509)
    MoveAndLoot(-9368, -6436)
    MoveAndLoot(-8533, -6648)
    MoveAndLoot(-8008, -6902)
    MoveAndLoot(-8001, -7898)
    MoveAndLoot(-8010, -8554)
    MoveAndLoot(-8902, -7501)
    MoveAndLoot(-9610, -8252)
    MoveAndLoot(-10591, -7652)
    
    GUI_ConsoleAppend("Return to Barradin...")
endfunc

func FarmingSpiderLegs ()
    GUI_ConsoleAppend("Go to farming spot...")
    
    MoveTo(22439, 4323)
    MoveTo(20560, 2503)
    MoveTo(19878, 1204)
    MoveTo(17602, -1215)
    MoveTo(17826, -2821)
    
    GUI_ConsoleAppend("Summoning Igneous...")
    
    UseSummoningStone()
    
    GUI_ConsoleAppend("Farming...")
    
    MoveAndLoot(17826, -2821)
    MoveAndLoot(17623, -3460)
    MoveAndLoot(17025, -4010)
    MoveAndLoot(15936, -4169)
    MoveAndLoot(15878, -5005)
    MoveAndLoot(15615, -5747)
    MoveAndLoot(15401, -6686)
    MoveAndLoot(15376, -7700)
    MoveAndLoot(15551, -8561)
    MoveAndLoot(16149, -9546)
    MoveAndLoot(16912, -10285)
    MoveAndLoot(17176, -11293)
    MoveAndLoot(17937, -11768)
    MoveAndLoot(18755, -12221)
    MoveAndLoot(19471, -12292)
    MoveAndLoot(20165, -12409)
    
    MoveAndLoot(20619, -12897)
    MoveAndLoot(21087, -13002)
    MoveAndLoot(21440, -12692)
    MoveAndLoot(22044, -12417)
    MoveAndLoot(21763, -11795)
    MoveAndLoot(21374, -11463)
    
    GUI_ConsoleAppend("Return to Fort Ranik...")
endfunc

func FarmingSkaleFins ()
    GUI_ConsoleAppend("Go to farming spot...")
    
    MoveTo(6884, 2996)
    MoveTo(7825, 2324)
    MoveTo(8969, 1797)
    MoveTo(10112, 1184)
    
    GUI_ConsoleAppend("Summoning Igneous...")
    
    UseSummoningStone()
    
    GUI_ConsoleAppend("Farming...")
    
    MoveAndLoot(10112, 1184)
    MoveAndLoot(10750, 845)
    MoveAndLoot(11641, 363)
    MoveAndLoot(11965, -382)
    MoveAndLoot(11861, -1161)
    MoveAndLoot(11955, -1941)
    MoveAndLoot(11942, -2817)
    MoveAndLoot(11418, -3182)
    MoveAndLoot(10829, -3546)
    MoveAndLoot(10583, -4113)
    MoveAndLoot(10015, -3610)
    MoveAndLoot(9196, -3671)
    MoveAndLoot(8469, -3742)
    MoveAndLoot(7729, -3571)
    MoveAndLoot(6873, -3610)
    MoveAndLoot(6248, -3398)
    MoveAndLoot(5447, -3195)
    MoveAndLoot(4702, -3094)
    MoveAndLoot(4061, -3737)
    MoveAndLoot(3502, -4249)
    MoveAndLoot(3138, -5130)
    MoveAndLoot(2611, -6379)
    MoveAndLoot(2280, -7062)
    MoveAndLoot(1516, -7578)
    MoveAndLoot(767, -8010)
    
    GUI_ConsoleAppend("Return to Ascalon...")
endfunc

func FarmingSkeletalLimbs ()
    GUI_ConsoleAppend("Go to farming spot...")
    
    MoveTo(13786, 1324)
    MoveTo(13816, -384)
    MoveTo(12341, -471)
    
    GUI_ConsoleAppend("Summoning Igneous...")
    
    UseSummoningStone()
    
    GUI_ConsoleAppend("Farming...")
    
    MoveAndLoot(12341, -471)
    MoveAndLoot(11477, -425)
    MoveAndLoot(10619, -25)
    MoveAndLoot(10048, 658)
    MoveAndLoot(9431, 1099)
    MoveAndLoot(8546, 1367)
    MoveAndLoot(7904, 1272)
    MoveAndLoot(7544, 914)
    MoveAndLoot(7307, 423)
    MoveAndLoot(6730, 132)
    MoveAndLoot(6059, -167)
    MoveAndLoot(5466, -408)
    MoveAndLoot(4816, -711)
    MoveAndLoot(4213, -989)
    MoveAndLoot(3738, -1199)
    MoveAndLoot(2792, -1586)
    MoveAndLoot(2071, -1871)
    MoveAndLoot(1488, -2108)
    MoveAndLoot(729, -2402)
    
    GUI_ConsoleAppend("Return to Ashford...")
endfunc

func FarmingBakedHusks ()
    GUI_ConsoleAppend("Go to farming spot...")
    
    MoveTo(-10559, -5502)
    
    GUI_ConsoleAppend("Summoning Igneous...")
    
    UseSummoningStone()
    
    GUI_ConsoleAppend("Farming...")
    
    MoveAndLoot(-10559, -5502)
    MoveAndLoot(-9856, -5264)
    MoveAndLoot(-9039, -4927)
    MoveAndLoot(-9610, -4690)
    MoveAndLoot(-10243, -4401)
    MoveAndLoot(-9726, -4034)
    MoveAndLoot(-9010, -3692)
    MoveAndLoot(-9575, -3430)
    MoveAndLoot(-10340, -3147)
    MoveAndLoot(-9599, -2739)
    MoveAndLoot(-9006, -2546)
    MoveAndLoot(-9609, -2339)
    MoveAndLoot(-10553, -2062)
    MoveAndLoot(-9780, -1825)
    MoveAndLoot(-8982, -1491)
    MoveAndLoot(-9694, -1116)
    MoveAndLoot(-10507, -818)
    MoveAndLoot(-9894, -544)
    MoveAndLoot(-9172, -253)
    MoveAndLoot(-9696, 473)
    
    GUI_ConsoleAppend("Return to Ashford...")
endfunc

func FarmingGrawlNecklaces ()
    GUI_ConsoleAppend("Go to farming spot...")
    
    MoveTo(5582, 4982)
    MoveTo(4414, 5663)
    MoveTo(3189, 5958)
    MoveTo(2139, 5779)
    MoveTo(778, 5535)
    MoveTo(-755, 5178)
    
    GUI_ConsoleAppend("Summoning Igneous...")
    
    UseSummoningStone()
    
    GUI_ConsoleAppend("Farming...")
    
    MoveAndLoot(-755, 5178)
    MoveAndLoot(-1515, 4961)
    MoveAndLoot(-2219, 4470)
    MoveAndLoot(-2694, 4994)
    MoveAndLoot(-3175, 5720)
    MoveAndLoot(-3794, 6529)
    MoveAndLoot(-4404, 6881)
    MoveAndLoot(-4981, 6604)
    MoveAndLoot(-5591, 6240)
    MoveAndLoot(-6243, 5866)
    MoveAndLoot(-6772, 5317)
    MoveAndLoot(-7429, 4771)
    MoveAndLoot(-8309, 4458)
    MoveAndLoot(-9038, 4293)
    MoveAndLoot(-9766, 4214)
    MoveAndLoot(-9543, 4902)
    MoveAndLoot(-9358, 5655)
    MoveAndLoot(-9155, 6575)
    MoveAndLoot(-9074, 7193)
    MoveAndLoot(-8579, 7996)
    
    GUI_ConsoleAppend("Return to Ashford...")
endfunc

func FarmingDullCarapaces ()
    GUI_ConsoleAppend("Go to farming spot...")
    
    MoveTo(6990, 2858)
    MoveTo(8657, 2027)
    
    GUI_ConsoleAppend("Summoning Igneous...")
    
    UseSummoningStone()
    
    GUI_ConsoleAppend("Farming...")
    
    MoveAndLoot(10181, 1170)
    MoveAndLoot(10997, 749)
    MoveAndLoot(11643, 166)
    MoveAndLoot(11778, -568)
    MoveAndLoot(11918, -1528)
    MoveAndLoot(11896, -2428)
    MoveAndLoot(11693, -3071)
    MoveAndLoot(10702, -3900)
    MoveAndLoot(10201, -4845)
    MoveAndLoot(9766, -5513)
    MoveAndLoot(9542, -6282)
    MoveAndLoot(9206, -8184)
    MoveAndLoot(9531, -8783)
    MoveAndLoot(10473, -9071)
    MoveAndLoot(9951, -10283)
    MoveAndLoot(9539, -11216)
    MoveAndLoot(8268, -11171)
    MoveAndLoot(7375, -11060)
    MoveAndLoot(6524, -11095)
    MoveAndLoot(5765, -10526)
    MoveAndLoot(5850, -9894)
    MoveAndLoot(5292, -10578)
    MoveAndLoot(4646, -11404)
    MoveAndLoot(3914, -12303)
    MoveAndLoot(3600, -13293)
    MoveAndLoot(2865, -13625)
    MoveAndLoot(2743, -12963)
    
    GUI_ConsoleAppend("Return to Ascalon...")
endfunc

Main()
