local effectTools = {}

-- 翻牌的效果
function effectTools.flopCard(bgCard, card)
    local rotateOut = cc.OrbitCamera:create(0.1, 1, 0, 0, 90, 0, 0)
    local rotateIn =  cc.OrbitCamera:create(0.1, 1, 0, 180 -90, -90, 0, 0)
    bgCard:setVisible(true)
    local function afterMoveCall()
        bgCard:setVisible(false)
    end
    local function afterCall()
        if card then
            card:setVisible(true)
        end
    end
    local actCall = cc.CallFunc:create(afterMoveCall)
    local cardActCall = cc.CallFunc:create(afterCall)
    local seq_1 = cc.Sequence:create(rotateOut, actCall)
    local seq_2 = cc.Sequence:create(cc.DelayTime:create(0.1), cardActCall, rotateIn)
    bgCard:runAction(seq_1)
    card:runAction(seq_2)
end

-- 3d旋转
function effectTools.rotate3DTo(node, from, to, time)
    time = time or 0.5
    return global.Promise.new(function(resolve, reject)
        node:setRotation3D({x = from.x, y = from.y, z = from.z})
        local speed = { x = (to.x - from.x) / time , y = (to.y - from.y) / time, z = (to.z - from.z) / time }
        local callbackEntry
        local tTime = 0
        local function callback(dt)
            tTime = tTime + dt
            if tolua.isnull(node) then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(callbackEntry)
                reject("Node removed!");
                return
            end
            if(tTime >= time) then
                node:setRotation3D(to)
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(callbackEntry)
                resolve();
            else
                node:setRotation3D({ x = from.x + speed.x * tTime, y = from.y + speed.y * tTime, z = from.z + speed.z * tTime })
            end
        end
        callbackEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 0, false)
    end)
end

-- 沿着轨迹移动
-- loopNum 为负数时 无限循环
-- nodes 可以是节点列表也可以是位置列表
function effectTools.moveByPath(nodes, moveNode, speed, loopNum)
    local totalTime = 0
    return global.Promise.new(function(resolve, reject)
        loopNum = loopNum or 0
        local pre_pos = nil
        local points = {}
        local times = {0}
        local updateHandler
        for _ , node in ipairs(nodes) do
            local pos
            if node.convertToWorldSpace then
                local worldP = node:convertToWorldSpace(cc.p(0,0))
                pos = moveNode:getParent():convertToNodeSpaceAR(worldP)
            else
                pos = cc.p(node.x, node.y)
                pos = moveNode:getParent():convertToNodeSpaceAR(pos)
            end
            table.insert(points , pos)
            if pre_pos then
                local dis = math.sqrt( cc.pDistanceSQ(pre_pos , pos) )
                local moveTime = dis / speed
                totalTime = totalTime + moveTime
                table.insert(times , totalTime)
            end
            pre_pos = pos
        end
        for index , v in ipairs(times) do
            times[index] = v / totalTime
        end
        local cur_time = 0
        local function interpolationPoint(start_p , end_p , percent)
            return cc.p(start_p.x + (end_p.x - start_p.x) * percent , start_p.y + (end_p.y - start_p.y) * percent)
        end
        local function applyCurTime()
            local pecent = cur_time / totalTime
            local cur_index = #times
            for index , v in ipairs(times) do
                if v > pecent then
                    cur_index = index
                    break
                end
            end
            local sub_pecent = (pecent - times[cur_index - 1])/(times[cur_index] - times[cur_index - 1])
            local pos = interpolationPoint(points[cur_index - 1] , points[cur_index] ,sub_pecent)
            moveNode:setPosition(pos)
        end
        applyCurTime()

        local function onTick(dt)
            if tolua.isnull(moveNode) then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(updateHandler)
                reject()
                return
            end
            cur_time = cur_time + dt
            if cur_time > totalTime then
                if loopNum > 0 or loopNum < 0 then
                    while cur_time > totalTime do
                        loopNum = loopNum - 1
                        cur_time = cur_time - totalTime 
                    end
                else
                    cur_time = totalTime
                    applyCurTime()
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(updateHandler)
                    resolve()
                    return
                end
            end
            applyCurTime()
        end
        updateHandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onTick, 0, false)
    end), totalTime
end

-- 异步执行action
function effectTools.runAction(node, ...)
    local actions = { ... }
    if #actions == 1 and type(actions[1]) == "table" then
        actions = actions[1]
    end
    return global.Promise.new(function(resolve, reject)
        if tolua.isnull(node) then
            reject("Node removed!");
            return
        end
        table.insert(actions, cc.CallFunc:create(function()
            resolve()
        end))
        node:runAction(cc.Sequence:create(actions))
    end)
end

return effectTools