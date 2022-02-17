local EventDispatch = class("EventDispatch")

EventDispatch.ENTER_FOREGROUND = "game_on_show"
EventDispatch.ENTER_BACKGROUND = "game_on_hide"

EventDispatch.ONKEY_BACK       = "APP_KEY_PRESS_BACK"
EventDispatch.ONKEY_MENU       = "APP_KEY_PRESS_MENU"

EventDispatch.ONKEY_DOWN       = "APP_KEY_DOWN"
EventDispatch.ONKEY_UP         = "APP_KEY_UP"

-- Refrence: EventDispatcherTestDemo.lua

local All_Listener = {} --添加监听的回调集合

-- 清理已经释放的对象
local function cleanRelease()
	for k,listener in pairs(All_Listener) do
		for i=#listener,1,-1 do
			if tolua.isnull(listener[i].target) then
				-- print("EventDispatch auto clean release target listener in key: "..k)
				table.remove(listener,i)
			end
		end
	end
end

-- 添加一个事件监听
function EventDispatch.on(eventName,callback,target,tag)
	assert(eventName ~= EventDispatch,"please use dot to call EventDispatch.on")
	assert(type(eventName) == "string","argument 1 is type string in EventDispatch.on")
	assert(type(callback) == "function","argument 2 is type function in EventDispatch.on")
	assert(type(target) == "userdata","argument 3 is type userdata in EventDispatch.on")
	assert(tag == nil or type(tag) == "string","argument 4 is type string in EventDispatch.on")

	All_Listener[eventName] = All_Listener[eventName] or {}
	local l = {}
	l.target = target
	l.callback = callback
	l.tag = tag
	table.insert(All_Listener[eventName], l)
	cleanRelease()
end

-- 移除这个函数对应的所有监听
function EventDispatch.offByFunc(callback)
	assert(type(callback) == "function","argument 1 is type function in EventDispatch.offByFunc")

	for k,listener in pairs(All_Listener) do
		for i=#listener,1,-1 do
			if listener[i].callback == callback then
				table.remove(listener,i)
			end
		end
	end
end

-- 移除所有对应事件名的所有回调,注意会移除其他人注册的哦!!
function EventDispatch.offByName(eventName)
	assert(type(eventName) == "string","argument 1 is type string in EventDispatch.offByName")

	All_Listener[eventName] = nil
end

-- 移除所有对应事件名绑定的对象的所有回调
function EventDispatch.offByNameTarget(eventName,target)
	assert(type(eventName) == "string","argument 1 is type string in EventDispatch.offByNameTarget")
	assert(type(target) == "userdata","argument 2 is type userdata in EventDispatch.offByNameTarget")

	local listener = All_Listener[eventName] or {}
	for i=#listener,1,-1 do
		if listener[i].target == target then
			table.remove(listener,i)
		end
	end
end

-- 移除所有对应事件名绑定的对象的所有回调
function EventDispatch.offByTarget(target)
	assert(type(target) == "userdata","argument 1 is type userdata in EventDispatch.offByTarget")
	for k,listener in pairs(All_Listener) do
		for i=#listener,1,-1 do
			if listener[i].target == target then
				print("移除target")
				table.remove(listener,i)
			end
		end
	end
end

-- 移除所有对应事件名绑定的对象的所有回调
function EventDispatch.offByTag(eventName,tag)
	assert(type(eventName) == "string","argument 1 is type string in EventDispatch.offByTag")
	assert(type(tag) == "string","argument 2 is type string in EventDispatch.offByTag")

	local listener = All_Listener[eventName] or {}
	for i=#listener,1,-1 do
		if listener[i].tag == tag then
			table.remove(listener,i)
		end
	end
end

-- 分发一个对应事件名的数据
function EventDispatch.emit(eventName, data, target)
	assert(type(eventName) == "string","argument 1 is type string in EventDispatch.emit")
	-- data should be nil
	local listeners = All_Listener[eventName] or {}
	if not target or not tolua.isnull(target) then
		for i=#listeners,1,-1 do
			if not tolua.isnull(listeners[i].target) and (not target or target == listeners[i].target) then
				local flag = nil
				xpcall(function ()
					flag = listeners[i].callback(clone(data),eventName)
				end, __G__TRACKBACK__)
				if type(flag) == "boolean" and flag == true then
					return
				end
			end
		end
	end
	-- for i,listener in ipairs(listeners) do
	-- 	if not tolua.isnull(listener.target) then
	-- 		xpcall(function ()
	-- 			listener.callback(clone(data),eventName)
	-- 		end, __G__TRACKBACK__)
	-- 	end
	-- end
	cleanRelease()
end

-- 分发一个对应事件名的数据
function EventDispatch.send(...)
	EventDispatch.emit(...)
end

-- 引擎事件的监听
local listenerBack = cc.EventListenerCustom:create(EventDispatch.ENTER_BACKGROUND,function (event)
	EventDispatch.emit(EventDispatch.ENTER_BACKGROUND,{name = EventDispatch.ENTER_BACKGROUND})
end)

local listenerFore = cc.EventListenerCustom:create(EventDispatch.ENTER_FOREGROUND,function (event)
	EventDispatch.emit(EventDispatch.ENTER_FOREGROUND,{name = EventDispatch.ENTER_FOREGROUND})
end)

cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listenerBack, 1)
cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listenerFore, 1)

local curScene = nil
cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
	local rScene = display.getRunningScene()
	if curScene ~= rScene then
		curScene = rScene
		local listenerKey = cc.EventListenerKeyboard:create()

		listenerKey:registerScriptHandler(function (keyCode, event)
			EventDispatch.emit(EventDispatch.ONKEY_DOWN,{code = keyCode,name = EventDispatch.ONKEY_DOWN})
		end, cc.Handler.EVENT_KEYBOARD_PRESSED)

		listenerKey:registerScriptHandler(function (keyCode, event)
			EventDispatch.emit(EventDispatch.ONKEY_UP,{code = keyCode,name = EventDispatch.ONKEY_UP})
			if keyCode == cc.KeyCode.KEY_BACK then
				EventDispatch.emit(EventDispatch.ONKEY_BACK,{name = EventDispatch.ONKEY_BACK})
			end
			if keyCode == cc.KeyCode.KEY_MENU then
				EventDispatch.emit(EventDispatch.ONKEY_MENU,{name = EventDispatch.ONKEY_MENU})
			end
		end, cc.Handler.EVENT_KEYBOARD_RELEASED)
		cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listenerKey, curScene)
	end
end,0.5,false)

return EventDispatch