local TouchInterrupt = class("TouchInterrupt", cc.load("mvc").BehaviorBase)

function TouchInterrupt:onCreate()
	local listener = cc.EventListenerTouchOneByOne:create();
    listener:registerScriptHandler(function( ... )
    							return self:isVisible();
    						end,
    						cc.Handler.EVENT_TOUCH_BEGAN); 
    listener:setSwallowTouches(true);
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self);
end

return TouchInterrupt