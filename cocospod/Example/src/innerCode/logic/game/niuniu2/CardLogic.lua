local CardLogic = class("CardLogic")

local Shuffle = cc.load("tools").Shuffle
--_CardState = {eCardState_null = 0, eCardState_An = 1, eCardState_Ming = 2, eCardState_Shu = 3,eCardState_Qi = 4};

function CardLogic:ctor()
end

local function getCardColor(num)
    return (math.floor(num/13))
end

local function getCardVal(num)
    return (num % 13 + 1)
end

local function getNiuNiuCardVal(num)
    return math.min(getCardVal(num), 10)
end

function CardLogic:getType( source )
    local type = 0
    local cardsValue = {}
    for i,v in ipairs(source) do
        local color,value = self:getColorValue(v)
        if value > 10 then
            value = 10
        end
        table.insert(cardsValue,value)
    end
    local lave = 0     --余数  
    for i = 1,#cardsValue do  
        lave = lave + cardsValue[i]  
    end  
    if lave == 0 then
        return 0
    end
    lave = lave % 10  
    for i = 1,#cardsValue - 1 do  
        for j = i + 1,#cardsValue do  
            if(cardsValue[i]+cardsValue[j])%10 == lave then  
                if lave == 0 then  
                    return 10,i,j  
                else  
                    return lave,i,j  
                end  
            end  
        end  
    end   
    return 0  
end
--0=��,1=÷,2=��,3=��
function CardLogic:parseCard(data)
    local des_color = math.floor( data / 13 )
    local num = data - 13*des_color
    if num == 0 then
        des_color = des_color - 1
        num = data - 13*des_color
    end
    --print(num,des_color)
    return {num,des_color}
end

function CardLogic:getName(type)
    require("config.GoldFlower_CardsCFG")
    local data = GoldFlower_CardsCFG:getData(type)
    return data.CardsName
end

function CardLogic:getColorValue(data)
    if data == nil then
        return nil, nil
    end
    local color = data.card_color
    local value = data.card_value
    return color,value
end

function CardLogic:resetCardShuffle()
    self.curVal = nil
    self.shuffleValue = nil
end

function CardLogic:getCardShuffle()
    if self.shuffleValue then
        return self.curVal, self.shuffleValue
    end

    --洗牌器
    math.randomseed(tostring(os.time()):reverse():sub(1, 5))

    local shuffleValue = Shuffle.new()
    shuffleValue:initNumByRange(0,51)
    self.shuffleValue = shuffleValue
    self.curVal = shuffleValue:start()

    return self.curVal, self.shuffleValue 
end

--设置牌值
function CardLogic:getCardData()
    local cards_data = {}
    local value = self:getCardShuffle()
    for i = 1,5 do 
        local val = value.next()
        local n = getCardVal(val)
        cards_data[i] = {card_color = getCardColor(val), card_value = n,card_count = getNiuNiuCardVal(val)}
    end
    return cards_data
end

function CardLogic:flipCards(poker,param,delay_time,act_time, callfunc)
    local delay = delay_time or 0
    local act_time = act_time or 0.2
    local color,value = self:getColorValue(param)
    local action0 = cc.DelayTime:create(delay)
    local action11 = cc.RotateTo:create(act_time, {x=0, y=-90, z=0});
    local action12 = cc.MoveBy:create(act_time, {x=-20, y=0});
    local action16 = cc.Spawn:create(action11, action12);
    local function setPokerCallBack()
        self:showPoker(poker,color,value)
        poker:setRotation3D({x=0, y=90, z=0});
    end
    
    local action13 = cc.CallFunc:create(setPokerCallBack);
    local action14 = cc.RotateTo:create(act_time, {x=0, y=0, z=0});
    local action15 = cc.MoveBy:create(act_time, {x=20, y=0});--20
    local action17 = cc.Spawn:create(action14, action15);

    if callfunc then
        local openAction = cc.Sequence:create(action0,action16, action13, action17, callfunc);
        poker:runAction(openAction)
    else
        local openAction = cc.Sequence:create(action0,action16, action13, action17);
        poker:runAction(openAction)
    end
end


--显示牌值
function CardLogic:showCard(poker,param)
    local color,value = self:getColorValue(param)
    self:showPoker(poker,color,value)
end

function CardLogic:showPoker(poker,design,num)
    -- print("showPoker == ", poker,design,num)
    local pokerbg = poker:getChildByName("pokerbg")
    pokerbg:loadTexture("foreground.png",1)
    if design == nil or num == nil then
        return
    end
    local color = poker:getChildByName("color")
    color:loadTexture("color_s_"..design..".png",1)
    color:setVisible(true)
    --牌值
    local value = poker:getChildByName("value")
    if design%2==0 then
        value:loadTexture("red"..num..".png",1)
    else
        value:loadTexture("black"..num..".png",1)
    end
    value:setVisible(true)
    --花色
    local icon = poker:getChildByName("icon")
    icon:loadTexture("color_"..design..".png",1)
    icon:setVisible(true)
end

function CardLogic:showBanker( poker )
    local zhuang = self.pokers[5]:getChildByName("zhuang")
    zhuang:loadTexture("robcows_zhaung.png",1)
    zhuang:setVisible(true)
end

function CardLogic:clearPoker( poker  )
    local pokerbg = ccui.Helper:seekWidgetByName(poker,"pokerbg")
    pokerbg:loadTexture("game/niuniu/resource/game/background.png",0)
    
    local color = ccui.Helper:seekWidgetByName(poker,"color")
    color:setVisible(false)

    local value = ccui.Helper:seekWidgetByName(poker,"value")
    value:setVisible(false)
    
    local icon = ccui.Helper:seekWidgetByName(poker,"icon")
    icon:setVisible(false)
   
    local zhuang = ccui.Helper:seekWidgetByName(poker,"zhuang")
    zhuang:setVisible(false)
end


return CardLogic