--[[
    ================================================================
    TRust-Menu Standalone Engine (Xeno Executor Fully Compatible)
    Custom Independent Script Menu with Default Eagle Logo Fix
    ================================================================
]]

local TRustMenu = {
    Flags = {},
    Tabs = {},
    CurrentTab = nil
}

-- Global Alias
getgenv().TRustMenu = TRustMenu

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Custom Asset Loader for Xeno (Downloads & Caches GitHub Images)
local function GetCustomAsset(url, filename)
    if not url or url == "" or type(url) ~= "string" then return "" end
    if string.find(url, "rbxassetid://") or string.find(url, "rbxasset://") then
        return url
    end
    
    if string.find(url, "http://") or string.find(url, "https://") then
        if not isfolder or not writefile or not isfile then return url end
        
        if not isfolder("TRustMenu") then makefolder("TRustMenu") end
        if not isfolder("TRustMenu/assets") then makefolder("TRustMenu/assets") end
        
        filename = filename or ("asset_" .. string.gsub(url, "%W", ""):sub(-10) .. ".png")
        local path = "TRustMenu/assets/" .. filename
        
        if not isfile(path) then
            local success, content = pcall(function()
                return game:HttpGet(url)
            end)
            if success and content and content ~= "" then
                writefile(path, content)
            end
        end
        
        if isfile(path) and getcustomasset then
            return getcustomasset(path)
        end
    end
    return url
end

-- GUI Protection for Xeno Executor
local function ProtectGui(gui)
    if gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    else
        gui.Parent = CoreGui
    end
end

-- Main Window Creation
function TRustMenu:CreateWindow(config)
    config = config or {}
    local Title = config.Title or config.Name or "TRust Menu"
    
    -- إضافة رابط شعار النسر (0.png) كشعار افتراضي في حال عدم تحديد شعار
    local DefaultEagleLogo = "https://raw.githubusercontent.com/nadmksa123456-lgtm/TRust_Menu/main/assets/0.png"
    local LogoUrl = config.Logo or config.LogoUrl or DefaultEagleLogo
    local ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    -- Clean Previous Instance
    if CoreGui:FindFirstChild("TRust_Standalone_UI") then
        CoreGui:FindFirstChild("TRust_Standalone_UI"):Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TRust_Standalone_UI"
    ScreenGui.ResetOnSpawn = false
    ProtectGui(ScreenGui)

    -- Window Base Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 580, 0, 390)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -195)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(40, 40, 50)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    -- Dragging System
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar Container
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 165, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundTransparency = 1
    Header.Parent = Sidebar

    if LogoUrl ~= "" then
        local LogoImg = Instance.new("ImageLabel")
        LogoImg.Name = "Logo"
        LogoImg.Size = UDim2.new(0, 30, 0, 30)
        LogoImg.Position = UDim2.new(0, 12, 0, 15)
        LogoImg.BackgroundTransparency = 1
        LogoImg.Image = GetCustomAsset(LogoUrl, "eagle_logo.png")
        LogoImg.Parent = Header
    end

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -55, 1, 0)
    TitleLabel.Position = UDim2.new(0, 50, 0, 0)
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = Header

    -- Tab Button Holder
    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Name = "TabHolder"
    TabHolder.Size = UDim2.new(1, 0, 1, -65)
    TabHolder.Position = UDim2.new(0, 0, 0, 65)
    TabHolder.BackgroundTransparency = 1
    TabHolder.ScrollBarThickness = 0
    TabHolder.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabHolder

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -175, 1, -20)
    ContentArea.Position = UDim2.new(0, 170, 0, 10)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    -- Keybind to Hide/Show UI
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    local WindowObj = { Tabs = {} }

    -- Create Tab Method
    function WindowObj:CreateTab(tabName, iconUrl)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName .. "_Btn"
        TabBtn.Size = UDim2.new(0, 145, 0, 35)
        TabBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
        TabBtn.Text = "   " .. tabName
        TabBtn.TextColor3 = Color3.fromRGB(160, 160, 170)
        TabBtn.Font = Enum.Font.SourceSansSemibold
        TabBtn.TextSize = 14
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabHolder

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 5)
        BtnCorner.Parent = TabBtn

        if iconUrl and iconUrl ~= "" then
            local IconImg = Instance.new("ImageLabel")
            IconImg.Size = UDim2.new(0, 18, 0, 18)
            IconImg.Position = UDim2.new(0, 8, 0.5, -9)
            IconImg.BackgroundTransparency = 1
            IconImg.Image = GetCustomAsset(iconUrl, tabName .. "_icon.png")
            IconImg.Parent = TabBtn
            TabBtn.Text = "         " .. tabName
        end

        -- Tab Content Page (Auto Elastic Canvas)
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = tabName .. "_Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 3
        TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.Parent = ContentArea

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = TabPage

        local function Select()
            for _, tab in ipairs(WindowObj.Tabs) do
                tab.Page.Visible = false
                tab.Button.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
                tab.Button.TextColor3 = Color3.fromRGB(160, 160, 170)
            end
            TabPage.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        TabBtn.MouseButton1Click:Connect(Select)

        if #WindowObj.Tabs == 0 then
            Select()
        end

        local TabObj = { Page = TabPage, Button = TabBtn }

        -- Component: Section Title
        function TabObj:CreateSection(titleText)
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, 0, 0, 24)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = TabPage

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.Text = titleText
            Label.TextColor3 = Color3.fromRGB(0, 160, 255)
            Label.Font = Enum.Font.SourceSansBold
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = SecFrame
        end

        -- Component: Button
        function TabObj:CreateButton(btnText, callback)
            callback = callback or function() end
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -5, 0, 34)
            Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            Btn.Text = btnText
            Btn.TextColor3 = Color3.fromRGB(240, 240, 245)
            Btn.Font = Enum.Font.SourceSans
            Btn.TextSize = 14
            Btn.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 5)
            Corner.Parent = Btn

            Btn.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end

        -- Component: Toggle
        function TabObj:CreateToggle(toggleText, defaultState, callback)
            callback = callback or function() end
            local state = defaultState or false

            local TogFrame = Instance.new("Frame")
            TogFrame.Size = UDim2.new(1, -5, 0, 34)
            TogFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
            TogFrame.Parent = TabPage

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 5)
            Corner.Parent = TogFrame

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -40, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Text = toggleText
            Label.TextColor3 = Color3.fromRGB(240, 240, 245)
            Label.Font = Enum.Font.SourceSans
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = TogFrame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 20, 0, 20)
            Switch.Position = UDim2.new(1, -30, 0.5, -10)
            Switch.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 70)
            Switch.Text = ""
            Switch.Parent = TogFrame

            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(0, 4)
            SwitchCorner.Parent = Switch

            Switch.MouseButton1Click:Connect(function()
                state = not state
                Switch.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 70)
                pcall(callback, state)
            end)
        end

        table.insert(WindowObj.Tabs, TabObj)
        return TabObj
    end

    return WindowObj
end

return TRustMenu
