local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local StarterGui = game:GetService("StarterGui")

local function showLoadingMessage(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = 3
        })
    end)
end

showLoadingMessage("寒冰恐鬼症专属脚本", "欢迎使用 寒冰恐鬼症专属脚本 - 定制版 pro Max 脚本")
task.wait(2)
showLoadingMessage("寒冰", "不是牢底你还开上脚本了？")
task.wait(2)
showLoadingMessage("寒冰", "寒冰祝你一辈子不卡脚 \"骗你的脚还是要卡的\"")
task.wait(2)
showLoadingMessage("寒冰", "\"你也在使用 寒冰的脚本吗？\"\n\"哦，是的先生，这得挨不少打\"")
task.wait(3)
showLoadingMessage("加载中", "脚本ui正在加载中...")
task.wait(1)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local state = {
    noclipEnabled = false,
    nightVisionEnabled = false,
    quickInteractEnabled = false,
    walkSpeed = 16,
    walkSpeedEnabled = false,
    originalWalkSpeed = 16,
    uiToggleKey = "End",
}

local connections = {}

local function disconnect(name)
    local c = connections[name]
    if c then
        c:Disconnect()
        connections[name] = nil
    end
end

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = 2
        })
    end)
end

local function getCharacter(player)
    player = player or LocalPlayer
    local char = player.Character
    if char and char.Parent then
        return char
    end
    return nil
end

local function getHumanoid(player)
    local char = getCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

local function updateCharacterRefs(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
end

LocalPlayer.CharacterAdded:Connect(updateCharacterRefs)
if LocalPlayer.Character then
    updateCharacterRefs(LocalPlayer.Character)
end

local Window = WindUI:CreateWindow({
    Title = "寒冰恐鬼症专属脚本 - 定制版 pro Max",
    Icon = "home",
    Folder = "SimpleScript",
    Size = UDim2.fromOffset(500, 420),
    Theme = "Dark",
    SideBarWidth = 180,
    ToggleKey = Enum.KeyCode.End,
})

WindUI:SetTheme("Dark")

local MainTab = Window:Tab({
    Title = "”点我展开“ - 功能",
    Icon = "home",
})

MainTab:Toggle({
    Title = "卡脚神器 - “不是我怎么又卡墙里了”",
    Value = state.noclipEnabled,
    Callback = function(v)
        state.noclipEnabled = v
        disconnect("noclip")
        if v then
            connections.noclip = RunService.Stepped:Connect(function()
                local char = getCharacter()
                if not char then return end
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
            notify("鬼打墙", "已开启")
        else
            local char = getCharacter()
            if char then
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            notify("鬼打墙", "已关闭")
        end
    end,
})

MainTab:Space()

MainTab:Toggle({
    Title = "青光眼神器 - “点开sls眼睛直接cos十字架烧了”",
    Value = state.nightVisionEnabled,
    Callback = function(v)
        state.nightVisionEnabled = v
        if v then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            notify("青光眼", "已开启")
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.Brightness = 1
            Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            notify("青光眼", "已关闭")
        end
    end,
})

MainTab:Space()

MainTab:Toggle({
    Title = "快速互动",
    Value = state.quickInteractEnabled,
    Callback = function(v)
        state.quickInteractEnabled = v
        if v then
            local prompts = {}
            local function check(obj)
                if obj:IsA("ProximityPrompt") then
                    table.insert(prompts, obj)
                end
            end
            for _, obj in ipairs(workspace:GetDescendants()) do
                check(obj)
            end
            connections.quickInteractAdded = workspace.DescendantAdded:Connect(check)
            connections.quickInteractInput = game.UserInputService.InputBegan:Connect(function(i)
                if i.KeyCode == Enum.KeyCode.E then
                    for _, prompt in ipairs(prompts) do
                        prompt.HoldDuration = 0.01
                        prompt:InputHoldBegin()
                        task.delay(0.05, function() prompt:InputHoldEnd() end)
                    end
                end
            end)
            notify("快速互动", "已开启")
        else
            disconnect("quickInteractAdded")
            disconnect("quickInteractInput")
            notify("快速互动", "已关闭")
        end
    end,
})

MainTab:Space()
MainTab:Divider()
MainTab:Space()

MainTab:Input({
    Title = "火车头速度",
    Desc = "输入速度值（默认16）",
    Value = tostring(state.walkSpeed),
    Placeholder = "16",
    Callback = function(v)
        local num = tonumber(v)
        if num then
            state.walkSpeed = num
            if state.walkSpeedEnabled then
                local hum = getHumanoid()
                if hum then
                    hum.WalkSpeed = state.walkSpeed
                end
            end
        end
    end,
})

MainTab:Space()

MainTab:Toggle({
    Title = "启用火车头速度",
    Value = state.walkSpeedEnabled,
    Callback = function(v)
        state.walkSpeedEnabled = v
        disconnect("walkSpeed")
        if v then
            local hum = getHumanoid()
            if hum then
                state.originalWalkSpeed = hum.WalkSpeed
            end
            connections.walkSpeed = RunService.Heartbeat:Connect(function()
                local hum = getHumanoid()
                if hum then
                    hum.WalkSpeed = state.walkSpeed
                end
            end)
            notify("火车头", "已开启，当前速度: " .. tostring(state.walkSpeed))
        else
            local hum = getHumanoid()
            if hum then
                hum.WalkSpeed = state.originalWalkSpeed
            end
            notify("火车头", "已关闭，恢复原始速度")
        end
    end,
})

MainTab:Space()
MainTab:Divider()
MainTab:Space()

MainTab:Keybind({
    Title = "UI 控制按键",
    Desc = "按下该键显示/隐藏 UI",
    Value = state.uiToggleKey,
    Callback = function(v)
        state.uiToggleKey = v
        local keycode = Enum.KeyCode[v]
        if keycode then
            Window:SetToggleKey(keycode)
            notify("按键设置", "UI 控制按键已设为: " .. v)
        end
    end,
})

Window.OnClose = function()
    disconnect("noclip")
    disconnect("walkSpeed")
    disconnect("quickInteractAdded")
    disconnect("quickInteractInput")
    if state.walkSpeedEnabled then
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = state.originalWalkSpeed
        end
    end
end

showLoadingMessage("成功", "脚本加载成功！")
