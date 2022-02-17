local UILogin = class("UILogin", cc.load("mvc").ModuleBase)
UILogin.RESOURCE_FILENAME = "game/niuniu/login.lua"
cc.exports.rule = import("logic.game.niuniu2.rule")
UILogin.behavior ={
    "logic.common.behavior.FontColorChange",
}
UILogin.changecolorfont = {
    playBtn = {},
    ruleBtn = {}
}
cc.exports.NIUNIU_BEST_SCORE = "NIUNIU_BEST_SCORE"
function UILogin:onCreate()
    audio.playMusic("game/niuniu/sound/bgm.mp3",true)
    self.mView["playBtn"]:setTitleText(global.L("hall.start_btn"))
    self.mView["ruleBtn"]:setTitleText(global.L("hall.rule_btn"))
    self.mView["bestText"]:setText(global.L("hall.best"))
    local score = global.saveTools.getData(NIUNIU_BEST_SCORE)
    if not score then
       score = 0
       global.saveTools.saveData(NIUNIU_BEST_SCORE,score) 
    end
    self.mView["scoreText"]:setString(score)
end

function UILogin:initSound()
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

function  UILogin:onruleBtnClick()
    local view = rule.new(nil,nil,1)
    global.viewMgr.showView(view, true)
    view:onruleBtnClick()
end

function  UILogin:onplayBtnClick()
    AudioEngine.playEffect("game/niuniu/sound/Button.mp3",false)
    require("logic.game.niuniu2.PlayModeGameScene").new():showWithScene("FadeTR", 0.5)
end

return UILogin
