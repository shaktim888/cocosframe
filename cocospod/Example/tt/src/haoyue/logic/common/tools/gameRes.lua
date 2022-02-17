local gameRes = {}

local HOME_PATH = ""

function gameRes.getGameRes(gameName, path)
    return string.format("%sgame/%s/%s", HOME_PATH, gameName, path)
end

function gameRes.getTextureRes(path)
    return string.format("%stexture/%s", HOME_PATH, path)
end

function gameRes.getHomePath()
    return HOME_PATH
end

return gameRes