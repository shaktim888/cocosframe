local BtnBinder = class("BtnBinder", cc.load("mvc").BehaviorBase)

function BtnBinder:onCreate()
	for key,callback in pairs(self.btnBind or {}) do
		if self.mView[key] and self[callback] then
			if self.mView[key].addClickEventListener then
				self.mView[key]:addClickEventListener(handler(self,self[callback]))
			else
				local listener = cc.EventListenerTouchOneByOne:create();
				listener:registerScriptHandler(function( ... )
											return self.mView[key]:isVisible();
										end,
										cc.Handler.EVENT_TOUCH_BEGAN); 
				listener:registerScriptHandler(function( ... )
											self[callback](self, ...)
										end,
										cc.Handler.EVENT_TOUCH_ENDED); 
				listener:setSwallowTouches(true);
				cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.mView[key]);
			end
		else
			print("[Warn] Behavior <BtnBinder> auto bind error in: " .. self:getName() .. " with key: " .. key)
		end
	end
end

return BtnBinder