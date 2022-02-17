local Notify = import(".Notify")
local NotifyManager = {}

function NotifyManager.BindNode(node , types , customFunc)
    local group = NotifyGroup.new()
    for _ , ptype in ipairs(types) do
        local point = Notify.NotifyMgr:GetPoint(ptype)
        if point then group:AddPoint(point) end
    end
    group:BindTo(node, customFunc)
end

function NotifyManager.BindNodeWithKey(node, ptype, keys, customFunc)
    local point = Notify.NotifyMgr:GetPoint(ptype)
    for _, v in ipairs(keys) do
        if point and point.GetPoint then
            point = point:GetPoint(v)
        else
            break
        end
    end
    if point then 
        point:BindTo(node, customFunc)
    end
end

-- 考虑放在登录后再开启
function NotifyManager.Start()
    Notify.NotifyMgr:Start()
end

return NotifyManager