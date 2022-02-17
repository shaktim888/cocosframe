local utils = {}
local audio = audio

utils.registerTimeTouch = function(node, time , touchFunc , holdFunc , endHoldFunc)
    local isHold = false
    local isTouch = false
    node:onTouch(function(event)
        if event.name == "began" then
            node:stopActionByTag(10086)
            local delayAction = cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function()
                if isTouch then return end
                if touchFunc then
                    holdFunc()
                end
                isHold = true
            end))
            delayAction:setTag(10086)
            node:runAction(delayAction)
        elseif event.name == "ended" or event.name == "cancelled" then
            if isHold then
                endHoldFunc()
                isHold = false
            else
                isTouch = true
                node:stopActionByTag(10086)
                touchFunc()
            end
        end
    end)
end

utils.sortByKeys = function(datas , keys , isMinTop)
    local recordValue = {}
    for _ , data in pairs(datas) do
        recordValue[data] = {}
        for index , val in ipairs(keys) do
            if type(val) == "function" then
                recordValue[data][index] = val(data)
            else
                recordValue[data][index] = data[val]
            end
        end
    end
    local list = {}
    for _ , data in pairs(datas) do
        local finalPos = #list + 1
        local isOk = false
        for i = #list , 1 , -1 do
            for index , val in ipairs(keys) do
                local iData = recordValue[list[i]][index]
                local curData = recordValue[data][index]
                if (isMinTop and iData > curData) or (not isMinTop and iData < curData ) then
                    finalPos = i
                    list[i + 1] = list[i] 
                    break
                elseif  (isMinTop and iData < curData) or (not isMinTop and iData > curData ) then
                    finalPos = i + 1
                    isOk = true
                    break
                end
            end
            if isOk then break end
        end
        list[finalPos] = data
    end
    return list
end

local sound = {}

sound.BG_VOLUME_KEY = "BG_VOLUME_KEY"
sound.SOUND_VOLUME_KEY = "SOUND_VOLUME_KEY"

sound.isSoundInited = false

function sound.initSound()
    if sound.isSoundInited then
        return
    end
    sound.isSoundInited = true
    local bgVolume = sound.getMusicVolume()
    local soundVolume = sound.getEffectVolume()
    -- audio.initData(true, bgVolume or 0.5, soundVolume or 0.5)
    audio.setMusicVolume(bgVolume)
    audio.setSoundsVolume(soundVolume)
end

function sound.playBgMusic(path)
    if sound.isStopMusic then return end
    sound.initSound()
    audio.playMusic(path, true)
end

function sound.getMusicVolume()
    local volume = global.saveTools.getData(sound.BG_VOLUME_KEY)
    if type(volume) == "number" then
        return volume
    end
    return 0.5
end

function sound.setMusicVolume(volume)
    global.saveTools.saveData(sound.BG_VOLUME_KEY, volume)
    audio.setMusicVolume(volume)
end

function sound.getEffectVolume()
    local volume = global.saveTools.getData(sound.SOUND_VOLUME_KEY)
    if type(volume) == "number" then
        return volume;
    end
    return 0.5
end

function sound.setEffectVolume(volume)
    global.saveTools.saveData(sound.SOUND_VOLUME_KEY, volume)
    audio.setSoundsVolume(volume)
    if volume == 0 then
        sound.isStopSound = true
    else
        sound.isStopSound = false
    end
end

function sound.playSound(path, isLoop)
    if sound.isStopSound then return end
    sound.initSound()
    audio.playSound(path, isLoop)
end

function sound.pauseMusic()
    sound.isStopMusic = true
    audio.pauseMusic()
end

function sound.resumeMusic()
    sound.isStopMusic = false
    audio.resumeMusic()
end

function sound.stopAllSound()
    sound.isStopSound = true
    audio.stopAllSounds()
end

function sound.unStopAllSound()
    sound.isStopSound = false
end

function sound.isSoundStopped()
    return not not sound.isStopSound
end

function sound.isMusicStopped()
    return not not sound.isStopMusic
end

function sound.getAudioEngine()
    return audio
end

utils.sound = sound

return utils