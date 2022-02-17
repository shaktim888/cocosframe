local Notify = {}

local NotifyPoint = class("NotifyPoint")

function NotifyPoint:Ctor()
    self.data = { cnt = 0 }
end

function NotifyPoint:BindTo(node , customFunc)
    return node:bindAttr(self.data , "cnt" , function(v, oldV)
        if customFunc then 
            customFunc(v, oldV)
        else
            if node.setVisible then
                node:setVisible(v > 0)
            end
            local gameObject = node.ui
            if gameObject and gameObject.setVisible then
                gameObject:setVisible(v > 0)
            end
        end
    end)
end

function NotifyPoint:SetBindCnt(cnt)
    self.data.cnt = cnt
end

function NotifyPoint:InitWrap()
    self:Init()
end

function NotifyPoint:Init()

end

function NotifyPoint:Check()
    
end

Notify.NotifyPoint = NotifyPoint
-----------------------------------------------------
local NotifyGroup = class("NotifyGroup", NotifyPoint)

function NotifyGroup:Ctor()
    self.handles = {}
    self.pointMap = {}
end

function NotifyGroup:GetPoint(key)
    return self.pointMap[key]
end

function NotifyGroup:AddPoint(item, key)
    if key ~= nil then
        self.pointMap[key] = item
    end
    local h = XBindTool.BindAttr(item.data , "cnt" , function ( v , o_v)
        o_v = o_v or 0
        self.data.cnt = self.data.cnt + ( v - o_v )
    end)
    self.handles[item] = h
    if self.isInit then
        item:InitWrap()
        item:Check()
    end
end

function NotifyGroup:RemovePoint(item)
    self.data.cnt = self.data.cnt - item.data.cnt
    XBindTool.UnBind(self.handles[item])
    self.handles[item] = nil
end

function NotifyGroup:InitWrap()
    if self.isInit then return end
    self.isInit = true
    self:Init()
    for item , _ in pairs(self.handles) do
        item:InitWrap()
    end
end

function NotifyGroup:Check(...)
    for item , _ in pairs(self.handles) do
        item:Check(...)
    end
end

Notify.NotifyGroup = NotifyGroup
-----------------------------------------------------
local NotifyMgr = class("NotifyMgr")
local UpdateTime = 10 * CS.XTimerManager.ONE_SECOND

function NotifyMgr:Ctor()
    self.mapValue = {}
    self.updateArr = {}
end

function NotifyMgr:RegistPoint(pType, point)
    self.mapValue[pType] = point
    if self.isStart then
        point:InitWrap()
        point:Check()
    end
end

function NotifyMgr:RemovePoint(ptype)
    local point = self.mapValue[ptype]
    if point then
        self.mapValue[ptype] = nil
        for index , v in ipairs(self.updateArr) do
            if v == point then
                table.remove(self.updateArr , index)
                return
            end
        end
    end
end

function NotifyMgr:RegistUpdatePoint(pType, point)
    self.mapValue[pType] = point;
    table.insert(self.updateArr , point)
    if self.isStart then
        point:InitWrap()
        point:Check()
        self:CheckRecycle()
    end
end

function NotifyMgr:GetPoint(pType)
    return self.mapValue[pType]
end

function NotifyMgr:Start()
    if self.isStart then return end
    self.isStart = true;
    for _ , point in pairs(self.mapValue) do
        point:InitWrap();
        point:Check();
    end
    self:CheckRecycle()
end

function NotifyMgr:CheckRecycle()
    if #self.updateArr > 0 and not self.updateHandler then
        self.updateHandler = CS.XTimerManager.Add(function(timer)
            self:Update(timer)
        end, UpdateTime, CS.XTimerManager.LOOP_FOREVER, 0)
        self:Update(0)
    else
        if #self.updateArr == 0 and self.updateHandler then
            CS.XTimerManager.Remove(self.updateHandler)
            self.updateHandler = nil
        end
    end
end

function NotifyMgr:Update(timer)
    for _ , v in pairs(self.updateArr) do
        v:Check()
    end
end

Notify.NotifyMgr = NotifyMgr.new()

------------------------------------------------------------

return Notify