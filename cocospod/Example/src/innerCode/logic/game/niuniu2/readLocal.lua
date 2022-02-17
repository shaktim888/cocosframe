local ReadLocal = class("ReadLocal")
function ReadLocal:ctor()

end
function ReadLocal:getLocalCoin(chairID)
    local coin = 0 
    local localsave 
    if chairID == 1 then
        localsave = global.saveTools.getData("MycoinNum")
    else
        localsave = global.saveTools.getData("AicoinNum")
    end

    if localsave then
        coin = localsave
    end 
    return coin
end

local name_arr = {
    "射弼紫",
    "戴庚斓",
    "石冥子",
    "红裘逇",
    "通暠封",
    "常壮悒",
    "汤蹇猩猩",
    "赵千高",
    "时仓啸",
    "莫靖歌",
    "米绯青",
    "时青玄",
    "权岩思",
    "宫海忻",
    "须铖昂",
    "刁逊院子",
    "公冶隶旻",
    "帅宽丝",
    "无祖旲",
    "益矗颜",
    "宇文磊彭",
    "姜栾沁",
    "须珺官人",
    "任世肉",
    "杜琛林",
    "拓拔玚瀚",
    "薛倧强",
    "党储帝",
    "万俟矗吟"
}

local name_arr_en = {
    "SheBiZi",
    "DaiGe",
    "ShiMi",
    "HongQ",
    "TongH",
    "Chang",
    "TangJ",
    "Zhao",
    "ShiQi",
    "MoJin",
    "MiFei",
    "ShiQin",
    "QuanYa",
    "GongH",
    "XuChe",
    "DiaoXu",
    "GongYe",
    "Shuai",
    "WuZuH",
    "YiChu",
    "YuWen",
    "JiangL",
    "XuJun",
    "RenShi",
    "DuChen",
    "TuoBa",
    "XueZo",
    "DangC",
    "WanYi"
}
local random_counter = 1
local  function random(t, e)
    random_counter = random_counter + 1
    math.randomseed(os.time() + random_counter)
    for i = 1, 6 do
        math.random()
    end
    return math.random(t, e)
end

-- function ReadLocal:randomIndex()
-- 	local range = math.min(#name_arr, #name_arr_en)
--     return math.random(1, range)
-- end

function ReadLocal:getRandomUserName()
	local lang = global.L._curLanguage

	local arr = name_arr_en
	if lang == cc.LANGUAGE_CHINESE then
		arr = name_arr
    end
	-- math.randomseed(os.time())
    
	return arr[random(1,#arr)]
end

function ReadLocal:getRandomScore()
    local score = math.random(10, 500)
    return score * 100
end

return ReadLocal
