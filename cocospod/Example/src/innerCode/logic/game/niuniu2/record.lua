local record = class("record", cc.load("mvc").ModuleBase)
record.RESOURCE_FILENAME = "game/niuniu/record.lua"
record.behavior = {
   "logic.common.behavior.FontColorChange"
}
record.changecolorfont = {
    btn_return = {},
    win_text = {}
}

function record:onCreate(players)

    self.mView["btn_return"]:setTitleText(global.L("game.btn_return"))
    local str = ""
    if players[1].smallNum > 0 then
        str = global.L("balance.win")
    elseif players[1].smallNum == 0 then
        str = global.L("balance.draw")
    else
        str = global.L("balance.lose")
    end
    self.mView["win_text"]:setText(str)
    for i,v in ipairs(players) do
        print(v.tblstate)
        local data = {name = v.name, coin = v.smallNum}
        if i == 1 then
            self:saveScore(v.smallNum)
        end
        if v.tblstate ~= 4 and data.name then
            self:recordInfo(data)
        end
    end
end

function record:saveScore(ownScore)
    local score = global.saveTools.getData(NIUNIU_BEST_SCORE)
    if ownScore > score then
        global.saveTools.saveData(NIUNIU_BEST_SCORE,ownScore) 
    end
end

function record:onbtn_returnClick()
    AudioEngine.playEffect("game/niuniu/sound/Button.mp3", false)
    global.viewJump.gotoMainGame()
end

function record:recordInfo(data)
    local rArr =  data
    if not rArr then
        return 
    end
    local rankNode = require("logic.game.niuniu2.recordCell"):create()
    local rankList = self.mView["List"]
    -- 隐藏滑动条
    rankList:setScrollBarEnabled(false);
    
    rankNode:setData(rArr);   
    rankList:pushBackCustomItem(rankNode);
    local waitSize = rankList:getContentSize();
    local itemSize = rankNode:getSize().width
    local height = itemSize*8;
    if height > waitSize.height then
        rankList:setInnerContainerSize(cc.size(waitSize.width,height));
    end
end

return  record

