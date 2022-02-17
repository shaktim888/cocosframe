local FrameAnimation = class("FrameAnimation")
FrameAnimation.sprite = nil;
FrameAnimation.playTimes = nil;
FrameAnimation.start = nil;
FrameAnimation.length = nil;
FrameAnimation.resName = nil;
FrameAnimation.animation = nil;
FrameAnimation.playIndex = nil;

function FrameAnimation:ctor(data)
	self.resName = data.resName;
	self.playTimes = data.playTimes;
	self.path = data.path;
	self.spriteFrame  = cc.SpriteFrameCache:getInstance()  
	-- print(data.path..data.resName..".plist");
   	self.spriteFrame:addSpriteFrames(data.path..data.resName..".plist");
    self.sprite = cc.Sprite:createWithSpriteFrameName(data.resName .. "01.png");
	self.timePerUnit = data.timePerUnit or 0.15; 

end

function FrameAnimation:playAnimation(time)
	self.playIndex = 1;
	time = time or self.playTimes;
	time = time or 1;
	if not self.animation then
		self:createAnimation();
	end
	local action = cc.Animate:create(self.animation);
	if time ~= -1 then     -- 播放指定次数
		local delAction = cc.DelayTime:create(0.5)
		local callFanc = cc.CallFunc:create(function()
							self.sprite:stopAllActions();
							self.spriteFrame:removeSpriteFramesFromFile(self.path..self.resName..".plist")
							self.sprite:removeFromParent(true);
		end)  
		local sequence = cc.Sequence:create(cc.Repeat:create(action, time),callFanc);    
		self.sprite:runAction(sequence);
	else                   -- 重复一直播放
		self.sprite:runAction(cc.RepeatForever:create(action));
	end
end

function FrameAnimation:createAnimation()
	self.animation  = cc.Animation:create();
	local idx = 1
	while(true) do
		local frameName = string.format(self.resName .. "%02d.png", idx);    
        local spriteFrame = self.spriteFrame:getSpriteFrameByName(frameName);

        if not spriteFrame then break end;

        self.animation:addSpriteFrame(spriteFrame); 

        idx = idx + 1;
	end
	
	self.animation:setDelayPerUnit(self.timePerUnit)            --设置两个帧播放时间             
    self.animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态
end


return FrameAnimation