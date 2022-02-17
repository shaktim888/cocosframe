local tips = class("tips", cc.load("mvc").ModuleBase)
tips.RESOURCE_FILENAME = "game/niuniu/tips.lua"
tips.behavior ={
    "logic.common.behavior.FontColorChange",
}
tips.changecolorfont = {
    contentText = {},
    btn_yes = {},
    btn_no = {}
}
function tips:onCreate(callback)
    self.callback = callback
    self.mView["btn_yes"]:setTitleText(global.L("tips.btn_yes"))
    self.mView["btn_no"]:setTitleText(global.L("tips.btn_no"))
    self.mView["contentText"]:setText(global.L("tips.tips_text"))
end

function tips:onbtn_yesClick()
    AudioEngine.playEffect("game/niuniu/sound/Button.mp3", false)
    self.callback()
end

function tips:onbtn_noClick()
    AudioEngine.playEffect("game/niuniu/sound/Button.mp3", false)
    self:removeFromParent(true)
end

return  tips

