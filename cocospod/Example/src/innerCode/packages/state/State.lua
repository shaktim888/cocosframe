-- https://github.com/pfzq303/state

local StateLua = {}
---------------------------console-----------------------
local console = {}
console.log = function(...)
    print("State Log:" , ...)
end
console.error = function(...)
    print("State Error:" , ...)
end
console.warn = function(...)
    print("State Warn:" , ...)
end
console.printTable = function(...)
    dump(...)
end
StateLua.console = console

-- cocos的isKindof有bug 修复如下：
local iskindof_
iskindof_ = function(cls, name)
    local __index = rawget(cls, "__index")
    if type(__index) == "table" and rawget(__index, "__cname") == name then return true end

    if rawget(cls, "__cname") == name then return true end
    local __supers = rawget(cls, "__supers") or (__index and rawget(__index, "__supers"))
    if not __supers then return false end
    for _, super in ipairs(__supers) do
        if iskindof_(super, name) then return true end
    end
    return false
end

local function iskindof(obj, classname)
    local t = type(obj)
    if t ~= "table" and t ~= "userdata" then return false end

    local mt
    if t == "userdata" then
        if tolua.iskindof(obj, classname) then return true end
        mt = tolua.getpeer(obj)
    else
        mt = getmetatable(obj)
    end
    if mt then
        return iskindof_(mt, classname)
    end
    return false
end

---------------------common function--------------------------
-- look for else transitins from a junction or choice
local findElse = function(pseudoState) 
    for transition , _ in pairs(pseudoState.outgoing) do
        if transition.guard == StateLua.Transition.FalseGuard then
            return transition
        end
    end
end

-- functions to retreive specif element behavior
local leave = function(elementBehavior) 
    elementBehavior[1] = elementBehavior[1] or StateLua.Behavior.new()
    return elementBehavior[1]
end

local beginEnter = function(elementBehavior) 
    elementBehavior[2] = elementBehavior[2] or StateLua.Behavior.new()
    return elementBehavior[2]
end

local endEnter = function(elementBehavior) 
    elementBehavior[3] = elementBehavior[3] or StateLua.Behavior.new()
    return elementBehavior[3]
end

local enter = function(elementBehavior) 
    return StateLua.Behavior.new(beginEnter(elementBehavior)):push(endEnter(elementBehavior))
end

-- get all the vertex ancestors of a vertex (including the vertex itself)
local ancestors 
ancestors = function(vertex)
    local ret = {vertex}
    if vertex.region then
        local p_list = ancestors(vertex.region.state)
        for i = #p_list , 1 , -1 do
            table.insert(ret , 1, p_list[i])
        end 
    end
    return ret
end
---------------------------Behavior-----------------------
local Behavior = class("Behavior")

function Behavior:ctor(behavior)
    self.actions = {}
    if behavior then
        self:push(behavior)
    end
end

function Behavior:push(behavior)
    if type(behavior) == "function" then
        table.insert(self.actions , behavior)
    else
        for _ , action in ipairs(behavior.actions) do
            table.insert(self.actions , action)
        end
    end
    return self
end

function Behavior:hasActions()
    return #self.actions > 0
end

function Behavior:invoke(...) 
    for _ , action in ipairs(self.actions) do
        action(...)
    end
end
StateLua.Behavior = Behavior
-------------------------PseudoStateKind--------------------------------
StateLua.PseudoStateKind = {
    Initial = 1,
    DeepHistory = 2,
    ShallowHistory = 3,
    Junction = 4,
    Choice = 5,
    Terminate =6,
}

-------------------------TransitionKind--------------------------------
StateLua.TransitionKind = {
    Internal = 1,
    Local = 2,
    External = 3,
}

---------------------------Element-----------------------
local Element = class("Element")
Element.NamespaceSeparator = "."
Element.StateCnt = 0
function Element:ctor(name , parent)
    self.name = name
    Element.StateCnt = Element.StateCnt + 1
    self.stateIndex = Element.StateCnt
    self.qualifiedName = parent and parent.qualifiedName .. Element.NamespaceSeparator .. name or name
end

function Element:toString()
    return self.qualifiedName .. "(" .. self.stateIndex .. ")"
end

StateLua.Element = Element
--------------------------------Vertex------------------------------
local Vertex  = class("Vertex" , Element)

function Vertex:ctor(name , parent)
    if parent and iskindof(parent , "State") then
        parent = parent:defaultRegion()
    end
    Vertex.super.ctor(self , name , parent)
    self.outgoing = {} 
    self.region = parent
    if self.region and self.region.vertices then
        self.region.vertices[self] = true
        self:getRoot():setClean(false)
    end
end

function Vertex:getFirstOutgoing()
    for out , _ in pairs(self.outgoing) do
        return out
    end
end

function Vertex:getOutgoingCnt()
    local cnt = 0
    for out , _ in pairs(self.outgoing) do
        cnt = cnt + 1
    end
    return cnt
end

function Vertex:getRoot()
    return self.region:getRoot()
end

function Vertex:to(target , kind)
    kind = kind or StateLua.TransitionKind.External
    return StateLua.Transition.new(self, target , kind)
end

function Vertex:To(...)
    return self:to(...)
end

function Vertex:accept(visitor , ...)
    
end

StateLua.Vertex = Vertex
--------------------------------Region------------------------------
local Region  = class("Region" , Element)
Region.defaultName = "default"

function Region:ctor(name , parent)
    Region.super.ctor(self , name , parent)
    self.vertices = {}
    self.state = parent 
    self.state.regions[self] = true
    self.state:getRoot():setClean(false)
end

function Region:isActive(stateMachineInstance)
    if self.state then
        self.state:isActive(stateMachineInstance)
    end
end

function Region:getVerticesCnt()
    local cnt = 0
    for vertex , _ in pairs(self.vertices) do
        cnt = cnt + 1
    end
    return cnt
end

function Region:isComplete(instance)
    return instance:getCurrent(self):isFinal()
end

function Region:getRoot()
    return self.state:getRoot()
end

function Region:accept(visitor , ...)
    visitor:visitRegion(self , ...)
end

StateLua.Region = Region
---------------------------PseudoState----------------------------------
local PseudoState  = class("PseudoState" , Vertex)

function PseudoState:ctor(name , parent,  kind)
    PseudoState.super.ctor(self , name , parent)
    self.kind = kind or StateLua.PseudoStateKind.Initial
end

function PseudoState:isHistory()
    return self.kind == StateLua.PseudoStateKind.DeepHistory or self.kind == StateLua.PseudoStateKind.ShallowHistory
end

function PseudoState:isInitial()
    return self.kind == StateLua.PseudoStateKind.Initial or self:isHistory()
end

function PseudoState:accept(visitor ,arg)
    visitor:visitPseudoState(self , arg)
end
StateLua.PseudoState = PseudoState

---------------------------State----------------------------------
local State  = class("State" , Vertex)

function State:ctor(name , parent)
    State.super.ctor(self , name , parent)
    self.regions = {}
    self.exitBehavior = StateLua.Behavior.new()
    self.entryBehavior = StateLua.Behavior.new()
end

function State:getRegionCnt()
    local cnt = 0
    for region , _ in pairs(self.regions) do
        cnt = cnt + 1
    end
    return cnt
end

function State:isActive(stateMachineInstance)
    if self.region then
        return self.region:isActive(stateMachineInstance) and stateMachineInstance:getCurrent(self.region) == element 
    else
        return true
    end
end

function State:defaultRegion()
    for region , _ in pairs(self.regions) do
        if region.name == StateLua.Region.defaultName then
            return region
        end
    end
    return StateLua.Region.new(StateLua.Region.defaultName , self)
end

function State:isFinal()
    return #self.outgoing == 0
end

function State:isComplete(instance)
    for region , _ in pairs(self.regions) do
        if not region:isComplete(instance) then
            return false
        end 
    end
    return true
end

function State:isSimple()
    for region , _ in pairs(self.regions) do
        return false
    end
    return true 
end

function State:isComposite()
    for region , _ in pairs(self.regions) do
        return true
    end
    return false 
end

function State:isOrthogonal()
    local cnt = 0
    for region , _ in pairs(self.regions) do
        cnt = cnt + 1
        if cnt > 1 then
            return true
        end
    end
    return false 
end

function State:exit(exitAction)
    self.exitBehavior:push(exitAction)
    self:getRoot():setClean(false)
    return self
end

function State:entry(entryAction)
    self.entryBehavior:push(entryAction)
    self:getRoot():setClean(false)
    return self
end

function State:accept(visitor , ...)
    visitor:visitState(self , ...)
end

StateLua.State = State
------------------FinalState---------------------------------------------
local FinalState  = class("FinalState" , State)

function FinalState:ctor(name , parent)
    FinalState.super.ctor(self, name , parent)
end

function FinalState:accept(visitor , ...)
    visitor:visitFinalState(self , ...)
end
StateLua.FinalState = FinalState

------------------StateMachine---------------------------------------------
local StateMachine  = class("StateMachine" , State)

function StateMachine:setClean(val)
    self.clean = val
end

function StateMachine:ctor(name , parent)
    StateMachine.super.ctor(self, name , parent)
    self.onInitialise = nil
    self.clean = false
end

function StateMachine:getRoot()
    return self.region and self.region:getRoot() or self
end

function StateMachine:accept(visitor ,...)
    visitor:visitStateMachine(self , ...)
end
StateLua.StateMachine = StateMachine
------------------------------Transition--------------------------
local Transition  = class("Transition")

Transition.TrueGuard = function()
    return true
end

Transition.FalseGuard = function()
    return false
end

function Transition:ctor(source , target , kind)
    kind = kind or StateLua.TransitionKind.External
    self.transitionBehavior = StateLua.Behavior.new()
    self.onTraverse = StateLua.Behavior.new()
    self.source = source
    self.target = target
    self.kind = target and kind or StateLua.TransitionKind.Internal
    self.guard = iskindof(source, "PseudoState") and Transition.TrueGuard or function(message)
        return message == self.source
    end
    self.source.outgoing[self] = true
    self.source:getRoot():setClean(false)
end

function Transition:Else()
    self.guard = Transition.FalseGuard
    return self
end

function Transition:When(guard)
    self.guard = guard
    return self
end

function Transition:when(...)
    return self:When(...)
end

function Transition:Effect(transitionAction)
    self.transitionBehavior:push(transitionAction)
    self.source:getRoot():setClean(false)
    return self
end

function Transition:accept(visitor ,...)
    visitor:visitTransition(self , ...)
end

function Transition:toString()
    return "[" .. (self.target and (self.source:toString() .. " -> " .. self.target:toString()) or self.source:toString()) .. "]"
end

StateLua.Transition = Transition
------------------StateMachineInstance---------------------------------------------
local StateMachineInstance = class("StateMachineInstance")

function StateMachineInstance:ctor(name)
    self.name = name or "unnamed"
    self.last = {}
    self.isTerminated = false
end

function StateMachineInstance:getRoot()
    return self.region and self.region:getRoot() or self
end

function StateMachineInstance:setCurrent(region , state)
    self.last[region.qualifiedName] = state
end

function StateMachineInstance:getCurrent(region , isDeepHistory)
    return self.last[region.qualifiedName]
end

function StateMachineInstance:toString()
    return self.name
end

StateLua.StateMachineInstance = StateMachineInstance
------------------Visitor---------------------------------------------
local Visitor  = class("Visitor")

function Visitor:ctor()
    
end

function Visitor:visitElement()
    
end

function Visitor:visitRegion(region , ...)
    local result = self:visitElement(region,...)
    for vertex , _ in pairs(region.vertices) do
        vertex:accept(self, ...)
    end
    return result
end

function Visitor:visitVertex(vertex , ...)
    local result = self:visitElement(vertex, ...)
    for transition , _ in pairs(vertex.outgoing) do
        transition:accept(self, ...)
    end
    return result
end

function Visitor:visitPseudoState(pseudoState , ... )
    return self:visitVertex(pseudoState, ...)
end

function Visitor:visitState(state , ... )
    local result = self:visitVertex(state, ...)
    for region , _ in pairs(state.regions) do
        region:accept(self, ...)
    end
    return result
end

function Visitor:visitFinalState(finalState , ... )
    return self:visitState(finalState, ...)
end

function Visitor:visitStateMachine(stateMachine , ... )
    return self:visitState(stateMachine, ...)
end

function Visitor:visitTransition(transition , ... )
    
end

StateLua.Visitor = Visitor
------------------InitialiseElements---------------------------------------------
local InitialiseElements = class("InitialiseElements" , Visitor) 

function InitialiseElements:ctor(...)
    InitialiseElements.super.ctor(self, ...)
    self.behaviours = {}
end

function InitialiseElements:behaviour(element)
    self.behaviours[element.qualifiedName] = self.behaviours[element.qualifiedName] or {}
    return self.behaviours[element.qualifiedName]
end

function InitialiseElements:visitElement(element)
    leave(self:behaviour(element)):push(function (message, instance)
        return StateLua.console.log(instance:toString() .. "  <-  " .. element:toString())
    end)
    beginEnter(self:behaviour(element)):push(function (message, instance)
        return StateLua.console.log(instance:toString() .. "  ->  " .. element:toString());
    end)
end

function InitialiseElements:visitRegion(region, deepHistoryAbove)
    local regionInitial
    for vertex , _ in pairs(region.vertices) do
        if iskindof(vertex , "PseudoState") and vertex:isInitial() then
            regionInitial = vertex
            break
        end
    end
    for vertex , _ in pairs(region.vertices) do
        vertex:accept(self, deepHistoryAbove or regionInitial and regionInitial.kind == StateLua.PseudoStateKind.DeepHistory);
    end
    -- leave the curent active child state when exiting the region
    leave(self:behaviour(region)):push(function (message, stateMachineInstance)
        return leave(self:behaviour(stateMachineInstance:getCurrent(region))):invoke(message, stateMachineInstance);
    end)
    -- enter the appropriate child vertex when entering the region
    if (deepHistoryAbove or not regionInitial or regionInitial:isHistory()) then
        endEnter(self:behaviour(region)):push(function (message, stateMachineInstance, history)
--            enter(_this.behaviour(history || regionInitial.isHistory() ? stateMachineInstance.getCurrent(region) || regionInitial : regionInitial)).invoke(message, stateMachineInstance, history || regionInitial.kind === StateJS.PseudoStateKind.DeepHistory);
            local target = (history or regionInitial:isHistory()) and (stateMachineInstance:getCurrent(region) or regionInitial) or regionInitial
            enter(self:behaviour(target)):invoke(message, stateMachineInstance, history or regionInitial.kind == StateLua.PseudoStateKind.DeepHistory)
        end)
    else
        endEnter(self:behaviour(region)):push(enter(self:behaviour(regionInitial)))
    end
    self:visitElement(region, deepHistoryAbove)
end

function InitialiseElements:visitPseudoState(pseudoState, deepHistoryAbove)
    InitialiseElements.super.visitPseudoState(self, pseudoState, deepHistoryAbove)
    if pseudoState:isInitial() then
        endEnter(self:behaviour(pseudoState)):push(function (message, stateMachineInstance, history) 
            if pseudoState:isHistory() and stateMachineInstance:getCurrent(pseudoState.region) then
                leave(self:behaviour(pseudoState)):invoke(message, stateMachineInstance, history or pseudoState.Kind == StateLua.PseudoStateKind.DeepHistory)
                enter(self:behaviour(stateMachineInstance:getCurrent(pseudoState.region))):invoke(message, stateMachineInstance , history or pseudoState.Kind == StateLua.PseudoStateKind.DeepHistory)
                return true
            else
                return StateLua.traverse(pseudoState:getFirstOutgoing(), stateMachineInstance);
            end
        end)
    elseif pseudoState.kind == StateLua.PseudoStateKind.Terminate then
        -- terminate the state machine instance upon transition to a terminate pseudo state
        beginEnter(self:behaviour(pseudoState)):push(function (message, stateMachineInstance)
            stateMachineInstance.isTerminated = true
            return true
        end)
    end
end

function InitialiseElements:visitState(state, deepHistoryAbove)
    for region , _ in pairs(state.regions) do
        region:accept(self, deepHistoryAbove);
        leave(self:behaviour(state)):push(leave(self:behaviour(region)))
        endEnter(self:behaviour(state)):push(enter(self:behaviour(region)))
    end
    self:visitVertex(state, deepHistoryAbove)
    -- add the user defined behaviour when entering and exiting states
    leave(self:behaviour(state)):push(state.exitBehavior)
    beginEnter(self:behaviour(state)):push(state.entryBehavior)
    -- update the parent regions current state
    beginEnter(self:behaviour(state)):push(function (message, stateMachineInstance)
        if (state.region) then
            stateMachineInstance:setCurrent(state.region, state)
        end
    end)
end

function InitialiseElements:visitStateMachine(stateMachine, deepHistoryAbove)
    InitialiseElements.super.visitStateMachine(self, stateMachine, deepHistoryAbove)
    stateMachine:accept(StateLua.InitialiseTransitions.new(), function (element)
        return self:behaviour(element)
    end);
    -- define the behaviour for initialising a state machine instance
    stateMachine.onInitialise = enter(self:behaviour(stateMachine))
end

StateLua.InitialiseElements = InitialiseElements
------------------InitialiseTransitions---------------------------------------------
local InitialiseTransitions = class("InitialiseTransitions" , Visitor) 

function InitialiseTransitions:ctor(...)
    InitialiseTransitions.super.ctor(self , ...)
end

function InitialiseTransitions:visitTransition(transition, behaviour)
    if transition.kind == StateLua.TransitionKind.Internal then
        transition.onTraverse:push(transition.transitionBehavior)
    elseif transition.kind == StateLua.TransitionKind.Local then
        self:visitLocalTransition(transition, behaviour)
    else
        self:visitExternalTransition(transition, behaviour)
    end
end

function InitialiseTransitions:visitLocalTransition(transition, behaviour)
    transition.onTraverse:push(function (message, instance)
        local targetAncestors = ancestors(transition.target)
        local i = 1
        -- find the first inactive element in the target ancestry
        while (StateLua.isActive(targetAncestors[i], instance)) do
            i = i + 1
        end
        -- exit the active sibling
        leave(behaviour(instance:getCurrent(targetAncestors[i].region))):invoke(message, instance)
        -- perform the transition action
        transition.transitionBehavior:invoke(message, instance);
        -- enter the target ancestry
        while i <= #targetAncestors do
            self:cascadeElementEntry(transition, behaviour, targetAncestors[i], targetAncestors[i], function (behavior)
                behavior:invoke(message, instance)
            end)
            i = i + 1
        end
        -- trigger cascade
        endEnter(behaviour(transition.target)):invoke(message, instance)
    end)
end

function InitialiseTransitions:visitExternalTransition(transition, behaviour)
    local sourceAncestors = ancestors(transition.source)
    local targetAncestors = ancestors(transition.target)
    local i = math.min(#sourceAncestors, #targetAncestors)
    -- find the index of the first uncommon ancestor (or for external transitions, the source)
    while (sourceAncestors[i - 1] ~= targetAncestors[i - 1]) do
        i = i - 1
    end
    -- leave source ancestry as required
    transition.onTraverse:push(leave(behaviour(sourceAncestors[i])));
    -- perform the transition effect
    transition.onTraverse:push(transition.transitionBehavior);
    -- enter the target ancestry
    while (i <= #targetAncestors) do
        self:cascadeElementEntry(transition, behaviour, targetAncestors[i], targetAncestors[i + 1], function (behavior)
            return transition.onTraverse:push(behavior)
        end);
        i = i + 1
    end
    -- trigger cascade
    transition.onTraverse:push(endEnter(behaviour(transition.target)))
end

function InitialiseTransitions:cascadeElementEntry(transition, behaviour, element, nxt, task)
--    StateLua.console.log("push Element:" , element:toString() , "->" , nxt and nxt:toString() or "nil")
    task(beginEnter(behaviour(element)))
    if nxt and iskindof(element , "State") then
        for region , _ in pairs(element.regions) do
            task(beginEnter(behaviour(region)))
            if region ~= nxt.region then
                task(endEnter(behaviour(region)))
            end
        end
    end
end

StateLua.InitialiseTransitions = InitialiseTransitions
------------------Validator---------------------------------------------
local Validator = class("Validator" , Visitor)

function Validator:ctor(...)
    Validator.super.ctor(self , ... )
end

function Validator:visitPseudoState(pseudoState)
    Validator.super.visitPseudoState(self, pseudoState)
    if (pseudoState.kind == StateLua.PseudoStateKind.Choice or pseudoState.kind == StateLua.PseudoStateKind.Junction) then
        -- [7] In a complete statemachine, a junction vertex must have at least one incoming and one outgoing transition.
        -- [8] In a complete statemachine, a choice vertex must have at least one incoming and one outgoing transition.
        if pseudoState:getFirstOutgoing() then
            StateLua.console.error(pseudoState .. ": " .. pseudoState.kind .. " pseudo states must have at least one outgoing transition.")
        end
        -- choice and junction pseudo state can have at most one else transition
        local cnt = 0
        for transition , _ in pairs(pseudoState.outgoing) do
            if transition.guard == StateLua.Transition.FalseGuard then
                cnt = cnt + 1
            end
        end
        if cnt > 1 then
            StateLua.console.error(pseudoState .. ": " .. pseudoState.kind .. " pseudo states cannot have more than one Else transitions.")
        end
    else
        -- non choice/junction pseudo state may not have else transitions
        local cnt = 0
        for transition , _ in pairs(pseudoState.outgoing) do
            if transition.guard == StateLua.Transition.FalseGuard then
                cnt = cnt + 1
            end
        end
        if cnt ~= 0 then
            StateLua.console.error(pseudoState .. ": " .. pseudoState.kind .. " pseudo states cannot have Else transitions.")
        end
        if (pseudoState:isInitial()) then
            if (pseudoState:getOutgoingCnt() ~= 1) then
                -- [1] An initial vertex can have at most one outgoing transition.
                -- [2] History vertices can have at most one outgoing transition.
                StateLua.console.error(pseudoState .. ": initial pseudo states must have one outgoing transition.")
            else
                -- [9] The outgoing transition from an initial vertex may have a behavior, but not a trigger or guard.
                if (pseudoState:getFirstOutgoing().guard ~= StateLua.Transition.TrueGuard) then
                    StateLua.console.error(pseudoState .. ": initial pseudo states cannot have a guard condition.")
                end
            end
        end
    end
end

function Validator:visitRegion(region)
    Validator.super.visitRegion(self, region)
    local initial
    for vertex , _ in pairs(region.vertices) do
        if iskindof(vertex , "PseudoState") and vertex:isInitial() then
            if (initial) then
                StateLua.console.error(region .. ": regions may have at most one initial pseudo state.");
            end
            initial = vertex;
        end
    end
end

function Validator:visitState(state)
    Validator.super.visitState(self, state)
    local cnt = 0
    for state, _ in pairs(state.regions) do
        if state.name == StateLua.Region.defaultName then
            cnt = cnt + 1
        end
    end
    if cnt > 1 then
        StateLua.console.error(state .. ": a state cannot have more than one region named " .. StateLua.Region.defaultName);
    end
end

function Validator:visitFinalState(finalState)
    Validator.super.visitFinalState(self, finalState)
    if (finalState:getOutgoingCnt() ~= 0) then
        StateLua.console.error(finalState .. ": final states must not have outgoing transitions.")
    end
    -- [2] A final state cannot have regions.
    if (finalState:getRegionCnt() ~= 0) then
        StateLua.console.error(finalState .. ": final states must not have child regions.")
    end
    -- [4] A final state has no entry behavior.
    if (finalState.entryBehavior:hasActions()) then
        StateLua.console.warn(finalState .. ": final states may not have entry behavior.")
    end
    -- [5] A final state has no exit behavior.
    if (finalState.exitBehavior:hasActions()) then
        StateLua.console.warn(finalState .. ": final states may not have exit behavior.")
    end
end

function Validator:visitTransition(transition)
    Validator.super.visitTransition(self, transition)
    if (transition.kind == StateLua.TransitionKind.Local) then
        local parents = ancestors(transition.target)
        local isFounded = false
        for i = #parents , 1 , -1 do
            if parents[i] == transition.source then
                isFounded = true
            end
        end
        if not isFounded then
            StateLua.console.error(transition .. ": local transition target vertices must be a child of the source composite sate.")
        end
    end
end

StateLua.Validator = Validator

---------------------------------------------------------------
local random = function(max)
    return math.random(1 , max)
end

StateLua.setRandom = function(func)
    random = func
end

StateLua.getRandom = function()
    return random
end
---------------------------------------------------------------
local isActive = function(element , stateMachineInstance)
--    if iskindof(element , "Region") then
--        return isActive(element.state , stateMachineInstance)
--    elseif iskindof(element , "State") then
--        if element.region then
--            return isActive(element.region , stateMachineInstance) and stateMachineInstance:getCurrent(element.region) == element
--        end
--        return true
--    end
    return element:isActive(stateMachineInstance)
end
StateLua.isActive = isActive
---------------------------------------------------------------
local validate = function(stateMachineModel)
    stateMachineModel:accept(StateLua.Validator.new())
end
StateLua.validate = validate
---------------------------------------------------------------
local isComplete = function(element , instance)
--    if (element instanceof StateLua.Region) {
--            return instance:getCurrent(element):isFinal();
--        } else if (element instanceof StateLua.State) {
--            return element.regions.every(function (region) {
--                return isComplete(region, instance);
--            });
--        }
--        return true;
    return element:isComplete(instance)
end
StateLua.isComplete = isComplete
---------------------------------------------------------------
local initialise = function(stateMachineModel, stateMachineInstance, autoInitialiseModel)
    if autoInitialiseModel == nil then
        autoInitialiseModel = true
    end
    if stateMachineInstance then
        -- initialise the state machine model if necessary
        if (autoInitialiseModel and not stateMachineModel.clean) then
            StateLua.initialise(stateMachineModel)
        end
        -- log as required
        StateLua.console.log("initialise " .. stateMachineInstance:toString())
        -- enter the state machine instance for the first time
        stateMachineModel.onInitialise:invoke(nil, stateMachineInstance)
    else
        -- log as required
        StateLua.console.log("initialise " .. stateMachineModel.name)
        -- initialise the state machine model
        stateMachineModel:accept(StateLua.InitialiseElements.new(), false)
        stateMachineModel.clean = true
    end
end
StateLua.initialise = initialise
---------------------------------------------------------------
local traverse = function(transition, instance, message)
    local onTraverse = StateLua.Behavior.new(transition.onTraverse)
    local target = transition.target
    while target and iskindof(target , "PseudoState") and target.kind == StateLua.PseudoStateKind.Junction do
        transition = StateLua.selectTransition(target, instance, message)
        target = transition.target
        onTraverse:push(transition.onTraverse)
    end
    onTraverse:invoke(message, instance)
    if target and iskindof(target , "PseudoState") and target.kind == StateLua.PseudoStateKind.Choice then
        StateLua.traverse(StateLua.selectTransition(target, instance, message), instance, message);
    elseif target and iskindof(target , "State") and StateLua.isComplete(target, instance) then
        -- test for completion transitions
        StateLua.evaluateState(target, instance, target)
    end
    return true
end
StateLua.traverse = traverse
---------------------------------------------------------------
local selectTransition = function(pseudoState, stateMachineInstance, message)
    local transitions = {}
    for transition , _  in pairs(state.outgoing) do
        if transition.guard(message, stateMachineInstance) then
            table.insert(transitions , transition)
        end
    end
    if pseudoState.kind == StateLua.PseudoStateKind.Choice then
        return #transitions ~= 0 and results[StateLua.getRandom()(#transitions)] or findElse(pseudoState)
    else
        if #transitions > 1 then
            StateLua.console.error("Multiple outbound transition guards returned true at " .. self:toString() .. " for " .. message);
        else
            return results[1] or findElse(pseudoState)
        end
    end
end
StateLua.selectTransition = selectTransition
---------------------------------------------------------------

local evaluateState = function(state, stateMachineInstance, message)
    local result = false
    for region , _ in pairs(state.regions) do
        if StateLua.evaluateState(stateMachineInstance:getCurrent(region) , stateMachineInstance , message) then
            result = true
            StateLua.isActive(state , stateMachineInstance)
        end
    end
    if result then
        if message ~= state and StateLua.isComplete(state , stateMachineInstance) then
            StateLua.evaluateState(state, stateMachineInstance, state)
        end
    else
        local transitions = {}
        for transition , _  in pairs(state.outgoing) do
            if transition.guard(message, stateMachineInstance) then
                table.insert(transitions , transition)
            end
        end
        if #transitions == 1 then
            result = StateLua.traverse(transitions[1], stateMachineInstance, message)
        elseif #transitions > 1 then
            StateLua.console.error(state:toString() .. ": multiple outbound transitions evaluated true for message " .. message)
        end
    end
    return result
end
StateLua.evaluateState = evaluateState
---------------------------------------------------------------
local evaluate = function(stateMachineModel, stateMachineInstance, message, autoInitialiseModel)
    if autoInitialiseModel == nil then
        autoInitialiseModel = true
    end
    StateLua.console.log(stateMachineInstance:toString())
    StateLua.console.printTable(message , "evaluate")
    if autoInitialiseModel and not stateMachineModel.clean then
        StateLua.initialise(stateMachineModel)
    end
    if stateMachineInstance.isTerminated then
        return false
    end
    return StateLua.evaluateState(stateMachineModel, stateMachineInstance, message)
end
StateLua.evaluate = evaluate
---------------------------------------------------------------
return StateLua