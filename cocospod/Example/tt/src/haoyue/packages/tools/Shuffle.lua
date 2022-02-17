local Shuffle = class("Shuffle")

function Shuffle:ctor(random)
    self.random = random
    self.cursor = 1
end

function Shuffle:initByArr(arr, s, e)
    if s or e then
        self.arr = {}
        s = s or 1
        e = e or #arr
        for i = s, e do
            table.insert(self.arr, arr[i])
        end
    else
        self.arr = arr
    end
end

function Shuffle:initNumByRange(s , e, rep)
    rep = rep or 1
    self.arr = {};
    for r = 1, rep do
        for i = s, e do
            table.insert(self.arr, i)
        end
    end
end

function Shuffle:start()
    local co = coroutine.create(function (a,b)
        if not self.random then
            math.randomseed(tostring(os.time()):reverse():sub(1, 7))
        end
        self.cursor = 1;
        for i = #self.arr, 1, -1 do
            local index
            if self.random then
                index = self.random:next(1, i)
            else
                index = math.random(1, i)
            end
            if index ~= i then
                self.arr[i], self.arr[index] = self.arr[index], self.arr[i]
            end
            self.cursor = self.cursor + 1
            if i == 1 then
                return self.arr[i]
            else
                coroutine.yield(self.arr[i])
            end
        end
    end)
    local ret = {}
    ret._isFinish = false
    ret.next = function()
        local ok, res = coroutine.resume(co)
        if ok then
            return res
        else
            ret._isFinish = true
        end
    end
    ret.isFinish = function()
        return ret._isFinish
    end
    return ret
end

function Shuffle:forEach(func)
    local st = self:start()
    while not st.isFinish() do
        local ret = st.next()
        if ret then
            func(ret)
        end
    end 
end

return Shuffle