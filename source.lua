--[[
    TRust Menu
    Official reusable Roblox/Luau UI library (Xeno Executor Fully Fixed Edition)
]]

local Services = setmetatable({}, {
    __index = function(_, serviceName)
        return game:GetService(serviceName)
    end,
})

local Players = Services.Players
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local Workspace = Services.Workspace

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local rgb = Color3.fromRGB
local fromOffset = UDim2.fromOffset
local clamp = math.clamp
local floor = math.floor
local max = math.max
local min = math.min
local insert = table.insert

local environment = getgenv and getgenv() or _G

local function getGuiParent()
    if gethui then
        local ok, result = pcall(gethui)
        if ok and result then
            return result
        end
    end

    local coreGui = game:GetService("CoreGui")
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, coreGui)
    end

    if coreGui:FindFirstChild("RobloxGui") then
        return coreGui:FindFirstChild("RobloxGui")
    end

    return coreGui or LocalPlayer:WaitForChild("PlayerGui")
end

local Theme = {
    Accent = rgb(0, 132, 255),
    AccentSoft = rgb(0, 86, 170),
    AccentLight = rgb(72, 169, 255),
    Window = rgb(2, 12, 20),
    Sidebar = rgb(2, 11, 18),
    Topbar = rgb(3, 14, 23),
    Content = rgb(2, 13, 22),
    Card = rgb(8, 24, 36),
    CardBottom = rgb(7, 20, 31),
    TabActive = rgb(7, 27, 43),
    Control = rgb(25, 49, 72),
    ControlBottom = rgb(20, 41, 61),
    ControlHover = rgb(31, 61, 90),
    Track = rgb(29, 52, 73),
    Border = rgb(18, 42, 58),
    Text = rgb(244, 247, 251),
    Muted = rgb(159, 170, 187),
    Dim = rgb(101, 116, 136),
    White = rgb(255, 255, 255),
}

local Fonts = {
    Regular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
    Semibold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
    Bold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
}

local Library = {
    Version = "2.0.0",
    Theme = Theme,
    Flags = {},
    Setters = {},
    Connections = {},
    Windows = {},
    ThemeBindings = {},
    ThemeListeners = {},
    _flagIndex = 0,
}
Library.__index = Library

local function create(className, properties)
    local object = Instance.new(className)
    local parent = properties.Parent

    if object:IsA("GuiObject") then
        object.BorderSizePixel = 0
    end

    for property, value in properties do
        if property ~= "Parent" then
            object[property] = value
        end
    end

    if parent then
        object.Parent = parent
    end

    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius or 8),
    })
end

local function stroke(parent, color, transparency, thickness)
    return create("UIStroke", {
        Parent = parent,
        Color = color or Theme.Border,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function resolveImage(assetId, localPath)
    local cAsset = getcustomasset or getsynasset

    local function fetchAndCache(url, filename)
        if not isfolder or not writefile or not isfile or not cAsset then return url end
        if not isfolder("TRustMenu") then pcall(makefolder, "TRustMenu") end
        if not isfolder("TRustMenu/assets") then pcall(makefolder, "TRustMenu/assets") end

        local cleanName = filename or ("asset_" .. string.gsub(url, "%W", ""):sub(-12) .. ".png")
        if not string.find(cleanName, "%.") then cleanName = cleanName .. ".png" end
        local filePath = "TRustMenu/assets/" .. cleanName

        if not isfile(filePath) then
            local content = nil
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            if req then
                local ok, res = pcall(req, {Url = url, Method = "GET"})
                if ok and type(res) == "table" and res.Body then content = res.Body end
            end
            if not content and game.HttpGet then
                local ok, res = pcall(function() return game:HttpGet(url) end)
                if ok and res then content = res end
            end

            if content and content ~= "" then
                pcall(writefile, filePath, content)
            end
        end

        if isfile(filePath) then
            local ok, asset = pcall(cAsset, filePath)
            if ok and asset then return asset end
        end

        return url
    end

    if localPath and type(localPath) == "string" and localPath ~= "" then
        local fileName = localPath:match("([^/]+)$") or localPath
        if isfile and isfile(localPath) and cAsset then
            local ok, asset = pcall(cAsset, localPath)
            if ok and asset then return asset end
        elseif isfile and isfile("TRustMenu/assets/" .. fileName) and cAsset then
            local ok, asset = pcall(cAsset, "TRustMenu/assets/" .. fileName)
            if ok and asset then return asset end
        end

        local rawUrl = "https://raw.githubusercontent.com/nadmksa123456-lgtm/TRust_Menu/main/assets/" .. fileName
        local result = fetchAndCache(rawUrl, fileName)
        if result and result ~= rawUrl then return result end
    end

    if not assetId or assetId == "" then return "" end

    if type(assetId) == "number" or tonumber(assetId) then
        return "rbxassetid://" .. tostring(assetId)
    end

    if type(assetId) == "string" then
        if string.find(assetId, "rbxassetid://") or string.find(assetId, "rbxasset://") then
            return assetId
        end

        if string.find(assetId, "http://") or string.find(assetId, "https://") then
            local fileName = assetId:match("([^/]+)$") or "web_asset.png"
            return fetchAndCache(assetId, fileName)
        end
    end

    return assetId
end

-- TRust Menu Standalone & Reusable Engine Wrapper
local TRustMenu = {}

function TRustMenu:CreateWindow(options)
    options = options or {}
    
    local guiParent = getGuiParent()
    if guiParent:FindFirstChild("TRust_Standalone_UI") then
        guiParent:FindFirstChild("TRust_Standalone_UI"):Destroy()
    end

    local ScreenGui = create("ScreenGui", {
        Name = "TRust_Standalone_UI",
        Parent = guiParent,
        ResetOnSpawn = false
    })

    local Title = options.Title or options.Name or "TRust Menu v2.0"
    local DefaultEagleLogo = "https://raw.githubusercontent.com/nadmksa123456-lgtm/TRust_Menu/main/assets/0.png"
    local LogoUrl = options.Logo or options.LogoUrl or DefaultEagleLogo
    local ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl

    local MainFrame = create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 580, 0, 390),
        Position = UDim2.new(0.5, -290, 0.5, -195),
        BackgroundColor3 = rgb(20, 20, 26),
        Active = true,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    corner(MainFrame, 8)
    stroke(MainFrame, rgb(40, 40, 50), 0, 1)

    -- Control Window Visibility
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    local Sidebar = create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 165, 1, 0),
        BackgroundColor3 = rgb(14, 14, 18),
        Parent = MainFrame
    })

    local Header = create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        Parent = Sidebar
    })

    if LogoUrl ~= "" then
        create("ImageLabel", {
            Name = "Logo",
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, 12, 0, 15),
            BackgroundTransparency = 1,
            Image = resolveImage(LogoUrl, "0.png"),
            Parent = Header
        })
    end

    create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -55, 1, 0),
        Position = UDim2.new(0, 50, 0, 0),
        Text = Title,
        TextColor3 = rgb(255, 255, 255),
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = Header
    })

    local TabHolder = create("ScrollingFrame", {
        Name = "TabHolder",
        Size = UDim2.new(1, 0, 1, -65),
        Position = UDim2.new(0, 0, 0, 65),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = Sidebar
    })

    local TabLayout = create("UIListLayout", {
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabHolder
    })

    local ContentArea = create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -175, 1, -20),
        Position = UDim2.new(0, 170, 0, 10),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    local WindowObj = { Tabs = {} }

    function WindowObj:CreateTab(tabName, iconUrl)
        local TabBtn = create("TextButton", {
            Name = tabName .. "_Btn",
            Size = UDim2.new(0, 145, 0, 35),
            BackgroundColor3 = rgb(24, 24, 30),
            Text = "   " .. tabName,
            TextColor3 = rgb(160, 160, 170),
            Font = Enum.Font.SourceSansSemibold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabHolder
        })
        corner(TabBtn, 5)

        local TabPage = create("ScrollingFrame", {
            Name = tabName .. "_Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 3,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = ContentArea
        })

        create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabPage
        })

        local function Select()
            for _, tab in ipairs(WindowObj.Tabs) do
                tab.Page.Visible = false
                tab.Button.BackgroundColor3 = rgb(24, 24, 30)
                tab.Button.TextColor3 = rgb(160, 160, 170)
            end
            TabPage.Visible = true
            TabBtn.BackgroundColor3 = rgb(0, 122, 255)
            TabBtn.TextColor3 = rgb(255, 255, 255)
        end

        TabBtn.MouseButton1Click:Connect(Select)

        if #WindowObj.Tabs == 0 then
            Select()
        end

        local TabObj = { Page = TabPage, Button = TabBtn }

        function TabObj:CreateSection(titleText)
            local SecFrame = create("Frame", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent = TabPage
            })

            create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                Text = titleText,
                TextColor3 = rgb(0, 160, 255),
                Font = Enum.Font.SourceSansBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = SecFrame
            })
        end

        function TabObj:CreateButton(btnText, callback)
            callback = callback or function() end
            local Btn = create("TextButton", {
                Size = UDim2.new(1, -5, 0, 34),
                BackgroundColor3 = rgb(28, 28, 36),
                Text = btnText,
                TextColor3 = rgb(240, 240, 245),
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                Parent = TabPage
            })
            corner(Btn, 5)

            Btn.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end

        function TabObj:CreateToggle(toggleText, defaultState, callback)
            callback = callback or function() end
            local state = defaultState or false

            local TogFrame = create("Frame", {
                Size = UDim2.new(1, -5, 0, 34),
                BackgroundColor3 = rgb(28, 28, 36),
                Parent = TabPage
            })
            corner(TogFrame, 5)

            create("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                Text = toggleText,
                TextColor3 = rgb(240, 240, 245),
                Font = Enum.Font.SourceSans,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = TogFrame
            })

            local Switch = create("TextButton", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundColor3 = state and rgb(0, 200, 100) or rgb(60, 60, 70),
                Text = "",
                Parent = TogFrame
            })
            corner(Switch, 4)

            Switch.MouseButton1Click:Connect(function()
                state = not state
                Switch.BackgroundColor3 = state and rgb(0, 200, 100) or rgb(60, 60, 70)
                pcall(callback, state)
            end)
        end

        table.insert(WindowObj.Tabs, TabObj)
        return TabObj
    end

    return WindowObj
end

getgenv().TRustMenu = TRustMenu
return TRustMenu
