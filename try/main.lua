local mod=RegisterMod("try", 1)
local MASK = 0x3FF      -- 10bit 掩码 (0~1023，适配上限1000)
local SHIFT_VAR = 10
local SHIFT_SUB = 20
local json=require("json")
local function TypeToNum(Type, Var, SubType)
    Type = Type & MASK
    Var  = Var  & MASK
    SubType = SubType & MASK
    return (Type << SHIFT_SUB) | (SubType << SHIFT_VAR) | Var
end
mod.Cham={}
if mod:HasData() then
    local data=mod:LoadData()
    mod.noCham=json.decode(data)
    print(1)
else
    print(2)
end
---@param EntN EntityNPC
function mod:try(EntN)
    if EntN:IsChampion() then
        mod.Cham[TypeToNum(EntN.Type,EntN.Variant,EntN.SubType)]=true
        print(EntN.Type,EntN.Variant,EntN.SubType)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.try)
function mod:save()
    
    mod:SaveData(json.encode(mod.Cham))
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT,mod.save)