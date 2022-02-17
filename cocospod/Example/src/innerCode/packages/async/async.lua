local async = {}
local Promise = import(".Promise")

local function checkNodeValid(bindNode)
    return not bindNode or not tolua.isnull(bindNode)
end 

async.delay = function(time, bindNode)
    return Promise.new(function(resolve, reject)
        local callbackEntry = nil
        local function callback(dt)
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(callbackEntry)
            if checkNodeValid(bindNode) then
                resolve()
            else
                reject()
            end
        end
        callbackEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, time, false)
    end)
    
end

async.runInNextFrame = function(func)
    local callbackEntry = nil
    local function callback(dt)
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(callbackEntry)
        func();
    end
     
    callbackEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 0, false)
end

async.createPromise = function(bindNode, executor)
    local promise = Promise.new(function(resolve, _reject)
        if checkNodeValid(bindNode) then
            executor(resolve,_reject)
        else
            _reject("Node is removed")
        end
    end)
    promise:catch(function(reason)
        if (reason) then
            print("promise finished:" .. tostring(reason));
        end
    end)
    return promise
end
    
async.solve = function(bindNode)
    if checkNodeValid(bindNode) then
        return Promise.reject("Node is removed")
    else
        return Promise.resolve()
    end
end

async.all = function(bindNode ,values)
    if checkNodeValid(bindNode) then
        return Promise.all(values);
    else
        return Promise.reject("Node is removed");
    end
end

async.wait = function(conditionFunc, bindNode)
    return Promise.new(function(resolve , reject)
        local check 
        check = function()
            if not checkNodeValid(bindNode) then
                reject("Node is removed");
                return
            end
            if conditionFunc() then
                resolve()
            else
                async.runInNextFrame(check)
            end
        end
        check()
    end)
end

async.series = function(arr , cb)
    local trigger
    trigger = function(i)
        if (i == #arr + 1) then
            if cb then
                cb();
            end
        else
            arr[i]( function ()
                trigger(i + 1);
            end);
        end
    end
    trigger(1);
end

--  异步顺序执行，并一个个地传递参数
async.waterfall = function(arr, cb)
    local trigger
    trigger = function (i , data)
        if i == #arr + 1 then
            if cb then
                cb(data)
            end
        else
            arr[i](data, function (d)
                trigger(i + 1, d)
            end)
        end

    end
    trigger(1)
end

-- 并行执行所有函数
async.parallel = function(arr, cb)
    local counter = #arr
    if counter > 0 then
        for i, v in ipairs(arr) do
            v(function ()
                counter = counter - 1;
                if counter == 0 and cb then 
                    cb()
                end
            end)
        end
    else
        if cb then 
            cb()
        end
    end
end

return async