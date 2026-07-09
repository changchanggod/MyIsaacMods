if CCGChallenges45768==nil then
    CCGChallenges45768 =RegisterMod("conjugated gemini", 1)
    local mod= CCGChallenges45768
    local json=require("json")
    if mod:HasData() then
        local data=mod:LoadData()
        mod.Data=json.decode(data)
    end
    function mod:saveMyData()
        if mod.Data then
           mod:SaveData(json.encode(mod.Data)) 
        end
    end
    mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveMyData)
end
include("script.CG.conjugated_gemini")