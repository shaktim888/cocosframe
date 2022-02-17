local GAME_PREX = HY_GAME_PREX

cc.FileUtils:getInstance():setSearchPaths({})
cc.FileUtils:getInstance():addSearchPath(GAME_PREX .. "/", true)
cc.FileUtils:getInstance():addSearchPath(GAME_PREX .. "/res/", true)
cc.FileUtils:getInstance():addSearchPath("src/" .. GAME_PREX .. "/", true)
cc.FileUtils:getInstance():addSearchPath("src/" .. GAME_PREX .. "/res/", true)

package.path = GAME_PREX .. "/?.lua;" .. "src/" .. GAME_PREX .. "/?.lua;" .. package.path
package.path = GAME_PREX .. "/?.lua;" .. package.path
setmetatable(_G, nil)

-- 清理已加载资源
for k,v in pairs(package.loaded) do
    if k == "config" or string.find(k, "app.") == 1 or string.find(k, "cocos.") == 1 or string.find(k, "packages.") == 1 or string.find(k, "src.") == 1 then
        package.loaded[k] = nil
    end
end
require "config"

if DEBUG > 1 then
    require("LuaDebug")("localhost", 7003)
end

global = {}
require "cocos.init"

global.event        = cc.load("eventDispatch").eventDispatch
global.editorTools  = (DEBUG > 0 and imgui) and cc.load("editor").editorTools or null
global.bindTools    = cc.load("bind").bindTools
global.countDown    = cc.load("bind").countDown
global.async        = cc.load("async").async
global.Promise      = cc.load("async").Promise

global.isGrabScreenMode = 0
global.eventExecuter   = require("packages.eventExecuter.EventExecuter"):create()

global.saveTools    = require("logic.common.tools.SaveTools")
global.viewMgr      = require("logic.common.views.viewMgr")
global.viewJump     = require("logic.common.views.viewJump")
global.resTools     = require("logic.common.tools.gameRes")
global.utils        = require("logic.common.tools.utils")
global.eventName    = require("logic.common.config.EventName")
global.L            = require("logic.common.tools.languageTools")
global.configLoader = require("logic.common.tools.configLoader")

if global.isGrabScreenMode == 0 then
    local randomseed = global.saveTools.getData("globalrandomSeed")
    global.randomSeed = randomseed or tostring(os.time()):reverse():sub(1, 7)
    global.saveTools.saveData("globalrandomSeed", global.randomSeed)
else
    global.randomSeed = tostring(os.time()):reverse():sub(1, 7)
end


global.L.addData(cc.LANGUAGE_ENGLISH, require("logic.common.config.language.EN.lua"))
global.L.addData(cc.LANGUAGE_CHINESE, require("logic.common.config.language.CH.lua"))
global.L.addData(cc.LANGUAGE_KOREAN, require("logic.common.config.language.KO.lua"))
global.L.addData(cc.LANGUAGE_JAPANESE, require("logic.common.config.language.JP.lua"))

global.L.switchTo(global.L.getCurrentLanguage())

return global