-- "addons\\chechaworkdeveloper\\lua\\autorun\\client\\menu_inventory.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- i love scripthookers

AddCSLuaFile()

Inventory = {}
Container = {}
local BList = {
    "weapon_hands",
    "gmod_tool",
    "weapon_physgun",
}

local function FindItemIndex(panel, index)
    if not IsValid(panel) then return end
    for _, child in pairs(panel:GetChildren()) do
        if IsValid(child) then
            if child:GetName() == "DButton" and child.item and child.index and child.posx and child.posy then
                if child.index == index then
                    return child
                end
            end
        end
    end
end

function InventoryGetWeapons(ply)
    local wints = 0
    local weapox = {}
    for i,v in ipairs(ply:GetWeapons()) do
        if table.HasValue(BList, v:GetClass()) then continue end
        wints = wints + 1
    end

    for z,polotenco in ipairs(ply:GetWeapons()) do
        if table.HasValue(BList, polotenco:GetClass()) then continue end
        table.insert(weapox,polotenco)
    end

    return wints, weapox
end

local vecZero = Vector(0,0,0)
local angZero = Angle(0,0,0)
local cameraPos,cameraAng
local angRotate = Angle(0,0,0)
local _cameraPos = Vector(20,20,10)
local _cameraAng = Angle(10,0,0)
whatglowe = nil

local cam_Start3D = cam.Start3D
local render_SuppressEngineLighting = render.SuppressEngineLighting

local render_SetLightingOrigin = render.SetLightingOrigin
local render_ResetModelLighting = render.ResetModelLighting
local render_SetColorModulation = render.SetColorModulation
local render_SetBlend = render.SetBlend

local render_SetModelLighting = render.SetModelLighting
function FindArmorKeyByEnt(entString)
    for key, armorData in pairs(JMod.ArmorTable) do
        if armorData.ent == entString then
            return key
        end
    end
    return nil
end
local render_SetColorModulation = render.SetColorModulation
local render_SetBlend = render.SetBlend
local render_SuppressEngineLighting = render.SuppressEngineLighting

local cam_IgnoreZ = cam.IgnoreZ

local cam_End3D = cam.End3D

local ClientsideModel = ClientsideModel
local RealTime = RealTime

local InfoArmor = {
    ["Strandhogg"] = {
        ["mag1"] = {
            count = 3,
            icon = "entities/eft_ak_attachments/mag/5456l18.png",
            name = "5.45x39",
            cursor = {
                x = 908,
                y = 493,
                w = 80,
                h = 100,
            },
        },
        ["mag2"] = {
            count = 2,
            icon = "entities/eft_glock_attachments/mag.png",
            name = "9x19",
            cursor = {
                x = 1002,
                y = 512,
                w = 27,
                h = 60,
            },
        },
        ["other"] = {
            count = 1,
            icon = "entities/arc9_ammo.png",
            name = "Medkit and Transmitter",
            cursor = {
                x = 879,
                y = 524,
                w = 36,
                h = 50,
            },
        }
    }
}

local function OpenRectConstructor()
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW(), ScrH())
    frame:Center()
    frame:SetTitle("Прямоугольный Конструктор")
    frame:MakePopup()
    frame.Paint = function(self,w,h)
        draw.RoundedBox(5, 0, 0, w, h, Color(255,255,255,15))
    end

    local canvas = vgui.Create("DPanel", frame)
    canvas:Dock(FILL)
    canvas:SetMouseInputEnabled(true)

    local rects = {}
    local drawing = false
    local startX, startY = 0, 0
    local currentRect = nil
    local selectedRect = nil

    function canvas:Paint(w, h)
        surface.SetDrawColor(30, 30, 30, 15)
        surface.DrawRect(0, 0, w, h)

        for _, rect in ipairs(rects) do
            surface.SetDrawColor(100, 150, 255, rect == selectedRect and 200 or 100)
            surface.DrawOutlinedRect(rect.x, rect.y, rect.w, rect.h)

            if rect == selectedRect then
                draw.SimpleText("X: " .. rect.x .. " Y: " .. rect.y, "DermaDefault", rect.x + 5, rect.y + 5, color_white)
                draw.SimpleText("W: " .. rect.w .. " H: " .. rect.h, "DermaDefault", rect.x + 5, rect.y + 20, color_white)
            end
        end

        if currentRect then
            surface.SetDrawColor(0, 255, 0, 180)
            surface.DrawOutlinedRect(currentRect.x, currentRect.y, currentRect.w, currentRect.h)
        end
    end

    function canvas:OnMousePressed(code)
        local mx, my = input.GetCursorPos()
        if code == MOUSE_LEFT then
            drawing = true
            startX, startY = mx, my
            currentRect = { x = mx, y = my, w = 0, h = 0 }
        elseif code == MOUSE_RIGHT then
            selectedRect = nil
            for _, rect in ipairs(rects) do
                if mx >= rect.x and mx <= rect.x + rect.w and my >= rect.y and my <= rect.y + rect.h then
                    selectedRect = rect
                    break
                end
            end
        end
    end

    function canvas:OnMouseReleased(code)
        if code == MOUSE_LEFT and currentRect then
            if currentRect.w < 0 then
                currentRect.x = currentRect.x + currentRect.w
                currentRect.w = -currentRect.w
            end
            if currentRect.h < 0 then
                currentRect.y = currentRect.y + currentRect.h
                currentRect.h = -currentRect.h
            end

            if currentRect.w >= 5 and currentRect.h >= 5 then
                table.insert(rects, currentRect)
            end

            drawing = false
            currentRect = nil
        end
    end

    function canvas:Think()
        if drawing and currentRect then
            local mx, my = input.GetCursorPos()
            currentRect.w = mx - startX
            currentRect.h = my - startY
        end
    end
end

concommand.Add("open_rect_gui", OpenRectConstructor)

local function ModelPreview(plyModel, name)
    if IsValid(frame) then return end
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)

    frame.OnRemove = function(self)
        frameinfo:Remove()
    end

    frame.Paint = function(self,w,h)
        draw.RoundedBox(6,0,0,w,h,Color(28,26,26,155))
    end

    frame.OnKeyCodePressed = function(self,kc)
        if kc == KEY_ESCAPE or kc == KEY_R or kc == KEY_W or kc == KEY_S or kc == KEY_A or kc == KEY_D then
            self:Remove()
        end
    end

    local modelPanel = vgui.Create("DModelPanel", frame)
    modelPanel:Dock(FILL)
    modelPanel:SetModel(plyModel or "models/Humans/Group01/Female_01.mdl")

    modelPanel.camRadius = 50
    modelPanel.camYaw = 0
    modelPanel.camPitch = 20
    modelPanel.targetYaw = 0
    modelPanel.targetPitch = 20

    modelPanel.LastX = 0
    modelPanel.LastY = 0
    modelPanel.Dragging = false
    
    timer.Simple(0, function()
        if not IsValid(modelPanel) then return end

        local ent = modelPanel.Entity
        local mn, mx = ent:GetRenderBounds()
        local sizeVec = mx - mn
        local center = (mn + mx) / 2

        local size = sizeVec:Length()
        modelPanel.camRadius = size * 0.8
        modelPanel.ModelCenter = center + Vector(0, 0, sizeVec.z * 0.05)
        local height = math.Clamp(sizeVec.z * 4 + 200, 400, 1000)
        local width = math.Clamp(sizeVec.z * 2.5 + 200, 300, 800)
        frame:SetSize(width, height)
        frame:Center()
    end)

    function modelPanel:LayoutEntity(ent)
        self:RunAnimation()

        self.camYaw = Lerp(FrameTime() * 10, self.camYaw, self.targetYaw)
        self.camPitch = Lerp(FrameTime() * 10, self.camPitch, self.targetPitch)

        local pitchRad = math.rad(self.camPitch)
        local yawRad = math.rad(self.camYaw)

        local x = math.cos(pitchRad) * math.cos(yawRad)
        local y = math.cos(pitchRad) * math.sin(yawRad)
        local z = math.sin(pitchRad)

        local dir = Vector(x, y, z)
        local center = self.ModelCenter or Vector(0, 0, 40)

        local camPos = center + dir * self.camRadius

        self:SetCamPos(camPos)
        self:SetLookAt(center)
    end

    local frameinfo = vgui.Create("DFrame")
    frameinfo:SetTitle("")
    frameinfo:SetPos(ScrW()/1.7, ScrH()/2.85)
    frameinfo:SetSize(300,300)
    frameinfo:ShowCloseButton(false)
    frameinfo.Paint = function(self,w,h)
        draw.RoundedBox(6,0,0,w,h,Color(28,26,26,155))
    end

    frameinfo.OnKeyCodePressed = function(self,kc)
        if kc == KEY_ESCAPE or kc == KEY_R or kc == KEY_W or kc == KEY_S or kc == KEY_A or kc == KEY_D then
            self:Remove()
        end
    end
    frame.OnRemove = function(self)
        if IsValid(frameinfo) then
            frameinfo:Remove()
        end
    end
    modelPanel.PaintOver = function(self)
        local mx, my = input.GetCursorPos()
        local cx, cy = self:CursorPos()
        local dal = {}
        if not InfoArmor[name] then return end
        for bag, a in pairs(InfoArmor[name]) do
            table.insert(dal, a)
        end

        for _, information in ipairs(dal) do
            if mx >= information.cursor.x and mx <= information.cursor.x + information.cursor.w and my >= information.cursor.y and my <= information.cursor.y + information.cursor.h then
                surface.SetTextColor(Color(255,255,255,255))
                surface.SetTextPos(cx-15, cy-40)
                surface.SetFont("SolidMapVote.NominationMapName")
                surface.DrawText(information.name)
                for i=1, information.count do
                    surface.SetDrawColor(Color(255,255,255,255))
                    surface.SetMaterial(Material(information.icon))
                    surface.DrawTexturedRect(cx-(50)+(i*25), cy-20, 64, 64)
                end
            end
        end
    end
end

concommand.Add("mdl_preview", function(ply, cmd, args)
    local model = ply:GetModel()
    ModelPreview(args[1] or model)
end)


WeaponByModel = {}
WeaponByModel.weapon_physgun = {
    WorldModel = "models/weapons/w_physics.mdl",
    PrintName = "Physgun"
}

local BASE_W, BASE_H = 1920, 1080

local function ScaleW(x)
    return ScrW() * (x / BASE_W)
end

local function ScaleH(y)
    return ScrH() * (y / BASE_H)
end

DWSEX = function(self,x,y,wide,tall,alpha)
    local cameraPos = self.dwsPos or _cameraPos
    local mdl = self.WorldModel

    if mdl then
        local DrawModel = G_DrawModel

        local lply = LocalPlayer()

        if not IsValid(DrawModel) then
            G_DrawModel = ClientsideModel(mdl,RENDER_GROUP_OPAQUE_ENTITY)
            DrawModel = G_DrawModel
            DrawModel:SetNoDraw(true)
        else
            DrawModel:SetModel(mdl)

            cam_Start3D(cameraPos,(-cameraPos):Angle() - (self.cameraAng or _cameraAng),30,x,y,wide,tall)
                --cam_IgnoreZ(true)
                render_SuppressEngineLighting(true)

                render_SetLightingOrigin(vecZero)
                render_ResetModelLighting(50 / 255,50 / 255,50 / 255)
                render_SetColorModulation(1,1,1)
                render_SetBlend(255)

                render_SetModelLighting(4,1,1,1)

                angRotate:Set(angZero)
                if self.Base == "salat_base" then
                    angRotate[2] = RealTime() * (-30) % 360
                else
                    angRotate[2] = RealTime() * 30 % 360
                end
                angRotate:Add(self.dwsItemAng or angZero)

                local dir = Vector(0,0,0)
                dir:Set(self.dwsItemPos or vecZero)
                dir:Rotate(angRotate)

                DrawModel:SetRenderAngles(angRotate)
                DrawModel:SetRenderOrigin(dir)
                DrawModel:DrawModel()

                render_SetColorModulation(1,1,1)
                render_SetBlend(1)
                render_SuppressEngineLighting(false)
                --cam_IgnoreZ(false)
            cam_End3D()
        end
    end
end

YesContainer = false
net.Receive("INV_DataInventory", function(l,x)
    Inventory = net.ReadTable()
end)

net.Receive("INV_DataContainer", function(l,x)
    YesContainer = net.ReadBool()
    Container = net.ReadTable()
end)

local InventoryResourceData = {
    ["panel_class"] = "DPanel",
    ["button_class"] = "DButton",
    ["label_class"] = "DLabel",

    ["iconpath_default"] = "vgui/avatar_default",
    ["trebuchetfont"] = "DebugOverlay",
    ["targetidfont"] = "TargetID",

    ["imenu_bgcolor"] = Color(37,37,37, 155),
    ["imenu_backpackbgcolor"] = Color(37,37,37, 200),
    ["invlabel_textcolor"] = Color(190,190,190,200),
    ["invlabel_text"] = "Your inventory",
    ["emptylabel_textcolor"] = Color(77,75,75,200),
    ["emptylabel_text"] = "Как-то пусто...",
    ["itembutton_defaultcolor"] = Color(59,59,59,255),
    ["itembutton_hovercolor"] = Color(30,29,29),
    ["itembutton_hoversound"] = "garrysmod/ui_hover.wav",
    ["itembutton_clicksound"] = "garrysmod/content_downloaded.wav",
    ["itembutton_takenetmessage"] = "INV_TakeItem",
    ["contlabel_text"] = "Container",
}

local function GetINVResource(name)
    if not InventoryResourceData[name] then print("nigger...") end
    return InventoryResourceData[name]
end

local rc = GetINVResource

function RemoveInventory()
    if IsValid(imenu) then
        imenu:Remove()
    end
    if IsValid(BGToDrop) then
        BGToDrop:Remove()
    end
    if IsValid(backpackmenu) then
        backpackmenu:Remove()
    end
    if IsValid(PDispBG) then
        PDispBG:Remove()
    end
    if IsValid(backpacklabel) then
        backpacklabel:Remove()
    end
end

concommand.Add("w_helper", function(ply,cmd,args)
    print(ScrW()*args[1])
end)

concommand.Add("h_helper", function(ply,cmd,args)
    print(ScrH()*args[1])
end)

local MCLAMP = math.Clamp
local MFLOOR = math.floor

local function CreateArmorSlotButton(parent, slot, x, y)
	local Buttalony, Ply = vgui.Create("DButton", parent), LocalPlayer()
	Buttalony:SetSize(52, 52)
	Buttalony:SetPos(x, y)
	Buttalony:SetText("")
    Buttalony.from = "InventoryArmor"
    Buttalony.slot = slot
    Buttalony:SetColor(Color(74, 72, 72, 100))
    Buttalony:Droppable("gomigrad_dragndrop")

    local ItemID, ItemData, ItemInfo = JMod.GetItemInSlot(Ply.EZarmor, slot)

    if ItemInfo then
        if ItemInfo.ent then
            Buttalony:SetMaterial(Material("entities/" .. ItemInfo.ent .. ".png"))
        end
    end

	function Buttalony:Paint(w, h)
		surface.SetDrawColor(self:GetColor())
		surface.DrawRect(0, 0, w, h)
	end
    Buttalony.dropped = false
    Buttalony.OnCursorEntered = function(self)
        if ItemID and not self.dropped then
            whatglowe = 
            {
                ["ID"] = ItemID, 
                ["SLOT"] = slot,
            }
        end
        if ItemInfo and not self.dropped then
            if ItemInfo.ent then
                LocalPlayer():EmitSound("arc9_eft_shared/generic_mag_pouch_in" ..  math.random(1,6) .. ".ogg")
            end
        end
        self:ColorTo(Color(111,106,106,100), 0.1, 0, nil)
    end

    Buttalony.OnCursorExited = function(self)
        whatglowe = nil
        if ItemInfo and not self.dropped then
            if ItemInfo.ent then
                LocalPlayer():EmitSound("arc9_eft_shared/generic_mag_pouch_out" ..  math.random(1,7) .. ".ogg")
            end
        end
        self:ColorTo(Color(74, 72, 72, 100), 0.1, 0, nil)
    end
    Buttalony.OnRemove = function(self)
        whatglowe = nil
    end
    Buttalony.DoClick = function(self)
        if self.dropped then return end
        if ItemInfo then
            local zxcv = DermaMenu()

            zxcv:AddOption(ItemInfo["PrintName"], function()
            end):SetIcon("icon16/monkey.png")

            if ItemInfo["storage"] != nil then
                zxcv:AddOption(MCLAMP(MFLOOR(ItemInfo["storage"]/3.5), 5, 60) .. " slots", function()
                end):SetIcon("icon16/briefcase.png")
            end

            zxcv:AddSpacer()

            zxcv:AddOption("Drop", function()
                net.Start("JMod_Inventory")
                    net.WriteInt(1, 8)
                    net.WriteString(ItemID)
                net.SendToServer()
                Buttalony:SetMaterial(nil)
                self.dropped = true
                whatglowe = nil
            end):SetIcon("icon16/bin_closed.png")

            if ItemInfo.tgl then
                zxcv:AddOption("Toggle", function()
                    net.Start("JMod_Inventory")
                        net.WriteInt(2, 8)
                        net.WriteString(ItemID)
                    net.SendToServer()
                end):SetIcon("icon16/lock_go.png")
            end

            zxcv:AddOption("Info", function()
                ModelPreview(ItemInfo.mdl, ItemData["name"])
            end):SetIcon("icon16/information.png")

            zxcv:Open()
        end
    end
end

function GetBPItems()
    return Inventory["Backpack"]
end

fovsowhat = {
    ["back"] = 55,
    ["pelvis"] = 30,
    ["chest"] = 30,
    ["acc_chestrig"] = 30,
    ["head"] = 25,
    ["eyes"] = 25,
    ["mouthnose"] = 20,
    ["ears"] = 25,
    ["rightshoulder"] = 30,
    ["rightforearm"] = 30,
    ["leftshoulder"] = 30,
    ["leftforearm"] = 30,

    ["rightthigh"] = 30,
    ["rightcalf"] = 30,

    ["leftthigh"] = 30,
    ["leftcalf"] = 30,
    ["waist"] = 25,
}
bonelookat = {
    ["head"] = "ValveBiped.Bip01_Head1",
    ["ears"] = "ValveBiped.Bip01_Head1",
    ["eyes"] = "ValveBiped.Bip01_Head1",
    ["back"] = "ValveBiped.Bip01_Spine2",
    ["mouthnose"] = "ValveBiped.Bip01_Neck1",
    ["rightshoulder"] = "ValveBiped.Bip01_R_Upperarm",
    ["rightforearm"] = "ValveBiped.Bip01_R_Forearm",

    ["leftshoulder"] = "ValveBiped.Bip01_L_Upperarm",
    ["leftforearm"] = "ValveBiped.Bip01_L_Forearm",

    ["rightthigh"] = "ValveBiped.Bip01_R_Thigh",
    ["rightcalf"] = "ValveBiped.Bip01_R_Calf",
    
    ["leftthigh"] = "ValveBiped.Bip01_L_Thigh",
    ["leftcalf"] = "ValveBiped.Bip01_L_Thigh",
    ["waist"] = "ValveBiped.Bip01_R_Thigh",
}
local function subtractValues(table1, table2)
    local result = {}

    local table1Map = {}
    for _, v in ipairs(table1) do
        table1Map[v] = true
    end

    for _, v in ipairs(table2) do
        if not table1Map[v] then
            table.insert(result, v)
        end
    end

    return result
end

local VLerp = Lerp
local VLerpVector = LerpVector
local maybepos = nil
local fovchanski = 44
local ply = LocalPlayer()
    --Inventory["Information"]["MaxItems"]+Inventory["Information"]["BackpackSlots"]

local function UpdateInventory()
    RemoveInventory()
    timer.Simple(0.2, function() CreateInventory(true) end)
end

local function CoreDND(priem, por, isdrop)
    if isdrop then
        for k, v in pairs( por ) do
            if priem.IsMenu == "Backpack" then
                net.Start("INV_MoveItem")
                    net.WriteEntity(v.item)
                    net.WriteString(v.from)
                    net.WriteTable({})
                net.SendToServer()
                v:Remove()
                UpdateInventory()
            end
            if priem.IsMenu == "DropPanel" then
                if v.from == "Inventory" then
                    net.Start("INV_ContextMenu_Drop")
                        net.WriteEntity(v.item)
                    net.SendToServer()
                    v:Remove()       
                end
                if v.from == "Container" then
                    net.Start("INV_DropContainer")
                        net.WriteString(v.item)
                        net.WriteString(v.index)
                    net.SendToServer()
                    v:Remove()
                end
                if v.from == "InventoryArmor" then
                    local ItemID, ItemData, ItemInfo = JMod.GetItemInSlot(LocalPlayer().EZarmor, v.slot)
                    net.Start("JMod_Inventory")
                        net.WriteInt(1, 8)
                        net.WriteString(ItemID)
                    net.SendToServer()
                    UpdateInventory()
                end
            end
            if priem.IsMenu == "Inventory" then
                if v.from == "Container" then
                    LocalPlayer():EmitSound(rc("itembutton_clicksound"))
                    if not string.StartsWith(v.item, "ent_jack_gmod_ezarmor") or v.item == "ent_jack_gmod_ezammo" then
                        if ply:HasWeapon(v.item) then LocalPlayer():ChatPrint("У вас уже есть этот предмет в инвентаре.") return end
                        local itemsigw = InventoryGetWeapons(LocalPlayer())
                        if itemsigw + 1 > Inventory["Information"]["MaxItems"] and Inventory["Information"]["BackpackSlots"] <= 0 then LocalPlayer():ChatPrint("Недостаточно места.") return end
                    end
                    net.Start(rc("itembutton_takenetmessage"))
                        net.WriteString(v.item)
                    net.SendToServer()
                    v:Remove()
                    UpdateInventory()
                end

                if v.from == "Backpack" then
                    if LocalPlayer():HasWeapon(v.class) then
                        LocalPlayer():ChatPrint("Этот предмет уже в инвентаре.")
                        return
                    end
                    local ntbl = {
                        item = v.item,
                        class = v.class,
                    }
                    net.Start("INV_MoveItem")
                        net.WriteEntity(nil)
                        net.WriteString(v.from)
                        net.WriteTable(ntbl)
                    net.SendToServer()
                    v:Remove()
                    UpdateInventory()
                end
            end
        end
    end
end

local ResIcons = {
    ["ent_jack_gmod_ezammo"] = "ez_resource_icons/ammo.png",
}

local CoolColors = {
    ["weapon_hg_"] = {
        Color(170,100,16),
        Color(195,151,55),
        Color(114,73,24),
        Color(94,47,12),
    },
    ["weapon_"] = {
        Color(127,33,125),
        Color(148,14,56),
        Color(255,0,119),
        Color(137,15,62),
        Color(131,48,82),
    },
    ["food_"] = {
        Color(15,169,21),
        Color(22,214,92),
        Color(79,235,100),
        Color(20,255,110)
    },
    ["medkit"] = {
        Color(140,15,15),
        Color(185,25,25),
        Color(186,71,71),
        Color(131,23,21),
        Color(105,13,13),
        Color(96,28,28),
        Color(195,30,30),
    },
    ["armor"] = {
        Color(36,27,216),
        Color(30,142,221),
        Color(25,25,173),
        Color(14,17,234),
        Color(47,0,255),
        Color(0,255,238),
        Color(18,129,241),
    },
    ["ammo"] = {
        Color(255,238,0),
        Color(233,200,14),
        Color(227,238,14),
    },
}

local function ItemAnimShake(item)
    item.animshake = true
    item:MoveTo(item.posx+15,item.posy,0.1,0,0.1,nil)
    timer.Simple(0.11, function()
        if item.posx and item.posy then
            item:MoveTo(item.posx-15,item.posy,0.1,0,0.1,nil)
            timer.Simple(0.11,function()
                if item.posx and item.posy then
                    item:MoveTo(item.posx,item.posy,0.1,0,0.1,nil)
                    timer.Simple(0.11,function()
                        if IsValid(item) then
                            item.animshake = false
                        end
                    end)
                end
            end)
        end
    end)
end
local itemButtons = {}

local function RefreshItemPositions()
    local posX = 5
    for _, btn in ipairs(itemButtons) do
        if IsValid(btn) then
            btn.posx = posX
            btn:MoveTo(posX, btn.posy, 0.15, 0, 0.2)
            posX = posX + 60
        end
    end
end
hook.Add("PostPlayerDraw", "HighlightBone", function(ply)
end)

function CreateInventory(buttonclose)
    if IsFirstTimePredicted() then return end
    if IsValid(imenu) then return end
    if IsValid(backpackmenu) then return end
    if IsValid(PDispBG) then return end
    if not Inventory then return end
    if not Inventory["Information"] then return end

    imenu = vgui.Create( "DPanel" )
    imenu:SetPos( ScrW()/2.2, ScrH()/1.2 )
    imenu:SetSize( ScrW()*(0.0315*(Inventory["Information"]["MaxItems"] or 8)), ScrH()*0.0556)
    imenu:SetBackgroundColor(rc("imenu_bgcolor"))
    imenu:MakePopup()
    imenu.IsMenu = "Inventory"
    imenu.Paint = function(self,w,h)
        local gradient = Material("gui/gradient") 
        draw.RoundedBox(0, 0, 0, w, h, Color(rc("imenu_bgcolor").r,rc("imenu_bgcolor").g,rc("imenu_bgcolor").b,180))

        surface.SetDrawColor(54, 53, 53, Color(rc("imenu_bgcolor").r,rc("imenu_bgcolor").g,rc("imenu_bgcolor").b,50))
        surface.SetMaterial(gradient)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    imenu:Receiver("gomigrad_dragndrop", CoreDND)

    BGToDrop = vgui.Create("DPanel")
    BGToDrop:SetPos(0, 0)
    BGToDrop:SetSize(ScrW(), ScrH())
    BGToDrop.IsMenu = "DropPanel"
    BGToDrop:SetBackgroundColor(Color(0,0,0,0))
    BGToDrop:Receiver("gomigrad_dragndrop", CoreDND)
    BGToDrop.Paint = function(self,w,h)
        local gradient = Material("vgui/gradient-l") 
		
        draw.RoundedBox(12, 0, 0, w, h, Color(0, 0, 0, 180))

        surface.SetDrawColor(0, 0, 0, 220)
        surface.SetMaterial(gradient)
        surface.DrawTexturedRect(0, 0, w, h)
    end

	PDispBG = vgui.Create("DPanel")
	PDispBG:SetPos(ScrW()*0.08, ScrH()/3.9)
	PDispBG:SetSize(500, 590)

	function PDispBG:Paint(w, h)
		surface.SetDrawColor(93, 93, 93, 0)
		surface.DrawRect(0, 0, w, h)
	end

    local PlayerDisplay = vgui.Create("DModelPanel", PDispBG)
	PlayerDisplay:SetPos(0, 0)
	PlayerDisplay:SetSize(400, 560)
	PlayerDisplay:SetModel(LocalPlayer():GetModel())
	PlayerDisplay:SetLookAt(PlayerDisplay:GetEntity():GetBonePosition(0))
	PlayerDisplay:SetFOV(44)
	PlayerDisplay:SetCursor("arrow")
	local Ent = PlayerDisplay:GetEntity()
	local entAngs = nil
	local curDif = nil
	local lastCurPos = input.GetCursorPos()
	local doneOnce = false
    local xcv = 45

    PlayerDisplay.Think = function(self)
        if not maybepos then
            maybepos = self:GetEntity():GetBonePosition(0)
        end 
        if whatglowe then
            if whatglowe["SLOT"] == "back" or whatglowe["SLOT"] == "waist" then
                if whatglowe["SLOT"] == "back" then
                    xcv = VLerp(0.16, xcv or 45, -125)
                    if whatglowe["BACK_FOV"] then
                        fovchanski = VLerp(0.4, fovchanski or 44, whatglowe["BACK_FOV"])
                    end
                else
                    xcv = VLerp(0.16, xcv or 45, -165)
                    fovchanski = VLerp(0.4, fovchanski or 44, fovsowhat[whatglowe["SLOT"]] or 44)
                end
            else
                xcv = VLerp(0.1, xcv or 45, 45)  
                fovchanski = VLerp(0.4, fovchanski or 44, fovsowhat[whatglowe["SLOT"]] or 44)          
            end
            if bonelookat[whatglowe["SLOT"]] then
                maybepos = VLerpVector(0.25, maybepos, self:GetEntity():GetBonePosition(self:GetEntity():LookupBone(bonelookat[whatglowe["SLOT"]])) or self:GetEntity():GetBonePosition(0))
            end
        else
            xcv = VLerp(0.1, xcv or 45, 45)
            fovchanski = VLerp(0.3, fovchanski or 44, 44)
            maybepos = VLerpVector(0.1, maybepos or self:GetEntity():GetBonePosition(0), self:GetEntity():GetBonePosition(0))
        end
        self:SetFOV(fovchanski)
        self:SetLookAt(maybepos)
    end

	function PlayerDisplay:LayoutEntity(ent)
        local kayax,kayay = input.GetCursorPos()
		ent:SetAngles( Angle( 0, xcv, 0 ) )
	end

    Ent.playerColor = LocalPlayer():GetPlayerColor()

    Ent:SetSkin(LocalPlayer():GetSkin())
	for k, v in pairs( LocalPlayer():GetBodyGroups() ) do
		local cur_bgid = LocalPlayer():GetBodygroup( v.id )
		Ent:SetBodygroup( v.id, cur_bgid )
	end

	if LocalPlayer().EZarmor.suited and LocalPlayer().EZarmor.bodygroups then
		PlayerDisplay:SetColor(LocalPlayer():GetColor())

		for k, v in pairs(LocalPlayer().EZarmor.bodygroups) do
			Ent:SetBodygroup(k, v)
		end
	end

    CreateArmorSlotButton(PDispBG, "acc_head", 384, 30)
	CreateArmorSlotButton(PDispBG, "acc_eyes", 384, 84)
	CreateArmorSlotButton(PDispBG, "acc_ears", 384, 138)
	CreateArmorSlotButton(PDispBG, "acc_neck", 384, 192)
	CreateArmorSlotButton(PDispBG, "aventail", 384, 246)
	CreateArmorSlotButton(PDispBG, "acc_chestrig", 384, 300)
	CreateArmorSlotButton(PDispBG, "armband", 384, 354)
    CreateArmorSlotButton(PDispBG, "acc_rshoulder", 384, 408)
    CreateArmorSlotButton(PDispBG, "acc_lshoulder", 384, 462)
    CreateArmorSlotButton(PDispBG, "waist", 384, 516)

    CreateArmorSlotButton(PDispBG, "head", 10, 30)
	CreateArmorSlotButton(PDispBG, "eyes", 10, 84)
	CreateArmorSlotButton(PDispBG, "mouthnose", 10, 138)
	CreateArmorSlotButton(PDispBG, "ears", 10, 192)
	CreateArmorSlotButton(PDispBG, "leftshoulder", 10, 246)
	CreateArmorSlotButton(PDispBG, "leftforearm", 10, 300)
	CreateArmorSlotButton(PDispBG, "leftthigh", 10, 354)
	CreateArmorSlotButton(PDispBG, "leftcalf", 10, 408)

    CreateArmorSlotButton(PDispBG, "rightshoulder", 330, 30)
	CreateArmorSlotButton(PDispBG, "rightforearm", 330, 84)
	CreateArmorSlotButton(PDispBG, "chest", 330, 138)
	CreateArmorSlotButton(PDispBG, "back", 330, 192)
	CreateArmorSlotButton(PDispBG, "pelvis", 330, 246)
	CreateArmorSlotButton(PDispBG, "rightthigh", 330, 300)
	CreateArmorSlotButton(PDispBG, "rightcalf", 330, 354)


    function PlayerDisplay:PostDrawModel(ent)
        ent.EZarmor = LocalPlayer().EZarmor
		JMod.ArmorPlayerModelDraw(ent, whatglowe)
    end
    
    if YesContainer == true then
        local menuW, menuH = ScaleW(350), ScaleH(60)
        local menuX, menuY = (ScrW() - menuW) / 2, (ScrH() - menuH) / 2
        
        contmenu = vgui.Create("DPanel")
        contmenu:SetPos(menuX, menuY)
        contmenu:SetSize(menuW, menuH)
        contmenu:SetBackgroundColor(rc("imenu_bgcolor"))
        contmenu.IsMenu = "Container"
        contmenu.Paint = function(self,w,h)
            draw.RoundedBoxEx(10,0,0,w,h,rc("imenu_bgcolor"), true, true, true ,true)
        end

        local labelc_button = vgui.Create("DLabel")
        labelc_button:SetPos(0,0)
        labelc_button:SetTextColor(rc("invlabel_textcolor"))
        labelc_button:SetFont(rc("targetidfont"))
        labelc_button:SetText("")
        labelc_button:SetColor(Color(255,255,255,255))
        labelc_button:SetVisible(false)
        local x2, y2 = 5, 5

        if buttonclose == true then
            function contmenu:OnKeyCodePressed(kcodex)
                if canopenm then
                    if kcodex == KEY_ESCAPE or kcodex == KEY_Q or kcodex == KEY_W or kcodex == KEY_A or kcodex == KEY_S or kcodex == KEY_D then
                        RemoveInventory()
                        if IsValid(backpackmenu) then
                            backpackmenu:Remove()
                        end
                        if IsValid(backpacklabel) then
                            backpacklabel:Remove()
                        end
                        if IsValid(dropmenu) then
                            dropmenu:Remove()
                        end
                        if IsValid(contmenu) then
                            contmenu:Remove()
                        end
                        if IsValid(PDispBG) then
                            PDispBG:Remove()
                        end
                    end
                end
            end
        end
        
        for i, item in ipairs(Container) do
            local itmx = vgui.Create( rc("button_class"), contmenu )
            itmx:SetPos( x2, y2 )
            itmx.posx = x2
            itmx.posy = y2
            x2 = x2 + 60
            itmx.item = item
            itmx.index = i
            itmx:SetSize( 52, 47)
            itmx:SetText( "" )
            itmx:Droppable("gomigrad_dragndrop")
            itmx.from = "Container"
            table.insert(itemButtons, itmx)
            local icon = rc("iconpath_default")
            if weapons.Get(item) != nil and isstring(weapons.Get(item).WepSelectIcon) then
                icon = weapons.Get(item).WepSelectIcon
            end
            if string.StartsWith(item, "ent_jack_gmod_ezarmor") or item == "ent_jack_gmod_ezammo" then
                local m = Material("entities/" .. item .. ".png")
                if not m:IsError() then
                    itmx:SetMaterial(Material("entities/" .. item .. ".png"))
                else
                    if ResIcons[item] then
                        itmx:SetMaterial(Material(ResIcons[item]))
                    else
                        itmx:SetMaterial(Material("question_mark.png"))
                    end
                end
            end
            itmx.alreadyfastlooting = false
            itmx.animshake = false
            itmx.movingremove = false
            itmx:SetColor(rc("itembutton_defaultcolor"))
            itmx.defcol = rc("itembutton_defaultcolor")
            for name, col in pairs(CoolColors) do
                if weapons.Get(item) then
                    if weapons.Get(item).Base == "medkit" or item == "medkit" then
                        local clxzzv = table.Random(CoolColors["medkit"])
                        itmx:SetColor(Color(clxzzv.r,clxzzv.g,clxzzv.b,215))
                        itmx.defcol = Color(clxzzv.r,clxzzv.g,clxzzv.b,215)
                    end
                    if string.StartsWith(item, name) then
                        if weapons.Get(item).Base == "weapon_hg_grenade_base" then
                            local clxzv = table.Random(CoolColors["weapon_hg_"])
                            itmx:SetColor(Color(clxzv.r,clxzv.g,clxzv.b,215))
                            itmx.defcol = Color(clxzv.r,clxzv.g,clxzv.b,215)
                        else
                            local choscol = table.Random(col)
                            itmx:SetColor(Color(choscol.r,choscol.g,choscol.b,215))
                            itmx.defcol = Color(choscol.r,choscol.g,choscol.b,215)
                        end
                    end
                end
            end

            if string.StartsWith(item, "ent_jack_gmod_ezarmor") then
                local daunezzg = table.Random(CoolColors["armor"])
                itmx:SetColor(Color(daunezzg.r,daunezzg.g,daunezzg.b,215))
                itmx.defcol = Color(daunezzg.r,daunezzg.g,daunezzg.b,215)                    
            end

            if item == "ent_jack_gmod_ezammo" then
                local daunezzg = table.Random(CoolColors["ammo"])
                itmx:SetColor(Color(daunezzg.r,daunezzg.g,daunezzg.b,215))
                itmx.defcol = Color(daunezzg.r,daunezzg.g,daunezzg.b,215) 
            end

            itmx.OnRemove = function(self)
                if IsValid(labelc_button) then
                    labelc_button:Remove()
                end
            end

            itmx.Paint = function(self,w,h)    
                draw.RoundedBox(5, 0, 0, w, h, self:GetColor())
    
                surface.SetDrawColor(29, 28, 28, self:GetColor().a)
                surface.SetMaterial(Material("vgui/gradient-u") )
                surface.DrawTexturedRect(0, 0, w, h)
                if not string.StartsWith(self.item, "ent_jack_gmod_ezarmor") or self.item == "ent_jack_gmod_ezammo" then
                    if not weapons.Get(self.item) then return end
                    if not weapons.Get(self.item).WorldModel then return end
                    local x,y = self:LocalToScreen(0,0)
                    DWSEX(weapons.Get(self.item),x,y,w,h)
                end
            end
            itmx.OnCursorEntered = function(self)
                local xc,yc = self:GetPos()
                if not self.movingremove or self.animshake then
                    --self:MoveTo(xc-3,yc-3, 0.05, 0, 0.6, nil)
                end
                self:SizeTo(52+6,47+6,0.2,0,0.6,nil)
                if IsValid(labelc_button) then
                    local pname = "Unknown"
                    if not string.StartsWith(self.item, "ent_jack_gmod_ezarmor") then
                        if self.item then
                            if self.item == "ent_jack_gmod_ezammo" then
                                pname = "Ammo Box"
                            end
                            if weapons.Get(self.item) then
                                if weapons.Get(self.item).PrintName != nil then
                                    pname = weapons.Get(self.item).PrintName
                                end
                            end
                        end
                    else
                        pname = JMod.ArmorTable[FindArmorKeyByEnt(self.item)].PrintName
                    end
                    local q,e = input.GetCursorPos()
                    labelc_button:SetText(pname)
                    labelc_button:SetVisible(true)
                    labelc_button:SizeToContents()
                end    
                LocalPlayer():EmitSound(rc("itembutton_hoversound"))
                self:ColorTo(rc("itembutton_hovercolor"), 0.3, 0, nil)
            end

            itmx.Think = function(self)
                if self:IsHovered() then
                    if input.IsKeyDown(KEY_LSHIFT) and not self.alreadyfastlooting then
                        itmx.alreadyfastlooting = true
                        LocalPlayer():EmitSound(rc("itembutton_clicksound"))
                        if string.StartsWith(self.item, "ent_jack_gmod_ezarmor") or self.item == "ent_jack_gmod_ezammo" then
                            net.Start(rc("itembutton_takenetmessage"))
                                net.WriteString(self.item)
                                net.WriteInt(self.index, 6)
                            net.SendToServer()
                            self.movingremove = true
                            self:MoveTo(self.posx,self.posy+90,0.25,0,0.3,nil)
                            self:AlphaTo(2, 0.25, 0, nil)
                            timer.Simple(0.26, function()
                                table.RemoveByValue(itemButtons, self)
                                self:Remove()
                                RefreshItemPositions()
                            end)
                        else
                            if ply:HasWeapon(self.item) then 
                                LocalPlayer():ChatPrint("У вас уже есть этот предмет в инвентаре.") 
                                ItemAnimShake(self)
                            return end
                            local itemsigw = InventoryGetWeapons(LocalPlayer())
                            if itemsigw + 1 > Inventory["Information"]["MaxItems"] and Inventory["Information"]["BackpackSlots"] <= 0 then LocalPlayer():ChatPrint("Недостаточно места.") return end
                            net.Start(rc("itembutton_takenetmessage"))
                                net.WriteString(self.item)
                                net.WriteInt(self.index, 6)
                            net.SendToServer()
                            self.movingremove = true
                            self:MoveTo(self.posx,self.posy+90,0.25,0,0.8,nil)
                            self:AlphaTo(2, 0.25, 0, nil)
                            timer.Simple(0.26, function()
                                table.RemoveByValue(itemButtons, self)
                                self:Remove()
                                RefreshItemPositions()
                            end)
                        end
                    end
                    if IsValid(labelc_button) then
                        local q,e = input.GetCursorPos()
                        labelc_button:SetPos(q-18,e-12)
                    end
                end
            end

            itmx.OnCursorExited = function(self)
                if IsValid(labelc_button) then
                    labelc_button:SetVisible(false)
                end
                if not self.movingremove or self.animshake then
                    --self:MoveTo(self.posx,self.posy, 0.05, 0, 0.6, nil)
                end
                self:SizeTo(52,47,0.2,0,0.6,nil)
                self:ColorTo(itmx.defcol, 0.3, 0, nil)
            end
    
            itmx.DoClick = function(self)
                LocalPlayer():EmitSound(rc("itembutton_clicksound"))
                if string.StartsWith(self.item, "ent_jack_gmod_ezarmor") or self.item == "ent_jack_gmod_ezammo" then
                    net.Start(rc("itembutton_takenetmessage"))
                        net.WriteString(self.item)
                        net.WriteInt(self.index, 6)
                    net.SendToServer()
                    self.movingremove = true
                    self:MoveTo(self.posx,self.posy+90,0.25,0,0.3,nil)
                    self:AlphaTo(2, 0.25, 0, nil)
                    timer.Simple(0.26, function()
                        table.RemoveByValue(itemButtons, self)
                        self:Remove()
                        RefreshItemPositions()
                    end)
                else
                    if ply:HasWeapon(self.item) then 
                        LocalPlayer():ChatPrint("У вас уже есть этот предмет в инвентаре.") 
                        ItemAnimShake(self)
                    return end
                    local itemsigw = InventoryGetWeapons(LocalPlayer())
                    if itemsigw + 1 > Inventory["Information"]["MaxItems"] and Inventory["Information"]["BackpackSlots"] <= 0 then LocalPlayer():ChatPrint("Недостаточно места.") return end
                    net.Start(rc("itembutton_takenetmessage"))
                        net.WriteString(self.item)
                        net.WriteInt(self.index, 6)
                    net.SendToServer()
                    self.movingremove = true
                    self:MoveTo(self.posx,self.posy+90,0.25,0,0.8,nil)
                    self:AlphaTo(2, 0.25, 0, nil)
                    timer.Simple(0.26, function()
                        table.RemoveByValue(itemButtons, self)
                        self:Remove()
                        RefreshItemPositions()
                    end)
                end
            end
        end
    end
    ply = LocalPlayer()
    local x, y = 5, 5
    local x_bp, y_bp = 5, 5
    imenu.OnRemove = function(self)
        if IsValid(BGToDrop) then
            BGToDrop:Remove()
        end
        if IsValid(dropmenu) then
            dropmenu:Remove()
        end
        if IsValid(contmenu) then
            contmenu:Remove()
        end
        if IsValid(PDispBG) then
            PDispBG:Remove()
        end
    end
    if IsValid(ply) then
        if ply.GetWeapons then
            local no, weaponsx = InventoryGetWeapons(LocalPlayer())
            for _, data in ipairs(weaponsx) do
                if item == "Information" then continue end
                if table.HasValue(BList, data:GetClass()) then continue end
                local itm = vgui.Create( rc("button_class"), imenu )
                itm:SetPos( x, y )
                x = x + 59.9
                itm.item = data
                itm.from = "Inventory"
                itm:SetSize( 52,47)
                itm:SetText( "" )
                itm:Droppable("gomigrad_dragndrop")
                local icon = rc("iconpath_default")
                if weapons.Get(item) != nil and isstring(weapons.Get(item).WepSelectIcon) then
                    icon = weapons.Get(item).WepSelectIcon
                end
                itm:SetColor(rc("itembutton_defaultcolor"))
                itm.Paint = function(self,w,h)
                    draw.RoundedBoxEx(5,0,0,w,h,self:GetColor(), true, true, true ,true)
                    local x,y = self:LocalToScreen(0,0)
                    DWSEX(data,x,y,w,h)
                end
                itm.DoClick = function(self)
                    local itm_menu = DermaMenu()

                    local iconka = "icon16/monkey.png"

                    if self.item.Base == "salat_base" then
                        iconka = "icon16/gun.png"
                    end

                    itm_menu:AddOption(self.item.PrintName, function()
                    end):SetIcon(iconka)

                    if self.item.Base == "salat_base" then
                        itm_menu:AddOption(self.item:Clip1() .. " - " .. self.item:GetMaxClip1() .. " Ammo", function()
                        end):SetIcon("icon16/briefcase.png")
                    end

                    if self.item.Base == "salat_base" then
                        itm_menu:AddOption(ply:GetAmmoCount(self.item:GetPrimaryAmmoType()) .. " Ammo In Stock", function()
                        end):SetIcon("icon16/box.png")
                    end

                    itm_menu:AddSpacer()

                    itm_menu:AddOption("Drop", function()
                        net.Start("INV_ContextMenu_Drop")
                            net.WriteEntity(self.item)
                        net.SendToServer()
                        self:Remove()
                    end):SetIcon("icon16/bin_closed.png")

                    itm_menu:Open()
                end
            end
        end
        if Inventory["Information"]["BackpackSlots"] > 0 and not IsValid(backpackmenu) then
            backpackmenu = vgui.Create( "DPanel" )                
            backpackmenu:SetPos( ScrW()/1.3, ScrH()/1.45 )
            backpackmenu:SetSize( ScrW()*0.1925, ScrH()*0.3)
            backpackmenu:SetBackgroundColor(rc("imenu_backpackbgcolor"))
            backpackmenu.IsMenu = "Backpack"
            backpackmenu.Paint = function(self,w,h)
                local gradient = Material("vgui/gradient-l") 
		
                draw.RoundedBox(10, 0, 0, w, h, rc("imenu_backpackbgcolor"))
        
                surface.SetDrawColor(0, 0, 0, 140)
                surface.SetMaterial(gradient)
                surface.DrawTexturedRect(0, 0, w, h)
            end
            backpackmenu:Receiver("gomigrad_dragndrop", CoreDND)

            backpacklabel = vgui.Create("DLabel")
            backpacklabel:SetPos(ScrW()/1.21, ScrH()/1.49)
            backpacklabel:SetTextColor(Color(192,192,192))
            backpacklabel:SetFont(rc("trebuchetfont"))
            backpacklabel:SetText("Backpack - " .. Inventory["Information"]["BackpackSlots"] .. " slots")
            backpacklabel:SizeToContents()
            backpackmenu.OnRemove = function(self)
                backpacklabel:Remove()
            end
            for _, data_bpack in pairs(GetBPItems()) do
                if item == "Information" then continue end
                if table.HasValue(BList, _) then continue end
                local itmbpack = vgui.Create( rc("button_class"), backpackmenu )
                itmbpack:SetPos( x_bp, y_bp )
                x_bp = x_bp + 59.9
                if x_bp + itmbpack:GetWide() >= backpackmenu:GetWide() then
                    x_bp = 5
                    y_bp = y_bp + itmbpack:GetTall() + 31
                end
                itmbpack.item = data_bpack
                itmbpack.class = _
                itmbpack.from = "Backpack"
                itmbpack:SetSize( 52,47)
                itmbpack:SetText( "" )
                itmbpack:Droppable("gomigrad_dragndrop")
                local icon = rc("iconpath_default")
                if weapons.Get(item) != nil and isstring(weapons.Get(item).WepSelectIcon) then
                    icon = weapons.Get(item).WepSelectIcon
                end
                itmbpack:SetColor(rc("itembutton_defaultcolor"))
                itmbpack.Paint = function(self,w,h)
                    draw.RoundedBoxEx(5,0,0,w,h,self:GetColor(), true, true, true ,true)
                    local x,y = self:LocalToScreen(0,0)
                    DWSEX(weapons.Get(self.class),x,y,w,h)
                end
                itmbpack.DoClick = function(self)
                    local itm_menux = DermaMenu()

                    local iconka = "icon16/monkey.png"

                    if self.item.Base == "salat_base" then
                        iconka = "icon16/gun.png"
                    end

                    itm_menux:AddOption(weapons.Get(self.class).PrintName, function()
                    end):SetIcon(iconka)

                    if self.item.Base == "salat_base" then
                        itm_menux:AddOption(self.item.Clip .. " - " .. self.item.MaxAmmo .. " Ammo", function()
                        end):SetIcon("icon16/briefcase.png")
                    end

                    if self.item.Base == "salat_base" then
                        itm_menux:AddOption(ply:GetAmmoCount(self.item.AmmoType) .. " Ammo In Stock", function()
                        end):SetIcon("icon16/box.png")
                    end

                    itm_menux:AddSpacer()

                    itm_menux:AddOption("Drop", function()
                        net.Start("INV_ContextMenu_Drop")
                            net.WriteEntity(self.item)
                        net.SendToServer()
                        self:Remove()
                    end):SetIcon("icon16/bin_closed.png")

                    itm_menux:Open()
                end
            end
        end
    end
    if buttonclose == true then
        function imenu:OnKeyCodePressed(kcode)
            if canopenm then
                if kcode == KEY_ESCAPE or kcode == KEY_Q or kcode == KEY_W or kcode == KEY_A or kcode == KEY_S or kcode == KEY_D then
                    RemoveInventory()
                    if IsValid(dropmenu) then
                        dropmenu:Remove()
                    end
                    if IsValid(backpackmenu) then
                        backpackmenu:Remove()
                    end
                    if IsValid(backpacklabel) then
                        backpacklabel:Remove()
                    end
                    if IsValid(PDispBG) then
                        PDispBG:Remove()
                    end
                end
            end
        end
    end
end

local canopen_team = true

local canopeninv = true
hook.Add("Think", "XXXOpenInv", function()
    if not LocalPlayer():Alive() then return end
    if 1 then return end
    if input.IsKeyDown(KEY_L) and canopeninv == true then
        canopeninv = false
        timer.Simple(0.5, function()
            canopeninv = true
        end)
        if not IsValid(imenu) then
            CreateInventory(true)
        else
            RemoveInventory()
        end
    end
end)

net.Receive("INV_ClientInventory", function(len,c)
    CreateInventory(true)
end)

net.Receive("INV_RemoveInventory", function(len,c)
    RemoveInventory()
end)

hook.Add("KeyPress", "gdmkgdfmkh", function(plx, kcode)
    if canopenm then
        if kcode == KEY_ESCAPE or kcode == KEY_Q or kcode == KEY_W or kcode == KEY_A or kcode == KEY_S or kcode == KEY_D then
            if IsValid(imenu) then
                imenu:Remove()
            end
            if IsValid(dropmenu) then
                dropmenu:Remove()
            end
            if IsValid(contmenu) then
                contmenu:Remove()
            end
            if IsValid(backpackmenu) then
                backpackmenu:Remove()
            end
            if IsValid(PDispBG) then
                PDispBG:Remove()
            end
        end
    end
end)

concommand.Add("error_pizdamashonka", function()
    PrintTable(vgui.GetAll())
end)

hook.Add("Think", "SEX2czxc312", function()
    if YesContainer == false then
        if IsValid(contmenu) then
            contmenu:Remove()
        end
    end
end)

timer.Create("MenuszxczxvDFGDSFGhka", 0.3, 0, function()
    canopenm = true
end)

concommand.Add("getteam", function()
    print(LocalPlayer():Team())
end)

local TranslateNameInRound = {
    [1] = {
        ["homicide"] = "Невинный",
        ["tdm"] = "Красный",
        ["riot"] = "Бунтующий",
        ["hl2dm"] = "Повстанец",
        ["hunter"] = "Искатель",
        ["event"] = "Участник",
        ["dm"] = "Боец",
    },
    [2] = {
        ["homicide"] = "Невинный",
        ["tdm"] = "Синий",
        ["riot"] = "Полиция",
        ["hl2dm"] = "Альянс",
        ["hunter"] = "Прячущийся",
        ["event"] = "Участник",
        ["dm"] = "Боец",
    },
}

local TranslateModelInRound = {
    [1] = {
        ["tdm"] = "models/player/Group01/male_01.mdl",
        ["hl2dm"] = "models/player/Group03/male_01.mdl",
        ["riot"] = "models/player/Group01/male_01.mdl",
    },
    [2] = {
        ["tdm"] = "models/player/Group01/male_01.mdl",
        ["hl2dm"] = "models/player/combine_soldier.mdl",
        ["riot"] = "models/player/swat.mdl",
    },
}

local TranslateColorInRouund = {
    [1] = {
        ["tdm"] = Color(143,39,39),
        ["hl2dm"] = Color(141,84,23),
        ["riot"] = Color(141,84,23),
        ["hunter"] = Color(173,34,34),
        ["event"] = Color(0,255,0),
        ["dm"] = Color(34,33,33),
    },
    [2] = {
        ["tdm"] = Color(37,21,175),
        ["riot"] = Color(37,21,175),
        ["hl2dm"] = Color(37,21,175),
        ["hunter"] = Color(21,155,44),
        ["event"] = Color(0,255,0),
        ["dm"] = Color(34,33,33),
    }
}

local MADEL = "models/player/Group01/Male_01.mdl"

local madelki = {
    "models/player/Group01/Female_01.mdl",
    "models/player/Group01/Female_02.mdl",
    "models/player/Group01/Female_03.mdl",
    "models/player/Group01/Female_04.mdl",
    "models/player/Group01/Female_06.mdl",
    "models/player/Group01/Male_01.mdl",
    "models/player/Group01/male_02.mdl",
    "models/player/Group01/male_03.mdl",
    "models/player/Group01/Male_04.mdl",
    "models/player/Group01/Male_05.mdl",
    "models/player/Group01/male_06.mdl",
    "models/player/Group01/male_07.mdl",
    "models/player/Group01/male_08.mdl",
    "models/player/Group01/male_09.mdl",
}

local FastTDMArmors = {
    ["1"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "Altyn",
        ["tgl"]	 =	false,
    },
    ["2"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "Altyn Face Shield",
        ["tgl"]	 =	false,
    },
    ["3"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "TacTec",
        ["tgl"]	 =	false,
    },
}

local Beach = {
    ["1"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "Bastion",
        ["tgl"]	 =	false,
    },
    ["2"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "TT SK",
        ["tgl"]	 =	false,
    },
}

local BeachDM = {
    ["1"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "Balaclava (Black)",
        ["tgl"]	 =	false,
    },
    ["2"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "BSS-MK1",
        ["tgl"]	 =	false,
    },
    ["3"] = {
        ["col"] = {
            ["a"]	=	255,
            ["b"]	=	128,
            ["g"]	=	128,
            ["r"]	=	128,
        },
        ["name"] = "Crye AirFrame",
        ["tgl"]	 =	false,
    },
}

local ArmorsInRound = {
    ["tdm"] = {
        [1] = FastTDMArmors,
        [2] = FastTDMArmors,
    },
    ["hunter"] = {
        [1] = Beach,
    },
    ["hl2dm"] = {
        [1] = Beach,
    },
    ["dm"] = {
        [1] = BeachDM,
        [2] = BeachDM,
    },
}

function XXXCreateModelButton(bgrund, parent, mdl, teamCommand)
    local w, h = parent:GetSize()
    local posX, posY = 0, 0

    local fovchkhik = 44
    local mdlPanel = vgui.Create("DModelPanel", parent)
    mdlPanel:SetSize(w, h)
    mdlPanel:SetModel(mdl)
    mdlPanel.dbtn = nil
	mdlPanel:SetLookAt(mdlPanel:GetEntity():GetBonePosition(0))
	mdlPanel:SetFOV(fovchkhik)
    mdlPanel.TeamID = teamCommand
    mdlPanel.PostDrawModel = function(self, ent)
        if not IsValid(self) then return end
        if not IsValid(ent) then return end
        if ArmorsInRound == nil then return end
        if roundActiveName == nil then return end
        if teamCommand == nil then return end
        if ArmorsInRound[roundActiveName] == nil then return end
        if ArmorsInRound[roundActiveName][teamCommand] == nil then return end
		ent.Armors = (ArmorsInRound[roundActiveName][teamCommand] or {})
		JMod.HelloMyFriends(ent)
    end
    mdlPanel.Think = function(self)
        if teamCommand == 1 and (LocalPlayer():Team() == 1002 or roundActiveName == "homicide") then
            self:SetModel(MADEL)
        end
        if self.dbtn:IsHovered() then
            fovchkhik = VLerp(0.15, fovchkhik or 44, 40)
        else
            fovchkhik = VLerp(0.15, fovchkhik or 44, 44)
        end
        local clrt = TranslateColorInRouund[self.TeamID][roundActiveName] or Color(255,255,255,255)
        self.Entity.playerColor = clrt:ToVector()
        self:SetFOV(fovchkhik)
    end
    function mdlPanel:LayoutEntity(ent)
		ent:SetAngles( Angle( 0, 45, 0 ) )
	end

    local btn = vgui.Create("DButton", parent)
    btn:SetSize(w, h)
    btn:SetPos(posX, posY)
    btn:SetText("")
    btn.modelPanel = mdlPanel
    btn.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 200))
    end
    btn.DoClick = function()
        RunConsoleCommand("changeteam", teamCommand)
        bgrund:AlphaTo(0, 0.2, 0, nil)
    end
    btn.Paint = function(self, w, h)
        draw.SimpleText((TranslateNameInRound[teamCommand][roundActiveName] or "?"), "DefaultSmall", w/2, 10, Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    mdlPanel.dbtn = btn
    
    return btn
end

function CreateTeamChangeGood()
    if IsValid(backgroundmkndhmvcd) then return end
    local backgroundmkndhmvcd = vgui.Create("DFrame")
    backgroundmkndhmvcd:SetSize(ScrW(), ScrH()) 
    backgroundmkndhmvcd:SetPos(0, 0)
    backgroundmkndhmvcd:SetAlpha(3)
    backgroundmkndhmvcd:SetTitle("")
    backgroundmkndhmvcd:ShowCloseButton(false)
    backgroundmkndhmvcd:SetDraggable(false)
    backgroundmkndhmvcd:MakePopup()
    backgroundmkndhmvcd.Paint = function(self, w, h)
        local gradient = Material("vgui/gradient-r") 
		
        draw.RoundedBox(12, 0, 0, w, h, Color(0, 0, 0, self:GetAlpha()-20))

        surface.SetDrawColor(0, 0, 0, self:GetAlpha()+20)
        surface.SetMaterial(gradient)
        surface.DrawTexturedRect(0, 0, w, h)
        draw.SimpleText("Выбор команды", "TargetIDSmall", ScrW() / 2, ScrH() / 3.5, Color(255,255,255,255), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    backgroundmkndhmvcd:AlphaTo(220, 0.2, 0, nil)
    
    backgroundmkndhmvcd.Think = function(self)
        if self:GetAlpha() <= 2 then
            self:Remove()
        end
        timer.Simple(1, function()
            if input.IsKeyDown(KEY_F2) then
                if IsValid(self) then
                    self:AlphaTo(0, 0.2, 0, nil)
                end
            end
        end)
    end

    local frame = vgui.Create("DPanel", backgroundmkndhmvcd)
    frame:SetSize(300, 60)
    frame:SetPos(ScrW() / 2 - 150, ScrH() / 1.2)
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 250))
    end

    local isoneteam = false
    if roundActiveName == "homicide" or roundActiveName == "event" or roundActiveName == "dm" then
        isoneteam = true
    end

    local Terrorist = vgui.Create("DPanel", backgroundmkndhmvcd)
    Terrorist:SetSize(270, 400)
    Terrorist:SetPos((not isoneteam and ScrW() / 2 - 300 or ScrW() / 2 - 140), ScrH() / 2 - 200)
    local dada_t = XXXCreateModelButton(backgroundmkndhmvcd, Terrorist, (TranslateModelInRound[1][roundActiveName] or LocalPlayer():GetModel()), 1)
    Terrorist.Paint = function(self, w, h)
        local gradient = Material("vgui/gradient-d") 
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 22, 22, 250))
        local sosal = LocalPlayer():GetPlayerColor()
        surface.SetDrawColor((not dada_t:IsHovered() and Color(49, 48, 48, 250) or (TranslateColorInRouund[1][roundActiveName] or Color(255,255,255,255))))
        surface.SetMaterial(gradient)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    if not isoneteam then
        local CT = vgui.Create("DPanel", backgroundmkndhmvcd)
        CT:SetSize(270, 400)
        CT:SetPos(ScrW() / 2 + 30, ScrH() / 2 - 200)
        local dada_ct = XXXCreateModelButton(backgroundmkndhmvcd, CT, (TranslateModelInRound[2][roundActiveName] or LocalPlayer():GetModel()), 2)
        CT.Paint = function(self, w, h)
            local gradient = Material("vgui/gradient-d") 
            draw.RoundedBox(8, 0, 0, w, h, Color(25, 22, 22, 250))
            local sosal = LocalPlayer():GetPlayerColor()
            surface.SetDrawColor((not dada_ct:IsHovered() and Color(49, 48, 48, 250) or (TranslateColorInRouund[2][roundActiveName] or Color(255,255,255,255))))
            surface.SetMaterial(gradient)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end

    local btnSpectator = vgui.Create("DButton", frame)
    btnSpectator:SetSize(280, 40)
    btnSpectator:SetPos(10, 10)
    btnSpectator:SetText("")
    btnSpectator.DoClick = function()
        RunConsoleCommand("changeteam", 1002)
        backgroundmkndhmvcd:AlphaTo(0, 0.2, 0, nil)
    end

    btnSpectator.Paint = function(self,w,h)
        draw.RoundedBox(6, 0, 0, w, h, (LocalPlayer():Team() != 1002 and Color(54,54,54,200) or Color(98,96,96,200)))
        draw.SimpleText("Наблюдатель", "DefaultSmall", w/2, h/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    return backgroundmkndhmvcd
end

timer.Create("ChangeModelKrasivo", 0.5, 0, function()
    MADEL = table.Random(madelki)
end)

net.Receive("GG_ShowTeam", function(len,ply)
    CreateTeamChangeGood()
end)

net.Receive("INV_UpdateLoot", function()
    local index = net.ReadInt(6)
    if IsValid(contmenu) then
        local itembutton = FindItemIndex(contmenu, index)
        if IsValid(itembutton) then
            itembutton.movingremove = true
            itembutton:MoveTo(itembutton.posx,itembutton.posy+90,0.25,0,0.8,nil)
            itembutton:AlphaTo(2, 0.25, 0, nil)
            timer.Simple(0.26, function()
                if IsValid(itembutton) then
                    table.RemoveByValue(itemButtons, itembutton)
                    itembutton:Remove()
                    RefreshItemPositions()
                end
            end)
        end
    end
end)