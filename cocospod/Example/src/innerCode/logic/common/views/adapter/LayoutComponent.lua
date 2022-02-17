local LayoutComponent = class("LayoutComponent")
local HorizontalEdge = 
{
    None = 0,
    Left = 1,
    Right = 2,
    Center = 3
}
local VerticalEdge = 
{
    None = 0,
    Bottom = 1,
    Top = 2,
    Center = 3
}
LayoutComponent.HorizontalEdge = HorizontalEdge
LayoutComponent.VerticalEdge = VerticalEdge
function LayoutComponent:ctor(node)
    self._name = "__ui_layout"
    self._horizontalEdge = HorizontalEdge.None
    self._verticalEdge = VerticalEdge.None
    self._leftMargin = 0
    self._rightMargin = 0
    self._bottomMargin = 0
    self._topMargin = 0
    self._usingPositionPercentX = false
    self._positionPercentX = 0
    self._usingPositionPercentY = false
    self._positionPercentY = 0
    self._usingStretchWidth = false
    self._usingStretchHeight = false
    self._percentWidth = 0
    self._usingPercentWidth = false
    self._percentHeight = 0
    self._usingPercentHeight = false
    self._actived = true
    self._isPercentOnly = false
    self._owner = node
end

function LayoutComponent:bindLayoutComponent(node)
    local layout = LayoutComponent.new(node)
    layout:init()
    return layout
end

function LayoutComponent:init()

end

function LayoutComponent:getOwnerParent()
    return self._owner:getParent()
end


function LayoutComponent:refreshHorizontalMargin()
    local parent = self:getOwnerParent()
    if not parent then
        return
    end

    local ownerlocal = self._owner:getPosition()
    local ownerAnchor = self._owner:getAnchorPoint()
    local ownerSize = self._owner:getContentSize()
    local parentSize = parent:getContentSize()

    self._leftMargin = ownerlocal.x - ownerAnchor.x * ownerSize.width
    self._rightMargin = parentSize.width - (ownerlocal.x + (1 - ownerAnchor.x) * ownerSize.width)
end

function LayoutComponent:refreshVerticalMargin()
    local parent = self:getOwnerParent()
    if not parent then
        return
    end
    local ownerlocal = self._owner:getPosition()
    local ownerAnchor = self._owner:getAnchorPoint()
    local ownerSize = self._owner:getContentSize()
    local parentSize = parent:getContentSize()

    self._bottomMargin = ownerlocal.y - ownerAnchor.y * ownerSize.height
    self._topMargin = parentSize.height - (ownerlocal.y + (1 - ownerAnchor.y) * ownerSize.height)
end

--OldVersion
function LayoutComponent:setUsingPercentContentSize(isUsed)
    self._usingPercentWidth = isUsed
    self._usingPercentHeight = isUsed
end

function LayoutComponent:getUsingPercentContentSize()
    return self._usingPercentWidth and self._usingPercentHeight
end

function LayoutComponent:setPercentContentSize(percent)
    self:setPercentWidth(percent.x)
    self:setPercentHeight(percent.y)
end
function LayoutComponent:getPercentContentSize()
    local vec2 = cc.p(self._percentWidth,self._percentHeight)
    return vec2
end

--Position & Margin
function LayoutComponent:getAnchorPosition()
    return self._owner:getAnchorPoint()
end

function LayoutComponent:setAnchorPosition(vec)
    local oldlocal = self._owner:getBoundingBox()
    self._owner:setAnchorPoint(vec)
    local newlocal = self._owner:getBoundingBox()
    local offSetX = oldlocal.x - newlocal.x
    local offSetY = oldlocal.y - newlocal.y

    local ownerPosition = self._owner:getPosition()
    ownerPosition.x = ownerPosition.x + offSetX
    ownerPosition.y = ownerPosition.y + offSetY

    self:setPosition(ownerPosition)
end

function LayoutComponent:getPosition()
    return self._owner:getPosition()
end

function LayoutComponent:setPosition(position)
    local parent = self:getOwnerParent()
    if parent then
        local ownerlocal = position
        local parentSize = parent:getContentSize()
        if (parentSize.width ~= 0) then
            self._positionPercentX = ownerlocal.x / parentSize.width
        else
            self._positionPercentX = 0
            if (self._usingPositionPercentX or self._horizontalEdge == HorizontalEdge.Center) then
                ownerlocal.x = 0
            end
        end

        if (parentSize.height ~= 0) then
            self._positionPercentY = ownerlocal.y / parentSize.height
        else
            self._positionPercentY = 0
            if (self._usingPositionPercentY or self._verticalEdge == VerticalEdge.Center) then
                ownerlocal.y = 0
            end
        end

        self._owner:setPosition(ownerlocal)

        self:refreshHorizontalMargin()
        self:refreshVerticalMargin()
    else
        self._owner:setPosition(position)
    end
end

function LayoutComponent:isPositionPercentXEnabled()
    return self._usingPositionPercentX
end

function LayoutComponent:setPositionPercentXEnabled(isUsed)
    self._usingPositionPercentX = isUsed
    if (self._usingPositionPercentX) then
        self._horizontalEdge = HorizontalEdge.None
    end
end

function LayoutComponent:getPositionPercentX()
    return self._positionPercentX
end

function LayoutComponent:setPositionPercentX(percentMargin)
    self._positionPercentX = percentMargin
    if (self._usingPositionPercentX or self._horizontalEdge == HorizontalEdge.Center) then
        local parent = self:getOwnerParent()
        if parent then
            self._owner:setPositionX(parent:getContentSize().width * self._positionPercentX)
            self:refreshHorizontalMargin()
        end
    end
end

function LayoutComponent:isPositionPercentYEnabled()
    return self._usingPositionPercentY
end
function LayoutComponent:setPositionPercentYEnabled(isUsed)
    self._usingPositionPercentY = isUsed
    if (self._usingPositionPercentY) then
        self._verticalEdge = VerticalEdge.None
    end
end

function LayoutComponent:getPositionPercentY()
    return self._positionPercentY
end

function LayoutComponent:setPositionPercentY(percentMargin)
    self._positionPercentY = percentMargin
    if (self._usingPositionPercentY or self._verticalEdge == VerticalEdge.Center) then
        local parent = self:getOwnerParent()
        if parent then
            self._owner:setPositionY(parent:getContentSize().height * self._positionPercentY)
            self:refreshVerticalMargin()
        end
    end
end

function LayoutComponent:getHorizontalEdge()
    return self._horizontalEdge
end

function LayoutComponent:setHorizontalEdge(hEage)
    self._horizontalEdge = hEage
    if (self._horizontalEdge ~= HorizontalEdge.None) then
        self._usingPositionPercentX = false
    end
end

function LayoutComponent:getVerticalEdge()
    return self._verticalEdge
end

function LayoutComponent:setVerticalEdge(vEage)
    self._verticalEdge = vEage
    if (self._verticalEdge ~= VerticalEdge.None) then
        self._usingPositionPercentY = false
    end
end

function LayoutComponent:getLeftMargin()
    return self._leftMargin
end

function LayoutComponent:setLeftMargin(margin)
    self._leftMargin = margin
end

function LayoutComponent:getRightMargin()
    return self._rightMargin
end

function LayoutComponent:setRightMargin(margin)
    self._rightMargin = margin
end

function LayoutComponent:getTopMargin()
    return self._topMargin
end

function LayoutComponent:setTopMargin(margin)
    self._topMargin = margin
end

function LayoutComponent:getBottomMargin()
    return self._bottomMargin
end

function LayoutComponent:setBottomMargin( margin)
    self._bottomMargin = margin
end

--local & Percent
function LayoutComponent:getSize()
    return self:getOwner():getContentSize()
end

function LayoutComponent:setSize( size)
    local parent = self:getOwnerParent()
    if parent then 
        local ownerSize = size
        local parentSize = parent:getContentSize()

        if (parentSize.width ~= 0) then
            self._percentWidth = ownerSize.width / parentSize.width
        else
            self._percentWidth = 0
            if (self._usingPercentWidth or (self._horizontalEdge ~= HorizontalEdge.Center and self._usingStretchWidth)) then
                ownerSize.width = 0
            end
        end

        if (parentSize.height ~= 0) then
            self._percentHeight = ownerSize.height / parentSize.height
        else
            self._percentHeight = 0
            if (self._usingPercentHeight or (self._verticalEdge ~= VerticalEdge.Center and self._usingStretchHeight)) then
                ownerSize.height = 0
            end
        end

        self._owner:setContentSize(ownerSize)

        self:refreshHorizontalMargin()
        self:refreshVerticalMargin()
    else
        self._owner:setContentSize(size)
    end
end

function LayoutComponent:isPercentWidthEnabled()
    return self._usingPercentWidth
end

function LayoutComponent:setPercentWidthEnabled(isUsed)
    self._usingPercentWidth = isUsed
    if (self._usingPercentWidth) then
        self._usingStretchWidth = false
    end
end

function LayoutComponent:getSizeWidth()
    return self._owner:getContentSize().width
end
    
function LayoutComponent:setSizeWidth( width)
    local ownerSize = self._owner:getContentSize()
    ownerSize.width = width

    local parent = self:getOwnerParent()
    if parent then
        local parentSize = parent:getContentSize()
        if (parentSize.width ~= 0) then
            self._percentWidth = ownerSize.width / parentSize.width
        else
            self._percentWidth = 0
            if (self._usingPercentWidth) then
                ownerSize.width = 0
            end
        end
        self._owner:setContentSize(ownerSize)
        self:refreshHorizontalMargin()
    else
        self._owner:setContentSize(ownerSize)
    end
end

function LayoutComponent:getPercentWidth()
    return self._percentWidth
end

function LayoutComponent:setPercentWidth( percentWidth)
    self._percentWidth = percentWidth
    if (self._usingPercentWidth) then
        local parent = self:getOwnerParent()
        if parent then
            local ownerSize = self._owner:getContentSize()
            ownerSize.width = parent:getContentSize().width * self._percentWidth
            self._owner:setContentSize(ownerSize)

            self:refreshHorizontalMargin()
        end
    end
end

function LayoutComponent:isPercentHeightEnabled()
    return self._usingPercentHeight
end

function LayoutComponent:setPercentHeightEnabled(isUsed)
    self._usingPercentHeight = isUsed
    if (self._usingPercentHeight) then
        self._usingStretchHeight = false
    end
end

function LayoutComponent:getSizeHeight()
    return self._owner:getContentSize().height
end

function LayoutComponent:setSizeHeight( height)
    local ownerSize = self._owner:getContentSize()
    ownerSize.height = height

    local parent = self:getOwnerParent()
    if parent then
        local parentSize = parent:getContentSize()
        if (parentSize.height ~= 0) then
            self._percentHeight = ownerSize.height / parentSize.height
        else
            self._percentHeight = 0
            if (self._usingPercentHeight) then
                ownerSize.height = 0
            end
        end
        self._owner:setContentSize(ownerSize)
        self:refreshVerticalMargin()
    else
        self._owner:setContentSize(ownerSize)
    end
end

function LayoutComponent:getPercentHeight()
    return self._percentHeight
end

function LayoutComponent:setPercentHeight( percentHeight)
    self._percentHeight = percentHeight
    if (self._usingPercentHeight) then
        local parent = self:getOwnerParent()
        if parent then
            local ownerSize = self._owner:getContentSize()
            ownerSize.height = parent:getContentSize().height * self._percentHeight
            self._owner:setContentSize(ownerSize)
            self:refreshVerticalMargin()
        end
    end
end

function LayoutComponent:isStretchWidthEnabled()
    return self._usingStretchWidth
end

function LayoutComponent:setStretchWidthEnabled(isUsed)
    self._usingStretchWidth = isUsed
    if (self._usingStretchWidth)then
        self._usingPercentWidth = false
    end
end

function LayoutComponent:isStretchHeightEnabled()
    return self._usingStretchHeight
end

function LayoutComponent:setStretchHeightEnabled(isUsed)
    self._usingStretchHeight = isUsed
    if (self._usingStretchHeight) then
        self._usingPercentHeight = false
    end
end

function LayoutComponent:refreshLayout()
    if (not self._actived) then
        return
    end
    
    local parent = self:getOwnerParent()
    if not parent then
        return
    end

    local parentSize = parent:getContentSize()
    local ownerAnchor = self._owner:getAnchorPoint()
    local ownerSize = self._owner:getContentSize()
    local ownerPosition = self._owner:getPosition()

    if(self._horizontalEdge == HorizontalEdge.None) then
        if (self._usingStretchWidth and not self._isPercentOnly) then
            ownerSize.width = parentSize.width * self._percentWidth
            ownerPosition.x = self._leftMargin + ownerAnchor.x * ownerSize.width
        else
            if (self._usingPositionPercentX) then
                ownerPosition.x = parentSize.width * self._positionPercentX
            end
            if (self._usingPercentWidth) then
                ownerSize.width = parentSize.width * self._percentWidth
            end
        end
    elseif self._horizontalEdge == HorizontalEdge.Left then
        if not self._isPercentOnly then
            if (self._usingPercentWidth or self._usingStretchWidth) then
                ownerSize.width = parentSize.width * self._percentWidth
            end
            ownerPosition.x = self._leftMargin + ownerAnchor.x * ownerSize.width
        end
    elseif self._horizontalEdge == HorizontalEdge.Right then
        if (not self._isPercentOnly) then
            if (self._usingPercentWidth or self._usingStretchWidth) then
                ownerSize.width = parentSize.width * self._percentWidth
            end
            ownerPosition.x = parentSize.width - (self._rightMargin + (1 - ownerAnchor.x) * ownerSize.width)
        end
    elseif self._horizontalEdge == HorizontalEdge.Center then
        if (not self._isPercentOnly) then
            if (self._usingStretchWidth) then
                ownerSize.width = parentSize.width - self._leftMargin - self._rightMargin
                if (ownerSize.width < 0) then
                    ownerSize.width = 0
                end
                ownerPosition.x = self._leftMargin + ownerAnchor.x * ownerSize.width
            else
                if (self._usingPercentWidth) then
                    ownerSize.width = parentSize.width * self._percentWidth
                end
                ownerPosition.x = parentSize.width * self._positionPercentX
            end
        end
    end

    if self._verticalEdge == VerticalEdge.None then
        if (self._usingStretchHeight and not self._isPercentOnly) then
            ownerSize.height = parentSize.height * self._percentHeight
            ownerPosition.y = self._bottomMargin + ownerAnchor.y * ownerSize.height
        else
            if (self._usingPositionPercentY) then
                ownerPosition.y = parentSize.height * self._positionPercentY
            end
            if (self._usingPercentHeight) then
                ownerSize.height = parentSize.height * self._percentHeight
            end
        end
    elseif self._verticalEdge == VerticalEdge.Bottom then
        if (not self._isPercentOnly) then
            if (self._usingPercentHeight or self._usingStretchHeight) then
                ownerSize.height = parentSize.height * self._percentHeight
            end
            ownerPosition.y = self._bottomMargin + ownerAnchor.y * ownerSize.height
        end
    elseif self._verticalEdge == VerticalEdge.Top then
        if (not self._isPercentOnly) then
            if (self._usingPercentHeight or self._usingStretchHeight) then
                ownerSize.height = parentSize.height * self._percentHeight
            end
            ownerPosition.y = parentSize.height - (self._topMargin + (1 - ownerAnchor.y) * ownerSize.height)
        end
    elseif self._verticalEdge == VerticalEdge.Center then
        if (not self._isPercentOnly) then
            if (self._usingStretchHeight) then
                ownerSize.height = parentSize.height - self._topMargin - self._bottomMargin
                if (ownerSize.height < 0) then
                    ownerSize.height = 0
                end
                ownerPosition.y = self._bottomMargin + ownerAnchor.y * ownerSize.height
            else
                if (self._usingPercentHeight) then
                    ownerSize.height = parentSize.height * self._percentHeight
                end
                ownerPosition.y = parentSize.height* self._positionPercentY
            end
        end
    end

    self._owner:setPosition(ownerPosition)
    self._owner:setContentSize(ownerSize)

    -- if (typeid(*self._owner) == typeid(PageView))
    
    --     PageView* page = static_cast<PageView*>(self._owner)
    --     page:forceDoLayout()

    --     Vector<Widget*> _widgetVector = page:getItems()
    --     for(auto& item : _widgetVector)
        
    --         ui:Helper:doLayout(item)
    --     end
    -- end
    -- else
    
    --     ui:Helper:doLayout(self._owner)
    -- end
end

function LayoutComponent:setActiveEnabled(enable)
    self._actived = enable
end

function LayoutComponent:setPercentOnlyEnabled(enable)
    self._isPercentOnly = enable
end

return LayoutComponent