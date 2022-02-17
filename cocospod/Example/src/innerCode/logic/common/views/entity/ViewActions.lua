local ViewActions = ViewActions or {}

-- 关闭
local function closeActionCallBack(sender)
	if sender and not tolua.isnull(sender) then
		sender:removeFromParent(true);
	end
end

--[[
]]
function ViewActions.scaleOpenAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.33
	end
	if layer.mLayout then
		layer.mLayout:setScale(0.1);
		local scaleAction = cc.ScaleTo:create(time, 1, 1);
		local seq = cc.Sequence:create(cc.EaseBackOut:create(scaleAction));
	    layer.mLayout:runAction(seq);
	end
end

function ViewActions.fadeOpenAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.33
	end
	if layer.mLayout then
		layer.mLayout:setOpacity(0);
		local scaleAction = cc.FadeIn:create(time);
		local seq = cc.Sequence:create(cc.EaseBackOut:create(scaleAction));
	    layer.mLayout:runAction(seq);
	end
end

function ViewActions.moveOpenAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.33
	end
    if layer.mLayout then
        layer.mLayout.__origin_x = layer.mLayout:getPositionX()
        dump(layer.mLayout.__origin_x)
		layer.mLayout:setPositionX(-2000);
		local scaleAction = cc.MoveTo:create(time, cc.p(layer.mLayout.__origin_x, layer.mLayout:getPositionY()));
		local seq = cc.Sequence:create(cc.EaseBackOut:create(scaleAction));
	    layer.mLayout:runAction(seq);
	end
end

function ViewActions.jumpOpenAction(layer, time)
	if(time == nil or time == 0)then
		time = 1
	end
    if layer.mLayout then
        layer.mLayout.__origin_x = layer.mLayout:getPositionX()
        dump(layer.mLayout.__origin_x)
        layer.mLayout:setPositionX(-1500);
        dump(layer.mLayout.__origin_x)
		local scaleAction = cc.JumpTo:create(time, cc.p(layer.mLayout.__origin_x, layer.mLayout:getPositionY()), 200, 1) --, 10, 20, true, true) -- cc.p(-2000, layer.mLayout:getPositionY()));
		local seq = cc.Sequence:create(cc.EaseElasticIn:create(scaleAction, 2));
        layer.mLayout:runAction(seq);
	end
end

function ViewActions.skewOpenAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.5
	end
    if layer.mLayout then
        layer.mLayout:setSkewX(-90);
        dump(layer.mLayout.__origin_x)
		local scaleAction = cc.SkewTo:create(time, 0, 0) --, 10, 20, true, true) -- cc.p(-2000, layer.mLayout:getPositionY()));
		local seq = cc.Sequence:create(cc.EaseBackOut:create(scaleAction));
        layer.mLayout:runAction(seq);
	end
end

function ViewActions.orbitOpenAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.3
	end
    if layer.mLayout then
		local scaleAction = cc.OrbitCamera:create(time, 0, 1, -90, 90, 0, 0) --, 10, 20, true, true) -- cc.p(-2000, layer.mLayout:getPositionY()));
        layer.mLayout:runAction(scaleAction);
	end
end

-- 关闭界面动画
--[[  
]]
function ViewActions.scaleCloseAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.33
	end
	print("关闭界面动画"..time)
	layer:setScale(1);
    local scaleAction = cc.ScaleTo:create(time, 0.1);
    local actionSequence = cc.Sequence:create(cc.EaseBackIn:create(scaleAction), cc.CallFunc:create(handler(layer, closeActionCallBack)));
    layer.mLayout:runAction(actionSequence);
end

function ViewActions.fadeCloseAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.2
	end
	if layer.mLayout then
		layer.mLayout:setOpacity(255);
		local scaleAction = cc.FadeOut:create(time);
        local actionSequence = cc.Sequence:create(cc.EaseBackIn:create(scaleAction), cc.CallFunc:create(handler(layer, closeActionCallBack)));
        layer.mLayout:runAction(actionSequence);
	end
end

function ViewActions.moveCloseAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.33
	end
	if layer.mLayout then
        dump(layer.mLayout.__origin_x)
		local scaleAction = cc.MoveTo:create(time, cc.p(-2000, layer.mLayout:getPositionY()));
        local actionSequence = cc.Sequence:create(cc.EaseBackIn:create(scaleAction), cc.CallFunc:create(handler(layer, closeActionCallBack)));
        layer.mLayout:runAction(actionSequence);
	end
end

function ViewActions.jumpCloseAction(layer, time)
	if(time == nil or time == 0)then
		time = 1
	end
	if layer.mLayout then
        dump(layer.mLayout.__origin_x)
		local scaleAction = cc.JumpTo:create(time, cc.p(-1000, layer.mLayout:getPositionY()), 200, 1); -- cc.p(-2000, layer.mLayout:getPositionY()));
        local actionSequence = cc.Sequence:create(cc.EaseBackIn:create(scaleAction), cc.CallFunc:create(handler(layer, closeActionCallBack)));
        layer.mLayout:runAction(actionSequence);
	end
end

function ViewActions.skewCloseAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.5
	end
	if layer.mLayout then
        layer.mLayout:setSkewX(0);
        dump(layer.mLayout.__origin_x)
        local scaleAction = cc.SkewTo:create(time, -90, 0) --, 10, 20, true, true) -- cc.p(-2000, layer.mLayout:getPositionY()));
        local actionSequence = cc.Sequence:create(cc.EaseBackIn:create(scaleAction), cc.CallFunc:create(handler(layer, closeActionCallBack)));
        layer.mLayout:runAction(actionSequence);
	end
end

function ViewActions.orbitCloseAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.5
	end
    if layer.mLayout then
		local scaleAction = cc.OrbitCamera:create(time, 0, 1, 0, -90, 0, 0) --, 10, 20, true, true) -- cc.p(-2000, layer.mLayout:getPositionY()));
        local actionSequence = cc.Sequence:create(scaleAction, cc.CallFunc:create(handler(layer, closeActionCallBack)));
        layer.mLayout:runAction(actionSequence);
	end
end

ViewActions.ACTION_TYPE_TBL = {
    "move",
    "fade",
    "scale",
    "skew",
    "orbit",
    "jump",
}

return ViewActions