local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Roact = require(script.Parent.Parent.Roact)
local RoactRodux = require(script.Parent.Parent.RoactRodux)

local BarTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
local InnerBarTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)

local e = Roact.createElement
local StaminaBar = Roact.PureComponent:extend("StaminaBar")

function StaminaBar:init(props)
    self.StaminaBarRef = Roact.createRef()
    self:setState({
        LastStamina = props.Stamina,
        Hide = true
    })
end

function StaminaBar:render()
    if self.state.Hide then return nil end
    return e("Frame", {
        [Roact.Ref] = self.StaminaBarRef,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.125, 0.95),
        Size = UDim2.fromScale(0.2, 0.012),
        BackgroundColor3 = Color3.new(),
        BackgroundTransparency = 1,
    }, {
        InnerBar = e("Frame", {
            BorderSizePixel = 0,
            Size = UDim2.fromScale(self.state.LastStamina/100, 1),
            Position = UDim2.fromScale(0, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1
        }, { 
            UICorner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(1, 0)
            })
        }),
        UICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(1, 0)
        })
    })
end

function StaminaBar:TweenIn()
    local bar = self.StaminaBarRef:getValue()
    local tween = TweenService:Create(bar, BarTweenInfo, { BackgroundTransparency = 0.5 })
    tween.Completed:Connect(function()
        tween:Destroy()
    end)
    TweenService:Create(bar.InnerBar, BarTweenInfo, { BackgroundTransparency = 0 }):Play()
    tween:Play()
end

function StaminaBar:TweenOut()
    local bar = self.StaminaBarRef:getValue()
    local tween = TweenService:Create(bar, BarTweenInfo, { BackgroundTransparency = 1 })
    TweenService:Create(bar.InnerBar, BarTweenInfo, { BackgroundTransparency = 1 }):Play()
    tween.Completed:Connect(function()
        tween:Destroy()
        self:setState({
            Hide = true
        })
    end)
    tween:Play()
end

function StaminaBar:TweenBar()
    local bar = self.StaminaBarRef:getValue()
    if not bar then return end
    local tween = TweenService:Create(bar.InnerBar, InnerBarTweenInfo, {
        Size = UDim2.fromScale(self.props.Stamina/100, 1)
    })
    tween.Completed:Connect(function()
        tween:Destroy()
    end)
    tween:Play()
end

function StaminaBar:didUpdate(lastProps, lastState)
    if self.state.Hide and self.props.isShowing then
        self:setState({
            Hide = false
        })
        return
    elseif not self.state.Hide and lastState.Hide then
        self:TweenIn()
        return
    elseif not self.state.Hide and not self.props.isShowing then
        self:TweenOut()
        return
    end

    if self.state.LastStamina ~= self.props.Stamina then
        -- stamina state updated
        self:TweenBar()
        self.state.LastStamina = self.props.Stamina
    end
end

StaminaBar = RoactRodux.connect(
    function(state, props)
        return {
            Stamina = state.Stamina,
            isShowing = state.StaminaBar.Enabled
        }
    end
)(StaminaBar)

return StaminaBar