local mod = RegisterMod("Skin Shuffle", 1)
local json = require("json")

local Category = {
    MASTER = 1,
    NORMAL = 2,
    BOSS = 3,
    PICKUP = 4,
    FRIENDLY = 5,
    INVULNERABLE = 6,
}

local function reset()
    mod.setting = {
        [Category.MASTER] = true,
        [Category.NORMAL] = true,
        [Category.BOSS] = false,
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
local flipXCache = {}
local flipYCache = {}

----------------------------------------------------------------------------
-- Entity Category Check
----------------------------------------------------------------------------

local function isEntityIncluded(entity)
    -- if not mod.setting[Category.MASTER] then
    --     return false
    -- end

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
    entityPosCache = {}
    flipXCache = {}
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom)

----------------------------------------------------------------------------
-- Render: Build entityPosCache & Chain Propagation
----------------------------------------------------------------------------
local fixArgs=0.65
function mod:onRender()
    local entities = Isaac.GetRoomEntities()
    entityPosCache = {}
    local cache = {}
    for _, e in ipairs(entities) do
        if e:Exists() then
            cache[e.Index] = e
            entityPosCache[e.Index] = e.Position
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
            end
        end
    end

    mapping = nextMapping
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)

----------------------------------------------------------------------------
-- NPC Update: Apply SpriteOffset per NPC
----------------------------------------------------------------------------

local function round2(v)
    return math.floor(v * 100 + 0.5) * 0.01
end

function mod:onNpcUpdate(npc)
    if next(mapping) == nil then
        return
    end

    if not mapping[npc.Index] then
        return
    end

    local spr = npc:GetSprite()
    local prevFlipX = flipXCache[npc.Index]
    local prevFlipY = flipYCache[npc.Index]
    if prevFlipX == nil then
        prevFlipX = false
    end
    if prevFlipY == nil then
        prevFlipY = false
    end

    if prevFlipX ~= npc.FlipX or prevFlipY ~= spr.FlipY then
        flipXCache[npc.Index] = npc.FlipX
        flipYCache[npc.Index] = spr.FlipY
        local offset = npc.SpriteOffset
        local x = offset.X
        local y = offset.Y
        if prevFlipX ~= npc.FlipX then
            if npc.SpriteRotation==180 then
                if npc.FlipX then
                    x=x/3
                    x=x/ (4.3710*npc.SpriteScale.X+1.4348)*5.85
                else
                    x=x*(4.3710*npc.SpriteScale.X+1.4348)/5.85
                    x=x*3
                end
                
            else
                 x = -x
                if npc.FlipX then
                    x = x / (npc.SpriteScale.X * 2 - 1)
                end
            end
           
            
        end
        if prevFlipY~=spr.FlipY then
            if spr.FlipY then
                if npc.SpriteRotation==-90 then
                    x = x - 2 * y*npc.SpriteScale.X
                else
                    x = x + 2 * y*npc.SpriteScale.X
                end
            else
                if npc.SpriteRotation==-90 then
                    x = x + 2 * y*npc.SpriteScale.X
                else
                    x = x - 2 * y*npc.SpriteScale.X
                end
            end
        end
        
        npc.SpriteOffset = Vector(x, y)
    end
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.onNpcUpdate)

----------------------------------------------------------------------------
-- NPC Render: Apply SpriteOffset per NPC
----------------------------------------------------------------------------
---@param npc  EntityNPC
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

    local dx = round2(tgtPos.X - npc.Position.X)
    local dy = round2(tgtPos.Y - npc.Position.Y)
    if npc.FlipX then
        if npc.SpriteRotation==180 then
            dx=dx/3
            dx=dx/ (4.3710*npc.SpriteScale.X+1.4348)*5.85
        else
            dx = -dx / (npc.SpriteScale.X*2-1)
        end
    end
    local spr=npc:GetSprite()
    if spr.FlipY then
        if npc.SpriteRotation==-90 then
            dx=dx-2*dy*npc.SpriteScale.X
        else
            dx=dx+2*dy*npc.SpriteScale.X
        end
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
        MN = "物影错置",
        ST = "\232\174\190\231\189\174",
        N0 = "\228\184\128\233\148\174\232\174\190\231\189\174: ",
        O0 = { "\229\133\179", "\229\188\128" },
        K0 = "\228\184\128\233\148\174\229\188\128\229\144\175/229\133\179\233\151\173\230\137\128\230\156\137\229\174\158\228\189\147",
        N1 = "\230\153\174\233\128\154\230\128\170\231\137\169: ",
        O1 = { "\229\133\179", "\229\188\128" },
        K1 = "\229\140\133\230\139\172\230\153\174\233\128\154\230\149\140\228\186\186(\233\157\158Boss\227\128\129\233\157\158\229\143\139\229\165\189\227\128\129\229\143\175\229\143\151\228\188\164\229\174\179)",
        N2 = "Boss: ",
        O2 = { "\229\133\179", "\229\188\128" },
        K2 = "\229\140\133\230\139\172\229\184\166BOSS\230\160\135\229\191\151\231\154\132\229\174\158\228\189\147",
        N3 = "\230\142\137\232\144\189\231\137\169: ",
        O3 = { "\229\133\179", "\229\188\128" },
        K3 = "\229\140\133\230\139\172\229\191\131\227\128\129\231\161\172\229\184\129\227\128\129\231\130\184\229\188\185\227\128\129\233\146\165\229\140\153\231\173\137\230\142\137\232\144\189\231\137\169",
        N4 = "\229\143\139\229\165\189\230\128\170\231\137\169: ",
        O4 = { "\229\133\179", "\229\188\128" },
        K4 = "\229\140\133\230\139\172\229\184\166FRIENDLY\230\160\135\229\191\151\231\154\132\229\174\158\228\189\147",
        N5 = "\230\151\160\230\149\140\230\156\186\229\133\179: ",
        O5 = { "\229\133\179", "\229\188\128" },
        K5 = "\229\140\133\230\139\172\229\136\186\231\159\179\227\128\129\231\159\179\229\131\143\233\172\188\231\173\137\228\184\141\229\143\175\231\160\180\229\157\143\231\154\132\230\149\140\228\186\186",
    },
    en = {
        MN = "Skin Shuffle",
        ST = "Settings",
        N0 = "One-Click Setup: ",
        O0 = { "OFF", "ON" },
        K0 = "Toggle all entity types on/off",
        N1 = "Normal Monsters: ",
        O1 = { "OFF", "ON" },
        K1 = "Include vulnerable non-boss non-friendly enemies",
        N2 = "Boss: ",
        O2 = { "OFF", "ON" },
        K2 = "Include entities with BOSS flag",
        N3 = "Pickups: ",
        O3 = { "OFF", "ON" },
        K3 = "Include hearts, coins, bombs, keys, etc.",
        N4 = "Friendly Monsters: ",
        O4 = { "OFF", "ON" },
        K4 = "Include entities with FRIENDLY flag (charmed, etc.)",
        N5 = "Invulnerable Traps: ",
        O5 = { "OFF", "ON" },
        K5 = "Include indestructible enemies (stone grimaces, etc.)",
    }
}

local function getMCMDes(key)
    local lan = Options.Language
    lan = FC_MCM[lan] and lan or "en"
    local zhMCM = ModConfigMenu.i18n == "Chinese"
    if zhMCM and lan ~= "zh" then
        lan = "zh"
    elseif not (zhMCM) and lan == "zh" then
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
        { cat = Category.MASTER,    name = "N0", opt = "O0", tooltip = "K0", isMaster = true },
        { cat = Category.NORMAL,    name = "N1", opt = "O1", tooltip = "K1" },
        { cat = Category.BOSS,      name = "N2", opt = "O2", tooltip = "K2" },
        { cat = Category.PICKUP,    name = "N3", opt = "O3", tooltip = "K3" },
        { cat = Category.FRIENDLY,  name = "N4", opt = "O4", tooltip = "K4" },
        { cat = Category.INVULNERABLE, name = "N5", opt = "O5", tooltip = "K5" },
    }

    for _, desc in ipairs(settingDescriptors) do
        ModConfigMenu.AddSetting(MN, ST, {
            Type = ModConfigMenu.OptionType.NUMBER,
            CurrentSetting = function()
                return mod.setting[desc.cat] and 1 or 0
            end,
            Minimum = 0,
            Maximum = 1,
            Display = function()
                return getMCMDes(desc.name) .. getMCMDes(desc.opt)[mod.setting[desc.cat] and 2 or 1]
            end,
            OnChange = function(n)
                if desc.isMaster then
                    mod.setting[Category.MASTER] = n == 1
                    for cat = Category.NORMAL, Category.INVULNERABLE do
                        mod.setting[cat] = n == 1
                    end
                else
                    mod.setting[desc.cat] = n == 1
                end
            end,
            Info = { getMCMDes(desc.tooltip) },
        })
    end
end

-- l local ent=Isaac.Spawn(241,0,0,(Isaac.GetPlayer()).Position,Vector.Zero,nil)
-- function mod:makeAllChampion(EntNPC)
--     EntNPC:MakeChampion(1,13,true)
-- end
-- mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT,mod.makeAllChampion)