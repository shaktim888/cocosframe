
local UICardsNew = class("UICardsNew", function()  
    return cc.Node:create()  
end  
)  
local PokerPos = {{x=95.69, y=183.81}, {x=155.69, y=183.81}, {x=215.69, y=183.81},{0,0}};
local otherPos = {{x=111.2, y=183}, {x=154.4, y=183}, {x=197.6, y=183}}
local tipPos = { {x=228,y=82},{x=228,y=82},{x=260,y=43},{x=75,y=82},{x=75,y=82} }

UICardsNew.itempos = {
    cc.p(60  , 80),
    cc.p(110  ,80), 
    cc.p(160 , 80),
    cc.p(210 , 80),
    cc.p(260 , 80)
};

function UICardsNew:ctor(index)
    self.index = index
    self.pokers = {}
    for i = 1, 5 do
        -- local poker = cc.CSLoader:createNode("game/niuniu/Poker.csb")
        local poker = require("game/niuniu/Poker.lua").create().root
        poker:setScale(0.8);
        local pos =  self:convertToNodeSpace(self.itempos[i])
        poker:setPosition(pos)
        self:addChild(poker)
        self.pokers[i] = poker:getChildByName("root")
    end
end

function UICardsNew:setStartPos( pos )
    self.startPos = pos
end

function UICardsNew:showBanker()
    local zhuang = self.pokers[5]:getChildByName("zhuang")
    zhuang:setVisible(true)
end

function UICardsNew:setPokers(pokers,type,delay)
    local callfunc =  cc.CallFunc:create(function ()
        self:showType(type) 
    end)
    for i = 1, #pokers do
        local tmp_callfunc = (i == #pokers) and callfunc or nil
        -- _CardLogic:flipCards(self.pokers[i],pokers[i],delay,0.02, tmp_callfunc)
        _CardLogic:showCard(self.pokers[i],pokers[i])
        self:showType(type) 
    end 
end


function UICardsNew:dealEndState()
    for i=1,5 do
        self.pokers[i]:stopAllActions()
        self.pokers[i]:setPosition(self.originPos[i])
    end
    self:setVisible(true)
end

function UICardsNew:playDone()
    for i=1,5 do
        self.pokers[i]:setVisible(true)
    end
end

function UICardsNew:showType(type)
    if self.type_node then
        return
    end
    --lua
    -- local  csb_name = "game/niuniu/animate/niu"..type..".lua"
    -- local animate  = require(csb_name).create()
    -- self.type_node = animate.root
    -- self.type_node:runAction(animate.animation)
    -- self:addChild(self.type_node)
    -- animate.animation:gotoFrameAndPlay(0, false) 
    local str = global.L(string.format("niu.niu%s",type))
    local text_cardtype = ccui.Text:create(str, "game/niuniu/resource/font/font.TTF", 50)
    local text_img = ccui.ImageView:create("game/niuniu/resource/game/showcard.png")
    text_img:setPosition(150,40)
    self:addChild(text_img)
    self.type_node = text_cardtype
    local color = cc.c3b(255, 200, 47 )
    if type == 0 then
        color = cc.c3b(81, 210, 236)
    end
    self.type_node:setColor(color)
    self.type_node:setPosition(150,40)
    self:addChild(self.type_node) 
   
    local str = string.format("game/niuniu/sound/niu%d.mp3",type)
    AudioEngine.playEffect(str,false)
   
    --csb
    -- self.type_node = cc.CSLoader:createNode(csb_name)
    -- local act = cc.CSLoader:createTimeline(csb_name)
    -- act:gotoFrameAndPlay(0, false) 
    -- self.type_node:runAction(act)
end

function UICardsNew:setDark()
    for i=1,3 do
        --self.pokers[i]:setColor(cc.c3b(96,96,96))
        self.pokers[i]:getChildByName("mask"):setVisible(true)
    end
end

function UICardsNew:clear()
    self:setVisible(false)
    for i=1,5 do
        _CardLogic:clearPoker(self.pokers[i])
    end

    if self.type_node then
        self.type_node:removeFromParent()
        self.type_node = nil
    end    
end

function UICardsNew:onDestroy()

end


return UICardsNew;