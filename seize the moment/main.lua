local Mod = RegisterMod("seize the moment", 1)
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, EP)
    EP:AddCollectible(378)
    EP:AddCollectible(229)
    EP:AddCollectible(572)
    EP:AddCollectible(209)
    EP:AddCollectible(116)
end)
Mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_)
    Game():GetRoom():RemoveDoor(0)
    Game():GetRoom():RemoveDoor(1)
    Game():GetRoom():RemoveDoor(2)
    Game():GetRoom():RemoveDoor(3)
    Game():GetPlayer(0):AddCollectible(36)
    local ent=Game():Spawn(261, 1, Game():GetRoom():GetCenterPos(), Vector(0, 0), nil, 0,
                Game():GetRoom():GetSpawnSeed())
    ent.MaxHitPoints=400
end)
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, EP, CF)
    if CF == CacheFlag.CACHE_DAMAGE then
        EP.Damage = 3
    end
    if CF == CacheFlag.CACHE_FIREDELAY then
        EP.MaxFireDelay = 70
    end
end)
