local TRustMenu = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/TRust-Menu/main/source.lua"))()


-- إنشاء النافذة الرئيسية مع دعم الشعار الحقيقي عبر Raw GitHub

local Window = TRustMenu:CreateWindow({

    Title = "TRust Menu v2.0",

    LogoUrl = "https://raw.githubusercontent.com/YourUsername/TRust-Menu/main/assets/0.png", -- رابط شعارك المباشر

    LogoFile = "logo_main.png", -- سيتم حفظ الشعار بهذا الاسم محلياً

    ToggleKey = Enum.KeyCode.RightControl -- زر إخفاء وإظهار المنيو

})


-- ============================================

-- القسم الأول: التعديلات العامة (Main Tab)

-- ============================================

local MainTab = Window:CreateTab("الرئيسية")


MainTab:CreateSection("--- إعدادات الشخصية ---")


-- إضافة زر (Button)

MainTab:CreateButton("تنسيط السرعة (Speed Boost)", function()

    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50

    print("تم تفعيل السرعة!")

end)


-- إضافة مفتاح تشغيل/إيقاف (Toggle)

MainTab:CreateToggle("قفز لا نهائي (Infinite Jump)", false, function(Value)

    _G.InfJump = Value

    game:GetService("UserInputService").JumpRequest:Connect(function()

        if _G.InfJump then

            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")

        end

    end)

end)


-- ============================================

-- القسم الثاني: السكربتات المخصصة (Scripts Tab)

-- ============================================

local ScriptsTab = Window:CreateTab("السكربتات")


ScriptsTab:CreateSection("--- أدوات مساعدة ---")


ScriptsTab:CreateButton("إعادة ريسبون (Reset Character)", function()

    game.Players.LocalPlayer.Character.Humanoid.Health = 0

end)


print("تم تحميل TRust-Menu بنجاح!") --[[
