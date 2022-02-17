local rule = class("rule", cc.load("mvc").ModuleBase)
rule.RESOURCE_FILENAME = "game/niuniu/rule.lua"
rule.behavior ={
    "logic.common.behavior.FontColorChange",
}
rule.changecolorfont = {
    contentText1 = {}
}
function rule:onCreate(mode)
    self:initSound()
    local isShow
    if mode == 1 then
        isShow = true
    else
        isShow = false
    end
    
    
    self.contentText1 = self.mView["contentText1"]
    self.contentText1:setText(global.L("hall.rule_text"))
    self.musicBtn = self.mView["musicBtn"]
    self.musicCloseBtn = self.mView["musicCloseBtn"]
    self.effectBtn = self.mView["effectBtn"]
    self.effectCloseBtn = self.mView["effectCloseBtn"]
    self.setPanel = self.mView["setPanel"]
    self.rulePanel = self.mView["rulePanel"]


    self.rulePanel:setVisible(isShow)
    self.setPanel:setVisible(not isShow)

    --音效滑动条
    self.sliderEffect_ = self.setPanel:getChildByName("sliderEffect");
    self.sliderEffect_:addEventListener(function(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local percent = "Percent " .. (self.sliderEffect_:getPercent() / self.sliderEffect_:getMaxPercent() * 100);
            local volume = self.sliderEffect_:getPercent() / self.sliderEffect_:getMaxPercent();
            global.saveTools.saveData("nwpk_effectPercent", volume)
            global.utils.sound.setEffectVolume(volume)
        end
    end)
    self.sliderEffect_:setPercent(global.utils.sound.getEffectVolume() * 100)

    --音量滑动条
    self.sliderNum_ = self.setPanel:getChildByName("sliderNum");
    self.sliderNum_:addEventListener(function(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local percent = "Percent" .. (self.sliderNum_:getPercent() / self.sliderNum_:getMaxPercent() * 100);
            local volume = self.sliderNum_:getPercent() / self.sliderNum_:getMaxPercent();
            global.saveTools.saveData("nwpk_musicPercent",volume)
            global.utils.sound.setMusicVolume(volume)
        end
    end)
    self.sliderNum_:setPercent(global.utils.sound.getMusicVolume() * 100)

end

function rule:initSound()
    local effect = global.saveTools.getData("nwpk_effectPercent")
    local music = global.saveTools.getData("nwpk_musicPercent")
    local perEffect = 1
    local perMusic = 0.5
    if effect then
        perEffect = effect
    end
    if music then
        perMusic = music
    end
    global.utils.sound.setEffectVolume(perEffect) 
    global.utils.sound.setMusicVolume(perMusic)
end



function rule:onruleBtnClick()
   
end

function rule:onshadeClick()
    self:removeFromParent(true)
    AudioEngine.playEffect("game/niuniu/sound/Button.mp3", false)
end

return  rule

