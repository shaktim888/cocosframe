local SocketManager = class("SocketManager")

local AllSocket = {}
local HeartBeatTime = 60 -- 多久没有数据则发送心跳包
local RecvTimeOut   = 3 -- 数据多久没回则认为网络有问题
local RecvTryTimes  = 3 -- 尝试重试次数

-- local HeartBeatTime = 10 -- 多久没有数据则发送心跳包
-- local RecvTimeOut   = 2 -- 数据多久没回则认为网络有问题
-- local RecvTryTimes  = 3 -- 尝试重试次数

local Index = {i=0}
setmetatable(Index,{__call = function ()
	Index.i = Index.i + 1
	return Index.i
end})

local STEP_CREATE  = Index()
local STEP_RECV    = Index()
local STEP_WAIT    = Index()
local STEP_TYR     = Index()
local STEP_DISCONN = Index()

-- local MiniStateMachine = {}
-- local StateMap         = {}
-- local StateFun         = {}

function SocketManager.createSocket(tag,ip,port,callback)
	SocketManager.destroy(tag)
	local socket = cc.load("network").SocketTCP.new()
	AllSocket[tag] = socket

	socket.____SendData = {}     -- 存放将要发送的数据
	socket.____SendedData = {}   -- 存放已经发送等待回包得数据,发送失败可能用到

	local lastRecvTime = os.time()
	local last_step = STEP_CREATE
	local cur_step = STEP_CREATE
	local sch = 0
	local try_times = 0 -- 重连测试时间按
	
	local function change(step)
		last_step = cur_step
		cur_step = step
	end

	local function unConn()
		if cur_step ~= STEP_DISCONN then
			global.event.dispatch(global.event.NETWORK_ERROR)
			global.viewMgr.showTextTip("抱歉您的网络似乎出了点问题")
			print(tag.."  "..tostring(socket).." 抱歉您的网络似乎出了点问题")
		end
		change(STEP_DISCONN)
	end

	local checkFunc = function ()
		if last_step == STEP_DISCONN and cur_step == STEP_RECV then -- 从断开状态到收到数据
			global.viewMgr.showTextTip("网络恢复正常")
			print(tag.."  "..tostring(socket).." 网络恢复正常")
			change(STEP_WAIT)
			if callback.onReConn then callback.onReConn() end
			return
		end
		if cur_step == STEP_RECV then -- 收到数据刷新连接存活时间
			lastRecvTime = os.time()
			try_times = 0
			change(STEP_WAIT)
			return
		end
		if cur_step == STEP_WAIT and os.time() - lastRecvTime > HeartBeatTime then -- 观察闲置时间
			lastRecvTime = os.time()
			print(tag.."  "..tostring(socket).."  发送闲置心跳")
			if callback.onBreat then callback.onBreat() end
			change(STEP_TYR)
			return
		end
		if cur_step == STEP_TYR and os.time() - lastRecvTime > RecvTimeOut then -- 心跳测试
			lastRecvTime = os.time()
			if try_times >= RecvTryTimes then
				unConn()
			else
				print(tag.."  "..tostring(socket).." 发送服务器检测心跳")
				if callback.onBreat then callback.onBreat() end
			end
			try_times = try_times + 1
			return
		end
		if cur_step == STEP_WAIT or cur_step == STEP_TYR or cur_step == STEP_DISCONN then
			return
		end
		error("不可达的代码都给你走到了,说明状态处理少了,上一个状态: "..last_step.." 现在状态: "..cur_step)
	end

	function socket:____SendOnConnect()
		if(socket.isConnected) then
			for i,v in ipairs(socket.____SendData) do
				table.insert(socket.____SendedData,v)
				-- print("socket 发送数据")
				socket:orgSend(v)
			end
			socket.____SendData = {}
		end
	end

	socket:onEvent(function (data,evName)
		if evName == socket.EVENT_CONNECTED then
			change(STEP_RECV)
			sch = cc.Director:getInstance():getScheduler():scheduleScriptFunc(checkFunc)
			print("开始定时器: "..sch)
			socket:____SendOnConnect()
		end
		if evName == socket.EVENT_CLOSED then
			print("停止定时器: "..sch) -- 停止定时器,交由SocketTCP的重连处理
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sch)
			unConn()
		end
		callback.onEvent(data,evName)
	end)

	socket:onRecv(function (data,evName)
		socket.____SendedData = {} -- 8K以内缓冲区是一次性发送的,并且数据有序
		change(STEP_RECV)
		callback.onRecv(data,evName)
	end)

	socket.orgSend = socket.send -- 保留旧的数据发送功能
	function socket:send(data)
		table.insert(socket.____SendData,data)
		socket:____SendOnConnect()
	end

	socket:setName(tag)
	socket:setTickTime(0.01)
	socket:setReconnTime(RecvTimeOut)
	socket:setConnFailTime(RecvTimeOut)
	socket:connect(ip,port,true)

	return socket
end

function SocketManager.getByTag(tag)
	assert(tag)
	return AllSocket[tag]
end

function SocketManager.destroy(tag)
	assert(tag)
	if not AllSocket[tag] then return end
	AllSocket[tag]:disconnect()
	AllSocket[tag]:onEvent(function ()end)
	AllSocket[tag]:onRecv(function ()end)
	AllSocket[tag] = nil
end

setmetatable(SocketManager, {
    __call = function(_,name)
        return SocketManager.getByTag(name)
    end,
})

return SocketManager