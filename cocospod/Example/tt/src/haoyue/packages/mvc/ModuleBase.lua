local ModuleBase = class("ModuleBase", cc.Node)

local WARNING = DEBUG > 0

local fileUtils = cc.FileUtils:getInstance()
local HISTORY_SAVE_KEY = "__HY_%s_SAVE_KEY__"
local HISTORY_SAVE_KEY_tbl = {}

local saveData = {}
local function readSaveData(key_)
    if not saveData or (table.nums(saveData) == 0) then
        saveData = global.saveTools.getData(string.format(HISTORY_SAVE_KEY, key_))
    end
    return saveData
end
local function saveDataToFile(key_)
    global.saveTools.saveData(string.format(HISTORY_SAVE_KEY, key_), saveData)
end

local LAYOUT_TYPE ={
    NONE = 0,
    LUA = 1,
    CSB = 2,
}
local function getLayoutType(layout)
    local extend = string.lower(layout:match(".+%.(%w+)$"))
    if extend == "csb" then
        return LAYOUT_TYPE.CSB
    elseif extend == "lua" then
        return LAYOUT_TYPE.LUA  
    end
    return LAYOUT_TYPE.NONE
end

-- 替换UI加载工具需要修改此处 !!
local is_need_fake = false
function ModuleBase:__loadLayoutFile(layout)
    local layout_type = getLayoutType(layout)
    if layout_type == LAYOUT_TYPE.CSB then
        return self:__loadLayoutFileWithCsb(layout)
    elseif layout_type == LAYOUT_TYPE.LUA then
        return self:__loadLayoutFileWithLua(layout)
    end
end

-- local function getRandomImdex(tbl_)
--     local index = #tbl_
--     local tbl = {}
--     -- local range = (index > #tbl) and index or #tbl
--     -- dump(range)
--     -- dump(tbl_)

--     for i = 1, index do
--         tbl[i] = i
--     end

--     -- dump(tbl)
--     math.randomseed(tostring(socket.gettime()):reverse():sub(1, 7))
--     local ret = {}
--     repeat 
--         ret[#ret+1] = table.remove(tbl, math.random(1, #tbl))
--     until (#tbl==0)

--     -- dump(ret)
--     return ret
-- end

function ModuleBase:__loadLayoutFileWithLua(layout)
    local scene = require(layout)
    -- dump(self.__createHandler)
    local game_scene = scene.create( handler(self, self.__createHandler))
    self.__csbAnimation = game_scene.animation

    return game_scene.root
end

function ModuleBase:__loadLayoutFileWithCsb(layout)
    return cc.CSLoader:createNode(layout)
end

function ModuleBase.__doLayout(self)
    local size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    self:setContentSize(size)
    self:setAnchorPoint(cc.p(0,0))
    self.mLayout:setContentSize(size)
    ccui.Helper:doLayout(self.mLayout)
end

local nodeeventnames = {
    "enter",
    "exit",
    "enterTransitionFinish",
    "exitTransitionStart",
    "cleanup",
}
function ModuleBase:ctor(scene, name, ...)
    self:enableNodeEvents()
    self.mScene    = scene
    self.mName     = name
    self.mView     = {}
    self.mModule   = {}
    self.mLayout   = nil

    if type(self.preCreate) == "function" then self:preCreate(...) end

    self:bindBehavior()
    self:loadLayout()
    self:bindModules()
    
    if type(self.onCreate) == "function" then self:onCreate(...) end

    -- print("ModuleBase:ctor == "..tostring(name))
    if global.eventExecuter:hasEvents() then
        local param = {
            name = self:getClassName(),
            timename = "enter",
            target = self
        }
        function ModuleBase:onEnterCallback_()
            local param = {
                name = self:getClassName(),
                timename = "enter",
                target = self
            }
            param.timename = "enter"
            global.eventExecuter:timeEvent(param)
        end

        function ModuleBase:onExitCallback_()
            local param = {
                name = self:getClassName(),
                timename = "enter",
                target = self
            }
            param.timename = "exit"
            global.eventExecuter:timeEvent(param)
        end

        function ModuleBase:onEnterTransitionFinishCallback_()
            local param = {
                name = self:getClassName(),
                timename = "enter",
                target = self
            }
            param.timename = "enterTransitionFinish"
            global.eventExecuter:timeEvent(param)
        end

        function ModuleBase:onEnterTransitionStartCallback_()
            local param = {
                name = self:getClassName(),
                timename = "enter",
                target = self
            }
            param.timename = "exitTransitionStart"
            global.eventExecuter:timeEvent(param)
        end

        function ModuleBase:onCleanupCallback_()
            local param = {
                name = self:getClassName(),
                timename = "enter",
                target = self
            }
            param.timename = "cleanup"
            global.eventExecuter:timeEvent(param)
        end
    end
end

local function seekByName(self, childName)
    local children = self:getChildren()
    local find = nil
    for i=1,#children do
        if (children[i]:getName() == childName) then
            find = children[i]
            break
        end
    end
    if not find then
        for i=1,#children do
            find = seekByName(children[i],childName)
            if (find) then
                break
            end
        end
    end
    if(find and type(find.addClickEventListener) == "function")then
        find.__org_addClickEventListener = find.__org_addClickEventListener or find.addClickEventListener
        find.addClickEventListener = function (...)
            local arg = {...}
            local func = arg[2]
            arg[1].__lastClickTime = 0
            arg[1].__diffClickTime = arg[1].__diffClickTime or 0.5
            arg[2] = function (...)
                if socket.gettime() - arg[1].__lastClickTime > arg[1].__diffClickTime then
                    arg[1].__lastClickTime = socket.gettime()
                    func(...)
                end
            end
            find.__org_addClickEventListener(unpack(arg))
            if find.setPressedActionEnabled then
                find:setPressedActionEnabled(true)
                find:setZoomScale(0.2)
            end
        end
    end
    if find then
        find.seekByName = seekByName
    end
    return find
end

local function stepView(self,parent)
    local children = parent:getChildren() or {}
    local widget
    for i=1,#children do
        widget = children[i]
        local name = widget:getName()
        print("stepView name = "..tostring(name))
        if(self.mView[name] ~= nil) then
            if WARNING then
                print("[Warning] Module:["..self:getName().."] append view but find same name: ["..name.."]")
            end
        else
            self.mView[name] = widget
            widget.seekByName = seekByName
            if type(self["on"..name.."Click"]) == "function" and type(widget.addClickEventListener) == "function" then
                widget:addClickEventListener(handler(self,self["on"..name.."Click"]))
                if widget.setPressedActionEnabled then
                    widget:setPressedActionEnabled(true)
                    widget:setZoomScale(0.2)
                end
            end
        end
        
        if (widget.isScale9Enabled and widget:isScale9Enabled()) then
        else
            if iskindof(widget, "ccui.ImageView") or iskindof(widget, "ccui.Button") then
                if widget.ignoreContentAdaptWithSize then
                    print(tostring(widget:isScale9Enabled()) .." ========stepview " ..widget:getName())
                    widget:ignoreContentAdaptWithSize(true)
                end
            end
        end
        stepView(self,widget)
    end
end

function ModuleBase:loadLayout()
    if type(self.RESOURCE_FILENAME) == "string" then
        xpcall(function()
                self.mLayout = self:__loadLayoutFile(self.RESOURCE_FILENAME)
                if self.mLayout then
                    self:add(self.mLayout)
                    stepView(self,self.mLayout)
                else
                    if WARNING then
                        print("Module ["..self:getName().."] could not find layout: "..self.RESOURCE_FILENAME)
                    end
                end
            end, function(msg)
                dump(msg)
                if WARNING then
                    print("Module ["..self:getName().."] could not find layout: "..self.RESOURCE_FILENAME)
                end
            end
        )
    end
    if self.mLayout then
        ModuleBase.__doLayout(self)
        if not next(self.mView) then
            error("Module ["..self:getName().."] load layout but found nothing view !")
        end

        -- for k, v in pairs(self.__layout__group_t or {}) do
        --     local index_t = saveData["group"..tostring(k)] or getRandomImdex(v)
        --     saveData["group"..tostring(k)] = index_t
        --     local pos = {}
        --     for i = 1, #v do 
        --         local t = self.mView[v[i]]
        --         if t then
        --             pos[i] = cc.p(t:getPosition())
        --         end
        --     end

        --     for i, sub_index in ipairs(index_t) do
        --         local t = self.mView[v[sub_index]]
        --         if t and pos[i] then
        --             t:setPosition(pos[i])
        --         end
        --     end
        -- end

        -- if is_need_fake and (getLayoutType(self.RESOURCE_FILENAME) == LAYOUT_TYPE.LUA) then
        --     if not global.viewMgr.__israndomed then
        --         global.viewMgr.__israndomed = true

        --         local ViewActions = require("logic.common.views.entity.ViewActions")
        --         local action_type_tbl = ViewActions.ACTION_TYPE_TBL
        --         math.randomseed(tostring(socket.gettime()):reverse():sub(1, 7))
        --         -- local action_name = "jump" --action_type_tbl[math.random(1, #action_type_tbl)]
        --         local action_name = action_type_tbl[math.random(1, #action_type_tbl)]
        --         dump(action_name)
        --         global.viewMgr.showAction = ViewActions[action_name.."OpenAction"]
        --         global.viewMgr.closeAction = ViewActions[action_name.."CloseAction"]
        --     end

        --     saveDataToFile(self.RESOURCE_FILENAME)
        -- end
    end
end

-- 绑定其它组件,与SceneBase相同
function ModuleBase:bindModules()
    for i,module in ipairs(self.module or {}) do
        xpcall(
            function()
                local mod = require(module)
                if rawget(mod,"ctor") then
                    error("[Error] Module "..module.." could not overwrite parent ctor() ,use onCreate() or preCreate()")
                end
                local m = mod:create(self, module)
                self.mModule[module] = m
                self:add(m)
            end, 
            function(err)
                if WARNING then
                    print("Module could not load sub module: "..module)
                    __G__TRACKBACK__(err)
                end
            end
        )
    end
end

-- 绑定一些行为
function ModuleBase:bindBehavior()
    for i,behavior in ipairs(self.behavior or {}) do
        xpcall(
            function()
                local beh    = require(behavior)
                local behTar = beh.new()
                if behTar.export == nil then
                    behTar.export = {}
                    for k,_ in pairs(beh) do
                        if type(behTar[k]) == "function" then
                            behTar.export[#behTar.export+1] = k
                        end
                    end
                end
                for i,func in ipairs(behTar.export or {}) do
                    local orgFunc = self[func]
                    self[func] = function (...)
                        local returnValue = nil
                        if orgFunc then
                            returnValue = orgFunc(...)
                        end
                        local rValue = behTar[func](...)
                        
                        return returnValue or rValue
                    end
                end
                print("Module: ["..self:getName().."] bind behavior: "..behavior)
            end,function(err)
                if WARNING then
                    print("Module ["..self:getName().."] could not bind behavior: "..behavior)
                    __G__TRACKBACK__(err)
                end
            end
        )
    end
end

function ModuleBase:preCreate()
    -- implement by children
end

function ModuleBase:onCreate()
    -- implement by children
end

function ModuleBase:getName()
    return self.mName or self.class.__cname
end

function ModuleBase:getClassName()
    return self.class.__cname
end

-- 刷新UI调用
function ModuleBase:refreshUI(data)
    -- implement by children
end

function ModuleBase:getTopModule()
    local top = self
    while top.mScene and iskindof(top.mScene, "ModuleBase") do
        top = top.mScene
    end
    return top
end

function ModuleBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self:getName())
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    if self.animEnter then
        self:animEnter()
    end 
    return self
end

function ModuleBase:removeView()
    if self.animExit then
        self:animExit()
    else
        self:removeFromParent()
    end 
end


function ModuleBase:__createHandler(filename_, sender_, funcName_)
    local func = self[funcName_]
    if not func then
        return function ()
            print("__createHandler  default function been called! "..tostring(funcName_))
        end
    end
    return handler(self, func)
end

-- ModuleBase.__createHandler = handler(self, ModuleBase.createHandler)

return ModuleBase
