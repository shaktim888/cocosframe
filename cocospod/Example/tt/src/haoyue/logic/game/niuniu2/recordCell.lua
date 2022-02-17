local recordCell = class("recordCell",ccui.Layout)
local function getRgb()
	local r = math.random(0,255)
	local g = math.random(0,255)
	local b = math.random(0,255)
	return cc.c3b(r,g,b)
end

function recordCell:getRandColor()
	math.randomseed(global.randomSeed)
	return getRgb()
end
function recordCell:ctor()
    local root = require("game/niuniu/recordCell.lua").create().root;
    self:addChild(root);
    self.root = root:getChildByName("root")
    self.coin = self.root:getChildByName("coin")
    -- self.coin:setColor(self:getRandColor())
    self.name = self.root:getChildByName("name")
    -- self.name:setColor(self:getRandColor())
    self:setContentSize(self:getSize().width,self:getSize().height+10);
end

function recordCell:setData(arr)
    local str = ""
    if arr.coin > 0 then
        str = "+"..arr.coin
    elseif arr.coin < 0 then
        str = arr.coin
    elseif arr.coin == 0 then
        str = " "..0
    end
    self.coin:setString(str)
    self.name:setString(arr.name)
end

function recordCell:getSize()
    return self.root:getContentSize();
end

return recordCell
