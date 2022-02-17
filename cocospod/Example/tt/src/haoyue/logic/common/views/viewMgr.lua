local viewMgr = {}

local fileUtils = cc.FileUtils:getInstance()

local UILayerOrder = 
{
    Scene = 0,
    View = 1,
    Tips = 10,
    Guide = 11,
    Hover= 12,
    Loading = 13,
    System = 14,
}
viewMgr.UILayerOrder = UILayerOrder

local layers = {}

-- 关闭
local function closeActionCallBack(sender)
	if sender and not tolua.isnull(sender) then
		sender:removeFromParent(true);
	end
end

function viewMgr.getLayer(order)
    local layer = layers[order];
    if layer and not tolua.isnull(layer) then
        return layer
    end
    local layer = ccui.Layout:create()
    layer:setContentSize(display.size)
    local parent = display.getRunningScene()
    parent:addChild(layer, order)
    layers[order] = layer
    return layer
end

-- 打开界面动画
function viewMgr.showAction(layer, time)
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

-- 关闭界面动画
function viewMgr.closeAction(layer, time)
	if(time == nil or time == 0)then
		time = 0.33
	end
	print("关闭界面动画"..time)
	layer:setScale(1);
    local scaleAction = cc.ScaleTo:create(time, 0.1);
    local actionSequence = cc.Sequence:create(cc.EaseBackIn:create(scaleAction), cc.CallFunc:create(handler(layer, closeActionCallBack)));
    layer.mLayout:runAction(actionSequence);
end

function viewMgr.showPaoMaDeng(txt, dt, callback)
    local layer = viewMgr.getLayer(UILayerOrder.Tips)
    dt = dt or 6;
    local wrap = cc.Node:create()
    local sprBg = ccui.Layout:create()
    sprBg:setAnchorPoint(cc.p(0.5,0.5))
    sprBg:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
    sprBg:setBackGroundColor(cc.c3b(128, 128, 128))
    sprBg:setOpacity(255)
	local label = cc.Label:createWithSystemFont(txt, "", 30)
    label:setAnchorPoint(cc.p(0,0.5))
    local labelSize = label:getContentSize()
    sprBg:setContentSize(800, labelSize.height)
    sprBg:setClippingEnabled(true)
	wrap:addChild(sprBg)
	sprBg:addChild(label)
    wrap:setPosition(display.cx, display.height - 140)
    layer:addChild(wrap)

    local count = 3
    local checkCount = nil

    local sprSize = sprBg:getContentSize()
    local function action()
        label:setPosition(sprSize.width, labelSize.height/2)
        label:runAction(
            cc.Sequence:create(
                cc.MoveBy:create(dt, cc.p(- sprSize.width - labelSize.width,0)),
                cc.CallFunc:create(checkCount)
            )
        )
    end

    checkCount = function ()
        if count > 0 then
            action()
            count = count - 1
        else
            if callback then
                callback()
            end
            wrap:removeFromParent()
        end
    end

	checkCount()
end

function viewMgr.showTips(txt, dt)
    local layer = viewMgr.getLayer(UILayerOrder.Tips)
    dt = dt or 1;
    local wrap = cc.Node:create()
    local sprBg = ccui.Layout:create()
    sprBg:setAnchorPoint(cc.p(0.5,0.5))
    sprBg:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid);
    sprBg:setBackGroundColor(cc.c3b(128, 128, 128))
    sprBg:setOpacity(200)
	local label = cc.Label:createWithSystemFont(txt, "", 30)
    label:setAnchorPoint(cc.p(0.5,0.5))
    local labelSize = label:getContentSize()
    sprBg:setContentSize(display.width, labelSize.height + 40)
	wrap:addChild(sprBg)
	wrap:addChild(label)
    wrap:setPosition(display.cx, display.cy)
    
	layer:addChild(wrap)

	local fadeIn = cc.FadeIn:create(0.3)
    local fadeOut = cc.FadeOut:create(0.7)
    wrap:runAction(cc.Sequence:create({fadeIn, cc.DelayTime:create(dt), fadeOut, cc.RemoveSelf:create()}))
end

function viewMgr.showView(unit, isAction, order)
    local layer = viewMgr.getLayer(order or UILayerOrder.View)
    layer:addChild(unit)
    if unit.animEnter then
        unit:animEnter()
    elseif isAction then
        viewMgr.showAction(unit)
    end
end

-- 移除一个layer
function viewMgr.removeView(unit, isAction)
    if unit.mLayout then
        if unit.animExit then
            unit:animExit()
        elseif isAction then
            viewMgr.closeAction(unit);
        end
    else
    	global.async.runInNextFrame(handler(unit, closeActionCallBack));
    end
end

function viewMgr.getPageRandomSeed(viewpath)
    if viewMgr.pageRandomSeed then
        return viewMgr.pageRandomSeed[viewpath]
    end

    return nil
end

function viewMgr.loadRandomGroupPageConf(confpath, custom_random)
    local random = custom_random or math.random
    if not custom_random then
        math.randomseed(global.randomSeed)
    end

    local ViewActions = require("logic.common.views.entity.ViewActions")
    local action_type_tbl = ViewActions.ACTION_TYPE_TBL

    -- math.randomseed(tostring(socket.gettime()):reverse():sub(1, 7))
    -- local action_name = "jump" --action_type_tbl[math.random(1, #action_type_tbl)]
    local action_name = action_type_tbl[random(1, #action_type_tbl)]
    dump(action_name)
    global.viewMgr.showAction = ViewActions[action_name.."OpenAction"]
    global.viewMgr.closeAction = ViewActions[action_name.."CloseAction"]

    local path = string.gsub(confpath, "%.", "/")
    local fullpath = fileUtils:fullPathForFilename("logic/"..path..".manifest")
    dump(fileUtils:getSearchPaths())
    if #fullpath ~= 0 then
        local manifest = fileUtils:getStringFromFile(fullpath)
        local g_t = load(manifest)()
        -- dump(g_t)
        if table.nums(g_t) ==0 then
            return 
        else
            table.sort(g_t)

            viewMgr.pageRandomSeed = {}
            for k, v in pairs(g_t) do 
                viewMgr.pageRandomSeed[v] = random()
            end
        end 
    end
end

function viewMgr.exitApp()
    cc.Director:sharedDirector():endToLua()
    if device.platform == "windows" or device.platform == "mac" or device.platform == "ios" then
        os.exit()
    end 
end

return viewMgr