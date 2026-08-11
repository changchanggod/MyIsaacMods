local mod = RegisterMod("Conjugated Gemini", 1)
local keyboardMap={
    {Keyboard.KEY_1,Keyboard.KEY_2,Keyboard.KEY_3,Keyboard.KEY_4,Keyboard.KEY_5,Keyboard.KEY_6,Keyboard.KEY_7,Keyboard.KEY_8,Keyboard.KEY_9,Keyboard.KEY_0},
    {Keyboard.KEY_Q,Keyboard.KEY_W,Keyboard.KEY_E,Keyboard.KEY_R,Keyboard.KEY_T,Keyboard.KEY_Y,Keyboard.KEY_U,Keyboard.KEY_I,Keyboard.KEY_O,Keyboard.KEY_P},
    {Keyboard.KEY_A,Keyboard.KEY_S,Keyboard.KEY_D,Keyboard.KEY_F,Keyboard.KEY_G,Keyboard.KEY_H,Keyboard.KEY_J,Keyboard.KEY_K,Keyboard.KEY_L,Keyboard.KEY_SEMICOLON},
    {Keyboard.KEY_Z,Keyboard.KEY_X,Keyboard.KEY_C,Keyboard.KEY_V,Keyboard.KEY_B,Keyboard.KEY_N,Keyboard.KEY_M,Keyboard.KEY_COMMA,Keyboard.KEY_PERIOD,Keyboard.KEY_SLASH}
}
local rLeft=false
local rRight=false
local rUp=false
local rDown=false
local DownKey,LeftKey,RightKey,UpKey =nil,nil,nil,nil
local DownPos,LeftPos,RightPos,UpPos =nil,nil,nil,nil
local DownKeyPos=Vector(3,2)
local point=Vector(0,0)
local NUM00001111=15
local NUM11110000=240
local function UpdateKeyNum(pos)
    local row, column = DownKeyPos.X, DownKeyPos.Y
    DownKey = keyboardMap[row][column]
    -- DownPos 改为 Vector
    DownPos = Vector(row, column)

    if column == 1 then
        LeftKey = keyboardMap[row][#keyboardMap[row]]
        -- LeftPos Vector
        LeftPos = Vector(row, #keyboardMap[row])
    else
        LeftKey = keyboardMap[row][column - 1]
        LeftPos = Vector(row, column - 1)
    end

    if column == #keyboardMap[row] then
        RightKey = keyboardMap[row][1]
        -- RightPos Vector
        RightPos = Vector(row, 1)
    else
        RightKey = keyboardMap[row][column + 1]
        RightPos = Vector(row, column + 1)
    end

    if row == 1 then
        UpKey = keyboardMap[#keyboardMap][column]
        -- UpPos Vector
        UpPos = Vector(#keyboardMap, column)
    else
        UpKey = keyboardMap[row - 1][column]
        UpPos = Vector(row - 1, column)
    end
end
UpdateKeyNum(DownKeyPos)
function mod:getPlayerAction(_)
    if Input.IsButtonPressed(LeftKey, 0) then
        rLeft=true
    else 
        rLeft=false
    end
    if Input.IsButtonPressed(RightKey, 0) then
        rRight=true
    else 
        rRight=false
    end
    if Input.IsButtonPressed(UpKey, 0) then
        rUp=true
    else 
        rUp=false
    end
    if Input.IsButtonPressed(DownKey, 0) then
        rDown=true
    else 
        rDown=false
    end
end
function mod:JudgePlayerAction(Ent, InputH, ButtonA)
    if Ent == nil then
        return nil
    end
    if InputH==InputHook.GET_ACTION_VALUE then
        if ButtonA==ButtonAction.ACTION_LEFT then
            if rLeft then
                return 1.0
            else
                return 0
            end
        end
        if ButtonA==ButtonAction.ACTION_RIGHT then
            if rRight then
                return 1.0
            else
                return 0
            end
        end
        if ButtonA==ButtonAction.ACTION_UP then
            if rUp then
                return 1.0
            else
                return 0
            end
        end
        if ButtonA==ButtonAction.ACTION_DOWN then
            if rDown then
                return 1.0
            else
                return 0
            end
        end
    end
    return nil
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.getPlayerAction)
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, mod.JudgePlayerAction)
local keyboardMapChar = {
    -- 第一行：主键盘数字 1 2 3 4 5 6 7 8 9 0
    {'1','2','3','4','5','6','7','8','9','0'},
    -- 第二行：Q W E R T Y U I O P
    {'Q','W','E','R','T','Y','U','I','O','P'},
    -- 第三行：A S D F G H J K L ;
    {'A','S','D','F','G','H','J','K','L',';'},
    -- 第四行：Z X C V B N M , . /
    {'Z','X','C','V','B','N','M',',','.','/'}
}
local sprScale=5
local sprSize = 100/sprScale
-- 布局边距（可按需调整）
local marginX = 20
local marginY = 20

local rowTotal = #keyboardMapChar
local colTotal = #keyboardMapChar[1]

-- 仅全局初始化：创建并加载所有精灵（只执行1次，不渲染）
local keyBoardSpr = {}
for i = 1, rowTotal do
    keyBoardSpr[i] = {}
    for j = 1, colTotal do
        local spr = Sprite()
        spr:Load("gfx/keyBoard.anm2", true)
        spr:Play("keyBoard", false)
        spr.Scale = Vector.One/sprScale
        keyBoardSpr[i][j] = spr
    end
end
local pointSpr=Sprite()
pointSpr:Load("gfx/point.anm2",true)
pointSpr:Play("point",false)
pointSpr.Scale = Vector.One/2
local pointSprPos=Vector.Zero
-- 每帧执行的渲染函数
function mod:RenderKeyBoard()
    -- 实时获取当前屏幕尺寸
    local screenHeight, screenWidth = Isaac.GetScreenHeight(), Isaac.GetScreenWidth()
    
    -- 计算键盘整体尺寸 + 左下角起点
    local boardTotalW = colTotal * sprSize
    local boardTotalH = rowTotal * sprSize
    local boardOriginX = marginX
    local boardOriginY = screenHeight - boardTotalH - marginY

    -- 遍历所有按键精灵，逐帧绘制
    for i = 1, rowTotal do
        for j = 1, colTotal do
            local tileLeftX = boardOriginX + (j - 1) * sprSize
            local tileTopY = boardOriginY + (i - 1) * sprSize
            local centerPos = Vector(tileLeftX + sprSize / 2, tileTopY + sprSize / 2)
            -- 统一配置所有移动方向：位置坐标 + 按下状态标记
            local moveDirs = {
                { pos = DownPos,  pressed = rDown  },
                { pos = LeftPos,  pressed = rLeft  },
                { pos = RightPos, pressed = rRight },
                { pos = UpPos,    pressed = rUp    },
            }
            local isDownKey = false
            local isMoveKey = false  -- 当前格子属于任意移动键的位置
            local isPress = false    -- 当前格子是被按住的移动键

            for count, dir in ipairs(moveDirs) do
                local pos = dir.pos
                -- 跳过pos为空的情况，防止nil下标报错
                if pos then
                    local isThisDir = (i == pos.X and j == pos.Y)
                    if isThisDir then
                        isMoveKey = true
                        if count==1 then
                            isDownKey=true
                        end
                        -- 该方向键位置匹配，且处于按下状态
                        if dir.pressed then
                            isPress = true
                        end
                    end
                end
            end
            if isPress then
                keyBoardSpr[i][j]:Play("keyBoardPress",true)
            else
                if isMoveKey then
                    keyBoardSpr[i][j]:Play("keyBoardMove",true)
                else 
                    keyBoardSpr[i][j]:Play("keyBoard",true)
                end
            end
            -- 绘制当前按键
            keyBoardSpr[i][j]:Render(centerPos)
            Isaac.RenderText(keyboardMapChar[i][j],centerPos.X- sprSize/8,centerPos.Y-sprSize/4,0,0,0,1)
            if isDownKey then
                pointSprPos= Vector(centerPos.X+point.Y*sprSize/2,centerPos.Y+point.X*sprSize/2)
            end
        end
    end
    pointSpr:Render(pointSprPos)
end
local din=Isaac.GetSoundIdByName("din")

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.RenderKeyBoard)
local moveSpeed = 2 / 60
function mod:movePoint()
    -- 上：Y增大（屏幕Y轴向下）
    if rUp then
        point.X = point.X - moveSpeed
    end
    -- 下：Y减小
    if rDown then
        point.X = point.X + moveSpeed
    end
    -- 左：X减小
    if rLeft then
        point.Y = point.Y - moveSpeed
    end
    -- 右：X增大
    if rRight then
        point.Y = point.Y + moveSpeed
    end
    local change=false
    if point.X <-1.4 then
        if DownKeyPos.X==1 then
            DownKeyPos.X=#keyboardMap
        else
            DownKeyPos.X=DownKeyPos.X-1
        end
        point.X=0.6
        change=true
    end
    if point.X>1.4 then
        if DownKeyPos.X==#keyboardMap then
            DownKeyPos.X=1
        else
            DownKeyPos.X=DownKeyPos.X+1
        end
        point.X=-0.6
        change=true
    end
    if point.Y<-1 then
        if DownKeyPos.Y==1 then
            DownKeyPos.Y=#keyboardMap[DownKeyPos.X]
        else
            DownKeyPos.Y=DownKeyPos.Y-1
        end
        point.Y=0.8
        change=true
    end
    if point.Y>1.2 then
        if DownKeyPos.Y==#keyboardMap[DownKeyPos.X] then
            DownKeyPos.Y=1
        else
            DownKeyPos.Y=DownKeyPos.Y+1
        end
        point.Y=-0.8
        change=true
    end
    if change then
        UpdateKeyNum(DownKeyPos)
        SFXManager():Play(din,10)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.movePoint)