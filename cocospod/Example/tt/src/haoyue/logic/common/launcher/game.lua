
local Game = class("Game", cc.load("mvc").AppBase)

function Game:onCreate()
    table.insert(self.configs_.viewsRoot, "logic")
end

return Game