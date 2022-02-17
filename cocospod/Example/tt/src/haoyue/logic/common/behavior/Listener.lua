local Listener = class("Listener", cc.load("mvc").BehaviorBase)

local CMD_Queue = {} -- 存储消息队列
local CMD_Block = {} -- 存储锁定信息

-- 遍历数组
local function findCMD(cmd,tab)
	for i,c in ipairs(tab) do
		if c.cmd == cmd[1] then
			return c,i
		end
	end
	return nil
end

function Listener:onCreate()
	for key,callback in pairs(self.listen or {}) do
		assert(self[callback],"listen callback undefine ~")
		-- todo: 处理服务器消息
		if type(key) == "string" then
			global.event.on(key, handler(self,self[callback]), self)
		end
	end
end

-- 阻塞指定指令,该指令会计算阻塞次数
function Listener:blockCMD( ... )
	local cmds = { ... }
	for i,cmd in ipairs(cmds) do
		local deal_cmd = findCMD(cmd,CMD_Block)
		if deal_cmd then
			deal_cmd.count = deal_cmd.count + 1
		else
			deal_cmd = {cmd=cmd[1],count=1}
			table.insert(CMD_Block,deal_cmd)
		end
	end
end

-- 释放指定指令,当释放达到0后会放开数据分发
function Listener:releaseCMD( ... )
	local cmds = { ... }
	for i,cmd in ipairs(cmds) do
		local deal_cmd,index = findCMD(cmd,CMD_Block)
		if deal_cmd then
			deal_cmd.count = deal_cmd.count - 1
			if deal_cmd.count == 0 then
				table.remove(CMD_Block,index)
			end
		end
	end

	local remove = 0
	for i,info in ipairs(CMD_Queue) do
		if findCMD(info.cmd,CMD_Block) then
			break
		else
			remove = i
			info.callback(info.target,info.data,info.cmd)
		end
	end

	for i=1,remove do
		table.remove(CMD_Queue,1)
	end
end

return Listener