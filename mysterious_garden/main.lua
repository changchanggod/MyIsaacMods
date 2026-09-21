local mod=RegisterMod("mysterious garden", 2)
local curseFreeFrame=0
local glowingHourglassFrame=0
local glowingHourglassRoomInd=-1
local sandCurseLevel=0
local drunkCurseLevel=0
local hearCurseLevel=0
local CurseStopGrow=false
local stageCount=0
local RECOMMENDED_SHIFT_IDX = 35






local game = Game()
local seeds = game:GetSeeds()
local startSeed = seeds:GetStartSeed()
local myRNG = RNG()
myRNG:SetSeed(math.max(1,startSeed), RECOMMENDED_SHIFT_IDX)
function mod:gameInit(isC)
    if isC then
        return
    end
    game = Game()
    seeds = game:GetSeeds()
    startSeed = seeds:GetStartSeed()
    myRNG:SetSeed(startSeed, RECOMMENDED_SHIFT_IDX)
    curseFreeFrame=0
    glowingHourglassFrame=0
    glowingHourglassRoomInd=-1
    sandCurseLevel=0
    drunkCurseLevel=0
    hearCurseLevel=0
    CurseStopGrow=false
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.gameInit)

--- 开始增加3血上限
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,function (_,isC)
    if not isC then
        local index,checked=0,{}
        while true do
            local player = Isaac.GetPlayer(index)
            if checked[player.Index] then
                break
            end
            checked[player.Index] = true
            player:AddMaxHearts(6)
            index = index + 1
        end
    end
end)
--- 挑战超过30分钟后每10秒造成伤害
mod:AddCallback(ModCallbacks.MC_POST_UPDATE,function (_)
    if Game():GetFrameCount()/30>1800 then
        if Game():GetFrameCount()%300==0 then
            local index,checked=0,{}
            while true do
                local player = Isaac.GetPlayer(index)
                if checked[player.Index] then
                    break
                end
                checked[player.Index] = true
                player:TakeDamage(1,DamageFlag.DAMAGE_RED_HEARTS|DamageFlag.DAMAGE_NO_MODIFIERS|DamageFlag.DAMAGE_INVINCIBLE|DamageFlag.DAMAGE_NO_PENALTIES,EntityRef(nil),0)
                index = index + 1
            end
        end
    end
end)
--- 特殊效果(龙)
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM,function (_,itemT)
    local level=Game():GetLevel()
    if level:IsAscent() then
        return
    end
    if level:GetStage()==LevelStage.STAGE3_1 and (level:GetStageType()==StageType.STAGETYPE_REPENTANCE or level:GetStageType()==StageType.STAGETYPE_REPENTANCE_B) then
        return
    end
    if level:GetStage()==LevelStage.STAGE3_2 and (level:GetStageType()==StageType.STAGETYPE_REPENTANCE or level:GetStageType()==StageType.STAGETYPE_REPENTANCE_B) and not Game():GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH_INIT) then
        return
    end
    if level:GetStage()>LevelStage.STAGE3_2 then
        return
    end
    if itemT==CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS then
        Game():SetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH,true)
        Game():StartStageTransition(true, 5, Isaac.GetPlayer())
        CurseStopGrow=true
        return false
    end
end)


--- 泥沙诅咒
local sandCurseSpr=Sprite()

sandCurseSpr:Load("gfx/sand_curse2.anm2",true)
mod:AddCallback(ModCallbacks.MC_POST_RENDER,function (_)
    if curseFreeFrame>0 then
        return
    end
    sandCurseSpr.Scale=Vector.One/3
    sandCurseSpr.Rotation=0
    if sandCurseLevel >= 1 then
        if sandCurseLevel>13 then
            sandCurseLevel=13
        end
        sandCurseSpr:Play("sandCurse"..sandCurseLevel, true)
        local renderPos=Vector(Isaac.GetScreenWidth()/2,Isaac.GetScreenHeight()/2)
        sandCurseSpr:Render(renderPos)
    end
    
end)





--- 氮醉诅咒
local all_doors={}
local all_room_doors={}
local door_size=1
local from_room_index=84
local effectStage=0
local function door_to_index(des, doorInd)
    return des.SafeGridIndex * DoorSlot.NUM_DOOR_SLOTS + doorInd
end
local function index_to_door(index)
    if index == nil then
        return nil, nil
    end
    return index // DoorSlot.NUM_DOOR_SLOTS, index % DoorSlot.NUM_DOOR_SLOTS
end
function mod:get_all_doors()
    all_doors = {}
    all_room_doors = {}
    door_size = 1
    local level=Game():GetLevel()
    local all_room = level:GetRooms()
    local address_room = {}
    local level_map = {}
    for i = 1, 13 do
        level_map[i] = {}
        for j = 1, 13 do
            level_map[i][j] = -1
        end
    end
    for i = 0, all_room.Size do
        local des = all_room:Get(i)
        if des and des.Data.Type ~= RoomType.ROOM_ULTRASECRET and 
        (des.Data.Difficulty ~= 0 or ((Game():GetLevel():GetStage()==LevelStage.STAGE4_3 or Game():GetLevel():IsAscent()) and des.SafeGridIndex==START_ROOM_INDEX)) then
            local sg = des.SafeGridIndex
            local shape = des.Data.Shape
            if shape == RoomShape.ROOMSHAPE_1x1 or shape == RoomShape.ROOMSHAPE_IH or shape == RoomShape.ROOMSHAPE_IV then
                level_map[sg // 13 + 1][sg % 13 + 1] = des.ListIndex
            elseif shape == RoomShape.ROOMSHAPE_1x2 or shape == RoomShape.ROOMSHAPE_IIV then
                level_map[sg // 13 + 1][sg % 13 + 1] = des.ListIndex
                level_map[sg // 13 + 2][sg % 13 + 1] = des.ListIndex
            elseif shape == RoomShape.ROOMSHAPE_2x1 or shape == RoomShape.ROOMSHAPE_IIH then
                level_map[sg // 13 + 1][sg % 13 + 1] = des.ListIndex
                level_map[sg // 13 + 1][sg % 13 + 2] = des.ListIndex
            elseif shape == RoomShape.ROOMSHAPE_2x2 then
                level_map[sg // 13 + 1][sg % 13 + 1] = des.ListIndex
                level_map[sg // 13 + 1][sg % 13 + 2] = des.ListIndex
                level_map[sg // 13 + 2][sg % 13 + 1] = des.ListIndex
                level_map[sg // 13 + 2][sg % 13 + 2] = des.ListIndex
            elseif shape == RoomShape.ROOMSHAPE_LTL then
                level_map[sg // 13 + 1][sg % 13 + 1] = des.ListIndex
                level_map[sg // 13 + 2][sg % 13 + 1] = des.ListIndex
                level_map[sg // 13 + 2][sg % 13] = des.ListIndex
            elseif shape == RoomShape.ROOMSHAPE_LTR then
                level_map[sg // 13 + 1][sg % 13 + 1] = des.ListIndex
                level_map[sg // 13 + 2][sg % 13 + 1] = des.ListIndex
                level_map[sg // 13 + 2][sg % 13 + 2] = des.ListIndex
            elseif shape == RoomShape.ROOMSHAPE_LBL then
                level_map[sg // 13 + 1][sg % 13 + 1] = des.ListIndex
                level_map[sg // 13 + 1][sg % 13 + 2] = des.ListIndex
                level_map[sg // 13 + 2][sg % 13 + 2] = des.ListIndex
            elseif shape == RoomShape.ROOMSHAPE_LBR then
                level_map[sg // 13 + 1][sg % 13 + 1] = des.ListIndex
                level_map[sg // 13 + 1][sg % 13 + 2] = des.ListIndex
                level_map[sg // 13 + 2][sg % 13 + 1] = des.ListIndex
            end
        end
    end

    for i = 0, all_room.Size do
        local des = all_room:Get(i)
        -- 过滤空房间对象与红隐藏与处理过的房间与特殊房间
        if des and des.Data.Type ~= RoomType.ROOM_ULTRASECRET and address_room[des.SafeGridIndex] == nil and 
        (des.Data.Difficulty ~= 0 or ((Game():GetLevel():GetStage()==LevelStage.STAGE4_3 or Game():GetLevel():IsAscent()) and des.SafeGridIndex==START_ROOM_INDEX)) -- 防止误伤？？？层与回溯层初始房间 
        then
            address_room[des.SafeGridIndex] = true
            local sg = des.SafeGridIndex
            local I, J = sg // 13 + 1, sg % 13 + 1
            local shape = des.Data.Shape
            all_room_doors[des.SafeGridIndex] = {} --TODO
            -- LEFT0
            if level_map[I][J - 1] and level_map[I][J - 1] >= 0 then
                all_doors[door_size] = door_to_index(des, DoorSlot.LEFT0)
                all_room_doors[des.SafeGridIndex][DoorSlot.LEFT0] = door_size --TODO
                door_size = door_size + 1
            end
            -- UP0
            if shape ~= RoomShape.ROOMSHAPE_LTL then
                if level_map[I - 1] and level_map[I - 1][J] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.UP0)
                    all_room_doors[des.SafeGridIndex][DoorSlot.UP0] = door_size --TODO
                    door_size = door_size + 1
                end
            else
                if level_map[I][J - 1] and level_map[I][J - 1] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.UP0)
                    all_room_doors[des.SafeGridIndex][DoorSlot.UP0] = door_size --TODO
                    door_size = door_size + 1
                end
            end

            -- RIGHT0
            if shape == RoomShape.ROOMSHAPE_1x1 or shape == RoomShape.ROOMSHAPE_IH or shape == RoomShape.ROOMSHAPE_IV or shape == RoomShape.ROOMSHAPE_1x2 or shape == RoomShape.ROOMSHAPE_IIV or shape == RoomShape.ROOMSHAPE_LTL or shape == RoomShape.ROOMSHAPE_LTR then
                if level_map[I][J + 1] and level_map[I][J + 1] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.RIGHT0)
                    all_room_doors[des.SafeGridIndex][DoorSlot.RIGHT0] = door_size --TODO
                    door_size = door_size + 1
                end
            else
                if level_map[I][J + 2] and level_map[I][J + 2] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.RIGHT0)
                    all_room_doors[des.SafeGridIndex][DoorSlot.RIGHT0] = door_size --TODO
                    door_size = door_size + 1
                end
            end
            -- DOWN0
            if shape == RoomShape.ROOMSHAPE_1x1 or shape == RoomShape.ROOMSHAPE_IH or shape == RoomShape.ROOMSHAPE_IV or shape == RoomShape.ROOMSHAPE_2x1 or shape == RoomShape.ROOMSHAPE_IIH or shape == RoomShape.ROOMSHAPE_LBL then
                if level_map[I + 1] and level_map[I + 1][J] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.DOWN0)
                    all_room_doors[des.SafeGridIndex][DoorSlot.DOWN0] = door_size --TODO
                    door_size = door_size + 1
                end
            elseif shape == RoomShape.ROOMSHAPE_LTL then
                if level_map[I + 2] and level_map[I + 2][J - 1] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.DOWN0)
                    all_room_doors[des.SafeGridIndex][DoorSlot.DOWN0] = door_size --TODO
                    door_size = door_size + 1
                end
            else
                if level_map[I + 2] and level_map[I + 2][J] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.DOWN0)
                    all_room_doors[des.SafeGridIndex][DoorSlot.DOWN0] = door_size --TODO
                    door_size = door_size + 1
                end
            end
            -- LEFT1
            if shape == RoomShape.ROOMSHAPE_1x2 or shape == RoomShape.ROOMSHAPE_2x2 or shape == RoomShape.ROOMSHAPE_LTR or shape == RoomShape.ROOMSHAPE_LBR then
                if level_map[I + 1] and level_map[I + 1][J - 1] and level_map[I + 1][J - 1] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.LEFT1)
                    all_room_doors[des.SafeGridIndex][DoorSlot.LEFT1] = door_size --TODO
                    door_size = door_size + 1
                end
            elseif shape == RoomShape.ROOMSHAPE_LTL then
                if level_map[I + 1] and level_map[I + 1][J - 2] and level_map[I + 1][J - 2] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.LEFT1)
                    all_room_doors[des.SafeGridIndex][DoorSlot.LEFT1] = door_size --TODO
                    door_size = door_size + 1
                end
            elseif shape == RoomShape.ROOMSHAPE_LBL then
                if level_map[I + 1] and level_map[I + 1][J] and level_map[I + 1][J] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.LEFT1)
                    all_room_doors[des.SafeGridIndex][DoorSlot.LEFT1] = door_size --TODO
                    door_size = door_size + 1
                end
            end
            -- UP1
            if shape == RoomShape.ROOMSHAPE_2x1 or shape == RoomShape.ROOMSHAPE_2x2 or shape == RoomShape.ROOMSHAPE_LBR or shape == RoomShape.ROOMSHAPE_LBL then
                if level_map[I - 1] and level_map[I - 1][J + 1] and level_map[I - 1][J + 1] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.UP1)
                    all_room_doors[des.SafeGridIndex][DoorSlot.UP1] = door_size --TODO
                    door_size = door_size + 1
                end
            elseif shape == RoomShape.ROOMSHAPE_LTL then
                if level_map[I - 1] and level_map[I - 1][J] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.UP1)
                    all_room_doors[des.SafeGridIndex][DoorSlot.UP1] = door_size --TODO
                    door_size = door_size + 1
                end
            elseif shape == RoomShape.ROOMSHAPE_LTR then
                if level_map[I][J + 1] and level_map[I][J + 1] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.UP1)
                    all_room_doors[des.SafeGridIndex][DoorSlot.UP1] = door_size --TODO
                    door_size = door_size + 1
                end
            end
            -- RIGHT1
            if shape == RoomShape.ROOMSHAPE_1x2 or shape == RoomShape.ROOMSHAPE_LTL or shape == RoomShape.ROOMSHAPE_LBR then
                if level_map[I + 1] and level_map[I + 1][J + 1] and level_map[I + 1][J + 1] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.RIGHT1)
                    all_room_doors[des.SafeGridIndex][DoorSlot.RIGHT1] = door_size --TODO
                    door_size = door_size + 1
                end
            elseif shape == RoomShape.ROOMSHAPE_2x2 or shape == RoomShape.ROOMSHAPE_LTR or shape == RoomShape.ROOMSHAPE_LBL then
                if level_map[I + 1] and level_map[I + 1][J + 2] and level_map[I + 1][J + 2] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.RIGHT1)
                    all_room_doors[des.SafeGridIndex][DoorSlot.RIGHT1] = door_size --TODO
                    door_size = door_size + 1
                end
            end
            -- DOWN1
            if shape == RoomShape.ROOMSHAPE_2x1 or shape == RoomShape.ROOMSHAPE_LBR then
                if level_map[I + 1] and level_map[I + 1][J + 1] and level_map[I + 1][J + 1] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.DOWN1)
                    all_room_doors[des.SafeGridIndex][DoorSlot.DOWN1] = door_size --TODO
                    door_size = door_size + 1
                end
            elseif shape == RoomShape.ROOMSHAPE_2x2 or shape == RoomShape.ROOMSHAPE_LTR or shape == RoomShape.ROOMSHAPE_LBL then
                if level_map[I + 2] and level_map[I + 2][J + 1] and level_map[I + 2][J + 1] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.DOWN1)
                    all_room_doors[des.SafeGridIndex][DoorSlot.DOWN1] = door_size --TODO
                    door_size = door_size + 1
                end
            elseif shape == RoomShape.ROOMSHAPE_LTL then
                if level_map[I + 2] and level_map[I + 2][J] and level_map[I + 2][J] >= 0 then
                    all_doors[door_size] = door_to_index(des, DoorSlot.DOWN1)
                    all_room_doors[des.SafeGridIndex][DoorSlot.DOWN1] = door_size --TODO
                    door_size = door_size + 1
                end
            end
        end
    end
end

local SHIFT_DIS = 50
local function door_pos_shift(door_slot, pos)
    if door_slot == 0 or door_slot == 4 then
        pos.X = pos.X + SHIFT_DIS
    elseif door_slot == 1 or door_slot == 5 then
        pos.Y = pos.Y + SHIFT_DIS
    elseif door_slot == 2 or door_slot == 6 then
        pos.X = pos.X - SHIFT_DIS
    elseif door_slot == 3 or door_slot == 7 then
        pos.Y = pos.Y - SHIFT_DIS
    end
    return pos
end

function mod:init_door_map()
    local player = Isaac.GetPlayer()
    local level = Game():GetLevel()
    from_room_index = level:GetStartingRoomIndex()
    if level:IsAscent() then
        from_room_index=level:GetCurrentRoomIndex ()
    end 
    level.EnterDoor = -1
    level.LeaveDoor = -1
    mod:get_all_doors()
    effectStage=Game():GetLevel():GetStage()
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.init_door_map)

function mod:address_room_change()
    local level=Game():GetLevel()
    if effectStage~=level:GetStage() then
        return
    end
    if curseFreeFrame>0 then
        return
    end
    local rand=myRNG:RandomInt(100)
    if rand>=drunkCurseLevel*20 then
        return
    end
    local player=Isaac.GetPlayer()
    local temp_fri = from_room_index
    from_room_index = level:GetCurrentRoomIndex() 
    local from_door = level.LeaveDoor
    if from_door < 0
        or all_room_doors[temp_fri] == nil
        or all_room_doors[temp_fri][from_door] == nil then
        return
    end
    local door_index = myRNG:RandomInt(door_size)+1
    local to_room_ind, to_door_ind = index_to_door(all_doors[door_index])
    level.EnterDoor = -1
    level.LeaveDoor = -1
    if to_door_ind == nil or to_room_ind==nil then
        return
    end
    Game():ChangeRoom(to_room_ind)
    local room = Game():GetRoom()

    local door_pos = room:GetDoorSlotPosition(to_door_ind)
    player.Position = door_pos_shift(to_door_ind, door_pos) --TODO:多玩家
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.address_room_change)

--- 氮醉诅咒2.0
local affectDirAngle=90
local lastV=Vector.Zero
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,function (_,EntP)
    if curseFreeFrame>0 then
        lastV=EntP.Velocity
        return
    end
    local difV=EntP.Velocity-lastV
    local affectScale=0
    if drunkCurseLevel==1 then
        affectScale=0.5
    elseif drunkCurseLevel==2 then
        affectScale=0.8
    end
    local affectLength=difV:Length()*affectScale
    if affectLength>10 then
        affectLength=10
    end
    affectDirAngle=affectDirAngle+(myRNG:RandomFloat()-0.4)
    EntP.Velocity=EntP.Velocity+affectLength*Vector.FromAngle(affectDirAngle+difV:GetAngleDegrees())
    lastV=EntP.Velocity
    if EntP.Velocity:Length()>1000 or lastV:Length()>1000 then
        EntP.Velocity=Vector.Zero
        lastV=Vector.Zero
        curseFreeFrame=30
    end
end)



--- 幻听诅咒
local sfxManager=SFXManager()
local musicManager=MusicManager()
local drown=Isaac.GetSoundIdByName("CCGdrown")
if drown~=-1 then
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE,function ()
        if curseFreeFrame>0 or hearCurseLevel<=0 then
            musicManager:Enable()
            sfxManager:Stop(drown)
            return
        end
        if not sfxManager:IsPlaying(drown) then
            sfxManager:Play(drown,8,2,true)
        end
        musicManager:Disable()
    end)
    mod:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY,function (_,id)
        if curseFreeFrame>0 or hearCurseLevel<=0 then
            return
        end
        if id~=drown then
            return false
        end
    end)
    print("load drown success")
end


--- 更新各诅咒(包括黑蜡烛处理逻辑)(龙)
local function blackCandleDecreaseCurse()
    local decreaseLevel=stageCount//2
    for _ = 1, decreaseLevel do
        local weightPool = {}
        local totalWeight = 0

        if sandCurseLevel > 0 then
            table.insert(weightPool, {val = sandCurseLevel, target = "sand"})
            totalWeight = totalWeight + sandCurseLevel
        end
        if drunkCurseLevel > 0 then
            table.insert(weightPool, {val = drunkCurseLevel, target = "drunk"})
            totalWeight = totalWeight + drunkCurseLevel
        end
        if hearCurseLevel > 0 then
            table.insert(weightPool, {val = hearCurseLevel, target = "hear"})
            totalWeight = totalWeight + hearCurseLevel
        end
        if totalWeight <= 0 then
            break
        end
        local roll = myRNG:RandomInt(totalWeight)
        local acc = 0
        local pick = nil
        for _,entry in ipairs(weightPool) do
            acc = acc + entry.val
            if roll < acc then
                pick = entry.target
                break
            end
        end

        -- 执行扣减，最低为0
        if pick == "sand" then
            sandCurseLevel = math.max(0, sandCurseLevel - 1)
        elseif pick == "drunk" then
            drunkCurseLevel = math.max(0, drunkCurseLevel - 1)
        elseif pick == "hear" then
            hearCurseLevel = math.max(0, hearCurseLevel - 1)
        end
    end
end
local function updateCurse()
    sandCurseLevel=stageCount-1
    drunkCurseLevel=stageCount//5
    hearCurseLevel=stageCount>8 and 1 or 0
    if Isaac.GetPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
        blackCandleDecreaseCurse()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,function ()
    if not CurseStopGrow then
        stageCount=stageCount+1
    end
    updateCurse()
end)
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE,function (_,itemT,_,isF)
    if itemT==CollectibleType.COLLECTIBLE_BLACK_CANDLE and isF then
        blackCandleDecreaseCurse()
    end
end)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,function (_,isC)
    if isC then
        return
    end
    stageCount=1
    updateCurse()
end)

--- 获取特殊道具时特殊效果(龙)
local hasSpawnGlowingHourglass=false
local itemConfig=Isaac.GetItemConfig()
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE,function (_,itemT,_,isF)
    local config=itemConfig:GetCollectible(itemT)
    if isF and config:IsCollectible() and (config:HasTags(ItemConfig.TAG_MOM) or config:HasTags(ItemConfig.TAG_BABY)) then
        curseFreeFrame=900
        glowingHourglassFrame=300
        glowingHourglassRoomInd=Game():GetLevel():GetRandomRoomIndex(false,Game():GetRoom():GetSpawnSeed())
        print(1431," ",glowingHourglassRoomInd)
        hasSpawnGlowingHourglass=false
    end
end)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE,function ()
    if curseFreeFrame>0 then
        curseFreeFrame=curseFreeFrame-1
    end
    if glowingHourglassFrame>0 then
        glowingHourglassFrame=glowingHourglassFrame-1
        print(Game():GetLevel():GetCurrentRoomDesc().SafeGridIndex)
        local level=Game():GetLevel()
        if level:GetRoomByIdx(glowingHourglassRoomInd) and level:GetCurrentRoomDesc().SafeGridIndex==level:GetRoomByIdx(glowingHourglassRoomInd).SafeGridIndex and not hasSpawnGlowingHourglass then
            hasSpawnGlowingHourglass=true
            local pos = Isaac.GetRandomPosition()
            local room=Game():GetRoom()
            game:Spawn(5, 100, room:FindFreePickupSpawnPosition(pos, 10, true, true), Vector(0, 0), nil, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS,room:GetSpawnSeed())
        end
    end
end)

---杀死母亲时掉落愚者卡
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL,function (_,EntN)
    if EntN.Variant==10 then
        Game():Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,EntN.Position,Vector.Zero,nil,1,Game():GetSeeds():GetStartSeed())
    end
end,EntityType.ENTITY_MOM)