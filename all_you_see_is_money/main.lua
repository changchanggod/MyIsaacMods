if CCGChallenges45768==nil then
    CCGChallenges45768 =RegisterMod("all you see is money", 1)
    local mod= CCGChallenges45768
    local json=require("json")
    if mod:HasData() then
        local data=mod:LoadData()
        mod.Data=json.decode(data)
    end
    function mod:saveMyData()
        mod:SaveData(json.encode(mod.Data))
    end
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveMyData)
end
include("script.AYSIM.all_you_see_is_money")