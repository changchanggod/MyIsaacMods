local mod = CCGChallenges45768
local utils=require("script.CCG_utils")
local challengeName="item countdown"
local challengeId = utils.GetChallengeSafe(challengeName)
if challengeId == nil then
    return nil
end
utils.allowChallengeSecretPath(challengeId,true)

local itemConfig=Isaac.GetItemConfig()
local frameInterval=300
local itemTotalNum=732
local function getNextItem(i,change)
    local nextItemId=i+change
    local config=itemConfig:GetCollectible(nextItemId)
    while config==nil and nextItemId>0 and nextItemId<=itemTotalNum do
        nextItemId=nextItemId+change
        config=itemConfig:GetCollectible(nextItemId)
    end
    return config,nextItemId
end
local function itemCountDown()
    if Game().Challenge==challengeId then
        if Game():GetFrameCount()% frameInterval==0 then
            local player=Isaac.GetPlayer()
            local change=Game():GetLevel():IsAscent() and 1 or -1
            for i=1,itemTotalNum do
                if player:HasCollectible(i,true) then
                    local config=itemConfig:GetCollectible(i)
                    local nextItemId=i
                    if config.Type==ItemType.ITEM_ACTIVE then
                        local config2=nil
                        config2,nextItemId=getNextItem(nextItemId,change)
                        while config2.Type~=ItemType.ITEM_ACTIVE and nextItemId>0 and nextItemId<=itemTotalNum do
                            config2,nextItemId=getNextItem(nextItemId,change)
                            if config2==nil then
                                break
                            end
                        end
                        if nextItemId>0 and nextItemId<=itemTotalNum then
                            player:RemoveCollectible(i,true)
                            player:AddCollectible(nextItemId,0,false)
                        end
                    elseif config.Type==ItemType.ITEM_PASSIVE or config.Type==ItemType.ITEM_FAMILIAR then
                        local config2=nil
                        config2,nextItemId=getNextItem(nextItemId,change)
                        while config2.Type~=ItemType.ITEM_PASSIVE and config.Type~=ItemType.ITEM_FAMILIAR and nextItemId>0 and nextItemId<=itemTotalNum do
                            config2,nextItemId=getNextItem(nextItemId,change)
                            if config2==nil then
                                break
                            end
                        end
                        player:RemoveCollectible(i,true)
                        if nextItemId>0 and nextItemId<=itemTotalNum then
                            player:AddCollectible(nextItemId,0,false)
                        end
                    end
                end
            end
        end
    end
    
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE,itemCountDown)