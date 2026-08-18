local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")
local LocalPlayer = Players.LocalPlayer

-- Konfigürasyon
local START_COORDS  = Vector3.new(43, 4, 1243)
local MID_COORDS    = Vector3.new(1766, 2, 1245)
local TARGET_COORDS = Vector3.new(1768, 14, 1222)

local AUTO_WIN_DELAY = 2
local AUTO_FARM_DELAY = 2
local SET_WALK_SPEED = 150

local SystemActive = false
local AutoRebirthActive = true
local AutoUpgradeActive = true
local CurrentMode = "AutoFarm"

-- ==========================================
-- DİL SİSTEMİ (LOCALIZATION DICTIONARY)
-- ==========================================
local Translations = {
    ["en"] = {
        title = "⚡ Global Auto Hub",
        sys_on = "SYSTEM: ENABLED",
        sys_off = "SYSTEM: DISABLED",
        mode_farm = "Mode: Auto Farm (3-Point Walk)",
        mode_win = "Mode: Auto Win (Teleport)",
        rebirth_on = "Auto Rebirth: ON",
        rebirth_off = "Auto Rebirth: OFF",
        upgrade_on = "Auto Upgrade: ON",
        upgrade_off = "Auto Upgrade: OFF",
        info = "Press [K] to Hide/Show Menu",
        lang_btn = "🌐 Lang: English"
    },
    ["tr"] = {
        title = "⚡ Global Auto Hub",
        sys_on = "SİSTEM: AÇIK",
        sys_off = "SİSTEM: KAPALI",
        mode_farm = "Mod: Auto Farm (3 Nokta Yürü)",
        mode_win = "Mod: Auto Win (Işınlan)",
        rebirth_on = "Auto Rebirth: AÇIK",
        rebirth_off = "Auto Rebirth: KAPALI",
        upgrade_on = "Auto Upgrade: AÇIK",
        upgrade_off = "Auto Upgrade: KAPALI",
        info = "[K] Tuşu ile Menüyü Gizle/Aç",
        lang_btn = "🌐 Dil: Türkçe"
    },
    ["es"] = {
        title = "⚡ Global Auto Hub",
        sys_on = "SISTEMA: ACTIVADO",
        sys_off = "SISTEMA: DESACTIVADO",
        mode_farm = "Modo: Auto Farm (Caminar)",
        mode_win = "Modo: Auto Win (Teletransporte)",
        rebirth_on = "Auto Rebirth: SÍ",
        rebirth_off = "Auto Rebirth: NO",
        upgrade_on = "Auto Mejora: SÍ",
        upgrade_off = "Auto Mejora: NO",
        info = "Presiona [K] para Ocultar/Mostrar",
        lang_btn = "🌐 Idioma: Español"
    },
    ["pt"] = {
        title = "⚡ Global Auto Hub",
        sys_on = "SISTEMA: ATIVADO",
        sys_off = "SISTEMA: DESATIVADO",
        mode_farm = "Modo: Auto Farm (Caminhar)",
        mode_win = "Modo: Auto Win (Teleporte)",
        rebirth_on = "Auto Rebirth: LIGADO",
        rebirth_off = "Auto Rebirth: DESLIGADO",
        upgrade_on = "Auto Upgrade: LIGADO",
        upgrade_off = "Auto Upgrade: DESLIGADO",
        info = "Pressione [K] para Ocultar/Mostrar",
        lang_btn = "🌐 Idioma: Português"
    },
    ["ru"] = {
        title = "⚡ Global Auto Hub",
        sys_on = "СИСТЕМА: ВКЛ",
        sys_off = "СИСТЕМА: ВЫКЛ",
        mode_farm = "Режим: Авто Фарм (Ходьба)",
        mode_win = "Режим: Авто Победа (ТП)",
        rebirth_on = "Авто Перерождение: ВКЛ",
        rebirth_off = "Авто Перерождение: ВЫКЛ",
        upgrade_on = "Авто Улучшение: ВКЛ",
        upgrade_off = "Авто Улучшение: ВЫКЛ",
        info = "Нажмите [K] Скрыть/Показать",
        lang_btn = "🌐 Язык: Русский"
    },
    ["de"] = {
        title = "⚡ Global Auto Hub",
        sys_on = "SYSTEM: AN",
        sys_off = "SYSTEM: AUS",
        mode_farm = "Modus: Auto Farm (Laufen)",
        mode_win = "Modus: Auto Win (Teleport)",
        rebirth_on = "Auto Rebirth: AN",
        rebirth_off = "Auto Rebirth: AUS",
        upgrade_on = "Auto Upgrade: AN",
        upgrade_off = "Auto Upgrade: AUS",
        info = "[K] Taste drücken zum Ein-/Ausblenden",
        lang_btn = "🌐 Sprache: Deutsch"
    },
    ["fr"] = {
        title = "⚡ Global Auto Hub",
        sys_on = "SYSTÈME: ACTIVÉ",
        sys_off = "SYSTÈME: DÉSACTIVÉ",
        mode_farm = "Mode: Auto Farm (Marcher)",
        mode_win = "Mode: Auto Win (Téléport)",
        rebirth_on = "Auto Rebirth: ACTIVÉ",
        rebirth_off = "Auto Rebirth: DÉSACTIVÉ",
        upgrade_on = "Auto Upgrade: ACTIVÉ",
        upgrade_off = "Auto Upgrade: DÉSACTIVÉ",
        info = "Appuyez sur [K] pour Masquer/Afficher",
        lang_btn = "🌐 Langue: Français"
    },
    ["ar"] = {
        title = "⚡ Global Auto Hub",
        sys_on = "النظام: مفعل",
        sys_off = "النظام: معطل",
        mode_farm = "الوضع: تجميع تلقائي (مشي)",
        mode_win = "الوضع: فوز تلقائي (انتقال)",
        rebirth_on = "إعادة التوليد: مفعل",
        rebirth_off = "إعادة التوليد: معطل",
        upgrade_on = "ترقية تلقائية: مفعل",
        upgrade_off = "ترقية تلقائية: معطل",
        info = "اضغط [K] لإخفاء/إظهار القائمة",
        lang_btn = "🌐 اللغة: العربية"
    }
}

local AvailableLangs = {"en", "tr", "es", "pt", "ru", "de", "fr", "ar"}
local currentLangIndex = 1

-- Oyuncunun Roblox Sistem Dilini Otomatik Bulma
local function DetectLanguage()
    local locale = string.sub(string.lower(LocalizationService.RobloxLocaleId), 1, 2)
    for index, code in ipairs(AvailableLangs) do
        if code == locale then
            currentLangIndex = index
            return
        end
    end
    currentLangIndex = 1 -- Eşleşmezse varsayılan İngilizce
end
DetectLanguage()

local function T(key)
    local langCode = AvailableLangs[currentLangIndex]
    return (Translations[langCode] and Translations[langCode][key]) or Translations["en"][key] or ""
end

-- ==========================================
-- GUI OLUŞTURMA
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GlobalAutoHub"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 290)
MainFrame.Position = UDim2.new(0.5, -125, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Başlık
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
Title.Text = T("title")
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Buton Oluşturma Yardımcısı
local function CreateButton(posPercent, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.88, 0, 0, 30)
    btn.Position = UDim2.new(0.06, 0, posPercent, 0)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

local ToggleBtn  = CreateButton(0.15, Color3.fromRGB(180, 40, 40))
local ModeBtn    = CreateButton(0.28, Color3.fromRGB(45, 45, 60))
local RebirthBtn = CreateButton(0.41, Color3.fromRGB(40, 150, 80))
local UpgradeBtn = CreateButton(0.54, Color3.fromRGB(40, 120, 180))
local LangBtn    = CreateButton(0.67, Color3.fromRGB(70, 70, 85))

local KeyInfo = Instance.new("TextLabel")
KeyInfo.Size = UDim2.new(1, 0, 0, 25)
KeyInfo.Position = UDim2.new(0, 0, 0.88, 0)
KeyInfo.BackgroundTransparency = 1
KeyInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
KeyInfo.TextSize = 11
KeyInfo.Font = Enum.Font.SourceSansItalic
KeyInfo.Parent = MainFrame

-- GUI Metinlerini Güncelleme Fonksiyonu
local function UpdateUITexts()
    Title.Text = T("title")
    ToggleBtn.Text = SystemActive and T("sys_on") or T("sys_off")
    ModeBtn.Text = (CurrentMode == "AutoFarm") and T("mode_farm") or T("mode_win")
    RebirthBtn.Text = AutoRebirthActive and T("rebirth_on") or T("rebirth_off")
    UpgradeBtn.Text = AutoUpgradeActive and T("upgrade_on") or T("upgrade_off")
    LangBtn.Text = T("lang_btn")
    KeyInfo.Text = T("info")
end
UpdateUITexts()

-- Dil Değiştirme Butonu Dinleyicisi
LangBtn.MouseButton1Click:Connect(function()
    currentLangIndex = (currentLangIndex % #AvailableLangs) + 1
    UpdateUITexts()
end)

-- ==========================================
-- HAREKET & YETENEK FONKSİYONLARI
-- ==========================================
RunService.Stepped:Connect(function()
    if SystemActive then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = SET_WALK_SPEED
            end
        end
    end
end)

local function TriggerRebirth()
    if not AutoRebirthActive then return end
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes and remotes:FindFirstChild("Rebirth") then
            remotes.Rebirth:InvokeServer()
        end
    end)
end

local function TriggerUpgrades()
    if not AutoUpgradeActive then return end
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            if remotes:FindFirstChild("UpgradeSpeed") then remotes.UpgradeSpeed:InvokeServer() end
            if remotes:FindFirstChild("LevelUp") then remotes.LevelUp:FireServer() end
        end
    end)
end

local currentTween = nil
local function StopTween()
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
end

local function WalkToPosition(targetPos, speed)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp then return end

    if humanoid then humanoid.WalkSpeed = speed end
    local distance = (hrp.Position - targetPos).Magnitude
    if distance < 2 then return end

    local duration = distance / speed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)

    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    currentTween:Play()
    currentTween.Completed:Wait()
end

local function AutoFarmWalk()
    WalkToPosition(START_COORDS, SET_WALK_SPEED)
    WalkToPosition(MID_COORDS, SET_WALK_SPEED)
    WalkToPosition(TARGET_COORDS, SET_WALK_SPEED)
end

local function AutoWinTeleport()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(TARGET_COORDS) end
end

-- ==========================================
-- BUTON ETKİLEŞİMLERİ
-- ==========================================
ToggleBtn.MouseButton1Click:Connect(function()
    SystemActive = not SystemActive
    if SystemActive then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        StopTween()
    end
    UpdateUITexts()
end)

ModeBtn.MouseButton1Click:Connect(function()
    StopTween()
    CurrentMode = (CurrentMode == "AutoFarm") and "AutoWin" or "AutoFarm"
    UpdateUITexts()
end)

RebirthBtn.MouseButton1Click:Connect(function()
    AutoRebirthActive = not AutoRebirthActive
    RebirthBtn.BackgroundColor3 = AutoRebirthActive and Color3.fromRGB(40, 150, 80) or Color3.fromRGB(180, 50, 50)
    UpdateUITexts()
end)

UpgradeBtn.MouseButton1Click:Connect(function()
    AutoUpgradeActive = not AutoUpgradeActive
    UpgradeBtn.BackgroundColor3 = AutoUpgradeActive and Color3.fromRGB(40, 120, 180) or Color3.fromRGB(180, 50, 50)
    UpdateUITexts()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.K then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Ana Döngü
task.spawn(function()
    while true do
        if SystemActive then
            if CurrentMode == "AutoFarm" then
                AutoFarmWalk()
                TriggerUpgrades()
                TriggerRebirth()
                task.wait(AUTO_FARM_DELAY)
            elseif CurrentMode == "AutoWin" then
                AutoWinTeleport()
                TriggerUpgrades()
                TriggerRebirth()
                task.wait(AUTO_WIN_DELAY)
            end
        else
            task.wait(0.3)
        end
    end
end)