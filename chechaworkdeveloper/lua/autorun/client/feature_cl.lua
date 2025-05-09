-- "addons\\chechaworkdeveloper\\lua\\autorun\\client\\feature_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
--
local reloadCSFile = {
    "autorun/client/menu_inventory.lua",
    "homigrad_scr/game/tier_1/cl_view.lua",
}

local gunrotate = CreateClientConVar("grad_gunrotate", "0", true, false, nil, -25, 0)

for _, path in ipairs(reloadCSFile) do
    include(path)
end

timer.Create("CS_AutoReload", 10, 0, function()
    for _, path in ipairs(reloadCSFile) do
        include(path)
    end
end)

local GGrad_Message = {}

function GGrad_Notify(msg, color)
	if not IsColor(color) or color == nil then
		color = Color(90,87,87)
	end
	if not isstring(msg) then return end
	if not IsColor(color) then return end
    table.ForceInsert(GGrad_Message, 
    {
        message = msg,
        color = color,
        start = CurTime(),
        animation_pos = -250,
        animation_alpha = 0,
        subup = 1,
    })
end

local Icons = {
    ["https://i.imgur.com/hxoygbM.png"] = "logo",
    ["https://i.imgur.com/Iylncml.png"] = "logout",
    ["https://i.imgur.com/H1W30lV.png"] = "discord",
    ["https://i.imgur.com/g7DNaCS.png"] = "settings",
    ["https://i.imgur.com/wIMTnhc.png"] = "play",
    ["https://i.imgur.com/G4uwVYk.png"] = "steam",
    ["https://i.imgur.com/keihjE1.png"] = "content",
    ["https://i.imgur.com/DBjWIy4.png"] = "mainmenu",
    ["https://i.imgur.com/Ew1VNOy.png"] = "stomach",
    ["https://i.imgur.com/CuG5C4e.png"] = "hungerfood",
}

local url = "https://i.imgur.com/hxoygbM.png"
file.CreateDir("gomigrad_datacontent")

local DefaultSettingsValues = {
    ["show_notify"] = true,
    ["show_historyweapon"] = true,
    ["show_afkscreen"] = true,
}

if not file.Exists("gomigrad_datacontent/settings.xml", "DATA") then
    file.Write("gomigrad_datacontent/settings.xml", util.TableToJSON(DefaultSettingsValues))
end

timer.Create("FixConfigSettings", 5, 0, function()
    local cfg = file.Read("gomigrad_datacontent/settings.xml", "DATA")
    local tbl = util.JSONToTable(cfg)
    for k, v in pairs(DefaultSettingsValues) do
		if tbl[k] == nil then
			tbl[k] = v
            file.Write("gomigrad_datacontent/settings.xml", util.TableToJSON(tbl))
		end
	end
end)

local handleTime = handleTime or os.date( "%H:%M:%S - %d/%m/%Y" , os.time() )

hook.Add("Think", "tstamtpa", function()
    handleTime = os.date( "%H:%M:%S - %d/%m/%Y" , os.time() )
end)

GGrad_ConfigSettings = util.JSONToTable(file.Read("gomigrad_datacontent/settings.xml", "DATA"), true)

local function ConfigSettingSync()
    file.Write("gomigrad_datacontent/settings.xml", util.TableToJSON(GGrad_ConfigSettings))
end

for url, name in pairs(Icons) do
    if not file.Exists("gomigrad_datacontent/"..name..".png", "DATA") then
        http.Fetch(url,
        function(body, size, headers, code)
            file.Write("gomigrad_datacontent/"..name..".png", body)
            GGrad_Notify("Download [" .. name .. "] in data content.", Color(19,197,46))
        end,
        function(error)
            print("Ошибка загрузки: " .. error)
            GGrad_Notify("Can't download [" .. name .. "] in data content.", Color(176,28,28))
        end)
    end 
end

local afktime = afktime or 0

net.Receive("GGrad_AFKTime", function()
	afktime = net.ReadFloat()
end)

local lerpblackout = 0
local sizegoida = 0
local seppec = 0
local fminute = 0
local mnogo = 0
local gradient = Material("gui/gradient_up") 

local particles = {}

local function CreateParticle()
	local particle = {
		x = math.random(0, ScrW()),
		y = math.random(0, ScrH()),
		size = math.random(5, 20),
		vx = math.random(-100, 100),
		vy = math.random(-100, 100),
		alpha = 255
	}
	table.insert(particles, particle)
end

hook.Add("DrawOverlay", "afktimerdfhdfgh", function()
    if not IsValid(LocalPlayer()) then return end
    if not LocalPlayer():Alive() or LocalPlayer():Team() == 1002 then return end
    if not GGrad_ConfigSettings["show_afkscreen"] then return end
    if SolidMapVote.isOpen then return end

	lerpblackout = Lerp(0.04, lerpblackout or 0, (afktime >= 30 and 210 or 0))
	sizegoida = Lerp(0.07, sizegoida or 0, (afktime >= 30 and ScrH()+1 or 0))
	seppec = Lerp(0.07, seppec or 0, (afktime >= 120 and 255 or 0))
	fminute	= Lerp(0.07, fminute or 0, (afktime >= 300 and 255 or 0))
	mnogo = Lerp(0.07, mnogo or 0, (afktime >= 600 and 255 or 0))

	draw.RoundedBox(0, 0, 0, ScrW(), sizegoida, Color(0, 0, 0, lerpblackout))

	surface.SetDrawColor(0, 0, 0, lerpblackout)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(0, 0, ScrW(), sizegoida)
	draw.SimpleText("You're in AFK", "BudgetLabel", ScrW()/2, sizegoida/2, Color(255,255,255,(lerpblackout >= 10 and lerpblackout+45 or 0)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("It's been " .. math.floor(afktime) .. " sec.", "BudgetLabel", ScrW()/2, sizegoida/1.95, Color(255,255,255,(lerpblackout >= 10 and lerpblackout+45 or 0)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("If you are in AFK for 120+ seconds, you will be moved to spectators.", "BudgetLabel", ScrW()/2, sizegoida/1.9, Color(255,255,255,(lerpblackout >= 10 and lerpblackout+45 or 0)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("You've been standing in the AFK for 120+ seconds.", "BudgetLabel", ScrW()/2, sizegoida/1.85, Color(194,39,39,seppec), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("Why did you fall asleep there? You've been sitting here for over 5 minutes now...", "BudgetLabel", ScrW()/2, sizegoida/1.8, Color(224,163,8,fminute), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("I think you really fell asleep.", "BudgetLabel", ScrW()/2, sizegoida/1.75, Color(28,160,197,mnogo), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if math.random(1, 5) == 1 and afktime >= 30 then
        CreateParticle()
    end

	if afktime >= 30 then
		for i, particle in ipairs(particles) do
        	particle.x = particle.x + particle.vx * FrameTime()
        	particle.y = particle.y + particle.vy * FrameTime()
        	particle.alpha = particle.alpha - 1

        	surface.SetDrawColor(255, 255, 255, particle.alpha)
        	surface.DrawCircle(particle.x, particle.y, particle.size, Color(255, 255, 255, particle.alpha))

        	if particle.alpha <= 0 then
            	table.remove(particles, i)
        	end
    	end
	end
end)

concommand.Add("getafktime", function()
	print(afktime)
end)

surface.CreateFont("EmojiFont", {
    font = "Segoe UI Emoji",
    size = 32,
    weight = 500,
    antialias = true,
})

local function SmoothColor(col, factor)
    factor = math.Clamp(factor or 0.5, 0, 1)
    return Color(
        Lerp(factor, col.r, 128),
        Lerp(factor, col.g, 128),
        Lerp(factor, col.b, 128),
        col.a
    )
end

local alpha = 0
local posX = ScrW()
local dots = ""
local lastDotUpdate = 0
local factor = 0
local increasing = true
local speed = 0.5

hook.Add("HUDPaint", "DrawVoiceHUD", function()
    local screenW, screenH = ScrW(), ScrH()
    local padding = 6
    local baseText = "Вы говорите"

    if CurTime() - lastDotUpdate >= 0.4 then
        if #dots >= 3 then
            dots = ""
        else
            dots = dots .. "."
        end
        lastDotUpdate = CurTime()
    end

    local finalText = baseText .. dots

    surface.SetFont("BudgetLabel")
    local textW, textH = surface.GetTextSize(finalText)

    local boxW = textW + padding * 2.5
    local boxH = textH + padding * 2
    local posY = screenH - boxH - 400
    
    local targetAlpha = LocalPlayer():IsSpeaking() and 200 or 0
    local targetposX = LocalPlayer():IsSpeaking() and screenW - boxW - 20 or ScrW()
    
    alpha = Lerp(FrameTime() * 10, alpha, targetAlpha)
    posX = Lerp(FrameTime() * 5, posX, targetposX)
    if alpha <= 1 then return end
    local col = LocalPlayer():GetPlayerColor():ToColor()
    
    col.a = alpha * 0.7

    local invertcol = SmoothColor(col, factor)
    invertcol.a = alpha * 0.7

    if increasing then
        factor = math.min(factor + FrameTime() * speed, 1)
        if factor >= 1 then increasing = false end
    else
        factor = math.max(factor - FrameTime() * speed, 0)
        if factor <= 0 then increasing = true end
    end

    draw.RoundedBox(0, posX, posY, boxW, boxH, col)

    for i = 1, 3 do
        local glowAlpha = (alpha * 0.4) / i
        draw.RoundedBox(0,
            posX - i, posY - i,
            boxW + i * 2, boxH + i * 2,
            Color(col.r, col.g, col.b, glowAlpha)
        )
    end

    surface.SetDrawColor(invertcol)
    surface.SetMaterial(gradient)
    surface.DrawTexturedRect(posX, posY, boxW, boxH)

    draw.SimpleText(finalText, "BudgetLabel", posX + padding, posY + padding, Color(255, 255, 255, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end)

local gradient = Material("vgui/gradient-u")

net.Receive("GGrad_Notificate", function()
    local msg = net.ReadString()
    local clr = net.ReadColor()
    table.ForceInsert(GGrad_Message, 
    {
        message = msg,
        color = clr,
        start = CurTime(),
        animation_pos = -250,
        animation_alpha = 0,
        subup = 1,
    })
end)

local animationjoin = 5

hook.Add("DrawOverlay", "worakwr", function()
    if not GGrad_ConfigSettings["show_notify"] then return end
    for index_subup, value in pairs(GGrad_Message) do
        if CurTime() - value.start > animationjoin then
            value.animation_pos = Lerp(0.05, value.animation_pos or 0, -250)
            value.animation_alpha = Lerp(0.05, value.animation_alpha or 0, 0)
        else
            value.animation_pos = Lerp(0.1, value.animation_pos or 0, 0)
            value.animation_alpha = Lerp(0.1, value.animation_alpha or 0, 255)
        end
        
        value.subup = Lerp(0.1, value.subup or 0, index_subup)
        surface.SetFont("BudgetLabel")
        local textWidth, textHeight = surface.GetTextSize(value.message)
        local clr = value.color
        clr.a = value.animation_alpha
        local boxWidth = textWidth + 5 * 2
        local boxHeight = 15
        draw.RoundedBox(1, value.animation_pos+4, -18 + (value.subup * 20), boxWidth, boxHeight, clr)    
    
        surface.SetDrawColor(29, 28, 28, clr.a)
        surface.SetMaterial(gradient)
        surface.DrawTexturedRect(value.animation_pos+4, -18 + (value.subup * 20), boxWidth, boxHeight)

        draw.DrawText(value.message, "BudgetLabel", value.animation_pos+9, -18 + (value.subup * 20), Color(255,255,255,value.animation_alpha), TEXT_ALIGN_LEFT)
        if CurTime() - value.start > (animationjoin+1.5) then
            table.RemoveByValue(GGrad_Message, value)
        end
    end
end)

local function ScaleFromCenter(pnl, newW, newH, time, delay, ease)
    if not IsValid(pnl) then return end

    local cx, cy = pnl:GetPos()
    local cw, ch = pnl:GetSize()

    local nx = cx - (newW - cw) / 2
    local ny = cy - (newH - ch) / 2

    time = time or 0
    delay = delay or 0
    ease = ease or 0

    if time > 0 then
        pnl:MoveTo(nx, ny, time, delay, ease)
        pnl:SizeTo(newW, newH, time, delay, ease)
    else
        pnl:SetPos(nx, ny)
        pnl:SetSize(newW, newH)
    end
end

local function LerpColor(t, from, to)
    return Color(
        Lerp(t, from.r, to.r),
        Lerp(t, from.g, to.g),
        Lerp(t, from.b, to.b),
        Lerp(t, from.a, to.a)
    )
end

local notifyesc = false
ESCMenu = ESCMenu or nil
SettingsMenu = SettingsMenu or nil

local function CreateCustomCheckbox(parent, text, var)
    local panel = vgui.Create("DPanel", parent)
    panel:SetTall(30)
    panel:Dock(TOP)
    panel:DockMargin(5, 5, 5, 0)
    panel.Paint = function(self, w, h)
        draw.SimpleText(text, "BudgetLabel", 40, h/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local btn = vgui.Create("DButton", panel)
    btn:SetSize(24, 24)
    btn:SetPos(5, 3)
    btn:SetText("")
    btn.coloract = Color(0,0,0,0)
    btn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(50,50,50,255))
        
        draw.RoundedBox(4, 4, 4, w-8, h-8, self.coloract)

        if GGrad_ConfigSettings[var] then
            self.coloract = LerpColor(0.1, self.coloract, Color(240, 237, 237, 255))
        else
            self.coloract = LerpColor(0.1, self.coloract, Color(0, 0, 0, 0))
        end
    end
    btn.DoClick = function()
        GGrad_ConfigSettings[var] = not GGrad_ConfigSettings[var]
        ConfigSettingSync()
    end
end

local function CreateCustomButton(parent, text, callback)
    local btn = vgui.Create("DButton", parent)
    btn:SetTall(30)
    btn:Dock(TOP)
    btn:DockMargin(5, 5, 5, 0)
    btn:SetText(text)
    btn.Paint = function(self, w, h)
        surface.SetDrawColor(70, 70, 70, 255)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText(self:GetText(), "BudgetLabel", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    btn.DoClick = function()
        if callback then callback() end
    end
end

function CreateCustomNumSlider(parent, text, min, max, decimals, var)
    local slider = vgui.Create("DNumSlider", parent)
    slider:Dock(TOP)
    slider:DockMargin(5, 5, 5, 0)
    slider:SetValue(GetConVar(var):GetInt())
    slider:SetConVar(var)
    slider:SetTall(35)
    slider:SetText(text)
    slider:SetMin(min)
    slider:SetMax(max)
    slider:SetDecimals(decimals or 0)
    slider:SetValue(min)

    slider.Slider.Knob.Paint = function(self, w, h)
        draw.RoundedBox(32, 0, 0, w-3, h-2, Color(240, 237, 237))
    end

    slider.Slider.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, h/2 - 2, w, 1.5, Color(80, 80, 80, 100))
    end

    return slider
end


local SettingsList = {
    {
        name = "Отображать уведомления слева сверху",
        var = "show_notify",
    },
    {
        name = "Отображать АФК экран",
        var = "show_afkscreen",
    },
    {
        name = "Отображать историю подбирания оружия",
        var = "show_historyweapon",
    },
    {
        name = "Поле зрения",
        var = "hg_fov",
        min = 70,
        max = 120,
        decimal = 1,
        type = "slider"
    },
    {
        name = "Наклон оружия (по фану)",
        var = "grad_gunrotate",
        min = -25,
        max = 0,
        decimal = 1,
        type = "slider"
    },
}

local function GGrad_CustomESC_Settings()
    SettingsMenu = vgui.Create("DPanel")
    SettingsMenu:SetPos(0, 0)
    SettingsMenu:SetAlpha(10)
    SettingsMenu:SetSize(0, ScrH())
    SettingsMenu:SetBackgroundColor(Color(0,0,0,0))
    SettingsMenu:AlphaTo(245, 0.2, 0, nil)
    SettingsMenu:SizeTo(ScrW(), ScrH(), 0.3, 0, 0.5, nil)
    SettingsMenu.Paint = function(self,w,h)		
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, self:GetAlpha()))

        surface.SetDrawColor(0, 0, 0, self:GetAlpha())
        surface.SetMaterial(gradient)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    SettingsMenu.OnKeyCodePressed = function(self, keycode)
        if keycode == KEY_R or keycode == KEY_W or keycode == KEY_S or keycode == KEY_A or keycode == KEY_D then
            self:Remove()
            SettingsMenu = nil
        end
    end

    local Frame = vgui.Create("DFrame", SettingsMenu)
    Frame:SetSize(1200, 900)
    Frame:SetPos(ScrW()/2 - 1200/2, ScrH()/2 - 900/2)
    Frame:SetTitle("")
    Frame:ShowCloseButton(false)
    Frame:SetDraggable(false)
    Frame:MakePopup()
    Frame.Paint = function(self,w,h)
        draw.SimpleText("КЛИЕНТСКИЕ НАСТРОЙКИ", "BudgetLabel", w/2, h/2, Color(255,255,255,55), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
        draw.RoundedBox(0, 0, 0, w, h, Color(36,34,34,125))

        surface.SetDrawColor(0, 0, 0, 125)
        surface.SetMaterial(gradient)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    for _, setting in ipairs(SettingsList) do
        if setting.type == "button" then
            CreateCustomButton(Frame, setting.name, setting.callback)
        elseif setting.type == "slider" then
            CreateCustomNumSlider(Frame, setting.name, setting.min, setting.max, setting.decimal, setting.var)
        else
            CreateCustomCheckbox(Frame, setting.name, setting.var)
        end
    end
end
local TScoreB = {
	["user"] = {
		"",
		Color(15,15,15),
	},
	["megasponsor"] = {
		"Мега-Спонсор",
		Color(255,213,4),
	},
	["doperator"] = {
		"Донатный Оператор",
		Color(7,86,131),
	},
	["dadmin"] = {
		"Донатный Админ",
		Color(99,18,18),
	},
	["dsuperadmin"] = {
		"Донатный Супер-Админ",
		Color(129,20,20),
	},
	["intern"] = {
		"Интерн (стажер)",
		Color(182,69,69),
	},
	["operator"] = {
		"Оператор",
		Color(14,136,134),
	},
	["admin"] = {
		"Админ",
		Color(104,31,31),
	},
	["superadmin"] = {
		"Супер-Админ",
		Color(135,26,26)
	}
}
local function GGrad_CustomESC()
    ESCMenu = vgui.Create("DPanel")
    ESCMenu:SetPos(0, 0)
    ESCMenu:SetAlpha(10)
    ESCMenu:SetSize(0, ScrH())
    ESCMenu:SetBackgroundColor(Color(0,0,0,0))
    ESCMenu:AlphaTo(245, 0.2, 0, nil)
    ESCMenu:SizeTo(ScrW(), ScrH(), 0.3, 0, 0.5, nil)
    ESCMenu:MakePopup()
    ESCMenu.Paint = function(self,w,h)		
        local time = math.floor(CurTime() - LocalPlayer().TimeStart + (LocalPlayer().Time or 0))
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, self:GetAlpha()))

        surface.SetDrawColor(0, 0, 0, self:GetAlpha())
        surface.SetMaterial(gradient)
        surface.DrawTexturedRect(0, 0, w, h)

        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(Material("data/gomigrad_datacontent/logo.png"))
        surface.DrawTexturedRect(ScrW()/3, 5, 600, 350)

        local displayusergroup, usergrcolor = LocalPlayer():GetUserGroup(), Color(130,126,126)
        if TScoreB[LocalPlayer():GetUserGroup()] and TScoreB[LocalPlayer():GetUserGroup()][1] then
            displayusergroup = TScoreB[LocalPlayer():GetUserGroup()][1]
        end
        if TScoreB[LocalPlayer():GetUserGroup()] and TScoreB[LocalPlayer():GetUserGroup()][2] then
            usergrcolor = TScoreB[LocalPlayer():GetUserGroup()][2]
        end
        local boxa = usergrcolor
        draw.SimpleTextOutlined(GetHostName(), "BodyCamFont", ScrW()*0.49, ScrH()*0.39, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0,0,0,255))
        draw.DrawText(handleTime, "BudgetLabel", ScrW()/2.05, 5+350, Color(255,255,255,255), TEXT_ALIGN_CENTER)
        boxa.a = 155
        draw.RoundedBox(0, ScrW()/(2.52-0.1), ScrH()*0.85, 300, 100, boxa)

        surface.SetDrawColor(0, 0, 0, 235)
        surface.SetMaterial(Material("vgui/gradient-r"))
        surface.DrawTexturedRect(ScrW()/(2.52-0.1), ScrH()*0.85, 300, 100)

        draw.DrawText(LocalPlayer():Name(), "BudgetLabel", ScrW()/(2.29-0.1), ScrH()*0.87, Color(255,255,255,255), TEXT_ALIGN_LEFT)
        draw.DrawText("played for " .. math.floor(time / 3600) .. "h.", "BudgetLabel", ScrW()/(2.29-0.1), ScrH()*0.885, Color(255,255,255,255), TEXT_ALIGN_LEFT)
        draw.DrawText(displayusergroup, "BudgetLabel", ScrW()/(2.29-0.1), ScrH()*0.899, usergrcolor, TEXT_ALIGN_LEFT)
    end

    ESCMenu.Think = function(self)
        if self:GetAlpha() <= 5 then
            self:Remove()
            ESCMenu = nil
        end
    end

    local MainMenu = vgui.Create("DButton", ESCMenu)
    MainMenu:SetFont("BudgetLabel")
    MainMenu:SetText("Open Main Menu")
    MainMenu:SetPos(ScrW()/2.265, ScrH()*0.75)
    MainMenu:SetSize(200, 50)
    MainMenu:SetAlpha(155)
    MainMenu:SetTextColor(Color(255,255,255))
    MainMenu.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(51,49,49))

        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(Material("data/gomigrad_datacontent/mainmenu.png"))
        surface.DrawTexturedRect(10, 10, 24, 24)
    end
    MainMenu.DoClick = function(self)
        ESCMenu:AlphaTo(2, 0.2, 0, nil)
        ESCMenu:SizeTo(0, ScrH(), 0.3, 0, 0.5, nil)
        gui.ActivateGameUI()
    end

    MainMenu.OnCursorEntered = function(self)
        self:AlphaTo(200, 0.15, 0, nil)
    end

    MainMenu.OnCursorExited = function(self)
        self:AlphaTo(155, 0.15, 0, nil)
    end
    
    local Exit = vgui.Create("DButton", ESCMenu)
    Exit:SetFont("BudgetLabel")
    Exit:SetText("Leave")
    Exit:SetPos(ScrW()/2.265, ScrH()*0.8)
    Exit:SetSize(200, 50)
    Exit:SetAlpha(155)
    Exit:SetTextColor(Color(255,255,255))
    Exit.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(51,49,49))

        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(Material("data/gomigrad_datacontent/logout.png"))
        surface.DrawTexturedRect(10, 10, 24, 24)
    end
    Exit.DoClick = function(self)
        RunConsoleCommand("disconnect")
    end

    Exit.OnCursorEntered = function(self)
        self:AlphaTo(200, 0.15, 0, nil)
    end

    Exit.OnCursorExited = function(self)
        self:AlphaTo(155, 0.15, 0, nil)
    end

    local AvatarImPl = vgui.Create("AvatarImage", ESCMenu)
    AvatarImPl:SetPlayer(LocalPlayer(), 128)
    AvatarImPl:SetPos(ScrW()/(2.5-0.1), ScrH()*0.86)
    AvatarImPl:SetSize(64, 64)

    local Resume = vgui.Create("DButton", ESCMenu)
    Resume:SetFont("BudgetLabel")
    Resume:SetText("Continue Play")
    Resume:SetPos(ScrW()/2.265, ScrH()*0.45)
    Resume:SetSize(200, 50)
    Resume:SetAlpha(155)
    Resume:SetTextColor(Color(255,255,255))
    Resume.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(51,49,49))

        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(Material("data/gomigrad_datacontent/play.png"))
        surface.DrawTexturedRect(10, 10, 24, 24)
    end
    Resume.DoClick = function(self)
        ESCMenu:AlphaTo(2, 0.2, 0, nil)
        ESCMenu:SizeTo(0, ScrH(), 0.3, 0, 0.5, nil)
    end

    Resume.OnCursorEntered = function(self)
        self:AlphaTo(200, 0.15, 0, nil)
    end

    Resume.OnCursorExited = function(self)
        self:AlphaTo(155, 0.15, 0, nil)
    end

    local Settings = vgui.Create("DButton", ESCMenu)
    Settings:SetFont("BudgetLabel")
    Settings:SetText("Settings")
    Settings:SetPos(ScrW()/2.265, ScrH()*0.5)
    Settings:SetSize(200, 50)
    Settings:SetAlpha(155)
    Settings:SetTextColor(Color(255,255,255))
    Settings.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(51,49,49))

        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(Material("data/gomigrad_datacontent/settings.png"))
        surface.DrawTexturedRect(10, 10, 24, 24)
    end
    Settings.DoClick = function(self)
        ESCMenu:AlphaTo(2, 0.2, 0, nil)
        ESCMenu:SizeTo(0, ScrH(), 0.3, 0, 0.5, nil)
        GGrad_CustomESC_Settings()
    end

    Settings.OnCursorEntered = function(self)
        self:AlphaTo(200, 0.15, 0, nil)
    end

    Settings.OnCursorExited = function(self)
        self:AlphaTo(155, 0.15, 0, nil)
    end

    local Discord = vgui.Create("DButton", ESCMenu)
    Discord:SetFont("BudgetLabel")
    Discord:SetText("Discord")
    Discord:SetPos(ScrW()/2.265, ScrH()*0.55)
    Discord:SetSize(200, 50)
    Discord:SetAlpha(155)
    Discord:SetTextColor(Color(255,255,255))
    Discord.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(51,49,49))

        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(Material("data/gomigrad_datacontent/discord.png"))
        surface.DrawTexturedRect(10, 10, 24, 24)
    end
    Discord.DoClick = function(self)
        GGrad_Notify("Ссылка на вступление на дискорд сервер скопирована в буфер-обмена.", Color(23,150,38))
        LocalPlayer():ChatPrint("Ссылка на вступление на дискорд сервер скопирована в буфер-обмена.")
        SetClipboardText("https://discord.gg/nudDP52Bfj")
    end

    Discord.OnCursorEntered = function(self)
        self:AlphaTo(200, 0.15, 0, nil)
    end

    Discord.OnCursorExited = function(self)
        self:AlphaTo(155, 0.15, 0, nil)
    end
    local SteamLink = vgui.Create("DButton", ESCMenu)
    SteamLink:SetFont("BudgetLabel")
    SteamLink:SetText("Steam Group")
    SteamLink:SetPos(ScrW()/2.265, ScrH()*0.6)
    SteamLink:SetSize(200, 50)
    SteamLink:SetAlpha(155)
    SteamLink:SetTextColor(Color(255,255,255))
    SteamLink.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(51,49,49))

        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(Material("data/gomigrad_datacontent/steam.png"))
        surface.DrawTexturedRect(10, 10, 24, 24)
    end
    SteamLink.DoClick = function(self)
        GGrad_Notify("Ссылка на группу в Steam скопирована в буфер-обмена.", Color(23,150,38))
        LocalPlayer():ChatPrint("Ссылка на группу в Steam скопирована в буфер-обмена.")
        SetClipboardText("https://steamcommunity.com/groups/gomigrad_ru")
    end

    SteamLink.OnCursorEntered = function(self)
        self:AlphaTo(200, 0.15, 0, nil)
    end

    SteamLink.OnCursorExited = function(self)
        self:AlphaTo(155, 0.15, 0, nil)
    end

    local ContentServer = vgui.Create("DButton", ESCMenu)
    ContentServer:SetFont("BudgetLabel")
    ContentServer:SetText("Server Content")
    ContentServer:SetPos(ScrW()/2.265, ScrH()*0.65)
    ContentServer:SetSize(200, 50)
    ContentServer:SetAlpha(155)
    ContentServer:SetTextColor(Color(255,255,255))
    ContentServer.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(51,49,49))

        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(Material("data/gomigrad_datacontent/content.png"))
        surface.DrawTexturedRect(10, 10, 24, 24)
    end
    ContentServer.DoClick = function(self)
        GGrad_Notify("Ссылка на контент сервера скопирована в буфер-обмена.", Color(23,150,38))
        LocalPlayer():ChatPrint("Ссылка на контент сервера скопирована в буфер-обмена.")
        SetClipboardText("https://steamcommunity.com/sharedfiles/filedetails/?id=3463425585")
    end

    ContentServer.OnCursorEntered = function(self)
        self:AlphaTo(200, 0.15, 0, nil)
    end

    ContentServer.OnCursorExited = function(self)
        self:AlphaTo(155, 0.15, 0, nil)
    end
end

hook.Add( "ChatText", "hide_joinleave", function( index, name, text, type )
    if ( type == "joinleave" ) then
        return false
    end
end)

hook.Add( "OnPauseMenuShow", "wtfescapeassd", function()
    if not notifyesc then
        GGrad_Notify("Если вы хотите открыть обычное ESC меню нажмите SHIFT+ESCAPE.", Color(181,126,18))
        notifyesc = true
        timer.Simple(5, function()
            notifyesc = false
        end)
    end
    if SettingsMenu == nil then
        if ESCMenu != nil then
            ESCMenu:AlphaTo(2, 0.2, 0, nil)
            ESCMenu:SizeTo(0, ScrH(), 0.3, 0, 0.5, nil)
        else
            GGrad_CustomESC()
        end
    else
        SettingsMenu:Remove()
        SettingsMenu = nil
    end   
    return false
end )