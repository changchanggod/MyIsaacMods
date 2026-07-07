local Mod = RegisterMod("DaWeiDinZhu", 1)
math.randomseed(Isaac.GetFrameCount())
local item_allow = {}
local item_pass = {0, 238, 239, 550, 551, 552, 327, 328, 626, 627}
local j = 1
for i = 1, 732 do
    local jump = false
    for _, pass in ipairs(item_pass) do
        if i == pass then
            jump = true
            break
        end
    end
    if not jump then
        local item = Isaac.GetItemConfig():GetCollectible(i)
        if item then
            if item.Quality <= 2 then
                item_allow[j] = i
                j = j + 1
            end
        end
    end
end

function Mod:ChangeItems()
    for _, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == 100 then
            print(entity.Touched)
            local jump = false
            for _, pass in ipairs(item_pass) do
                if entity.SubType == pass then
                    jump = true
                    break
                end
            end
            for _, allow in ipairs(item_allow) do
                if entity.SubType == allow then
                    jump = true
                    break
                end
            end
            if not jump then
                local index = 0
                local id = entity.SubType
                local player = Isaac.GetPlayer()
                while true do
                    if #item_allow == 0 then
                        break
                    end
                    index = math.random(#item_allow)
                    id = item_allow[index]
                    if player:HasCollectible(id, true) then
                        table.remove(item_allow, index)
                    else
                        local item = Isaac.GetItemConfig():GetCollectible(id)
                        if item then
                            if item.Quality < 2 then
                                break
                            end
                            if item.Quality == 2 then
                                if math.random(3) >= 2 then
                                    break
                                end
                            end
                            if item.Quality > 2 then
                                table.remove(item_allow, index)
                            end
                        else
                            table.remove(item_allow, index)
                        end
                    end
                end
                entity:ToPickup():Morph(5, 100, id, true)
            end
        end
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.ChangeItems)
