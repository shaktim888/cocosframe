
local ViewJump = {}
-- require("logic.game.read.ReadCsv");
-- require("logic.game.read.GameSaveData");
-- require("logic.game.read.GameData");

function ViewJump.gotoMainGame()
    -- 初始化游戏保存数据
    --GameSaveData.init();

    ViewJump.gotoniuniu()
end

function ViewJump.gotoniuniu()
    require("logic.common.launcher.game"):create():run("game.niuniu2.loginScene")  
end

return ViewJump