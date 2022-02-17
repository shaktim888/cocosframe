local cardTool = class("cardTool")

---花色0-4 牌值：1-13 
local seq = nil
--五小牛>炸弹>金牛>银牛>牛牛>有牛>没牛
local CardType =
{

    NOT_NIU=0,        --没牛
    NIU_1 =1,         --牛一
    NIU_2 =2,         --牛二
    NIU_3 =3,         --牛三
    NIU_4 =4,         --牛四
    NIU_5 =5,         --牛五
    NIU_6 =6,         --牛六
    NIU_7 =7,         --牛七
    NIU_8 =8,         --牛八
    NIU_9 =9,         --牛九
    NIU_NIU = 10,      --牛牛
    SEQUENCE_NIU = 11, --顺子牛
    SAME_NIU = 12,    -- 同花牛
    GOLD_NIU= 13,      --五花牛  都是大于等于10
    BOMB = 14,        --炸弹
    SMALL_NIU = 15,   --五小牛  都小于5
}
local CardTypeCount = table.nums(CardType)

function cardTool:onCreate()
    
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

function cardTool:getCardtblByNum(num)
    return getCardColor(num), getCardVal(num)
end

function cardTool:sortByCardsValue(cards)
    
    local function compByCardsValue(a, b)
        if a.card_value < b.card_value then
            return true
        end

        if a.card_value > b.card_value then
            return false
        end

        return a.card_color < b.card_color
    end
    table.sort(cards, compByCardsValue);
    seq = cards
end

function cardTool:is_small_niu(cards)
    
    local sum = 0     
    for i = 1,#cards do
        sum = sum + cards[i].card_count
    end
    if sum <= 10 then
        return true
    else
        return false
    end
end

function cardTool:is_bomb(cards)

    if cards[1].card_value == cards[4].card_value then
        return true
    elseif cards[2].card_value == cards[5].card_value then
        return true
    else
        return false
    end
end

function cardTool:is_gold_niu(cards)
    if cards[1].card_value > 10 then
        return true
    else
        return false
    end
end

function cardTool:is_same_niu(cards)
    local idx = 0
    for i =1,4 do
        if cards[i].card_color == cards[i+1].card_color  then
            idx = idx + 1
        end
       
    end
    if idx == 4 then
        return true
    else
        return false
    end
end
function cardTool:is_sequence_niu(cards)
    local idx = 0
    for i = 1,4 do 
        if cards[i].card_value + 1  == cards[i+1].card_value then
            idx = idx + 1 
        end
        
    end
    if idx == 4 then
        return true
    else
        return false
    end
end

function cardTool:getNiubyCards(cards)
    local lave = 0     --余数
    for i = 1,#cards do
        lave = lave + cards[i].card_count
    end
    lave = lave % 10
    for i = 1,#cards - 1 do
        for j = i + 1,#cards do
            if(cards[i].card_count+cards[j].card_count)%10 == lave then
                if lave == 0 then
                    return 10
                else
                    return lave
                end
            end
        end
    end
    return 0
end

function cardTool:getTypeName(cardtype)
    for k, v in pairs(CardType) do
        if v == cardtype then
            return k
        end
    end
end

function cardTool:getTypebyCards(data)
    
    self:sortByCardsValue(data)
    local cardtype = CardType.NOT_NIU
    if cardTool:is_small_niu(seq) then
        cardtype = CardType.SMALL_NIU
        return cardtype
    end
    if cardTool:is_bomb(seq) then
        cardtype = CardType.BOMB
        return cardtype
    end 
    if cardTool:is_gold_niu(seq) then
        cardtype = CardType.GOLD_NIU
        return cardtype
    end
 
    if cardTool:is_same_niu(seq) then
        cardtype = CardType.SAME_NIU
        return cardtype
    end
    if cardTool:is_sequence_niu(seq) then
        cardtype = CardType.SEQUENCE_NIU
        return cardtype
    end

    cardtype=cardTool:getNiubyCards(seq)
    return cardtype
end

function cardTool:getTypeCoin(type)
    local mul  = 0
    if type>=0 and type<=6 then 
        mul = 1
    elseif type>=7 and type<=9 then
        mul = 2 
    elseif type == 10 then
        mul =3
    elseif type == 11 or type == 12 then
        mul = 4 
    elseif type == 13 then
        mul = 5 
    elseif type == 14 then 
        mul = 6 
    elseif type == 15 then
        mul = 7
    end
    return mul 
end

function cardTool:getRandomCardType()
    local index = math.random(1, 10)
    if index < 3 then
        return math.random(1, CardTypeCount)
    else
        return CardType.NOT_NIU
    end
end

function cardTool:getCardsByCardType()
    
end

--[[
    获取整牛的牌型 3张牌
        {	
        card_color = 2,	
        card_count = 10,	
        card_value = 10,	
    },	
]]
function cardTool:getCardsWithNiu(cardtype)
    if cardtype == CardType.NOT_NIU then
        return 
    end

    -- 非特殊牛 非五小牛  非五花牛 非同花牛
    local cardnum1 = math.random(1, 13)

    -- if cardtype < CardType.NIU_NIU then

    -- else
    
    -- end
end
return cardTool