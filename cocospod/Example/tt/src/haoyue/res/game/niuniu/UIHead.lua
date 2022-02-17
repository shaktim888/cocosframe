--------------------------------------------------------------
-- This file was automatically generated by Cocos Studio.
-- Do not make changes to this file.
-- All changes will be lost.
--------------------------------------------------------------

local luaExtend = require "LuaExtend"

-- using for layout to decrease count of local variables
local layout = nil
local localLuaFile = nil
local innerCSD = nil
local innerProject = nil
local localFrame = nil

local Result = {}
------------------------------------------------------------
-- function call description
-- create function caller should provide a function to 
-- get a callback function in creating scene process.
-- the returned callback function will be registered to 
-- the callback event of the control.
-- the function provider is as below :
-- Callback callBackProvider(luaFileName, node, callbackName)
-- parameter description:
-- luaFileName  : a string, lua file name
-- node         : a Node, event source
-- callbackName : a string, callback function name
-- the return value is a callback function
------------------------------------------------------------
function Result.create(callBackProvider)

local result={}
setmetatable(result, luaExtend)

--Create Layer
local Layer=cc.Node:create()
Layer:setName("Layer")
layout = ccui.LayoutComponent:bindLayoutComponent(Layer)
layout:setSize({width = 160.0000, height = 230.0000})

--Create infoPanel
local infoPanel = ccui.Layout:create()
infoPanel:ignoreContentAdaptWithSize(false)
infoPanel:setClippingEnabled(false)
infoPanel:setBackGroundColorOpacity(102)
infoPanel:setTouchEnabled(true);
infoPanel:setLayoutComponentEnabled(true)
infoPanel:setName("infoPanel")
infoPanel:setTag(386)
infoPanel:setCascadeColorEnabled(true)
infoPanel:setCascadeOpacityEnabled(true)
infoPanel:setAnchorPoint(0.0000, 0.5000)
infoPanel:setPosition(3.2021, 81.1687)
layout = ccui.LayoutComponent:bindLayoutComponent(infoPanel)
layout:setPositionPercentX(0.0200)
layout:setPositionPercentY(0.3529)
layout:setPercentWidth(1.0000)
layout:setPercentHeight(0.2043)
layout:setSize({width = 160.0000, height = 47.0000})
layout:setLeftMargin(3.2021)
layout:setRightMargin(-3.2021)
layout:setTopMargin(125.3313)
layout:setBottomMargin(57.6687)
Layer:addChild(infoPanel)

--Create coninL
local coninL = ccui.ImageView:create()
coninL:ignoreContentAdaptWithSize(false)
coninL:loadTexture("game/niuniu/resource/head/coninL.png",0)
coninL:setLayoutComponentEnabled(true)
coninL:setName("coninL")
coninL:setTag(381)
coninL:setCascadeColorEnabled(true)
coninL:setCascadeOpacityEnabled(true)
coninL:setPosition(81.0000, 21.0000)
layout = ccui.LayoutComponent:bindLayoutComponent(coninL)
layout:setPositionPercentX(0.5063)
layout:setPositionPercentY(0.4468)
layout:setPercentWidth(0.9375)
layout:setPercentHeight(0.9787)
layout:setSize({width = 150.0000, height = 46.0000})
layout:setLeftMargin(6.0000)
layout:setRightMargin(4.0000)
layout:setTopMargin(3.0000)
layout:setBottomMargin(-2.0000)
infoPanel:addChild(coninL)

--Create nickname_17
local nickname_17 = cc.Sprite:create("game/niuniu/resource/head/nickname.png")
nickname_17:setName("nickname_17")
nickname_17:setTag(178)
nickname_17:setCascadeColorEnabled(true)
nickname_17:setCascadeOpacityEnabled(true)
nickname_17:setPosition(29.6646, 21.9605)
layout = ccui.LayoutComponent:bindLayoutComponent(nickname_17)
layout:setPositionPercentX(0.1854)
layout:setPositionPercentY(0.4672)
layout:setPercentWidth(0.1813)
layout:setPercentHeight(0.6809)
layout:setSize({width = 29.0000, height = 32.0000})
layout:setLeftMargin(15.1646)
layout:setRightMargin(115.8354)
layout:setTopMargin(9.0395)
layout:setBottomMargin(5.9605)
nickname_17:setBlendFunc({src = 1, dst = 771})
infoPanel:addChild(nickname_17)

--Create m_pUserName
local m_pUserName = ccui.Text:create()
m_pUserName:ignoreContentAdaptWithSize(true)
m_pUserName:setTextAreaSize({width = 0, height = 0})
m_pUserName:setFontName("game/niuniu/resource/font/font.TTF")
m_pUserName:setFontSize(20)
m_pUserName:setString([[yourname]])
m_pUserName:setLayoutComponentEnabled(true)
m_pUserName:setName("m_pUserName")
m_pUserName:setTag(387)
m_pUserName:setCascadeColorEnabled(true)
m_pUserName:setCascadeOpacityEnabled(true)
m_pUserName:setAnchorPoint(0.0000, 0.5000)
m_pUserName:setPosition(53.6364, 21.9605)
layout = ccui.LayoutComponent:bindLayoutComponent(m_pUserName)
layout:setPositionPercentX(0.3352)
layout:setPositionPercentY(0.4672)
layout:setPercentWidth(0.6750)
layout:setPercentHeight(0.4894)
layout:setSize({width = 108.0000, height = 23.0000})
layout:setLeftMargin(53.6364)
layout:setRightMargin(-1.6364)
layout:setTopMargin(13.5395)
layout:setBottomMargin(10.4605)
infoPanel:addChild(m_pUserName)

--Create coinPanel
local coinPanel = ccui.Layout:create()
coinPanel:ignoreContentAdaptWithSize(false)
coinPanel:setClippingEnabled(false)
coinPanel:setBackGroundColorOpacity(102)
coinPanel:setTouchEnabled(true);
coinPanel:setLayoutComponentEnabled(true)
coinPanel:setName("coinPanel")
coinPanel:setTag(398)
coinPanel:setCascadeColorEnabled(true)
coinPanel:setCascadeOpacityEnabled(true)
coinPanel:setPosition(3.2021, 8.4090)
layout = ccui.LayoutComponent:bindLayoutComponent(coinPanel)
layout:setPositionPercentX(0.0200)
layout:setPositionPercentY(0.0366)
layout:setPercentWidth(1.0000)
layout:setPercentHeight(0.2043)
layout:setSize({width = 160.0000, height = 47.0000})
layout:setLeftMargin(3.2021)
layout:setRightMargin(-3.2021)
layout:setTopMargin(174.5910)
layout:setBottomMargin(8.4090)
Layer:addChild(coinPanel)

--Create coninL
local coninL = ccui.ImageView:create()
coninL:ignoreContentAdaptWithSize(false)
coninL:loadTexture("game/niuniu/resource/head/coninL.png",0)
coninL:setLayoutComponentEnabled(true)
coninL:setName("coninL")
coninL:setTag(382)
coninL:setCascadeColorEnabled(true)
coninL:setCascadeOpacityEnabled(true)
coninL:setPosition(81.0000, 21.0000)
layout = ccui.LayoutComponent:bindLayoutComponent(coninL)
layout:setPositionPercentX(0.5063)
layout:setPositionPercentY(0.4468)
layout:setPercentWidth(0.9375)
layout:setPercentHeight(0.9787)
layout:setSize({width = 150.0000, height = 46.0000})
layout:setLeftMargin(6.0000)
layout:setRightMargin(4.0000)
layout:setTopMargin(3.0000)
layout:setBottomMargin(-2.0000)
coinPanel:addChild(coninL)

--Create coinIcon
local coinIcon = cc.Sprite:create("game/niuniu/resource/head/coinIcon.png")
coinIcon:setName("coinIcon")
coinIcon:setTag(662)
coinIcon:setCascadeColorEnabled(true)
coinIcon:setCascadeOpacityEnabled(true)
coinIcon:setPosition(31.6646, 22.9499)
layout = ccui.LayoutComponent:bindLayoutComponent(coinIcon)
layout:setPositionPercentX(0.1979)
layout:setPositionPercentY(0.4883)
layout:setPercentWidth(0.2062)
layout:setPercentHeight(0.7021)
layout:setSize({width = 33.0000, height = 33.0000})
layout:setLeftMargin(15.1646)
layout:setRightMargin(111.8354)
layout:setTopMargin(7.5501)
layout:setBottomMargin(6.4499)
coinIcon:setBlendFunc({src = 1, dst = 771})
coinPanel:addChild(coinIcon)

--Create m_pLableGameGold
local m_pLableGameGold = ccui.Text:create()
m_pLableGameGold:ignoreContentAdaptWithSize(true)
m_pLableGameGold:setTextAreaSize({width = 0, height = 0})
m_pLableGameGold:setFontName("game/niuniu/resource/font/font.TTF")
m_pLableGameGold:setFontSize(26)
m_pLableGameGold:setString([[0.00]])
m_pLableGameGold:setLayoutComponentEnabled(true)
m_pLableGameGold:setName("m_pLableGameGold")
m_pLableGameGold:setTag(399)
m_pLableGameGold:setCascadeColorEnabled(true)
m_pLableGameGold:setCascadeOpacityEnabled(true)
m_pLableGameGold:setAnchorPoint(0.0000, 0.5000)
m_pLableGameGold:setPosition(54.8584, 20.5061)
layout = ccui.LayoutComponent:bindLayoutComponent(m_pLableGameGold)
layout:setPositionPercentX(0.3429)
layout:setPositionPercentY(0.4363)
layout:setPercentWidth(0.3875)
layout:setPercentHeight(0.6383)
layout:setSize({width = 62.0000, height = 30.0000})
layout:setLeftMargin(54.8584)
layout:setRightMargin(43.1416)
layout:setTopMargin(11.4939)
layout:setBottomMargin(5.5061)
coinPanel:addChild(m_pLableGameGold)

--Create headPanel
local headPanel = ccui.Layout:create()
headPanel:ignoreContentAdaptWithSize(false)
headPanel:setClippingEnabled(false)
headPanel:setBackGroundColorOpacity(102)
headPanel:setTouchEnabled(true);
headPanel:setLayoutComponentEnabled(true)
headPanel:setName("headPanel")
headPanel:setTag(392)
headPanel:setCascadeColorEnabled(true)
headPanel:setCascadeOpacityEnabled(true)
headPanel:setAnchorPoint(0.5000, 0.5000)
headPanel:setPosition(82.2080, 169.9700)
layout = ccui.LayoutComponent:bindLayoutComponent(headPanel)
layout:setPositionPercentXEnabled(true)
layout:setPositionPercentYEnabled(true)
layout:setPositionPercentX(0.5138)
layout:setPositionPercentY(0.7390)
layout:setPercentWidth(0.6563)
layout:setPercentHeight(0.4522)
layout:setSize({width = 105.0000, height = 104.0000})
layout:setLeftMargin(29.7080)
layout:setRightMargin(25.2920)
layout:setTopMargin(8.0300)
layout:setBottomMargin(117.9700)
Layer:addChild(headPanel)

--Create game_head_bg
local game_head_bg = cc.Sprite:create("game/niuniu/resource/head/headbg.png")
game_head_bg:setName("game_head_bg")
game_head_bg:setTag(393)
game_head_bg:setCascadeColorEnabled(true)
game_head_bg:setCascadeOpacityEnabled(true)
game_head_bg:setPosition(51.4710, 51.1056)
layout = ccui.LayoutComponent:bindLayoutComponent(game_head_bg)
layout:setPositionPercentXEnabled(true)
layout:setPositionPercentYEnabled(true)
layout:setPositionPercentX(0.4902)
layout:setPositionPercentY(0.4914)
layout:setPercentWidth(1.1619)
layout:setPercentHeight(1.1731)
layout:setSize({width = 122.0000, height = 122.0000})
layout:setLeftMargin(-9.5290)
layout:setRightMargin(-7.4710)
layout:setTopMargin(-8.1056)
layout:setBottomMargin(-9.8944)
game_head_bg:setBlendFunc({src = 1, dst = 771})
headPanel:addChild(game_head_bg)

--Create headImage
local headImage = ccui.ImageView:create()
headImage:ignoreContentAdaptWithSize(false)
headImage:loadTexture("game/niuniu/resource/head/headName1.png",0)
headImage:setLayoutComponentEnabled(true)
headImage:setName("headImage")
headImage:setTag(93)
headImage:setCascadeColorEnabled(true)
headImage:setCascadeOpacityEnabled(true)
headImage:setPosition(47.5268, 51.7954)
layout = ccui.LayoutComponent:bindLayoutComponent(headImage)
layout:setPositionPercentX(0.4526)
layout:setPositionPercentY(0.4980)
layout:setPercentWidth(0.9905)
layout:setPercentHeight(1.0000)
layout:setSize({width = 104.0000, height = 104.0000})
layout:setLeftMargin(-4.4732)
layout:setRightMargin(5.4732)
layout:setTopMargin(0.2046)
layout:setBottomMargin(-0.2046)
headPanel:addChild(headImage)

--Create game_prompt_banker
local game_prompt_banker = ccui.Text:create()
game_prompt_banker:ignoreContentAdaptWithSize(true)
game_prompt_banker:setTextAreaSize({width = 0, height = 0})
game_prompt_banker:setFontName("game/niuniu/resource/font/font.TTF")
game_prompt_banker:setFontSize(20)
game_prompt_banker:setString([[banker]])
game_prompt_banker:setLayoutComponentEnabled(true)
game_prompt_banker:setName("game_prompt_banker")
game_prompt_banker:setTag(1095)
game_prompt_banker:setCascadeColorEnabled(true)
game_prompt_banker:setCascadeOpacityEnabled(true)
game_prompt_banker:setVisible(false)
game_prompt_banker:setPosition(6.5654, 92.7343)
layout = ccui.LayoutComponent:bindLayoutComponent(game_prompt_banker)
layout:setPositionPercentX(0.0625)
layout:setPositionPercentY(0.8917)
layout:setPercentWidth(0.7238)
layout:setPercentHeight(0.2212)
layout:setSize({width = 76.0000, height = 23.0000})
layout:setLeftMargin(-31.4346)
layout:setRightMargin(60.4346)
layout:setTopMargin(-0.2343)
layout:setBottomMargin(81.2343)
headPanel:addChild(game_prompt_banker)

--Create win
local win = ccui.TextAtlas:create([[10000]],
													"Default/TextAtlas.png",
													18,
													27,
													"+")
win:setLayoutComponentEnabled(true)
win:setName("win")
win:setTag(427)
win:setCascadeColorEnabled(true)
win:setCascadeOpacityEnabled(true)
win:setVisible(false)
win:setPosition(47.3894, 55.1587)
layout = ccui.LayoutComponent:bindLayoutComponent(win)
layout:setPositionPercentX(0.4513)
layout:setPositionPercentY(0.5304)
layout:setPercentHeight(0.2596)
layout:setSize({width = 0.0000, height = 27.0000})
layout:setLeftMargin(47.3894)
layout:setRightMargin(57.6106)
layout:setTopMargin(35.3413)
layout:setBottomMargin(41.6587)
headPanel:addChild(win)

--Create lose
local lose = ccui.TextAtlas:create([[10000]],
													"Default/TextAtlas.png",
													18,
													27,
													"+")
lose:setLayoutComponentEnabled(true)
lose:setName("lose")
lose:setTag(428)
lose:setCascadeColorEnabled(true)
lose:setCascadeOpacityEnabled(true)
lose:setVisible(false)
lose:setPosition(47.1829, 56.1239)
layout = ccui.LayoutComponent:bindLayoutComponent(lose)
layout:setPositionPercentX(0.4494)
layout:setPositionPercentY(0.5397)
layout:setPercentHeight(0.2596)
layout:setSize({width = 0.0000, height = 27.0000})
layout:setLeftMargin(47.1829)
layout:setRightMargin(57.8171)
layout:setTopMargin(34.3761)
layout:setBottomMargin(42.6239)
headPanel:addChild(lose)

--Create Animation
result['animation'] = ccs.ActionTimeline:create()
  
result['animation']:setDuration(0)
result['animation']:setTimeSpeed(1.0000)
--Create Animation List

result['root'] = Layer
return result;
end

return Result

