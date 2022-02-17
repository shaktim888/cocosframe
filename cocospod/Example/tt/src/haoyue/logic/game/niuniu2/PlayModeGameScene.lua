local gameScene = class("gameScene", cc.load("mvc").ModuleBase)
cc.exports._CardLogic = require("logic.game.niuniu2.CardLogic").new()
cc.exports._ReadLocal = require("logic.game.niuniu2.readLocal").new()
cc.exports.GAMEPLAYER_NIUNIU = 6
cc.exports.rule = import(".rule")
local UICardsClass = require("logic.game.niuniu2.cardNew")
gameScene.RESOURCE_FILENAME = "game/niuniu/game.lua"
local cardTool = require("logic.game.niuniu2.logic.cardTool")
local UIHead = import(".uiHead")
gameScene.behavior ={
    "logic.common.behavior.FontColorChange",
}
gameScene.changecolorfont = {
    btn_noniu = {},
    btndisplay = {},
    gameStartBtn = {},
    continueBtn = {},
    bet1 = {},
    bet2 = {},
    bet3 = {},
    bet4 = {}
}



local BaseScore = 100
local random_counter = 1
local MaxRound = 10

local  function random(t, e)
    random_counter = random_counter + 1
    math.randomseed(os.time() + random_counter)
    for i = 1, 6 do
        math.random()
    end
    return math.random(t, e)
end

function gameScene:onCreate()
    audio.playMusic("game/niuniu/sound/bgm.mp3",true)
    self:init()
    self:initOwnArea()
    self:initHead()
    self:initSound()
    if global.isGrabScreenMode == 1 then
        self:ongameStartBtnClick()
        self:onbet4Click()
    end
end

function gameScene:initSound()
    local effect = global.saveTools.getData("nwpk_effectPercent")
    local music = global.saveTools.getData("nwpk_musicPercent")
    local perEffect = 1
    local perMusic = 0.5
    if effect then
        perEffect = effect
    end
    if music then
        perMusic = music
    end
    global.utils.sound.setEffectVolume(perEffect) 
    global.utils.sound.setMusicVolume(perMusic)
end

function gameScene:init()
    self.randIndex = 0
    self.seq = 0
    self.ownPokers = {}
    self.cardindex = 0
    self.bigBalanceNum = 0
    BaseScore = 100
    self.ownPokerdata = nil
    self.mainbg = self.mView["topPanel"]
    self.havebtn = self.mView["btndisplay"]
    self.havebtn:setTitleText(global.L("game.btndisplay"))
    self.btn_noniu = self.mView["btn_noniu"]
    self.btn_noniu:setTitleText(global.L("niu.niu0"))
    self.gamestart = self.mView["gameStartBtn"]
    self.gamestart:setTitleText(global.L("game.start_btn"))
    self.continueBtn = self.mView["continueBtn"]
    self.continueBtn:setTitleText(global.L("game.continue_btn"))
    for i = 1,4 do
        self.mView["bet"..i]:setTitleText(i..global.L("game.rate_btn"))
    end
    self.betpnl = self.mView["betpnl"]
    self.betpnl:setVisible(false)
    self.playerpnl = self.mView["playerpnl"]
    self.cardpnl = self.mView["cardpnl"]
    self.destNum = self.mView["destNum"]
    self.destNum:setString(tostring(self.bigBalanceNum+1).."/"..tostring(MaxRound))
end

function gameScene:onEnterTransitionFinish()
    -- print("gameScene:onEnterTransitionFinish ======")
    self.schedulehandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.updatePerFrame), 1, false)
end

function gameScene:onExit()
    -- print("gameScene:onExit ======")
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulehandler)
end

  --玩家进行随机摊牌

function gameScene:updatePerFrame(dt)
    -- print("gameScene:updatePerFrame ======"..tostring(dt))
    local curtime = os.time()
    for i=2,GAMEPLAYER_NIUNIU do
        local player = self.m_pUserInfo[i]
        if player then
            -- 玩家在场上的存活时间  
            if not player.livetime then
                local livetime = (math.random(3, 6) * 10)
                player.livetime = os.time() + livetime
                print(" player.livetime == "..tostring(livetime))
            else
                -- 超过时间 就要发起离开状态  在下一局开始的时候正式离开
                if player.livetime < curtime then
                    if self:determinateHasAI() then
                        player.livetime = nil
                        if player:isInTable() then
                            player:preLeaveTable()
                        else
                            player:preEnterTable()
                        end
                    end
                end
            end
        end
    end
   
    if self.isShowDown then
        if not self.openSeq then
            self.openSeq = self:getOpenSeq()
        end
        self.seq = self.seq + dt 
        if #self.openSeq ~= 0 then
            for k,v in ipairs(self.openSeq) do
                if self.seq > v.opentime then
                    print("当前时间为：",self.seq)
                    print("当前开牌的id:",v.id)
                    local pokerdata = _CardLogic:getCardData()
                    local pokertype = cardTool:getTypebyCards(pokerdata)
                    self.cards[v.id]:stopAllActions()
                    self.cards[v.id]:setPokers(pokerdata, pokertype, 1)
                    self.cards[v.id]:setVisible(true)
                    self.m_pUserInfo[v.id]:setCards(pokerdata)
                    self.m_pUserInfo[v.id]:setOpenCard()
                    self.mView["NodeAI"..v.id]:removeAllChildren(true)
                    table.remove(self.openSeq,k)
                end
            end    
        else
            self.isShowDown = false
            if self.m_pUserInfo[1].isOpen then
                self:enterBalance()
            end
        end
    end
end

function gameScene:determinateHasAI()
    return ((math.random(1,10000)%2) == 0)
end

function gameScene:getOpenSeq()
    local seqSeat = self:getSeatSeqId()
    local openSeq = {}
    local i = 0
    for k,v in ipairs(seqSeat) do
        if v ~= 1 then
            i = i + 1
            openSeq[i] = {id = v ,opentime = random(0,10)}
        end
    end
    return openSeq
end


-- 初始化头像
function gameScene:initHead()
    self.m_pUserInfo = {};
    local AIplayer
    for i=1,GAMEPLAYER_NIUNIU do
        local headUI = self.mView[string.format("headNode_%d",i)]
        local head = UIHead:create(headUI);
        self.m_pUserInfo[i] = head;
        if i ~= 1 then
            if self:determinateHasAI() then
                head:produceRandomData()
                AIplayer = head
            else
                headUI:setVisible(false)
            end
        else
            head:enterTable()
        end

        if i == GAMEPLAYER_NIUNIU and not AIplayer then
            -- 如果这一轮没有玩家也不行  那就硬拉最后一个过来
            local index = math.random(2, i)
            self.m_pUserInfo[index]:produceRandomData()
            print("那就硬拉最后一个过来"..index)
        end





    end
    self.ownCoin = _ReadLocal:getLocalCoin(1)
    self.m_pUserInfo[1]:setData(global.L(string.format( "name.name_%d",random(1,6))),self.ownCoin,1)
    self.aiCoin = _ReadLocal:getLocalCoin(2)
    self.m_pUserInfo[1]:setBanker()             
end

function gameScene:onsettingBtnClick()
    AudioEngine.playEffect("game/niuniu/sound/Button.mp3",false)
    local view = rule.new(nil,nil,2)
    global.viewMgr.showView(view, true)
end

function gameScene:onbackBtnClick()
    AudioEngine.playEffect("game/niuniu/sound/Button.mp3",false)
    local tips = require("logic.game.niuniu2.tips")
    global.viewMgr.showView(tips.new(nil,nil,handler(self, self.recordEnter)),true)
end

function gameScene:recordEnter()
    local tips = require("logic.game.niuniu2.record")
    global.viewMgr.showView(tips.new(nil,nil,self.m_pUserInfo),true)
end

function gameScene:onbet1Click(sender)
    BaseScore = 100
    self.betpnl:setVisible(false)
    self:ongameStart()
end

function gameScene:onbet2Click(sender)
    BaseScore = 200    
    self.betpnl:setVisible(false)
    self:ongameStart()
end

function gameScene:onbet3Click(sender)
    BaseScore = 300        
    self.betpnl:setVisible(false)
    self:ongameStart()
end

function gameScene:onbet4Click(sender)
    BaseScore = 400        
    self.betpnl:setVisible(false)
    self:ongameStart()
end

function gameScene:choiceBaseScore()
    self.betpnl:setVisible(true)
end

function gameScene:ongameStartBtnClick()
    self:choiceBaseScore()
end

function gameScene:ongameStart()
    self.destNum:setString(tostring(self.bigBalanceNum+1).."/"..tostring(MaxRound))
    self.own_Area:setVisible(true)
    self.cardindex = 0
    for i=1,3 do
        self.select_labels[i]:setString("")
    end
    self.total_num = 0
    self.havebtn:setVisible(false)
    self.btn_noniu:setVisible(false)
    self.caculatorbg:setVisible(false)  
    self.success_niu = false

    self.openSeq = nil
    self.seq = 0

    for i = 1,6 do
        self.mView["NodeAI"..i]:setVisible(true)
    end

    self.total_label:setString("0")
    self.mView["gameStartBtn"]:setVisible(false)
    local viewsz = cc.Director:getInstance():getVisibleSize();
    local centerpos = cc.p(viewsz.width/2 ,  viewsz.height/2);

    if self.cards and type(self.cards) == "table" then
        for i, v in ipairs(self.cards) do
            if v and not tolua.isnull(v) then
                v:removeFromParent()
            end
        end
    end

    self.cards = {}
    -- 重新洗牌
    _CardLogic:resetCardShuffle()
    self.UICardsPos = {
        cc.p(250,130),
        cc.p(120,420),
        cc.p(120,800),
        cc.p(250,980),
        cc.p(370,800),
        cc.p(370,420),
    }
    self.mCenterPos = centerpos;
    local AIplayer 
    for i=1,GAMEPLAYER_NIUNIU do
        local uicard = UICardsClass:create(i);
        local pos = self.UICardsPos[i];
        if i == 1 then
            uicard:setScale(0.92)
        else
            uicard:setScale(0.72)
        end
        uicard:setAnchorPoint(cc.p(1,0))
        uicard:setPosition(cc.p(pos.x , pos.y))
        uicard:setVisible(false);

        local pos = uicard:convertToNodeSpace(centerpos);
        uicard:setStartPos(pos)
        self.cardpnl:addChild(uicard,10)
        table.insert(self.cards, uicard)
        
        local headUI = self.mView[string.format("headNode_%d",i)]
        local player = self.m_pUserInfo[i]
        player.isOpen = false
        if (i ~= 1) and player then
            local flag = player:isInTable()
            if flag then
                if player:isPreEnterTable() then
                    player:produceRandomData()
                    AIplayer = player
                elseif player:isPreLeaveTable() then
                    player:leaveTable()
                elseif player:getScore() <= 0 then
                    player:leaveTable()
                end
            else
                player:leaveTable()
            end
        end

        if i == GAMEPLAYER_NIUNIU and not AIplayer then
            -- 如果这一轮没有玩家也不行  那就硬拉最后一个过来
            print("那就硬拉最后一个过来")
            player:produceRandomData()
        end
    end
    self:dealCard()
end

function gameScene:dealCard()
    --发牌动画
    -- 创建所有的牌
	self:createBeiCard()
	-- 发牌动画
	performWithDelay( self,function()
		self:sendCardAction()
    end,0.7 )
    --自己牌值数据
    self.ownPokerdata = _CardLogic:getCardData()
end

function gameScene:setCardData()
    for i=1,GAMEPLAYER_NIUNIU do
        local seatid = i
        local player = self.m_pUserInfo[i]
        if seatid ~= 1 then
            if player then
                if player:isInTable() and not player:isPreEnterTable() then

                else
                    player:printState()
                    player:setCards(nil)
                end
            end
        end
    end
end

function gameScene:getSeatSeqId()
    local send_seq = {}
    for i=1,GAMEPLAYER_NIUNIU do
        local seatid = i
        local player = self.m_pUserInfo[i]
        if player then
            if player:isInTable() and not player:isPreEnterTable() then
                table.insert(send_seq,seatid) 
            end
        end
    end
    return send_seq
end




function gameScene:getRandArr(arr)
    if type(arr) == "table" and #arr > 1 then
        for i = 1,#arr do
            local j = random(1, #arr)
            if  j > i then
                arr[i],arr[j] = arr[j],arr[i]
            end
        end
    end
    return arr
end

function gameScene:createBeiCard()
    local NodePoker = require("logic.game.niuniu2.NodePoker")
    self.NodeAllPoker = self.mView["NodeAllPoker"]
    self._allPokerNode = {}
	for i = 1,52 do
		local poker = NodePoker.new(self)
		self.NodeAllPoker:addChild( poker )
		poker:setRotation( -135 ) 
		poker:setPosition( cc.p( random(-5,5),random(-5,5) ) )
		self._allPokerNode[i] = poker
	end
end

function gameScene:sendCardAction()
    local seq_seat = self:getSeatSeqId()
    -- local send_random_seq = self:getRandArr(seq_seat)
    local send_random_seq = seq_seat
	local actions = {}
    for i = 1,5 do
		for k,v in ipairs( send_random_seq ) do
			local delay_time = cc.DelayTime:create( 0.2 )
			local call_send = cc.CallFunc:create( function()
				self:sendOneCardAction( v )
			end )
			table.insert( actions,delay_time )
			table.insert( actions,call_send )
			
			-- 发牌结束 开始游戏
			if i == 5 and k == #send_random_seq then
				local delay_time2 = cc.DelayTime:create( 0.5 )
                local send_card_done = cc.CallFunc:create( function()
                    self:allCardClick()
                    self:setCardData()
                    self.isShowDown = true
                    self:showOwnArea()
				end )
				table.insert( actions,delay_time2 )
				table.insert( actions,send_card_done )
			end
		end
	end
	local seq = cc.Sequence:create( actions )
	self:runAction( seq )
end


function gameScene:sendOneCardAction( seatPos )
	assert( seatPos," !! seatPos is nl !! " )
	if #self._allPokerNode == 0 then
		return
    end
	audio.playSound("game/niuniu/sound/sendcard.mp3", false)
	local top_poker = self._allPokerNode[#self._allPokerNode]
	table.remove( self._allPokerNode,#self._allPokerNode )
	local dest_node = self.mView["NodeAI"..seatPos]
	local end_world_pos,rotation = self:getCardPosBySeat( seatPos )
	local rotation_diss = rotation - top_poker:getRotation()
	local action_time = 0.25
	local end_node_pos = self.NodeAllPoker:convertToNodeSpace( end_world_pos )
	local move_by = cc.MoveBy:create( 0.1,cc.p( 20,20 ))
	local move_to = cc.MoveTo:create( action_time,end_node_pos )
	local rotation_by = cc.RotateBy:create( action_time,rotation_diss )
	local spawn = cc.Spawn:create({ move_to,rotation_by })
	local call = cc.CallFunc:create( function()
		top_poker:retain()
        top_poker:removeFromParent()
		dest_node:addChild( top_poker )
		top_poker:release()
		-- 玩家扑克添加点击
		if seatPos == 1 then
            self.cardindex = self.cardindex + 1
            self.ownPokers[self.cardindex] = top_poker
            -- top_poker:addPokerClick()
            top_poker:showPoker(self.ownPokerdata[self.cardindex])
		end
		local node_pos = dest_node:convertToNodeSpace( end_world_pos )
		top_poker:setPosition( node_pos )
		self:aiHandPokerAction( seatPos )
	end )
	local seq = cc.Sequence:create({ move_by,spawn,call })
	top_poker:runAction( seq )
end

function gameScene:getCardPosBySeat( seatPos )
	assert( seatPos," !! seatPos is nil !! " )
	local dest_node = self.mView["NodeAI"..seatPos]
	local end_world_pos = dest_node:getParent():convertToWorldSpace( cc.p(dest_node:getPosition()) )
	local rotation = 0
	if seatPos == 2 or seatPos == 3 then
		end_world_pos.x = end_world_pos.x + 5
		rotation = 90
	elseif seatPos == 4 then
		end_world_pos.y = end_world_pos.y - 5
		rotation = 180
	elseif seatPos == 5 or seatPos == 6 then
		end_world_pos.x = end_world_pos.x - 5
		rotation = 270
	elseif seatPos == 1 then
		end_world_pos.y = end_world_pos.y + 5
		rotation = 0
	end
	return end_world_pos,rotation
end

-- 将ai手中的牌 平铺
function gameScene:aiHandPokerAction( seatPos )
	assert( seatPos," !! seatPos is nl !! " )
	local dest_node = self.mView["NodeAI"..seatPos]
	local childs = dest_node:getChildren()
	local nums = #childs
	if nums <= 1 then
		return
	end

	local end_world_pos,rotation = self:getCardPosBySeat( seatPos )
	if seatPos == 2  or seatPos == 3 then
		local start_rotation = rotation - ( nums - 1 ) * 5
		local start_posY = end_world_pos.y + ( nums - 1 ) * 10
		for i = 1,nums do
			local finaly_rotation = start_rotation + ( i - 1) * 10
			local rotation_diss = finaly_rotation - childs[i]:getRotation()
			local rotation_by = cc.RotateBy:create( 0.2,rotation_diss )

			local finaly_posY = start_posY - ( i - 1) * 20
			local pos = clone( end_world_pos )
			pos.y = finaly_posY

			local node_pos = dest_node:convertToNodeSpace( pos )
			local pos_disx = node_pos.x - childs[i]:getPositionX()
			local pos_disy = node_pos.y - childs[i]:getPositionY()
			local move_by = cc.MoveBy:create( 0.2,cc.p( pos_disx,pos_disy ) )
			local spawn = cc.Spawn:create({ move_by,rotation_by })
			childs[i]:runAction( spawn )
		end
	elseif seatPos == 4 then
		local start_rotation = rotation - ( nums - 1 ) * 5
		local start_posX = end_world_pos.x + ( nums - 1 ) * 10
		for i = 1,nums do
			local finaly_rotation = start_rotation + ( i - 1) * 10
			local rotation_diss = finaly_rotation - childs[i]:getRotation()
			local rotation_by = cc.RotateBy:create( 0.2,rotation_diss )

			local finaly_posX = start_posX - ( i - 1) * 20
			local pos = clone( end_world_pos )
			pos.x = finaly_posX

			local node_pos = dest_node:convertToNodeSpace( pos )
			local pos_disx = node_pos.x - childs[i]:getPositionX()
			local pos_disy = node_pos.y - childs[i]:getPositionY()
			local move_by = cc.MoveBy:create( 0.2,cc.p( pos_disx,pos_disy ) )
			local spawn = cc.Spawn:create({ move_by,rotation_by })
			childs[i]:runAction( spawn )
		end
	elseif seatPos == 5 or seatPos == 6 then
		local start_rotation = rotation - ( nums - 1 ) * 5
		local start_posY = end_world_pos.y - ( nums - 1 ) * 10
		for i = 1,nums do
			local finaly_rotation = start_rotation + ( i - 1) * 10
			local rotation_diss = finaly_rotation - childs[i]:getRotation()
			local rotation_by = cc.RotateBy:create( 0.2,rotation_diss )
			local finaly_posY = start_posY + ( i - 1) * 20
			local pos = clone( end_world_pos )
			pos.y = finaly_posY
			local node_pos = dest_node:convertToNodeSpace( pos )
			local pos_disx = node_pos.x - childs[i]:getPositionX()
			local pos_disy = node_pos.y - childs[i]:getPositionY()
			local move_by = cc.MoveBy:create( 0.2,cc.p( pos_disx,pos_disy ) )
			local spawn = cc.Spawn:create({ move_by,rotation_by })
			childs[i]:runAction( spawn )
		end
	elseif seatPos == 1 then
		local start_posX = end_world_pos.x - ( nums - 1 ) * 30
		for i = 1,nums do
			local finaly_posX = start_posX + ( i - 1) * 60
			local pos = clone( end_world_pos )
			pos.x = finaly_posX
			local node_pos = dest_node:convertToNodeSpace( pos )
			local pos_disx = node_pos.x - childs[i]:getPositionX()
			local pos_disy = node_pos.y - childs[i]:getPositionY()
			local move_by = cc.MoveBy:create( 0.2,cc.p( pos_disx,pos_disy ) )
			childs[i]:runAction( move_by )
		end
	end
end

---显示自己的区域
function gameScene:showOwnArea()
    self.havebtn:setVisible(true)
    self.btn_noniu:setVisible(true)
    self.caculatorbg:setVisible(true)  
    self.success_niu = false
end

function gameScene:checkWiner(bankercards, checkcards)
    local pokertype = cardTool:getTypebyCards(bankercards)
    local check_pokertype = cardTool:getTypebyCards(checkcards)

    if pokertype == check_pokertype then
        local pokers = clone(bankercards)
        local clone_checkcards = clone(checkcards)
        --最大牌大小
        cardTool:sortByCardsValue(pokers)
        cardTool:sortByCardsValue(clone_checkcards)
        for i = 5 ,1,-1 do
            local p = pokers[i]
            local c = clone_checkcards[i]
            if p.card_value == c.card_value then
                if p.card_color == c.card_color then
                else
                    return (p.card_color > c.card_color), pokertype, check_pokertype
                end
            else
                return (p.card_value > c.card_value), pokertype, check_pokertype
            end
        end   
    else
        return (pokertype > check_pokertype), pokertype, check_pokertype
    end 
end

local function getBalanceCoin(iswin, type1, type2)
    return iswin and cardTool:getTypeCoin(type1) or cardTool:getTypeCoin(type2)
end

function gameScene:printTest(i, j, winnum)
    local aname = self.m_pUserInfo[j]:getUserName()
    local bname = self.m_pUserInfo[i]:getUserName()
    print(j.." == j = "..aname .." 输给了 "..bname..winnum.." 块钱! ".." i = " .. i .. " ")

    if aname == "" then
        print(self.m_pUserInfo[j]:getScore() .."  index = "..j)
    end

    if bname == "" then
        print(self.m_pUserInfo[i]:getScore() .."  index = "..i)
    end
end

function gameScene:gameBalance()
    local count = GAMEPLAYER_NIUNIU
    local balance_players = {}
    for i, v in ipairs(self.m_pUserInfo) do
         v:setPreBalance(0)
    end
    for i = 1, count do
        local a_player = self.m_pUserInfo[i]
        local acards = a_player:getCards()
        if acards then
            print("check " ..a_player:getUserName().." 输赢！")
            local tbl = {}
            for j = i + 1, count do
                local b_player = self.m_pUserInfo[j]
                local bcards = b_player:getCards()
                if bcards then
                    local iswin, type1, type2 = self:checkWiner(acards, bcards)
                    local winnum = getBalanceCoin(iswin,type1,type2) * BaseScore

                    print(" " ..a_player:getUserName().." 牌型 = "..cardTool:getTypeName(type1))
                    print(" " ..b_player:getUserName().." 牌型 = "..cardTool:getTypeName(type2))

                    a_player:addPreBalance(iswin and winnum or (0 - winnum))
                    b_player:addPreBalance(iswin and (0 - winnum) or winnum)

                    if iswin then
                        local p1 = self.mView[string.format("headNode_%d",i)]
                        local p2 = self.mView[string.format("headNode_%d",j)]
                        self:goldFlyAnimation(p2, p1, winnum * 10)

                        self:printTest(i,j, winnum)
                    else
                        -- 输的
                        tbl[#tbl + 1] = {j, winnum}
                    end
                end
            end

            -- 执行飞金币动画 输的
            self:runAction(cc.Sequence:create(
                cc.DelayTime:create(1),
                cc.CallFunc:create(function ()
                    for k, v in ipairs(tbl) do
                        local p1 = self.mView[string.format("headNode_%d",i)]
                        local p2 = self.mView[string.format("headNode_%d",v[1])]
                        self:goldFlyAnimation(p1, p2, v[2] * 10)
                        self:printTest(v[1], i, v[2])
                    end
                end)
            ))

            break
        end
    end

    -- 钱数额变化
    for i, v in ipairs(self.m_pUserInfo) do
        if v:getCards() then
            local prebalance = v:getPreBalance()
            local interval = (prebalance > 0) and 1 or -1
            local val = v:getScore() + prebalance
            -- m_pLableGameGold
            if prebalance ~= 0 then
                local pUI = self.mView[string.format("headNode_%d",i)]
                local label = pUI:getChildByName("coinPanel"):getChildByName("m_pLableGameGold")
                label:runAction(cc.Sequence:create(
                        cc.CallFunc:create(function ()
                            label:runAction(
                                cc.RepeatForever:create(
                                    cc.Sequence:create(
                                        cc.CallFunc:create(function ()
                                            if interval > 0 then
                                                local num = math.min(v:getScore() + interval, val)
                                                v:setScore(num)
                                            else
                                                local num = math.max(v:getScore() + interval, val)
                                                v:setScore(num)
                                            end
                                        end),
                                        cc.DelayTime:create(0.02) 
                                    )
                                )
                            )
                        end),
                        cc.DelayTime:create(2), 
                        cc.CallFunc:create(function()
                            label:stopAllActions()
                            v:setScore(val)
                        end)
                    )
                )
            end
        end
    end
end

-- p1 飞往 p2, num表示输赢数值  根据比例生成飞的金币数量
function gameScene:goldFlyAnimation(p1, p2, num)
    local goldcount = math.floor(num/100)
    local gold = ccui.ImageView:create("game/niuniu/resource/head/coinIcon.png")
    local size = gold:getContentSize()
    
    local node1 = p1:getChildByName("coinPanel")
    local origin_p = cc.p(node1:getChildByName("coinIcon"):getPosition())
    origin_p.x =  origin_p.x + size.width /2
    origin_p.y =  origin_p.y --+ size.height/2

    local node2 = p2:getChildByName("coinPanel"):getChildByName("coinIcon")
    local p = node2:convertToWorldSpace(cc.p(node2:getPosition()))
    local pos = node1:convertToNodeSpace(p)
    pos.x = math.floor(pos.x + size.width/2)
    pos.y = math.floor(pos.y)

    local range = 4

    local delay = 0.01
    for i = 1, goldcount do
        local sp = gold:clone()
        p1:add(sp)

        origin_p.x =  origin_p.x + math.random(-range, range)
        origin_p.y =  origin_p.y + math.random(-range, range)
        sp:setPosition(origin_p)

        local tmp = {}
        tmp.x = math.random(-range, range) + pos.x
        tmp.y = math.random(-range, range) + pos.y

        local seq = cc.Sequence:create(
            cc.DelayTime:create(i * delay),
            cc.EaseInOut:create(cc.MoveTo:create(0.6, tmp), 0.8),
            cc.CallFunc:create(function ()
                sp:removeFromParent()
            end)
        )
        sp:runAction(seq)
    end
end

function gameScene:onShowHandBtnClick(sender)
    self.m_pUserInfo[1]:setCards(self.ownPokerdata)
    local pokers = self.m_pUserInfo[1]:getCards()
    local pokertype = cardTool:getTypebyCards(pokers)
    if self.success_niu or pokertype >= 11  then
        --牌数据
        self:showDown()
    else
        -- global.viewMgr.showTips(global.L("game.niu_error"))
        AudioEngine.playEffect("game/niuniu/sound/Button.mp3",false)
        local tips = require("logic.game.niuniu2.errorTips")
        global.viewMgr.showView(tips.new(nil,nil,"error_niu"),true)
        
    end
end

function gameScene:onNoNiuBtnClick()
    self.m_pUserInfo[1]:setCards(self.ownPokerdata)
    local pokers = self.m_pUserInfo[1]:getCards()
    local pokertype = cardTool:getTypebyCards(pokers)
    if pokertype == 0 then
        self:showDown()
    else
        -- global.viewMgr.showTips(global.L("game.niu_error"))
        AudioEngine.playEffect("game/niuniu/sound/Button.mp3",false)
        local tips = require("logic.game.niuniu2.errorTips")
        global.viewMgr.showView(tips.new(nil,nil,"noniu"),true)
    end
end

function gameScene:showDown()
    self.m_pUserInfo[1]:setOpenCard()
    self.mView["NodeAI1"]:removeAllChildren(true)
    self.NodeAllPoker:removeAllChildren(true)
    self.own_Area:setVisible(false)
    local pokers = self.m_pUserInfo[1]:getCards()
    if pokers ~= nil then
        local pokertype = cardTool:getTypebyCards(pokers)
        self.cards[1]:setVisible(true);
        self.cards[1]:stopAllActions()
        self.cards[1]:setPokers(pokers,pokertype,0)
    end
    
    if self.isShowDown == false then
        self:enterBalance()
    end
end

function gameScene:enterBalance()
    self.continueBtn:setVisible(true)
    self:gameBalance()
    self.bigBalanceNum = self.bigBalanceNum + 1
    if self.bigBalanceNum == MaxRound then
        local tips = require("logic.game.niuniu2.record")
        global.viewMgr.showView(tips.new(nil,nil,self.m_pUserInfo),true)
    end
    
end



function gameScene:initOwnArea( )
    if self.own_Area ~= nil then
        return
    end
    self.own_Area = self.mView["ownlayer"]
    self.own_Area:setVisible(true)
    --摊牌按钮
    self.havebtn:setVisible(false)
    --没牛
    self.btn_noniu:setVisible(false)
    self.btn_noniu:addClickEventListener(handler(self, self.onNoNiuBtnClick))
    self.havebtn:addClickEventListener(handler(self, self.onShowHandBtnClick))
    self.caculatorbg = self.mView["calcbg"]
    self.caculatorbg:setVisible(false)

    self.select_labels = {}
    for i=1,3 do
        local str = string.format("select_label%d",i)
        self.select_labels[i] = self.mView[str]
        self.select_labels[i]:setString("")
    end

    self.total_label = self.mView["total_label"]
    self.total_label:setString("")
    
    self.continueBtn:addClickEventListener(function(sender)
        self:choiceBaseScore()
        self.continueBtn:setVisible(false)
    end)
    
end

function gameScene:allCardClick()
    for i = 1,5 do
        local btn = self.ownPokers[i].root
        btn:addClickEventListener((handler(self, self.onCardClick)))
        -- btn:setTouchEnabled(false)
    end
end

function gameScene:onCardClick(sender)
    AudioEngine.playEffect("game/niuniu/sound/clickCard.mp3",false)
    
    local value = sender.value
    local is_select = sender.selected
    if is_select == false then
        if self:selectNum() == 3 then
            return
        end
        sender:runAction(cc.MoveBy:create(0.1,cc.p(0,20)))
        sender.selected = true
    else
        sender:runAction(cc.MoveBy:create(0.1,cc.p(0,-20)))
        sender.selected = false
    end 
    self:showCaculator(value,is_select)
end

function gameScene:selectNum()
    local num = 0
    for i = 1,5 do
        local btn = self.ownPokers[i].root
        if btn.selected then
            num = num + 1
        end
    end
    return num
end

function gameScene:nextSelectNum()
    local num = 0
    for i,v in ipairs(self.select_labels) do
        if self.select_labels[i]:getString() == "" then
            num = i
            break
        end
    end
    return num
end

function gameScene:showCaculator(show_num,is_select)
    local select_num = self:selectNum()
    local next_index = self:nextSelectNum()
    if is_select == false then
        self.select_labels[next_index]:setString(show_num)
        self.total_num = self.total_num + show_num
    else
        self.total_num = self.total_num - show_num
        for i = 1 , 3 do
            if tonumber(self.select_labels[i]:getString()) == show_num then
                self.select_labels[i]:setString("")
                break
            end
        end
    end
    self.total_label:setString(self.total_num)
    --自动拼牛
    if select_num == 2 then
        local poker = nil
        for i = 1,5 do
            local btn = self.ownPokers[i].root
            if not btn.selected and (self.total_num+btn.value) % 10 == 0 then
                poker = btn
                break
            end
        end
        if poker then
            self:onCardClick(poker)
            self.success_niu = true
        end
    end
end





return gameScene
