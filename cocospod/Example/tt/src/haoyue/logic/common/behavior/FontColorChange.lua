local FontColorChange = class("FontColorChange", cc.load("mvc").BehaviorBase)

local fontcolorset = {
	cc.c3b(255,0,0),
	cc.c3b(0,255,0),
	cc.c3b(0,0,255)
}

local function getRgb()
	local r = math.random(0,255)
	local g = math.random(0,255)
	local b = math.random(0,255)
	return cc.c3b(r,g,b)
end

function FontColorChange:onCreate()
	math.randomseed(global.randomSeed)
	-- local color_index = math.random(1, #fontcolorset)
	-- print("FontColorChange color_index = ", color_index);
	-- local fontcolor = fontcolorset[color_index]
	local fontcolor = getRgb()
	dump(fontcolor)
	local widget
	for key, v in pairs(self.changecolorfont or {}) do
		widget = self.mView[key]
		if widget and widget.setTextColor and type(widget.setTextColor) == "function" then
			widget:setTextColor(fontcolor)
		elseif widget and widget.setTitleColor and type(widget.setTitleColor) == "function"  then
			widget:setTitleColor(fontcolor)
		end
	end
end

return FontColorChange