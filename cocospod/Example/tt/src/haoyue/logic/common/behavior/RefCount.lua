local RefCount = class("RefCount", cc.load("mvc").BehaviorBase)

function RefCount:onCreate()
	self._refNum = self:isVisible() and 1 or 0
end

function RefCount:setRefActive(val)
	if val then
        self._refNum = self._refNum + 1;
        if self._refNum == 1 then
            self:setVisible(true);
        end
    else 
        self._refNum = self._refNum - 1;
        if self._refNum == 0 then
            self:setVisible(false);
        end
    end
end

return RefCount