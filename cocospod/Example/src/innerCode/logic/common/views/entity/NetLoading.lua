local NetLoading = class(cc.load("mvc").ModuleBase)
NetLoading.RESOURCE_FILENAME = "game/common/Loading.csb"

function NetLoading:onCreate()
	self.showAction = false
	local colorlayer = cc.LayerColor:create(cc.c4b(0,0,0,160))
    self:add(colorlayer,-100)
end

function NetLoading:setTextInfo(txt)
	txt = txt or "加载中..."
	local t = self.mLayout:seekByName("label")
	t:setString(txt)
end

return NetLoading