
local uiHead = class("uiHead")

local PLAYER_TABLE_STATE = {
	DEFAULT = 0,
	PRE_ENTER_TABLE = 1,
	ENTER_TABLE = 2,
	PRE_LEAVE_TABLE = 3,
	LEAVE_TABLE = 4
}

function uiHead:initVars_()
	self.container_ = nil;
	self.headPanel_ = nil;
	self.m_pLableTimer_ = nil;
	self.game_head_mask_ = nil;
	self.myHeadImage_ = nil;
	self.game_prompt_banker_ = nil;
	self.game_head_bg2_ = nil;
	self.coinPanel_ = nil;
	self.m_pLableGameGold_ = nil;
	self.coinBar_ = nil;
	self.infoPanel_ = nil;
	self.m_pUserName_ = nil;
	self.m_pLableCity_ = nil;
	self.fillPanel_ = nil;
	self.m_pUserStakeLable_ = nil;
    self.myHeadClip_ = nil;
	self.postionNameX = 0;
	self.postionCityX = 0;
	self.positonFillX = 0;
	self.positonFillY = 0;
	self.smallNum = 0
	self.isOpen = false
end
function uiHead:ctor(ui)
	self:initVars_();
	self:initUI_(ui);
	self.tblstate = 0
end

local function getRgb()
	local r = math.random(0,255)
	local g = math.random(0,255)
	local b = math.random(0,255)
	return cc.c3b(r,g,b)
end

function uiHead:getRandColor()
	math.randomseed(global.randomSeed)
	return getRgb()
end
function uiHead:initUI_(ui)
	self.container_= ui;
	self.headPanel_ = self.container_:getChildByName("headPanel");
	self.game_prompt_banker_ = self.headPanel_:getChildByName("game_prompt_banker");
	self.game_prompt_banker_:setText(global.L("game.banker"))
	self.win = self.headPanel_:getChildByName("win");
	self.lose = self.headPanel_:getChildByName("lose");
	self.game_prompt_banker_:setLocalZOrder(5);
	self.game_prompt_banker_:hide();
	self.coinPanel_ = self.container_:getChildByName("coinPanel");
	
	self.infoPanel_ = self.container_:getChildByName("infoPanel");

	self.m_pUserName_ = self.infoPanel_:getChildByName("m_pUserName");
	self.m_pUserName_:setColor(self:getRandColor())
	self.m_pLableGameGold_ = self.coinPanel_:getChildByName("m_pLableGameGold");
	self.m_pLableGameGold_:setColor(self:getRandColor())
	--下注
	self.m_pUserStakeLable_ = ""
    self.headImage = self.headPanel_:getChildByName("headImage")
end

function uiHead:getScore()
	self.score = self.score or 0
	return self.score
end

function uiHead:setScore(score)
	self.score = score
	self.m_pLableGameGold_:setString(score);
end

function uiHead:setOpenCard()
	self.isOpen = true
end



function uiHead:setStakeLable(fillLabel)
	self.m_pUserStakeLable_:setString(fillLabel)
end

function uiHead:isBanker()
	return self.banker
end

function uiHead:setBanker()
	self.banker = true
	self.game_prompt_banker_:setVisible(true);
end


function uiHead:isInTable()
	return (self.tblstate > PLAYER_TABLE_STATE.DEFAULT) and (self.tblstate <= PLAYER_TABLE_STATE.PRE_LEAVE_TABLE)
end

function uiHead:isPreEnterTable()
	return (self.tblstate == PLAYER_TABLE_STATE.PRE_ENTER_TABLE)
end

function uiHead:isPreLeaveTable()
	return (self.tblstate == PLAYER_TABLE_STATE.PRE_LEAVE_TABLE)
end

function uiHead:isLeaveTable()
	
end

local function getStateName(state)
	for k, v in pairs(PLAYER_TABLE_STATE) do
		if state == v then
			return k
		end
	end
end
function uiHead:preEnterTable()
	if (self.tblstate == PLAYER_TABLE_STATE.DEFAULT) or (self.tblstate == PLAYER_TABLE_STATE.PRE_LEAVE_TABLE) or (self.tblstate == PLAYER_TABLE_STATE.LEAVE_TABLE) then
		self.tblstate = PLAYER_TABLE_STATE.PRE_ENTER_TABLE
	else
		print("uiHead:preEnterTable failed! state = "..tostring(getStateName(self.tblstate)))			
	end
end
function uiHead:enterTable()
	if (self.tblstate == PLAYER_TABLE_STATE.DEFAULT) or (self.tblstate == PLAYER_TABLE_STATE.PRE_ENTER_TABLE) or (self.tblstate == PLAYER_TABLE_STATE.PRE_LEAVE_TABLE) or (self.tblstate == PLAYER_TABLE_STATE.LEAVE_TABLE)then
		self.tblstate = PLAYER_TABLE_STATE.ENTER_TABLE
		self.container_:setVisible(true)
	else
		print(tostring(self.name).."uiHead:enterTable failed! state = "..tostring(getStateName(self.tblstate)))
	end
end
function uiHead:preLeaveTable()
	if (self.tblstate == PLAYER_TABLE_STATE.ENTER_TABLE) or (self.tblstate == PLAYER_TABLE_STATE.PRE_ENTER_TABLE) then
		self.tblstate = PLAYER_TABLE_STATE.PRE_LEAVE_TABLE
	else
		print("uiHead:preLeaveTable failed! state = "..tostring(getStateName(self.tblstate)))	
	end
end
function uiHead:leaveTable()
	if (self.tblstate == PLAYER_TABLE_STATE.PRE_LEAVE_TABLE) or (self.tblstate == PLAYER_TABLE_STATE.DEFAULT) then
		self.tblstate = PLAYER_TABLE_STATE.LEAVE_TABLE
		self.container_:setVisible(false)
	else
		print("uiHead:leaveTable failed! state = "..tostring(getStateName(self.tblstate)))		
	end
end


function uiHead:printState()
	-- body
	print(tostring(self.name) .." uiHead:printState state = "..tostring(getStateName(self.tblstate)))		
end

function uiHead:setCards(cards)
	self.cards = cards
end

function uiHead:getCards()
	return self.cards
end

function uiHead:setPreBalance(num)
	self.prebalance = num
end

function uiHead:getPreBalance()
	self.prebalance = self.prebalance or 0
	return self.prebalance
end

function uiHead:addPreBalance(num)
	self.smallNum = self.smallNum + num
	self.prebalance = self.prebalance or 0
	self.prebalance = self.prebalance + num
end

function uiHead:getUserName()
	self.name = self.name or ""
	return self.name
end

function uiHead:setData(name,score,wcliChairID)
	self:enterTable()
	self.name = name
	self.m_pUserName_:setString(name);
	self:setScore(score,wcliChairID)

	wcliChairID = wcliChairID or 0

	local str = ""
	if wcliChairID == 1 then
		str = "game/niuniu/resource/head/headName1.png"
	else
		str = "game/niuniu/resource/head/headName2.png"
	end
	self.headImage:loadTexture(str, 0)
end

function uiHead:getPosition()
	return self.container_:getPosition();
end

function uiHead:getSize()
    return self.container_:getContentSize();
end
function uiHead:uiHide()
    self.isShowed_ = false;
	self.container_:setVisible(false);      
end

function uiHead:showResultGold(gold, delay,index)
    local tag = 2

    local text_res = nil
    local text_bg = nil
    local str = ""
    if gold > 0 then
        text_res = "game/niuniu/resource/win_num.png"
        text_bg = "game/niuniu/resource/winnum_bg.png"
    else
        text_res = "game/niuniu/resource/lose_num.png"
        text_bg = "game/niuniu/resource/losenum_bg.png"
	end
	
	local result_num = cc.Label:createWithCharMap(text_res, 18, 26, 43)
	local x,y = self.win:getPosition()
    result_num:setPosition(cc.p(x,y))
    result_num:setString(tostring(gold))
    result_num:setAdditionalKerning(-3)
    self.headPanel_:addChild(result_num, 10000)
    result_num:setVisible(false)


    if index == 1 then
        if gold > 0 then
            result_num:setScale(1.4)
        else
            result_num:setScale(1.2)
        end
    else
        if gold > 0 then
            result_num:setScale(1.3)
        else
            result_num:setScale(1.1)
        end
    end

    result_num:runAction(cc.Sequence:create(
		cc.DelayTime:create(delay),
		cc.CallFunc:create(function()
			result_num:setVisible(true)
		end),
		cc.MoveBy:create(0.8, cc.p(0, 60)),
		cc.CallFunc:create(function()
		--刷新金币
		--global.event.emit("refreshCoin")
		end),
		cc.DelayTime:create(1.5),
		cc.FadeOut:create(0.5),
		cc.RemoveSelf:create()
    ))

    local numbg = cc.Sprite:create(text_bg)
    numbg:setPosition(cc.p(x,y-10))
    self.headPanel_:addChild(numbg, 9)
    numbg:setVisible(false)
    numbg:runAction(cc.Sequence:create(
    cc.DelayTime:create(delay),
		cc.CallFunc:create(function()
			numbg:setVisible(true)
		end),
		cc.MoveBy:create(0.8, cc.p(0, 60)),
		cc.DelayTime:create(1.5),
		cc.FadeOut:create(0.5),
		cc.RemoveSelf:create()
    ))

end

function uiHead:produceRandomData()
	self.banker = false
	local name = _ReadLocal:getRandomUserName()
	local score = _ReadLocal:getRandomScore()

	self:setData(name, score,2)
end

function uiHead:smallBalance()
	return self.smallNum
end




return uiHead;
