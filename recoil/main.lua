local mod = RegisterMod("recoil", 1)
function mod:recoil(Ent)
    if Ent==nil then
        return 
    end
    local player = Isaac.GetPlayer()
    player.Velocity=player.Velocity-Ent.Velocity:Normalized()*10
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,mod.recoil)