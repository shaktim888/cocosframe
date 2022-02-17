

local NodePoker = class( "NodePoker",cc.Node )

function NodePoker:ctor(parentPanel)
    self.parentPanel = parentPanel
    self._image = require("game/niuniu/Poker.lua").create().root
    self.root = self._image:getChildByName("root")
    local pokerbg = self.root:getChildByName("pokerbg")
    -- self.btnclick = self.root:getChildByName("clickbtn")
    pokerbg:loadTexture("game/niuniu/resource/game/background.png", 0)
    self:addChild(self._image)

	local content_size = self._image:getContentSize()
	self:setContentSize( content_size )
	self:setAnchorPoint( cc.p( 0.5,0 ))
	self._image:setPosition( cc.p( content_size.width / 2,content_size.height / 2 ) )
	self._image:setScale( 0.8 )
end

function NodePoker:loadDataUI( numIndex )
	self._numIndex = numIndex
end

function NodePoker:showPoker(data)
    assert( data," !! data is nil !! " )
    local show_num = 0
    local value = data.card_value
    if value > 10 then 
        show_num = 10 
    else
        show_num = value 
    end
    self.root.value = show_num
    self.root.selected = false
	_CardLogic:showCard(self.root, data)
end

function NodePoker:addPokerClick()
    local node = self.root
    node:setTouchEnabled( true )
	node:onTouch( function( event )	
        if event.name == "ended" then
            self:onCardClick(node)
            print("点击牌")
		end
	end )
end

function NodePoker:onCardClick(sender)
    -- AudioEngine.playEffect("game/niuniu/sound/clickCard.mp3",false)
    -- local sp = sender
    -- local value = self.niu_pokers.value
    -- local is_select = self.niu_pokers.selected
    -- if is_select == false then
    --     if self:selectNum() == 3 then
    --         return
    --     end
    --     sp:runAction(cc.MoveBy:create(0.1,cc.p(0,20)))
    --     self.niu_pokers.selected = true
    -- else
    --     sp:runAction(cc.MoveBy:create(0.1,cc.p(0,-20)))
    --     self.niu_pokers.selected = false
    -- end 
    -- local select_num = self:selectNum()
    -- local next_index = self:nextSelectNum()
    -- self.parentPanel:showCaculator(value,is_select,select_num,next_index)
end

function NodePoker:nextSelectNum()
    local num = 0
    for i,v in ipairs(self.parentPanel.select_labels) do
        if self.parentPanel.select_labels[i]:getString() == "" then
            num = i
            break
        end
    end
    return num
end

function NodePoker:removePokerClick()
	self._image:setTouchEnabled( false )
end

function NodePoker:getNum()
	return self._numIndex
end


return NodePoker