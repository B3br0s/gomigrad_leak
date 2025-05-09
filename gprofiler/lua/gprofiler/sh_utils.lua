if CLIENT then
	GProfiler.Menu = GProfiler.Menu or {}

	local MenuColors = GProfiler.MenuColors
	local BorderColor = MenuColors.DListColumnOutline
	local TabPadding = 10

	local draw = draw
	local table = table
	local ipairs = ipairs
	local string = string
	local surface = surface

	local function PaintEmpty() end

	local function PaintColumn(s, w, h)
		if k == columnCount then return end
		surface.SetDrawColor(BorderColor.r, BorderColor.g, BorderColor.b, BorderColor.a)
		surface.DrawRect(w - 2, 0, 2, h)
	end

	local function PaintLine(s, w, h)
		if s:IsHovered() then
			draw.RoundedBox(2, 0, 0, w, h, MenuColors.DListRowHover)
		else
			draw.RoundedBox(2, 0, 0, w, h, MenuColors.DListRowBackground)
		end

		if s:IsLineSelected() then
			draw.RoundedBox(2, 0, 0, w, h, MenuColors.DListRowSelected)
		end
	end

	local function PaintHeader(s, w, h)
		draw.RoundedBox(1, 0, 0, w, h, MenuColors.DListColumnOutline)
		draw.RoundedBox(1, 1, 1, w - 2, h - 2, MenuColors.DListColumnBackground)

		if s:IsHovered() then
			draw.RoundedBox(1, 0, 0, w, h, MenuColors.DListColumnOutline)
		end
	end

	function GProfiler.StyleDListView(v)
		local Columns = v.Columns
		for k, v1 in ipairs(Columns) do
			v1.Header:SetFont("GProfiler.Menu.ListHeader")
			v1.Header.Paint = PaintHeader
			v1.Header:SetTextColor(MenuColors.White)
		end

		local Lines = v.Lines
		for k, v in ipairs(Lines) do
			local columnCount = table.Count(v.Columns)
			for k, v in ipairs(v.Columns) do
				v:SetTextColor(MenuColors.DListRowTextColor)
				v.Paint = PaintColumn
			end
			v.Paint = PaintLine
		end

		GProfiler.StyleScrollbar(v)

		function v:Paint(w, h)
			draw.RoundedBox(2, 0, 0, w, h, MenuColors.DListBackground)
			surface.SetDrawColor(BorderColor.r, BorderColor.g, BorderColor.b, BorderColor.a)
			surface.DrawOutlinedRect(0, 0, w, h)
		end
	end

	local function PaintGrip(s, w, h)
		draw.RoundedBox(2, 0, 0, w, h, MenuColors.ScrollBarGripOutline)
		draw.RoundedBox(2, 1, 1, w - 2, h - 2, MenuColors.ScrollBarGrip)

		if s:IsHovered() or s.Depressed then
			draw.RoundedBox(2, 0, 0, w, h, MenuColors.ScrollBarGripOutline)
		end
	end

	local function PaintScrollbar(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, MenuColors.ScrollBar)
	end

	function GProfiler.StyleScrollbar(v)
		local ScrollBar = v.VBar or (v.GetVBar and v:GetVBar()) or nil
		if not IsValid(ScrollBar) then return end
		ScrollBar.btnUp:SetVisible(false)
		ScrollBar.btnDown:SetVisible(false)
		ScrollBar.Paint = PaintScrollbar
		ScrollBar.btnGrip.Paint = PaintGrip
		ScrollBar.PerformLayout = function()
			local wide = ScrollBar:GetWide()
			local scroll = ScrollBar:GetScroll() / ScrollBar.CanvasSize
			local barSize = math.max(ScrollBar:BarScale() * (ScrollBar:GetTall() - (wide * 2)), 10)
			local track = ScrollBar:GetTall() - (wide * 2) - barSize

			ScrollBar.btnGrip:SetPos(0, (wide + (scroll * (track + 3))) - 16)
			ScrollBar.btnGrip:SetSize(wide, barSize + 30)
		end
	end

	local function PaintSeperator(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, MenuColors.HeaderSeparator)
	end

	function GProfiler.Menu.CreateHeader(parent, text, x, y, w, h)
		local header = vgui.Create("DPanel", parent)
		header:SetSize(w, h)
		header:SetPos(x, y)
		header.Paint = PaintEmpty

		local headerText = vgui.Create("DLabel", header)
		headerText:SetFont("GProfiler.Menu.SectionHeader")
		headerText:SetText(text)
		headerText:SizeToContents()
		headerText:SetPos(TabPadding, header:GetTall() / 2 - headerText:GetTall() / 2)
		headerText:SetTextColor(MenuColors.White)

		local separator = vgui.Create("DPanel", header)
		separator:SetSize(header:GetWide() - TabPadding * 2, 1)
		separator:SetPos(TabPadding, header:GetTall() - 1)
		separator.Paint = PaintSeperator

		return header, headerText
	end

	local function PaintRealmSelector(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, MenuColors.ButtonOutline)
		draw.RoundedBox(4, 1, 1, w - 2, h - 2, MenuColors.ButtonBackground)

		if s:IsHovered() then
			draw.RoundedBox(4, 1, 1, w - 2, h - 2, MenuColors.ButtonHover)
		end
	end

	function GProfiler.Menu.CreateRealmSelector(parent, profiler, x, y, w, h, onSelect)
		local RealmSelector = vgui.Create("DComboBox", parent)
		RealmSelector:SetPos(x, y)
		RealmSelector:SetValue(string.format("%s: %s", GProfiler.Language.GetPhrase("realm"), GProfiler.Language.GetPhrase(string.format("realm_%s", GProfiler[profiler].Realm:lower()))))
		RealmSelector:AddChoice("Server", nil, nil, 'icon16/server.png')
		RealmSelector:AddChoice("Client", nil, nil, 'icon16/computer.png')
		RealmSelector:SetTextColor(MenuColors.White)
		RealmSelector:SetFont("GProfiler.Menu.RealmSelector")
		RealmSelector:SizeToContents()
		RealmSelector:SetTall(h)
		RealmSelector:SetWide(RealmSelector:GetWide() + 10)
		RealmSelector.OnSelect = onSelect
		RealmSelector.Paint = PaintRealmSelector
		RealmSelector.Think = function(s)
			if GProfiler[profiler].ProfileActive then
				s:SetEnabled(false)
			else
				s:SetEnabled(true)
			end
		end
		RealmSelector.OldOpen = RealmSelector.OpenMenu
		function RealmSelector:OpenMenu(...)
			RealmSelector.OldOpen(self, ...)
			local tables = self.Menu:GetCanvas():GetChildren()

			for k, v in ipairs(tables) do
				v:SetTextColor(MenuColors.White)
				v:SetFont("GProfiler.Menu.RealmSelector")
				v:SetText(GProfiler.Language.GetPhrase(string.format("realm_%s", v:GetText():lower())))
				function v:Paint(w, h)
					draw.RoundedBox(4, 0, 0, w, h, MenuColors.ButtonOutline)
					draw.RoundedBox(4, 1, 1, w - 2, h - 2, MenuColors.ButtonBackground)

					if self:IsHovered() then
						draw.RoundedBox(4, 1, 1, w - 2, h - 2, MenuColors.ButtonHover)
					end
				end
			end
		end

		return RealmSelector
	end

	function GProfiler.TimeRunning(start, endd, profileActive)
		local time = 0

		if profileActive then
			time = SysTime() - start
		else
			time = endd - start
		end
		return string.format("%.2f", time)
	end

	function GProfiler.CopyLang(copy)
		copy = string.lower(string.Replace(copy, " ", "_"))
		return string.format("%s %s", GProfiler.Language.GetPhrase("copy"), GProfiler.Language.GetPhrase(copy))
	end

	function GProfiler.RequestFunctionSource(file, lineStart, lineEnd, callback)
		net.Start("GProfiler_RequestFunctionSource")
		net.WriteString(file)
		net.WriteUInt(lineStart, 32)
		net.WriteUInt(lineEnd, 32)
		net.SendToServer()

		local lines = {}
		net.Receive("GProfiler_RequestFunctionSource", function()
			local isFirst = net.ReadBool()
			local isLast = net.ReadBool()
			local count = net.ReadUInt(32)
			for i = 1, count do
				table.insert(lines, net.ReadString())
			end

			if isLast then
				callback(lines)
			end
		end)
	end
else
	util.AddNetworkString("GProfiler_RequestFunctionSource")

	-- Chunked net messages to avoid net message overflow
	local chunkSizeLimit = 65535 -- 187765611979610789976877

	net.Receive("GProfiler_RequestFunctionSource", function(l, ply)
		if not GProfiler.Access.HasAccess(ply) then return end

		local f = net.ReadString()
		local start = net.ReadUInt(32)
		local endd = net.ReadUInt(32)

		local res = GProfiler.ReadFunctionSource(f, start, endd)
		local chunkCount = 1
		local currentChunkSize = 0
		local chunks = {}
		if type(res) == "string" then res = {res} end
		for k, v in ipairs(res) do
			local str = string.Replace(v, "\t", "    ")
			if currentChunkSize + string.len(str) > (chunkSizeLimit - 1300) then
				chunkCount = chunkCount + 1
				currentChunkSize = 0
			end

			if not chunks[chunkCount] then chunks[chunkCount] = {} end
			table.insert(chunks[chunkCount], str)
			currentChunkSize = currentChunkSize + string.len(str)
		end

		for k, v in ipairs(chunks) do
			net.Start("GProfiler_RequestFunctionSource")
			net.WriteBool(k == 1)
			net.WriteBool(k == table.Count(chunks))
			net.WriteUInt(table.Count(v), 32)
			for k, v1 in ipairs(v) do
				net.WriteString(v1)
			end
			net.Send(ply)
		end
	end)

	function GProfiler.ReadFunctionSource(f, start, endd)
		if not file.Exists(f, "GAME") then return "" end
		if start < 0 or endd < 0 or endd < start then return "" end

		local f = file.Open(f, "r", "GAME")

		for i = 1, start - 1 do f:ReadLine() end

		local lines = {}
		for i = start, endd do table.insert(lines, f:ReadLine() or "") end

		return lines
	end
end

-- Shared util functions
function GProfiler.GetFunctionLocation(func)
	local info = debug.getinfo(func)
	if info.short_src == "[C]" then return "C" end
	return info.short_src .. ":" .. info.linedefined
end