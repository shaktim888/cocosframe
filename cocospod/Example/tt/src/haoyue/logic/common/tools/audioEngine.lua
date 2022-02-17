local audioEngine = {}

audioEngine.bgMusicId = -1
local isPlayingBgMusic = false;
local isPlayingEffect = true;
local bgMusicUrl = "";       
local bgMusicVolume = 0.2;             
local SoundEffectVolume = 0.5;
local effectMap = {};
local enterVolume = 0;

local holder

audioEngine.initData = function (soundOn, musicVolume, soundVolume)
    if holder then return end
    holder = cc.Node:create()
    holder:retain()
	isPlayingEffect = soundOn;
	bgMusicVolume = musicVolume;
    SoundEffectVolume = soundVolume; 
    
    global.event.on(global.event.ENTER_FOREGROUND,function ()
        print("声音管理,切到前台 "..bgMusicVolume)
        audioEngine.setBgMusicVolume(bgMusicVolume)
        if isPlayingEffect then
            audioEngine.setSoundEffectVolume(SoundEffectVolume)
        end
    end,holder)

    global.event.on(global.event.ENTER_BACKGROUND,function ()
        local lastVolBg  = bgMusicVolume
        local lastVolEff = SoundEffectVolume
        print("声音管理,切到后台 " .. lastVolBg)
        audioEngine.setBgMusicVolume(0)
        audioEngine.setSoundEffectVolume(0)
        bgMusicVolume = lastVolBg
        SoundEffectVolume = lastVolEff
    end,holder)
end

audioEngine.dtor = function ()
    holder:release()
    holder = nil
end

-- 播放背景音乐
audioEngine.playBgMusic = function (path, loop)
	
	if (isPlayingBgMusic and path == bgMusicUrl)then return end
	if (audioEngine.bgMusicId ~= cc.AUDIO_INVAILD_ID)then
		ccexp.AudioEngine:stop(audioEngine.bgMusicId);
	end
	if(loop == nil) then
		loop = true;
	end

	bgMusicUrl = path or bgMusicUrl;
	if bgMusicUrl and bgMusicUrl ~= "" then
		audioEngine.bgMusicId = ccexp.AudioEngine:play2d(path, loop, bgMusicVolume);
		isPlayingBgMusic = true;
	end
end

-- 停止播放音乐
audioEngine.stopBgMusic = function( )
	if (not isPlayingBgMusic or audioEngine.bgMusicId == cc.AUDIO_INVAILD_ID)then return end
	isPlayingBgMusic = false;
	ccexp.AudioEngine:stop(audioEngine.bgMusicId);
	audioEngine.bgMusicId = cc.AUDIO_INVAILD_ID;
end

-- 播放音效
audioEngine.playEffect = function (path, loop)
	if (isPlayingEffect == false or SoundEffectVolume <= 0)then return end;
	if(loop == nil)then loop = false end;
	ccexp.AudioEngine:play2d(path, loop, SoundEffectVolume);
	
end

-- 暂停背景音乐
audioEngine.pauseBgMusic = function (path)
	
end

-- 继续背景音乐
audioEngine.resumeBgMusic = function()
    
end

-- 设置背景音乐音量
audioEngine.setBgMusicVolume = function(v)

	bgMusicVolume = v;
	if (audioEngine.bgMusicId == nil or audioEngine.bgMusicId == cc.AUDIO_INVAILD_ID)then return end;
	ccexp.AudioEngine:setVolume(audioEngine.bgMusicId, bgMusicVolume);
end

-- 设置音效音量
audioEngine.setSoundEffectVolume = function(v)
	SoundEffectVolume = v;
	if (v > 0)then
		isPlayingEffect = true;
	end
end

audioEngine.setPlaySoundStaus = function(isplay)
	isPlayingEffect = isplay;
end

-- 是否正在播放背景音乐
audioEngine.getIsPlayBgMusic = function()
	return isPlayingBgMusic;
end

return audioEngine;