local CountDown = {}
local BindTools = import(".BindTools")

local TimerRecord = { bindCnt = 0, record = {}, timeHandle = nil }

local function updateTimerRecord()
    local now = os.time()
    for _ , v in pairs(TimerRecord.record) do
        if v.bindCnt > 0 and v.remainTime > 0 then
            v.remainTime = v.remainTime - (now - v.lastTime)
            v.lastTime = now
            if v.remainTime < 0 then
                v.remainTime = 0
            end
        end
    end
end

function CountDown.createTimer(name, remainTime, now)
    assert(name ~= CountDown,"please use dot to call CountDown.createTimer")
    if not TimerRecord.record[name] then
        TimerRecord.record[name] = {
            bindCnt = 0,
        }
    end
    now = now or os.time()
    TimerRecord.record[name].remainTime = remainTime
    TimerRecord.record[name].lastTime = now
end

function CountDown.removeTimer(name)
    assert(name ~= CountDown,"please use dot to call CountDown.removeTimer")
    local record = TimerRecord.record[name]
    if record then
        TimerRecord.bindCnt = TimerRecord.bindCnt - record.bindCnt
        BindTools.unBindObj(record)
        TimerRecord.record[name] = nil
        if TimerRecord.bindCnt == 0 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(TimerRecord.timeHandle)
            TimerRecord.timeHandle = nil
        end
    end
end

function CountDown.getRemainTime(name)
    assert(name ~= CountDown,"please use dot to call CountDown.getRemainTime")
    local record = TimerRecord.record[name]
    if record then
        local now = os.time()
        if record.bindCnt > 0 and record.remainTime > 0 then
            record.remainTime = record.remainTime - (now - record.lastTime)
            record.lastTime = now
            if record.remainTime < 0 then
                record.remainTime = 0
            end
        end
        return record.remainTime
    else
        return 0
    end
end

function CountDown.bindTimer(node, name, cb)
    assert(node ~= CountDown,"please use dot to call CountDown.bindTimer")
    local record = TimerRecord.record[name]
    if record then
        if not TimerRecord.timeHandle then
            TimerRecord.timeHandle = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
                updateTimerRecord()
            end, 1, false)
            updateTimerRecord()
        end
        TimerRecord.bindCnt = TimerRecord.bindCnt + 1
        record.bindCnt = record.bindCnt + 1
        node:bindAttr(record, "remainTime", cb, function()
            TimerRecord.bindCnt = TimerRecord.bindCnt - 1
            record.bindCnt = record.bindCnt - 1
            if TimerRecord.bindCnt == 0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(TimerRecord.timeHandle)
                TimerRecord.timeHandle = nil
            end
        end)
    end
end

return CountDown