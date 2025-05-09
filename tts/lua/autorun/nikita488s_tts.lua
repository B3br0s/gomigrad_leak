-- "addons\\tts\\lua\\autorun\\nikita488s_tts.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
if SERVER then
    util.AddNetworkString("PlayTTS")

    -- Разрешённые группы для TTS
    local allowedGroups = {
        megasponsor  = true,
        operator     = true,
        doperator    = true,
        intern       = true,
        dadmin       = true,
        admin        = true,
        dsuperadmin  = true,
        superadmin   = true
    }

    hook.Add("PlayerSay", "OnPlayerSayTTS", function(sender, text)
        -- Проверка группы: озвучивать только для разрешённых
        if not allowedGroups[sender:GetUserGroup()] then return end

        net.Start("PlayTTS")
            net.WriteEntity(sender)
            net.WriteString(sender:GetInfo("cl_tts_type"))
            net.WriteString(sender:GetInfo("cl_tts_speaker"))
            net.WriteString(sender:GetInfo("cl_tts_emotion"))
            net.WriteString(text)
        net.Broadcast()
    end)

elseif CLIENT then
    -- Клиентские ConVar'ы с голосом Kostya по умолчанию
    CreateClientConVar("cl_tts_enable",   "1")
    CreateClientConVar("cl_tts_3d_sound", "0")
    CreateClientConVar("cl_tts_type",     "google", true, true)
    CreateClientConVar("cl_tts_speaker",  "kostya", true, true)
    CreateClientConVar("cl_tts_emotion",  "neutral", true, true)

    -- TTS URL-шаблоны
    list.Set("TTSUrls", "google", function(speaker, emotion, text)
        return string.format("https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=%s&q=%s", GetConVar("gmod_language"):GetString(), text)
    end)
    list.Set("TTSUrls", "yandex", function(speaker, emotion, text)
        return string.format("https://tts.voicetech.yandex.net/tts?speaker=%s&emotion=%s&text=%s", speaker, emotion, text)
    end)

    local CharToHex = function(char) return string.format("%%%02X", string.byte(char)) end
    local function UrlEncode(str)
        return str:gsub("[^%w _~%.%-]", CharToHex):gsub(" ", "+")
    end

    net.Receive("PlayTTS", function()
        if not GetConVar("cl_tts_enable"):GetBool() then return end

        local sender = net.ReadEntity()
        local tts_type = net.ReadString()
        local tts_speaker = net.ReadString()
        local tts_emotion = net.ReadString()
        local text = UrlEncode(net.ReadString())
        local url = list.GetForEdit("TTSUrls")[tts_type](tts_speaker, tts_emotion, text)
        local is_3d_sound = GetConVar("cl_tts_3d_sound"):GetBool()
        local sound_type = is_3d_sound and "3d" or "mono"

        sound.PlayURL(url, sound_type, function(sound_channel)
            if IsValid(sound_channel) then
                local tts_speech = {
                    speech = sound_channel,
                    speaker = sender,
                    is_3d = is_3d_sound
                }
                function tts_speech:IsValid()
                    return self.speech:GetState() == GMOD_CHANNEL_PLAYING
                end
                function tts_speech:UpdateSpeechPosition()
                    if self.is_3d then
                        self.speech:SetPos(self.speaker:GetPos())
                    end
                end
                hook.Add("Think", tts_speech, function(self) self:UpdateSpeechPosition() end)
                sound_channel:Play()
            end
        end)
    end)

    -- TTS настройки в меню
    list.Set("TTSTypes", "#nikita488.tts_settings.type.google", "google")
    list.Set("TTSTypes", "#nikita488.tts_settings.type.yandex", "yandex")

    list.Set("YandexTTSEmotions", "#nikita488.tts_settings.emotion.good",    "good")
    list.Set("YandexTTSEmotions", "#nikita488.tts_settings.emotion.evil",    "evil")
    list.Set("YandexTTSEmotions", "#nikita488.tts_settings.emotion.neutral", "neutral")

    -- Yandex голоса
    list.Set("YandexTTSSpeakers", "#nikita488.tts_settings.speaker.kostya", "kostya")
    list.Set("YandexTTSSpeakers", "#nikita488.tts_settings.speaker.zahar",  "zahar")
    list.Set("YandexTTSSpeakers", "#nikita488.tts_settings.speaker.ermil",  "ermil")
    -- ... остальные голоса без изменений ...

    local function ListBox(panel, strLabel, strConVar, tblOptions)
        local current_option = GetConVar(strConVar):GetString()
        local ctrl = vgui.Create("DListView", panel)
        ctrl:SetMultiSelect(false)
        ctrl:AddColumn(strLabel)
        for k, v in pairs(tblOptions) do
            local line = ctrl:AddLine(language.GetPhrase(k))
            line.argument = v
            if current_option == v then line:SetSelected(true) end
        end
        local line_height = ctrl:GetDataHeight()
        ctrl:SetTall(line_height + table.Count(tblOptions) * line_height)
        ctrl:SortByColumn(1, false)
        ctrl.OnRowSelected = function(_, _, Line)
            RunConsoleCommand(strConVar, Line.argument)
        end
        panel:AddItem(ctrl)
    end

    hook.Add("PopulateToolMenu", "PopulateTTSSettingsMenu", function()
        spawnmenu.AddToolMenuOption("Utilities", "User", "tts_settings", "#nikita488.spawnmenu.utilities.tts_settings", "", "", function(panel)
            panel:CheckBox("#nikita488.tts_settings.enable",   "cl_tts_enable")
            panel:CheckBox("#nikita488.tts_settings.3d_sound", "cl_tts_3d_sound")
            ListBox(panel, "#nikita488.tts_settings.type",    "cl_tts_type",     list.Get( "TTSTypes" ))
            ListBox(panel, "#nikita488.tts_settings.emotion","cl_tts_emotion", list.Get( "YandexTTSEmotions" ))
            ListBox(panel, "#nikita488.tts_settings.speaker","cl_tts_speaker", list.Get( "YandexTTSSpeakers" ))
        end)
    end)
end
