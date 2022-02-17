local tips = class("tips", cc.load("mvc").ModuleBase)
tips.RESOURCE_FILENAME = "game/niuniu/errorTips.lua"
tips.behavior = {
   "logic.common.behavior.ClickToClose",
   "logic.common.behavior.FontColorChange"
}
tips.changecolorfont = {
    contentText = {}
}
function tips:onCreate(type)
    local str = ""
    if type == "noniu" then
        str = global.L("game.noniu_error")
    else
        str = global.L("game.niu_error")
    end
    self.mView["contentText"]:setText(str)
end

return  tips

