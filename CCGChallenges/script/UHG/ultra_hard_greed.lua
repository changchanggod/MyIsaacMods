local mod = CCGChallenges45768
local utils=require("script.CCG_utils")
local challengeName="ultra hard greed"
local challengeId = utils.GetChallengeSafe(challengeName)
if challengeId == nil then
    return nil
end
local myRNG=utils.getRNG()


local championWeight={
    [0]=20,
    [1]=20,
    [2]=20,
    [3]=10,
    [4]=10,
    [5]=20,
    [6]=1,
    [7]=20,
    [8]=2,
    [9]=2,
    [10]=20,
    [11]=2,
    [12]=10,
    [13]=20,
    [14]=5,
    [15]=5,
    [16]=5,
    [17]=5,
    [18]=5,
    [19]=5,
    [20]=2,
    [21]=2,
    [22]=2,
    [23]=2,
    [24]=2,
    [25]=1,
}
local prefix = {}
local total = 0
for key, v in pairs(championWeight) do
    total = total + v
    table.insert(prefix, {sum = total, data = key})
end

local champion = {
    ["12582912"] = true,
    ["15728640"] = true,
    ["62914560"] = true,
    ["59768832"] = true,
    ["270532608"] = true,
    ["57671681"] = true,
    ["293601280"] = true,
    ["216006656"] = true,
    ["262144000"] = true,
    ["11534337"] = true,
    ["225443840"] = true,
    ["14680065"] = true,
    ["272629770"] = true,
    ["258998272"] = true,
    ["253755392"] = true,
    ["874512386"] = true,
    ["40894466"] = true,
    ["238026752"] = true,
    ["224395264"] = true,
    ["24117248"] = true,
    ["248512512"] = true,
    ["267386880"] = true,
    ["24117249"] = true,
    ["236978176"] = true,
    ["851443712"] = true,
    ["314572800"] = true,
    ["252706816"] = true,
    ["15728641"] = true,
    ["26214400"] = true,
    ["41944064"] = true,
    ["42991617"] = true,
    ["315621376"] = true,
    ["25165825"] = true,
    ["63963139"] = true,
    ["218103809"] = true,
    ["319815680"] = true,
    ["291504128"] = true,
    ["213909504"] = true,
    ["57671680"] = true,
    ["40894464"] = true,
    ["39845889"] = true,
    ["303038464"] = true,
    ["26214401"] = true,
    ["23068673"] = true,
    ["10485762"] = true,
    ["41944065"] = true,
    ["231735296"] = true,
    ["218103808"] = true,
    ["241172480"] = true,
    ["261095424"] = true,
    ["57671682"] = true,
    ["873463808"] = true,
    ["289406976"] = true,
    ["245366784"] = true,
    ["90177536"] = true,
    ["920649728"] = true,
    ["219152384"] = true,
    ["16777217"] = true,
    ["92274688"] = true,
    ["23068672"] = true,
    ["35651584"] = true,
    ["92274689"] = true,
    ["325060608"] = true,
    ["33554432"] = true,
    ["236978178"] = true,
    ["240123904"] = true,
    ["42991616"] = true,
    ["255852545"] = true,
    ["217055233"] = true,
    ["16777218"] = true,
    ["296747008"] = true,
    ["26214402"] = true,
    ["301989888"] = true,
    ["41945090"] = true,
    ["41947138"] = true,
    ["874512385"] = true,
    ["41946113"] = true,
    ["27262977"] = true,
    ["898629632"] = true,
    ["217055232"] = true,
    ["900726784"] = true,
    ["292552704"] = true,
    ["63963136"] = true,
    ["236978177"] = true,
    ["235929600"] = true,
    ["317718528"] = true,
    ["63963138"] = true,
    ["41945088"] = true,
    ["41946112"] = true,
    ["16777216"] = true,
    ["27262976"] = true,
    ["264241152"] = true,
    ["39845891"] = true,
    ["32505856"] = true,
    ["22020096"] = true,
    ["269484032"] = true,
    ["25165826"] = true,
    ["61865984"] = true,
    ["41943041"] = true,
    ["251658240"] = true,
    ["23068674"] = true,
    ["265289728"] = true,
    ["271581184"] = true,
    ["58720256"] = true,
    ["325061632"] = true,
    ["59768833"] = true,
    ["30408704"] = true,
    ["240123905"] = true,
    ["62914562"] = true,
    ["15728642"] = true,
    ["41943042"] = true,
    ["60817409"] = true,
    ["63963137"] = true,
    ["238026753"] = true,
    ["214958080"] = true,
    ["55574529"] = true,
    ["24117250"] = true,
    ["260046848"] = true,
    ["31457281"] = true,
    ["874512384"] = true,
    ["318767104"] = true,
    ["266338304"] = true,
    ["257949696"] = true,
    ["221249536"] = true,
    ["11534336"] = true,
    ["325059584"] = true,
    ["25165824"] = true,
    ["30408706"] = true,
    ["304087040"] = true,
    ["91226112"] = true,
    ["40894467"] = true,
    ["35651585"] = true,
    ["322961408"] = true,
    ["56623104"] = true,
    ["313524224"] = true,
    ["30408705"] = true,
    ["55574528"] = true,
    ["41943040"] = true,
    ["218103810"] = true,
    ["254803968"] = true,
    ["295698432"] = true,
    ["31457280"] = true,
    ["31457282"] = true,
    ["324009984"] = true,
    ["28311552"] = true,
    ["94371840"] = true,
    ["60817408"] = true,
    ["855638016"] = true,
    ["220200960"] = true,
    ["27262978"] = true,
    ["875560960"] = true,
    ["10485760"] = true,
    ["10485761"] = true,
    ["95420416"] = true,
    ["867172352"] = true,
    ["234881024"] = true,
    ["39845888"] = true,
    ["321912832"] = true,
    ["14680064"] = true,
    ["15728643"] = true,
    ["62914561"] = true,
    ["40894465"] = true,
    ["297795584"] = true,
    ["255852544"] = true,
    ["92274690"] = true,
    ["290455552"] = true,
    ["28311553"] = true
}
---@param entN EntityNPC
local function turnIntoChampion(_,entN)
    if Game().Challenge==challengeId then
        if entN:IsBoss() or entN.SpawnerEntity or entN:IsChampion() or champion[tostring(utils.TypeToNum(entN.Type,entN.Variant,entN.SubType))]==nil then
            return
        end
        local rand=myRNG:RandomInt(total)+1
        for _, p in ipairs(prefix) do
            if rand <= p.sum then
                entN:MakeChampion(Game():GetSeeds():GetStartSeed(),p.data,true)
                entN.HitPoints=entN.MaxHitPoints
                break
            end
        end

    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT,turnIntoChampion)
---@param entPick EntityPickup
local function removeHeart(_,entPick)
    if Game().Challenge==challengeId then
        entPick:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT,removeHeart,PickupVariant.PICKUP_HEART)

---@param EntN EntityNPC
local function doubleTrouble(_,EntN)
    if Game().Challenge==challengeId then
        if Game():GetLevel().GreedModeWave>=Game():GetGreedBossWaveNum() and Game():GetLevel():GetStage()>LevelStage.STAGE1_GREED then
            if not EntN:IsBoss() or EntN.SpawnerEntity or Game():GetRoom():GetType()~=RoomType.ROOM_DEFAULT then
                return
            end
            Game():Spawn(EntN.Type,EntN.Variant,EntN.Position+RandomVector()*EntN.Size,EntN.Velocity,EntN,EntN.SubType,EntN.InitSeed)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT,doubleTrouble)
--l print(Game():GetGreedWavesNum().." "..Game():GetGreedBossWaveNum())