local TextBinder = class("TextBinder", cc.load("mvc").BehaviorBase)

function TextBinder:onCreate()
	for key, value in pairs(self.textBind or {}) do
        if self.mView[key] then
            if self.mView[key].setText then
                self.mView[key]:setText(global.L(value))
            elseif self.mView[key].setString then
                self.mView[key]:setString(global.L(value))
            end
        end
    end
    global.event.on(global.eventName.LANGUAGE_REFRESH, handler(self,self.refreshUI), self)
end

function TextBinder:refreshUI()
	for key, value in pairs(self.textBind or {}) do
        if self.mView[key] then
            if self.mView[key].setText then
                self.mView[key]:setText(global.L(value))
            elseif self.mView[key].setString then
                self.mView[key]:setString(global.L(value))
            end
        end
	end
end

return TextBinder