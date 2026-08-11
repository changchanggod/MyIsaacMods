local mod = RegisterMod("Skin Shuffle", 1)
local json = require("json")

local Category = {
    MASTER = 1,
    NORMAL = 2,
    BOSS = 3,
    PLAYER = 4,
    PICKUP = 5,
    FRIENDLY = 6,
    INVULNERABLE = 7,
}

local function reset()
    mod.setting = {
        [Category.MASTER] = true,
        [Category.NORMAL] = true,
        [Category.BOSS] = false,
        [Category.PLAYER] = false,
        [Category.PICKUP] = false,
        [Category.FRIENDLY] = false,
        [Category.INVULNERABLE] = false,
    }
end

if mod:HasData() then
    local data = mod:LoadData()
    mod.setting = json.decode(data)
    if type(mod.setting) ~= "table" or mod.setting[Category.MASTER] == nil then
        reset()
    end
else
    reset()
end

local mapping = {}
local entityPosCache = {}

----------------------------------------------------------------------------
-- Entity Category Check
----------------------------------------------------------------------------

local function isEntityIncluded(entity)
    if not mod.setting[Category.MASTER] then
        return false
    end

    if mod.setting[Category.NORMAL] then
        if entity:IsVulnerableEnemy()
            and not entity:IsBoss()
            and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            return true
        end
    end

    if mod.setting[Category.BOSS] then
        if entity:IsBoss() then
            return true
        end
    end

    if mod.setting[Category.PLAYER] then
        if entity.Type == EntityType.ENTITY_PLAYER then
            return true
        end
    end

    if mod.setting[Category.PICKUP] then
        if entity.Type == EntityType.ENTITY_PICKUP then
            return true
        end
    end

    if mod.setting[Category.FRIENDLY] then
        if entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
            and entity.Type ~= EntityType.ENTITY_PLAYER then
            return true
        end
    end

    if mod.setting[Category.INVULNERABLE] then
        if entity:IsActiveEnemy()
            and not entity:IsVulnerableEnemy()
            and not entity:IsBoss() then
            return true
        end
    end

    return false
end

----------------------------------------------------------------------------
-- Derangement (Sattolo's Algorithm)
----------------------------------------------------------------------------

local function sattoloShuffle(arr)
    local n = #arr
    for i = n, 2, -1 do
        local j = math.random(i - 1)
        arr[i], arr[j] = arr[j], arr[i]
    end
end

----------------------------------------------------------------------------
-- Mapping Construction
----------------------------------------------------------------------------

function mod:onNewRoom()
    mapping = {}

    local included = {}
    local entities = Isaac.GetRoomEntities()
    for _, entity in ipairs(entities) do
        if entity:Exists() and isEntityIncluded(entity) then
            included[#included + 1] = entity.Index
        end
    end

    local n = #included
    if n < 2 then
        return
    end

    sattoloShuffle(included)

    for i = 1, n do
        mapping[included[i]] = included[(i % n) + 1]
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom)

----------------------------------------------------------------------------
-- Render: Apply SpriteOffset & Chain Propagation
----------------------------------------------------------------------------
local fixArgs=0.65
function mod:onRender()
    local entities = Isaac.GetRoomEntities()
    local cache = {}
    entityPosCache = {}
    for _, e in ipairs(entities) do
        if e:Exists() then
            cache[e.Index] = e
            entityPosCache[e.Index] = e.Position
        end
    end
    for srcIdx, _ in pairs(mapping) do
        local src = cache[srcIdx]
        if src then
            src.SpriteOffset = Vector(0, 0)
        end
    end

    if next(mapping) == nil then
        return
    end

    local nextMapping = {}

    for srcIdx, tgtIdx in pairs(mapping) do
        local src = cache[srcIdx]
        if src then
            local cur = tgtIdx
            local visited = {}
            while cur and not visited[cur] and not cache[cur] do
                visited[cur] = true
                cur = mapping[cur]
            end
            if cur and cache[cur] then
                nextMapping[srcIdx] = cur
                local dx = cache[cur].Position.X - src.Position.X
                local dy = cache[cur].Position.Y - src.Position.Y
                if src.FlipX then
                    dx = -dx
                end
                if src.FlipY then
                    dy = -dy
                end
                src.SpriteOffset = Vector(dx, dy)*fixArgs
            end
        end
    end

    mapping = nextMapping
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)

----------------------------------------------------------------------------
-- NPC Update: Apply SpriteOffset per NPC
----------------------------------------------------------------------------

function mod:onNpcUpdate(npc)
    if next(mapping) == nil then
        return
    end

    local tgtIdx = mapping[npc.Index]
    if not tgtIdx then
        return
    end

    local tgtPos = entityPosCache[tgtIdx]
    if not tgtPos then
        return
    end

    local dx = tgtPos.X - npc.Position.X
    local dy = tgtPos.Y - npc.Position.Y
    if npc.FlipX then
        dx = -dx
    end
    if npc.FlipY then
        dy = -dy
    end
    npc.SpriteOffset = Vector(dx, dy)*fixArgs
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.onNpcUpdate)

----------------------------------------------------------------------------
-- NPC Render: Apply SpriteOffset per NPC
----------------------------------------------------------------------------

function mod:onNpcRender(npc, _)
    if next(mapping) == nil then
        return
    end

    local tgtIdx = mapping[npc.Index]
    if not tgtIdx then
        return
    end

    local tgtPos = entityPosCache[tgtIdx]
    if not tgtPos then
        return
    end

    local dx = tgtPos.X - npc.Position.X
    local dy = tgtPos.Y - npc.Position.Y
    if npc.FlipX then
        dx = -dx
    end
    if npc.FlipY then
        dy = -dy
    end
    npc.SpriteOffset = Vector(dx, dy)*fixArgs
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.onNpcRender)

----------------------------------------------------------------------------
-- Save
----------------------------------------------------------------------------

function mod:saveSettings()
    mod:SaveData(json.encode(mod.setting))
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveSettings)

----------------------------------------------------------------------------
-- MCM (Mod Config Menu)
----------------------------------------------------------------------------

local FC_MCM = {
    zh = {
        MN = "Skin Shuffle",
        ST = "\xE8\xAE\xBE\xE7\xBD\xAE",
        N0 = "\xE6\x80\xBB\xE5\xBC\x80\xE5\x85\xB3: ",
        N1 = "\xE6\x99\xAE\xE9\x80\x9A\xE6\x80\xAA\xE7\x89\xA9: ",
        N2 = "Boss: ",
        N3 = "\xE7\x8E\xA9\xE5\xAE\xB6: ",
        N4 = "\xE6\x8E\x89\xE8\x90\xBD\xE7\x89\xA9: ",
        N5 = "\xE5\x8F\x8B\xE5\xA5\xBD\xE6\x80\xAA\xE7\x89\xA9: ",
        N6 = "\xE6\x97\xA0\xE6\x95\x8C\xE6\x9C\xBA\xE5\x85\xB3: ",
        ON = "\xE5\xBC\x80",
        OFF = "\xE5\x85\xB3",
        K0 = "\xE4\xB8\x80\xE9\x94\xAE\xE5\xBC\x80\xE5\x90\xAF\x2F\xE5\x85\xB3\xE9\x97\xAD\xE6\x89\x80\xE6\x9C\x89\xE5\xAE\x9E\xE4\xBD\x93",
        K1 = "\xE5\x8C\x85\xE6\x8B\xAC\xE6\x99\xAE\xE9\x80\x9A\xE6\x95\x8C\xE4\xBA\xBA\x28\xE9\x9D\x9E\x42\x6F\x73\x73\xE3\x80\x81\xE9\x9D\x9E\xE5\x8F\x8B\xE5\xA5\xBD\xE3\x80\x81\xE5\x8F\xAF\xE5\x8F\x97\xE4\xBC\xA4\xE5\xAE\xB3\x29",
        K2 = "\xE5\x8C\x85\xE6\x8B\xAC\xE5\xB8\xA6\x42\x4F\x53\x53\xE6\xA0\x87\xE5\xBF\x97\xE7\x9A\x84\xE5\xAE\x9E\xE4\xBD\x93",
        K3 = "\xE5\x8C\x85\xE6\x8B\xAC\xE7\x8E\xA9\xE5\xAE\xB6\xE5\xAE\x9E\xE4\xBD\x93",
        K4 = "\xE5\x8C\x85\xE6\x8B\xAC\xE5\xBF\x83\xE3\x80\x81\xE7\xA1\xAC\xE5\xB8\x81\xE3\x80\x81\xE7\x82\xB8\xE5\xBC\xB9\xE3\x80\x81\xE9\x92\xA5\xE5\x8C\x99\xE7\xAD\x89\xE6\x8E\x89\xE8\x90\xBD\xE7\x89\xA9",
        K5 = "\xE5\x8C\x85\xE6\x8B\xAC\xE5\xB8\xA6\x46\x52\x49\x45\x4E\x44\x4C\x59\xE6\xA0\x87\xE5\xBF\x97\xE7\x9A\x84\xE5\xAE\x9E\xE4\xBD\x93",
        K6 = "\xE5\x8C\x85\xE6\x8B\xAC\xE5\x88\xBA\xE7\x9F\xB3\xE3\x80\x81\xE7\x9F\xB3\xE5\x83\x8F\xE9\xAC\xBC\xE7\xAD\x89\xE4\xB8\x8D\xE5\x8F\xAF\xE7\xA0\xB4\xE5\x9D\x8F\xE7\x9A\x84\xE6\x95\x8C\xE4\xBA\xBA",
    },
    en = {
        MN = "Skin Shuffle",
        ST = "Settings",
        N0 = "Master Switch: ",
        N1 = "Normal Monsters: ",
        N2 = "Boss: ",
        N3 = "Player: ",
        N4 = "Pickups: ",
        N5 = "Friendly Monsters: ",
        N6 = "Invulnerable Traps: ",
        ON = "ON",
        OFF = "OFF",
        K0 = "Toggle all entity types on/off",
        K1 = "Include vulnerable non-boss non-friendly enemies",
        K2 = "Include entities with BOSS flag",
        K3 = "Include player entities",
        K4 = "Include hearts, coins, bombs, keys, etc.",
        K5 = "Include entities with FRIENDLY flag (charmed, etc.)",
        K6 = "Include indestructible enemies (stone grimaces, etc.)",
    }
}

local function getMCMDes(key)
    local lan = Options.Language
    lan = FC_MCM[lan] and lan or "en"
    local zhMCM = ModConfigMenu.i18n == "Chinese"
    if zhMCM and lan ~= "zh" then
        lan = "zh"
    elseif not zhMCM and lan == "zh" then
        lan = "en"
    end
    return FC_MCM[lan] and FC_MCM[lan][key]
end

if ModConfigMenu and mod.setting then
    local MN = getMCMDes("MN")
    local ST = getMCMDes("ST")
    ModConfigMenu.RemoveSubcategory(MN, ST)
    ModConfigMenu.AddSpace(MN, ST)

    local settingDescriptors = {
        { cat = Category.MASTER,    name = "N0", tooltip = "K0", isMaster = true },
        { cat = Category.NORMAL,    name = "N1", tooltip = "K1" },
        { cat = Category.BOSS,      name = "N2", tooltip = "K2" },
        { cat = Category.PLAYER,    name = "N3", tooltip = "K3" },
        { cat = Category.PICKUP,    name = "N4", tooltip = "K4" },
        { cat = Category.FRIENDLY,  name = "N5", tooltip = "K5" },
        { cat = Category.INVULNERABLE, name = "N6", tooltip = "K6" },
    }

    for _, desc in ipairs(settingDescriptors) do
        ModConfigMenu.AddSetting(
            MN, ST,
            {
                CurrentSetting = function()
                    return mod.setting[desc.cat]
                end,
                ModifySetting = function(val)
                    if desc.isMaster then
                        mod.setting[Category.MASTER] = val
                        for cat = Category.NORMAL, Category.INVULNERABLE do
                            mod.setting[cat] = val
                        end
                    else
                        mod.setting[desc.cat] = val
                    end
                end,
                Display = function()
                    local label = getMCMDes(desc.name)
                    local state = mod.setting[desc.cat] and getMCMDes("ON") or getMCMDes("OFF")
                    return label .. state
                end,
                Type = ModConfigMenu.OptionType.BOOLEAN,
                Info = { getMCMDes(desc.tooltip) },
            }
        )
    end
end
