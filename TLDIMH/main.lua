local mod = RegisterMod("TLDIMH", 1)
function mod:TLDIMH(Ent)
    if Ent==nil then
        return 
    end
    -- local ents=Isaac.FindByType(EntityType.ENTITY_FAMILIAR,FamiliarVariant.INCUBUS)
    -- if(#ents==0) then
    --    print("not lily")
    --    return
    -- end
    if Ent.SpawnerType==EntityType.ENTITY_FAMILIAR then
        local player = Isaac.GetPlayer()
        local familiar = Ent.SpawnerEntity
        local dir=player.Position-familiar.Position
        if dir:Length()==0 then
            return
        end
        Ent.Velocity=Ent.Velocity:Rotated(dir:GetAngleDegrees ())
    elseif Ent.SpawnerType==EntityType.ENTITY_PLAYER then
        local player = Isaac.GetPlayer()
        local dir=player.Position-Ent.Position
        if dir:Length()==0 then
            return
        end
        Ent.Velocity=Ent.Velocity:Rotated(dir:GetAngleDegrees ())
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT,mod.TLDIMH)