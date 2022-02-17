if nil == cc.XMLHttpRequest then
    return
end

--tip
local function deprecatedTip(old_name,new_name)
    print("\n********** \n"..old_name.." was deprecated please use ".. new_name .. " instead.\n**********")
end

--functions of WebSocket will be deprecated begin
local targetPlatform = CCApplication:getInstance():getTargetPlatform()
if (kTargetIphone == targetPlatform) or (kTargetIpad == targetPlatform) or (kTargetAndroid == targetPlatform) or (kTargetWindows == targetPlatform) then

end
--functions of WebSocket will be deprecated end
