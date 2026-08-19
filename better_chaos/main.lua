local mod = RegisterMod("better_chaos", 1)
local myRNG = RNG()
myRNG:SetSeed(Random() % 1000000000 + 1, 1)
local player = Isaac.GetPlayer(0)
local level = Game():GetLevel()
local START_ROOM_INDEX = 84
local all_doors = {}
local door_size = 1
local all_room_doors = {}
local door_map = {}
local door_map_valid = false
local mapLevel=-1

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
        
        if des and des.SafeGridIndex == 84 then
            print(des.Data.Type ~= RoomType.ROOM_ULTRASECRET)
            print(address_room[des.SafeGridIndex] == nil)
            print(des.Data.Difficulty ~= 0)
        end
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

local function select_from_door(room_visited, room_door_size)
    local candidates = {}
    local candidates_size = 0
    for i, r_ind in ipairs(room_visited) do
        if room_door_size[r_ind] > 0 then
            for k, v in pairs(all_room_doors[r_ind]) do
                if door_map[v] == nil then
                    candidates[candidates_size] = v
                    candidates_size = candidates_size + 1
                end
            end
        end
    end
    local the_chosen_door = candidates[myRNG:RandomInt(candidates_size)]
    return the_chosen_door, candidates_size
end

local function is_visited(room_map, room)
    for i, r in ipairs(room_map) do
        if r == room then
            return i
        end
    end
    return -1
end

local function shuffle_zero_arr(arr, len)
    for i = len - 1, 1, -1 do
        -- 随机取 [0, i] 范围内下标
        local r = myRNG:RandomInt(i + 1)
        -- 交换元素
        arr[i], arr[r] = arr[r], arr[i]
    end
end

function mod:set_door_map()
    door_map = {}
    local all_room_size = 0
    local room_door_size = {}
    for k, r in pairs(all_room_doors) do
        all_room_size = all_room_size + 1
        room_door_size[k] = 0
        for k2, d in pairs(r) do
            room_door_size[k] = room_door_size[k] + 1
        end
    end
    local is_room_visited = { START_ROOM_INDEX }
    local is_room_visited_size = 2
    door_map_valid = true
    local AOVID_DEATH_LOOP = 100000
    while is_room_visited_size <= all_room_size do
        AOVID_DEATH_LOOP = AOVID_DEATH_LOOP - 1
        if AOVID_DEATH_LOOP <= 0 then
            door_map_valid = false
            break
        end
        local from_door, from_door_size = select_from_door(is_room_visited, room_door_size)
        local candidates = {}
        local candidates_size = 0
        local to_room_door_size = 1
        if from_door_size <= 1 and is_room_visited_size ~= all_room_size then
            to_room_door_size = 2
        end
        for i, d in ipairs(all_doors) do
            if door_map[i] == nil then
                local to_room_ind, to_door_ind = index_to_door(d)
                if room_door_size[to_room_ind] >= to_room_door_size then
                    if is_visited(is_room_visited, to_room_ind) < 0 then
                        candidates[candidates_size] = i
                        candidates_size = candidates_size + 1
                    end
                end
            end
        end
        local to_door = candidates[myRNG:RandomInt(candidates_size)]
        local to_room_ind, to_door_ind = index_to_door(all_doors[to_door])
        local from_room_ind, from_door_ind = index_to_door(all_doors[from_door])
        local to_in_visited = is_visited(is_room_visited, to_room_ind) >= 0
        -- if from_door_size==1 then
        --     print("start")
        --     for i, r_ind in ipairs(is_room_visited) do
        --         print(r_ind," ",room_door_size[r_ind])
        --     end
        --     print("end")
        --     print(from_room_ind," ",from_door_ind," ",to_room_ind," ",to_door_ind)
        -- end
        if to_room_ind ~= nil
            and from_room_ind ~= nil
            and room_door_size[to_room_ind] ~= nil
            and room_door_size[from_room_ind] ~= nil
        then
            room_door_size[to_room_ind] = room_door_size[to_room_ind] - 1
            room_door_size[from_room_ind] = room_door_size[from_room_ind] - 1
            door_map[to_door] = from_door
            door_map[from_door] = to_door
            if not to_in_visited then
                is_room_visited[is_room_visited_size] = to_room_ind
                is_room_visited_size = is_room_visited_size + 1
            end
        end
    end
    if door_map_valid then
        local candidates = {}
        local candidates_size = 0
        for i = 1, door_size - 1 do
            if door_map[i] == nil then
                candidates[candidates_size] = i
                candidates_size = candidates_size + 1
            end
        end
        shuffle_zero_arr(candidates, candidates_size)
        for i = 0, candidates_size - 1, 2 do
            if i + 1 > candidates_size - 1 then
                door_map[candidates[i]] = candidates[i]
                break
            end
            door_map[candidates[i]] = candidates[i + 1]
            door_map[candidates[i + 1]] = candidates[i]
        end
    else
        print("set_door_map failed")
    end
    -- for i = 1, door_size-1 do
    --     if door_map[i]==nil then
    --         local from_room_ind,from_door_ind=index_to_door(all_doors[i])
    --         print("nil!!!:",from_room_ind," ",from_door_ind)
    --     else
    --         local from_room_ind,from_door_ind=index_to_door(all_doors[i])
    --         local to_room_ind,to_door_ind=index_to_door(all_doors[door_map[i]])
    --         print(from_room_ind," ",from_door_ind,"     ",to_room_ind," ",to_door_ind)
    --     end
    -- end
end

local from_room_index = START_ROOM_INDEX
function mod:init_door_map()
    player = Isaac.GetPlayer()
    level = Game():GetLevel()
    from_room_index = level:GetStartingRoomIndex()
    if level:IsAscent() then
        from_room_index=level:GetCurrentRoomIndex ()
    end 
    level.EnterDoor = -1
    level.LeaveDoor = -1
    mod:get_all_doors()
    mod:set_door_map()
    mapLevel=Game():GetLevel():GetStage()
    -- level.EnterDoor = -1
    -- level.LeaveDoor = -1
    --Game():ChangeRoom(level:GetStartingRoomIndex())
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.init_door_map)

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

function mod:address_room_change()
    if door_map_valid then
        if mapLevel~=Game():GetLevel():GetStage() then
            return
        end
        local temp_fri = from_room_index
        from_room_index = level:GetCurrentRoomIndex() 
        local from_door = level.LeaveDoor
        if from_door < 0
            or all_room_doors[temp_fri] == nil
            or all_room_doors[temp_fri][from_door] == nil then
            return
        end
        local door_index = door_map[all_room_doors[temp_fri][from_door]]
        local to_room_ind, to_door_ind = index_to_door(all_doors[door_index])
        level.EnterDoor = -1
        level.LeaveDoor = -1
        if to_door_ind == nil then
            return
        end
        Game():ChangeRoom(to_room_ind)
        local room = Game():GetRoom()

        local door_pos = room:GetDoorSlotPosition(to_door_ind)
        player.Position = door_pos_shift(to_door_ind, door_pos)

        -- if room:GetRoomShape()>3 then
        --     Game():StartRoomTransition(to_room_ind, Direction.NO_DIRECTION, RoomTransitionAnim.FADE,player,-1)
        -- end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.address_room_change)
-- function mod:try3413()
--     print("change ROOM")
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.try3413)
--   l local level = Game():GetLevel() print(level:GetCurrentRoomIndex ( ))
--   l local level = Game():GetLevel() level.EnterDoor = -1 level.LeaveDoor = -1 Game():ChangeRoom(84)
--   l local player = Isaac.GetPlayer(0) local room = Game():GetRoom() local door_pos=room:GetDoorSlotPosition(to_door_ind) player.Position=door_pos
-- l local room = Game():GetRoom() print(room:GetDoor (2) ~=nil)
-- l print(Game():GetLevel():GetStartingRoomIndex())








local tId = Isaac.GetItemIdByName("intro")
if tId == -1 then
    Isaac.ConsoleOutput(string.format("[CCG][Error]: item \"%s\" load failed, missing item\n", "intro"))
    return nil
end
local tId2 = Isaac.GetItemIdByName("intro2")
if tId2 == -1 then
    Isaac.ConsoleOutput(string.format("[CCG][Error]: item \"%s\" load failed, missing item\n", "intro"))
    return nil
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isC)
    if isC then
        return
    end
    local game = Game()
    local room = game:GetRoom()
    game:Spawn(5, 100, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 10, true, true), Vector(0, 0), nil, tId,
        room:GetSpawnSeed())
    game:Spawn(5, 100, room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(40, 0), 10, true, true),
        Vector(0, 0), nil, tId2,
        room:GetSpawnSeed())
    local player = Isaac.GetPlayer()
    player:AddCollectible(76)
    player:AddCollectible(17)
end)

if EID then
    EID:addCollectible(tId,
        "#设A为你当前所在房间，B为左侧房间，C为任意房间" ..
        "#一般情况下，A左侧门对应B右侧门" ..
        "#从A左侧门入，会从B右侧门出" ..
        "#从B右侧门入，会从A左侧门出" ..
        "#随机重排后，A左侧门可能对应C上侧门" ..
        "#从A左侧门入，会从C上侧门出" ..
        "#从C上侧门入，会从A左侧门出" ..
        "#{{Damage}} 管你看没看懂，打就完了！！！",
        "门对应关系重排详细介绍",
        "zh_cn")
    EID:addCollectible(tId2,
        "#由于点播被拖了至少一个月之久，代码早已更新换代" ..
        "#现在可下矿" ..
        "#不必手动调道具了，伟大的作者已为你调好" ..
        "#不想打百变怪可以不打，改为羔羊或？？？" ..
        "#如果遇到门打不开（如挑战房门）导致卡关就使用控制台" ..
        "#我知道这个点播很屎，但为了把前大吧主培养成小蓝人，整个略鸭区都在努力着啊！！！",
        "点播修正",
        "zh_cn")
end