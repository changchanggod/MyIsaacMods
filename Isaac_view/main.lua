local mod = RegisterMod("Isaac_view", 1)
local view_distance=1
local grid_half_size=20
local picture_size=1024*1.538
local spr_size=400
local view_rotate_speed=10
local view_angle=120

local SQRT2=math.sqrt(2)
local UDspr,LRspr,Squares={},{},{}
for i = 1, spr_size*2, 1 do
    UDspr[i]=Sprite()
    UDspr[i]:Load("gfx/updown_triangle.anm2", true)
end
for i = 1, spr_size, 1 do
    LRspr[i]=Sprite()
    LRspr[i]:Load("gfx/leftright_triangle.anm2", true)
end
for i = 1, spr_size, 1 do
    Squares[i]=Sprite()
    Squares[i]:Load("gfx/square.anm2", true)
end
local UD_count,LR_count,Square_count=1,1,1
local view_spr=Sprite()
view_spr:Load("gfx/view.anm2", true)
view_spr:Play("view",false)

local function startSprPlaying(spr,str)
    if spr and not spr:IsPlaying() then
        spr:Play(str,false)
    end
end

-- 版本1：返回夹角正切值(θ∈[0,π]，恒非负)
-- vecA, vecB: 以撒 Vector
-- 返回: tanθ；垂直时返回 nil
local function GetVectorAngleTan(vecA, vecB)
    local x1, y1 = vecA.X, vecA.Y
    local x2, y2 = vecB.X, vecB.Y

    local dot = x1 * x2 + y1 * y2       -- 点积
    local cross = x1 * y2 - y1 * x2     -- 叉积

    local eps = 0.0001
    -- 点积接近0 → 垂直，tan无意义
    if math.abs(dot) < eps then
        return nil
    end

    -- 夹角 0~π，取叉积绝对值
    return math.abs(cross) / dot
end

-- 求两条直线的交点
-- 直线1：p0(定点), dirU(方向向量)
-- 直线2：q0(定点), dirV(方向向量)
-- 返回值：
--   1. 有唯一交点：true, 交点Vector
--   2. 平行无交点：false, nil
--   3. 完全重合：false, "coincident"
local function GetLineIntersection(p0, dirU, q0, dirV)
    local ux = dirU.X
    local uy = dirU.Y
    local vx = dirV.X
    local vy = dirV.Y

    local dx = q0.X - p0.X
    local dy = q0.Y - p0.Y

    -- 计算叉积 D
    local D = ux * vy - uy * vx

    -- 浮点数容差，规避精度误差
    local eps = 0.0001
    if math.abs(D) < eps then
        -- 两直线平行，判断是否重合
        local cross1 = dx * uy - dy * ux
        if math.abs(cross1) < eps then
            return false, "coincident"  -- 直线重合
        else
            return false, nil           -- 平行不相交
        end
    end

    -- 求解参数 t
    local t = (dx * vy - dy * vx) / D
    -- 计算交点
    local intersectX = p0.X + t * ux
    local intersectY = p0.Y + t * uy

    return true, Vector(intersectX, intersectY)
end

-- 带精度容差的钝角判断
-- tolerance: 精度阈值，默认 0.001
local function IsVectorObtuse(vecA, vecB, tolerance)
    tolerance = tolerance or 0.001
    local dot = vecA.X * vecB.X + vecA.Y * vecB.Y
    return dot < -tolerance
end

local function GetLeftNormal(vec)
    return Vector(-vec.Y, vec.X)
end
-- 主函数：三点 A,B,C 构成三角形，过A作BC边上的高
-- 返回：高长度, tan(∠BAH), tan(∠CAH)
local function TriangleAltitudeAndTan(A, B, C)
    -- 底边 BC 方向向量
    local dirBC = Vector(C.X - B.X, C.Y - B.Y)
    -- 过 A 作 BC 的垂线：方向为 BC 的左法向量
    local dirAH = GetLeftNormal(dirBC)

    -- 求垂足 H (直线BC 与 垂线AH 的交点)
    local ok, H = GetLineIntersection(B, dirBC, A, dirAH)
    if not ok then
        -- 三点共线，无法构成三角形
        return 0, 0, 0
    end

    -- 高 AH 长度
    local altLen = math.sqrt((A.X - H.X)^2 + (A.Y - H.Y)^2)

    -- 构造向量 AB, AH, AC
    local vecAB = Vector(B.X - A.X, B.Y - A.Y)
    local vecAH = Vector(H.X - A.X, H.Y - A.Y)
    local vecAC = Vector(C.X - A.X, C.Y - A.Y)

    -- 两个角的 tan 值（自动取绝对值 = 取大角）
    local tan1 = GetVectorAngleTan(vecAB, vecAH)
    local tan2 = GetVectorAngleTan(vecAC, vecAH)

    return altLen, tan1, tan2, vecAH
end

local function GetSquareVertices(center)
    local x = center.X
    local y = center.Y

    -- 四个顶点
    local topLeft     = Vector(x - grid_half_size, y + grid_half_size)
    local topRight    = Vector(x + grid_half_size, y + grid_half_size)
    local bottomRight = Vector(x + grid_half_size, y - grid_half_size)
    local bottomLeft  = Vector(x - grid_half_size, y - grid_half_size)

    return {topLeft, topRight, bottomRight, bottomLeft}
end

local function JudgeSquareNineArea(squarePts, targetPt)
    -- 提取四个顶点
    local tl = squarePts[1]
    local tr = squarePts[2]
    local br = squarePts[3]
    local bl = squarePts[4]

    -- 正方形边界 X / Y 极值
    local minX = tl.X
    local maxX = tr.X
    local maxY = tl.Y
    local minY = br.Y

    local px = targetPt.X
    local py = targetPt.Y

    -- 划分三个横向区间、三个纵向区间
    -- 纵向：左 / 中 / 右
    local dirX
    if px < minX then
        dirX = 1  -- 左
    elseif px > maxX then
        dirX = 3  -- 右
    else
        dirX = 2  -- 中 (包含左右边线)
    end

    -- 横向：上 / 中 / 下
    local dirY
    if py > maxY then
        dirY = 1  -- 上
    elseif py < minY then
        dirY = 3  -- 下
    else
        dirY = 2  -- 中 (包含上下边线)
    end

    -- 九宫格编号规则 (dirY行, dirX列)
    -- 行1(上): 左上(1,1) | 正上(1,2) | 右上(1,3)
    -- 行2(中): 正左(2,1) | 内部(2,2) | 正右(2,3)
    -- 行3(下): 左下(3,1) | 正下(3,2) | 右下(3,3)
    local areaMap = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    }

    local areaId = areaMap[dirY][dirX]

    return areaId
end

local function RenderShadow(squarePts, targetPt, areaId)
    local p1, p2=nil,nil
    if areaId == 2 then
        -- 正上方：左上、右上
        p1 = squarePts[1]
        p2 = squarePts[2]
    elseif areaId == 4 then
        -- 正左方：左上、左下
        p1 = squarePts[1]
        p2 = squarePts[4]
    elseif areaId == 6 then
        -- 正右方：右上、右下
        p1 = squarePts[2]
        p2 = squarePts[3]
    elseif areaId == 8 then
        -- 正下方：左下、右下
        p1 = squarePts[4]
        p2 = squarePts[3]
    else
        -- 非正方向，返回空
        return nil
    end

    -- 计算向量：目标点 -> 端点 (以撒 Vector 支持加减运算)
    if p1 and p2 then
        local vecToP1 = targetPt - p1
        local vecToP2 = targetPt - p2
        if areaId==4 or areaId==6 then
            startSprPlaying(Squares[Square_count],"square")
            Squares[Square_count].Scale=Vector(view_distance,2*grid_half_size/picture_size)
            Squares[Square_count].Rotation=0
            if areaId==4 then
                Squares[Square_count]:Render(Isaac.WorldToScreen(Vector(p1.X+picture_size/2*view_distance,(p1.Y+p2.Y)/2)))
            else
                Squares[Square_count]:Render(Isaac.WorldToScreen(Vector(p1.X-picture_size/2*view_distance,(p1.Y+p2.Y)/2)))
            end
            Square_count=Square_count+1
            vecToP1.Y=-vecToP1.Y
            if vecToP1.X ~= 0 then
                vecToP1:Resize(math.abs(vecToP1:Length()/vecToP1.X*view_distance))
            end
            vecToP2.Y=-vecToP2.Y
            if vecToP2.X ~= 0 then
                vecToP2:Resize(math.abs(vecToP2:Length()/vecToP2.X*view_distance))
            end
            startSprPlaying(LRspr[LR_count],"triangle")
            LRspr[LR_count].Scale=vecToP1
            LRspr[LR_count].Rotation=0
            LRspr[LR_count]:Render(Isaac.WorldToScreen(p1))
            LR_count=LR_count+1
            startSprPlaying(LRspr[LR_count],"triangle")
            LRspr[LR_count].Scale=vecToP2
            LRspr[LR_count].Rotation=0
            LRspr[LR_count]:Render(Isaac.WorldToScreen(p2))
            LR_count=LR_count+1
        elseif areaId==2 or areaId==8 then
            startSprPlaying(Squares[Square_count],"square")
            Squares[Square_count].Scale=Vector(2*grid_half_size/picture_size,view_distance)
            Squares[Square_count].Rotation=0
            if areaId==2 then
                Squares[Square_count]:Render(Isaac.WorldToScreen(Vector((p1.X+p2.X)/2,p1.Y-picture_size/2*view_distance)))
            else
                Squares[Square_count]:Render(Isaac.WorldToScreen(Vector((p1.X+p2.X)/2,p1.Y+picture_size/2*view_distance)))
            end
            Square_count=Square_count+1
            vecToP1.X=-vecToP1.X
            if vecToP1.Y ~= 0 then
                vecToP1:Resize(math.abs(vecToP1:Length()/vecToP1.Y*view_distance))
            end
            vecToP2.X=-vecToP2.X
            if vecToP2.Y ~= 0 then
                vecToP2:Resize(math.abs(vecToP2:Length()/vecToP2.Y*view_distance))
            end
            startSprPlaying(UDspr[UD_count],"triangle")
            UDspr[UD_count].Scale=vecToP1
            UDspr[UD_count].Rotation=0
            UDspr[UD_count]:Render(Isaac.WorldToScreen(p1))
            UD_count=UD_count+1
            startSprPlaying(UDspr[UD_count],"triangle")
            UDspr[UD_count].Scale=vecToP2
            UDspr[UD_count].Rotation=0
            UDspr[UD_count]:Render(Isaac.WorldToScreen(p2))
            UD_count=UD_count+1
        end
    end
end

local function RenderShadow2(squarePts, targetPt, areaId)

    -- 顶点索引：1左上  2右上  3右下  4左下
    local p1, p2=nil,nil
    if areaId == 1 then
        -- 1 左上区域 → 返回 右上(2)、左下(4)
        p1 = squarePts[2]
        p2 = squarePts[4]
    elseif areaId == 3 then
        -- 3 右上区域 → 返回 左上(1)、右下(3)
        p1 = squarePts[3]
        p2 = squarePts[1]
    elseif areaId == 7 then
        -- 7 左下区域 → 返回 左上(1)、右下(3)
        p1 = squarePts[1]
        p2 = squarePts[3]
    elseif areaId == 9 then
        -- 9 右下区域 → 返回 右上(2)、左下(4)
        p1 = squarePts[4]
        p2 = squarePts[2]
    else
        -- 不是斜角区域，返回空
        return nil
    end
    if p1 and p2 then
        local vecToP1 = p1 - targetPt
        local vecToP2 = p2 - targetPt
        local p1Top2 = p2-p1
        local p2Top1 = p1-p2
        local centerP=(p1+p2)/2
        local angle=0
        if IsVectorObtuse(vecToP1,p2Top1) then
            angle=angle+1
        end
        if IsVectorObtuse(vecToP2,p1Top2) then
            angle=angle+2
        end
        startSprPlaying(Squares[Square_count],"square")
        Squares[Square_count].Scale=Vector(2*grid_half_size/picture_size,2*grid_half_size/picture_size)
        Squares[Square_count].Rotation=0
        Squares[Square_count]:Render(Isaac.WorldToScreen(Vector(centerP.X,centerP.Y)))
        Square_count=Square_count+1
        if angle==0 then
            startSprPlaying(Squares[Square_count],"square")
            Squares[Square_count].Scale=Vector(view_distance,2*SQRT2*grid_half_size/picture_size)
            if areaId==1 then
                Squares[Square_count].Rotation=-45
                Squares[Square_count]:Render(Isaac.WorldToScreen(Vector(centerP.X+picture_size/2/SQRT2*view_distance,centerP.Y-picture_size/2/SQRT2*view_distance)))
            elseif areaId==9 then
                Squares[Square_count].Rotation=-45
                Squares[Square_count]:Render(Isaac.WorldToScreen(Vector(centerP.X-picture_size/2/SQRT2*view_distance,centerP.Y+picture_size/2/SQRT2*view_distance)))
            elseif areaId==3 then
                Squares[Square_count].Rotation=45
                Squares[Square_count]:Render(Isaac.WorldToScreen(Vector(centerP.X-picture_size/2/SQRT2*view_distance,centerP.Y-picture_size/2/SQRT2*view_distance)))
            else
                Squares[Square_count].Rotation=45
                Squares[Square_count]:Render(Isaac.WorldToScreen(Vector(centerP.X+picture_size/2/SQRT2*view_distance,centerP.Y+picture_size/2/SQRT2*view_distance)))
            end
            Square_count=Square_count+1
            local vertial=Vector(p2Top1.Y,-p2Top1.X)
            if IsVectorObtuse(vertial,vecToP1) then
                vertial=-vertial
            end
            local tan1=GetVectorAngleTan(vertial,vecToP1)
            startSprPlaying(UDspr[UD_count],"triangle")
            UDspr[UD_count].Scale=Vector(view_distance*tan1,view_distance)
            UDspr[UD_count].Rotation=(vertial:GetAngleDegrees()+90)
            UDspr[UD_count]:Render(Isaac.WorldToScreen(p1))
            UD_count=UD_count+1
            local tan2=GetVectorAngleTan(vertial,vecToP2)
            startSprPlaying(UDspr[UD_count],"triangle")
            UDspr[UD_count].Scale=Vector(-view_distance*tan2,view_distance)
            UDspr[UD_count].Rotation=-(vertial:GetAngleDegrees()+90)
            UDspr[UD_count]:Render(Isaac.WorldToScreen(p2))
            UD_count=UD_count+1
        else
            local tan=GetVectorAngleTan(vecToP1,vecToP2)
            startSprPlaying(UDspr[UD_count],"triangle")
            UDspr[UD_count].Scale=Vector(view_distance*tan,view_distance)
            UDspr[UD_count].Rotation=(vecToP2:GetAngleDegrees()+90)
            UDspr[UD_count]:Render(Isaac.WorldToScreen(p2))
            UD_count=UD_count+1
            startSprPlaying(UDspr[UD_count],"triangle")
            UDspr[UD_count].Scale=Vector(-view_distance*tan,view_distance)
            UDspr[UD_count].Rotation=-(vecToP1:GetAngleDegrees()+90)
            UDspr[UD_count]:Render(Isaac.WorldToScreen(p1))
            UD_count=UD_count+1
            local can_cross,crossP=GetLineIntersection(p1,vecToP2,p2,vecToP1)
            if not can_cross then
                print("error:can't cross!")
                return
            end
            local h,tan1,tan2,hV=nil,nil,nil,nil
            if angle>=2 then
                h,tan1,tan2,hV=TriangleAltitudeAndTan(p1,p2,crossP)
                h=h+1
                startSprPlaying(UDspr[UD_count],"triangle")
                UDspr[UD_count].Scale=Vector(h*tan2/picture_size,h/picture_size)
                UDspr[UD_count].Rotation=(hV:GetAngleDegrees()+90)
                UDspr[UD_count]:Render(Isaac.WorldToScreen(p1))
                UD_count=UD_count+1
                startSprPlaying(UDspr[UD_count],"triangle")
                UDspr[UD_count].Scale=Vector(-h*tan1/picture_size,h/picture_size)
                UDspr[UD_count].Rotation=-(hV:GetAngleDegrees()+90)
                UDspr[UD_count]:Render(Isaac.WorldToScreen(p1))
                UD_count=UD_count+1
            else
                h,tan1,tan2,hV=TriangleAltitudeAndTan(p2,p1,crossP)
                h=h+1
                startSprPlaying(UDspr[UD_count],"triangle")
                UDspr[UD_count].Scale=Vector(h*tan1/picture_size,h/picture_size)
                UDspr[UD_count].Rotation=(hV:GetAngleDegrees()+90)
                UDspr[UD_count]:Render(Isaac.WorldToScreen(p2))
                UD_count=UD_count+1
                startSprPlaying(UDspr[UD_count],"triangle")
                UDspr[UD_count].Scale=Vector(-h*tan2/picture_size,h/picture_size)
                UDspr[UD_count].Rotation=-(hV:GetAngleDegrees()+90)
                UDspr[UD_count]:Render(Isaac.WorldToScreen(p2))
                UD_count=UD_count+1
            end
        end
    end
end

local function GetFastestAngleDir(angleA, angleB)
    local full = 360
    -- 先把角度规整到 [0, 360) 区间
    local a = angleA % full
    local b = angleB % full
    if a==b then
        return 0
    end
    -- 正向增量：b 不断增加到 a 的差值
    local diffAdd = (a - b) % full
    -- 反向减量：b 不断减少到 a 的差值
    local diffSub = full - diffAdd
    local vel=1
    if math.min(diffAdd,diffSub)<view_rotate_speed then
        vel=math.min(diffAdd,diffSub)/view_rotate_speed
    end
    if diffAdd <= diffSub then
        return vel
    else
        return -vel
    end
end

-- 计算两个二维向量的【最小夹角】(单位：度，范围 0 ~ 180°)
-- 返回值：夹角数值；若存在零向量，返回 nil
local function GetVectorMinAngleDeg(vecA, vecB)
    local lenA = vecA:Length()
    local lenB = vecB:Length()
    local EPS = 0.0001
    -- 零向量无夹角，直接返回 nil
    if lenA < EPS or lenB < EPS then
        return nil
    end

    -- 向量点积
    local dot = vecA.X * vecB.X + vecA.Y * vecB.Y
    -- 计算 cosθ，浮点误差会导致值略超出 [-1,1]，强制钳位
    local cosVal = dot / (lenA * lenB)
    cosVal = math.max(-1, math.min(1, cosVal))

    -- 反余弦求弧度 → 转为角度
    local rad = math.acos(cosVal)
    return math.deg(rad)
end

local function CheckSquareVertexAngle(squarePts, targetPt, dirVec)
    -- 先校验参考方向是否为零向量
    local dirLen = dirVec:Length()
    local EPS = 0.0001
    if dirLen < EPS then
        return false
    end

    -- 遍历正方形四个顶点
    for i = 1, 4 do
        local vertex = squarePts[i]
        -- 构造向量：检测点 targetPt → 顶点 vertex
        local vecPV = Vector(vertex.X - targetPt.X, vertex.Y - targetPt.Y)

        -- 获取当前向量与参考方向的夹角
        local angle = GetVectorMinAngleDeg(vecPV, dirVec)
        -- 跳过零向量(检测点与顶点重合)
        if angle ~= nil then
            -- 只要有一个夹角小于阈值，立即返回 true（短路优化）
            if angle <= view_angle/2+5 then
                return true
            end
        end
    end

    -- 遍历完所有顶点，均不满足条件
    return false
end

function mod:updateShadowRender()
    local l_UD, l_LR, l_S = UD_count, LR_count, Square_count
    UD_count, LR_count, Square_count=1,1,1
    local player= Isaac.GetPlayer()
    local room = Game():GetRoom()
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0) or
    Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0) or
    Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0) or
    Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0)
     then
        local playerDir=player:GetAimDirection()
        if room:IsMirrorWorld() then
            playerDir=Vector(-playerDir.X,playerDir.Y)
        end        
        local aimAngle=playerDir:GetAngleDegrees()
        view_spr.Rotation=view_spr.Rotation+view_rotate_speed*GetFastestAngleDir(aimAngle,view_spr.Rotation)
    end
    local lightPos=player.Position+Vector.FromAngle(view_spr.Rotation)*player.Size/2
    if room:IsMirrorWorld() then
        local view_spr_pos=Isaac.WorldToScreen(lightPos)
        view_spr_pos.X=Isaac.GetScreenWidth()- view_spr_pos.X
        view_spr:Render(view_spr_pos)
        lightPos.X=room:GetCenterPos().X*2- lightPos.X
    else
        view_spr:Render(Isaac.WorldToScreen(lightPos))
    end
    local grids,grid_count,grid_total_num={},1,room:GetGridHeight( )*room:GetGridWidth()
    for i = 1,grid_total_num , 1 do
        local grid=room:GetGridEntity(i)
        if grid then
            if player.CanFly then
                if 
                (grid:GetType()==GridEntityType.GRID_LOCK and grid.State~=1 ) or
                (grid:GetType()==GridEntityType.GRID_PILLAR and grid.State~=2 )
                then
                    grids[grid_count]=grid.Position
                    grid_count=grid_count+1
                end
            else
                if 
                (grid:GetType()==GridEntityType.GRID_ROCK and grid.State~=2 ) or
                (grid:GetType()==GridEntityType.GRID_ROCKB and grid.State~=2 ) or
                (grid:GetType()==GridEntityType.GRID_ROCKT and grid.State~=2 ) or
                (grid:GetType()==GridEntityType.GRID_ROCK_BOMB and grid.State~=2 ) or
                (grid:GetType()==GridEntityType.GRID_ROCK_ALT and grid.State~=2 ) or
                (grid:GetType()==GridEntityType.GRID_LOCK and grid.State~=1) or
                (grid:GetType()==GridEntityType.GRID_TNT and grid.State~=4 ) or
                (grid:GetType()==GridEntityType.GRID_ROCK_SS and grid.State~=2 ) or
                (grid:GetType()==GridEntityType.GRID_PILLAR and grid.State~=2 ) or
                (grid:GetType()==GridEntityType.GRID_ROCK_SPIKED and grid.State~=2 ) or
                (grid:GetType()==GridEntityType.GRID_ROCK_ALT2 and grid.State~=2 ) or
                (grid:GetType()==GridEntityType.GRID_ROCK_GOLD and grid.State~=2 )
                then
                    grids[grid_count]=grid.Position
                    grid_count=grid_count+1
                end
            end
        end
    end
    for k, grid in pairs(grids) do
        local four_vertices=GetSquareVertices(grid)
        if CheckSquareVertexAngle(four_vertices,lightPos,Vector.FromAngle(view_spr.Rotation)) then
            local areaId=JudgeSquareNineArea(four_vertices,lightPos)
            if areaId==5 then
                startSprPlaying(Squares[Square_count],"square")
                Squares[Square_count].Scale=Vector(1,1)
                Squares[Square_count].Rotation=0
                Squares[Square_count]:Render(Isaac.WorldToScreen(lightPos))
                Square_count=Square_count+1
            else
                RenderShadow(four_vertices,lightPos,areaId) 
                RenderShadow2(four_vertices,lightPos,areaId)    
            end
        end
    end
    while l_UD>=UD_count do
        if UDspr[l_UD]:IsPlaying() then
            UDspr[l_UD]:Stop()
        end
        l_UD=l_UD-1
    end
    while l_LR>=LR_count do
        if LRspr[l_LR]:IsPlaying() then
            LRspr[l_LR]:Stop()
        end
        l_LR=l_LR-1
    end
    while l_S>=Square_count do
        if Squares[l_S]:IsPlaying() then
            Squares[l_S]:Stop()
        end
        l_S=l_S-1
    end
end

function mod:darkenRoom()
    Game():Darken(1,10000)
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.updateShadowRender)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.darkenRoom)