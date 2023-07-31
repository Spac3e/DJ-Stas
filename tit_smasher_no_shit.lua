surface.CreateFont("ts font #1", {font = "Open Sans MS", size = 45})
surface.CreateFont("ts font #2", {font = "Courier New", size = 15, weight = 500, outline = true})
surface.CreateFont("gamer title", {font = "Trebuchet", size = 18, weight = 650})
surface.CreateFont("gamer tab", {font = "Trebuchet", size = 16, weight = 550})
local me = LocalPlayer()
ts = {}
ts.rang = {}
ts.cvars = {}
ts.ys = GetConVarNumber("m_yaw")
ts.aat = nil
ts.aas = false
ts.atk = false
ts.ld = false
ts.gd = false
ts.hm = 0
ts.dc = 0
ts.ct = 0
ts.flt = 0
ts.fltm = 0
ts.er = 0
ts.eg = 0
ts.eb = 0
ts.fa = nil
ts.sp = nil
ts.ep = nil
ts.atl = 0

function ts.Log(...)
	MsgC(Color(5, 130, 255), "[TitaniumSmasher] ", Color(255, 190, 5), ...)
	MsgN("")
end

ts.Log("Loading...")

function ts.CreateConsoleVar(name, default)
	local ret = CreateClientConVar(name, default)
	ts.cvars[name] = tostring(default)
	ts.Log("Created convar: ", Color(255, 120, 5), name, Color(255, 0, 0), " (default: " .. tostring(default) .. ", value: ", ret:GetString(), ")")
	return ret
end

ts.vars = {
	aimbot = {
		enabled = ts.CreateConsoleVar("ts_aimbot", 1),
		point = ts.CreateConsoleVar("ts_aimbot_point", 0.5),
		multipoint = ts.CreateConsoleVar("ts_aimbot_multipoint", 1),
		mpmode = ts.CreateConsoleVar("ts_aimbot_multipoint_mode", 1),
		autowall = ts.CreateConsoleVar("ts_aimbot_autowall", 0),
		silent = ts.CreateConsoleVar("ts_aimbot_silent", 1),
		nospread = ts.CreateConsoleVar("ts_aimbot_nospread", 1),
		bodyaim = ts.CreateConsoleVar("ts_aimbot_body", 0),
		static = ts.CreateConsoleVar("ts_aimbot_staticaa", 1),
		nextshot = ts.CreateConsoleVar("ts_aimbot_nextshot", 1),
		autoshoot = ts.CreateConsoleVar("ts_aimbot_autoshoot", 1),
		team = ts.CreateConsoleVar("ts_aimbot_ignoreteam", 1),
		friends = ts.CreateConsoleVar("ts_aimbot_ignorefriends", 0)
	},

	visuals = {
		esp = ts.CreateConsoleVar("ts_visuals_esp", 1),
		name = ts.CreateConsoleVar("ts_visuals_esp_name", 1),
		box = ts.CreateConsoleVar("ts_visuals_esp_box", 1),
		weapon = ts.CreateConsoleVar("ts_visuals_esp_weapon", 1),
		rank = ts.CreateConsoleVar("ts_visuals_esp_rank", 1),
		angles = ts.CreateConsoleVar("ts_visuals_esp_angles", 1),
		health = ts.CreateConsoleVar("ts_visuals_esp_health", 1),
		snapline = ts.CreateConsoleVar("ts_visuals_snapline", 1),
		chams = ts.CreateConsoleVar("ts_visuals_chams", 1),
		wepchams = ts.CreateConsoleVar("ts_visuals_wepchams", 1),
		watermark = ts.CreateConsoleVar("ts_visuals_watermark", 1),
		fullbright = ts.CreateConsoleVar("ts_visuals_fullbright", 1),
		asus = ts.CreateConsoleVar("ts_visuals_asuswalls", 1),
		viewmodel = ts.CreateConsoleVar("ts_visuals_viewmodel", 1),
		fov = ts.CreateConsoleVar("ts_visuals_fov", 90)
	},

	misc = {
		autohop = ts.CreateConsoleVar("ts_misc_autohop", 1),
		highjump = ts.CreateConsoleVar("ts_misc_highjump", 0),
		thirdperson = ts.CreateConsoleVar("ts_thirdperson", 1),
		killspam = ts.CreateConsoleVar("ts_misc_killspam", 0),
		ksmode = ts.CreateConsoleVar("ts_misc_killspam_mode", 1),
		robo = ts.CreateConsoleVar("ts_misc_killspam_robo", 1),
		autostrafe = ts.CreateConsoleVar("ts_misc_autostrafe", 1),
		autogain = ts.CreateConsoleVar("ts_misc_autostrafe_gain", 1),
		autogainmin = ts.CreateConsoleVar("ts_misc_autostrafe_gain_min", 1.25),
		autogainmax = ts.CreateConsoleVar("ts_misc_autostrafe_gain_max", 5.25),
		autogainmult = ts.CreateConsoleVar("ts_misc_autostrafe_gain_velmult", 0.01),
		autogainkey = ts.CreateConsoleVar("ts_misc_autostrafe_gain_key", "f"),
		walkbot = ts.CreateConsoleVar("ts_misc_walkbot", 0),
		walkbotrec = ts.CreateConsoleVar("ts_misc_walkbot_rec", 0)
	},

	hvh = {
		antiaim = ts.CreateConsoleVar("ts_hvh_antiaim", 1),
		edge = ts.CreateConsoleVar("ts_hvh_aa_edge", 1),
		edgemet = ts.CreateConsoleVar("ts_hvh_aa_edge_met", 1),
		adaptive = ts.CreateConsoleVar("ts_hvh_aa_adaptive", 1),
		adapyaw = ts.CreateConsoleVar("ts_hvh_adap_yaw", 450),
		adapmax = ts.CreateConsoleVar("ts_hvh_adap_max", 15),
		adapspeed = ts.CreateConsoleVar("ts_hvh_adap_speed", 1),
		fakeangles = ts.CreateConsoleVar("ts_hvh_aa_fakeangles", 0),
		pitch = ts.CreateConsoleVar("ts_hvh_aa_pitch", -91),
		pitchrand = ts.CreateConsoleVar("ts_hvh_aa_pitch_addrand", 1),
		pitchrandmin = ts.CreateConsoleVar("ts_hvh_aa_pitch_rand_min", -3),
		pitchrandmax = ts.CreateConsoleVar("ts_hvh_aa_pitch_rand_max", 3),
		yaw = ts.CreateConsoleVar("ts_hvh_aa_yaw", -541),
		roll = ts.CreateConsoleVar("ts_hvh_aa_roll", 0),
		fakelag = ts.CreateConsoleVar("ts_hvh_fakelag", 0),
		flchtse = ts.CreateConsoleVar("ts_hvh_fl_chtse", 9),
		flsend = ts.CreateConsoleVar("ts_hvh_fl_send", 4),
		aaa = ts.CreateConsoleVar("ts_hvh_antiaa", 1)
	}
}

ts.pitches = {
	["-89"] = {
		-1.05,
	},

	["89"] = {
		-5.00,
		1.05,
	}
}

ts.cones = {}

function ts.GetCone(wep)
	local cone = 0
	if !wep then return nil end
	if wep.Cone then cone = wep.Cone end
	if wep.Primary and wep.Primary.Cone then cone = wep.Primary.Cone end
	if wep.Secondary and wep.Secondary.Cone then cone = wep.Secondary.Cone end
	if cone != 0 then return Vector(-cone, -cone, -cone) end
	return nil
end

function ts.Compensate(cmd, ang)
	local wep = me:GetActiveWeapon()
	if !IsValid(wep) then return ang end
	local cone = ts.cones[wep:GetClass()]
	if !cone then return ang end
	return (ts.vars["aimbot"]["nospread"]:GetBool() and dickwrap.Predict(cmd, ang:Forward(), cone):Angle()) or ang
end

ts.pti = 0

function ts.SetTickInterval()
	local interp = GetConVar("cl_interp"):GetFloat()
	local ratio = GetConVar("cl_interp_ratio"):GetFloat()
	local updaterate = GetConVar("cl_updaterate"):GetFloat()
	local interpolation = math.max(interp, ratio / updaterate)
	ts.pti = engine.TickInterval() * interpolation
end

function ts.CheckVis(ent)
	local bodyaim = ts.vars["aimbot"]["bodyaim"]:GetBool()
	local sp = me:GetShootPos()
	local ep
	local bone, ang, min, max
	if bodyaim then
		bone, ang = ent:GetBonePosition(ent:GetHitBoxBone(15, 0))
		min, max = ent:GetHitBoxBounds(15, 0)
		min:Rotate(ang)
		max:Rotate(ang)
		ep = bone + ((min + max) * ts.vars["aimbot"]["point"]:GetFloat())
	else
		bone, ang = ent:GetBonePosition(ent:GetHitBoxBone(0, 0))
		min, max = ent:GetHitBoxBounds(0, 0)
		min:Rotate(ang)
		max:Rotate(ang)
		ep = bone + ((min + max) * ts.vars["aimbot"]["point"]:GetFloat())
	end

	local evel = ent:GetVelocity()
	local mevel = me:GetVelocity()
	local ti = engine.TickInterval()
	local rft = RealFrameTime()
	ep = ep + ((evel * ti * rft) - (mevel * ti * rft))
	local tdata = {
		start = sp,
		endpos = ep,
		filter = {ent, me},
		mask = MASK_SHOT
	}

	local trace = util.TraceLine(tdata)
	if trace.Fraction != 1 and ts.vars["aimbot"]["multipoint"]:GetBool() then
		local mode = ts.vars["aimbot"]["mpmode"]:GetInt()
		if mode == 1 then // corners
			local tests = {
				Vector(min.x, min.y, min.z),
				Vector(min.x, max.y, min.z),
				Vector(max.x, max.y, min.z),
				Vector(max.x, min.y, min.z),
				Vector(min.x, min.y, max.z),
				Vector(min.x, max.y, max.z),
				Vector(max.x, max.y, max.z),
				Vector(max.x, min.y, max.z)
			}

			for i = 1, #tests do
				ep = bone + tests[i]
				ep = ep + ((evel * ti * rft) - (mevel * ti * rft))
				tdata.endpos = ep
				trace = util.TraceLine(tdata)
				if trace.Fraction == 1 then
					return true, sp, ep
				end
			end
		else // hitscan
			local group = 0
			for hitbox = 0, ent:GetHitBoxCount(group) - 1 do
				bone, ang = ent:GetBonePosition(ent:GetHitBoxBone(hitbox, group))
				min, max = ent:GetHitBoxBounds(hitbox, group)
				min:Rotate(ang)
				max:Rotate(ang)
				ep = bone + ((min + max) * 0.5)
				ep = ep + ((evel * ti * rft) - (mevel * ti * rft))
				tdata.endpos = ep
				trace = util.TraceLine(tdata)
				if trace.Fraction == 1 then
					return true, sp, ep
				end
			end
		end
	end

	return trace.Fraction == 1, sp, ep
end

function ts.CanWallbang(sp, ep, ent)
    local tdata = {
    	start = sp,
    	endpos = ep,
    	filter = {ent, me},
    	mask = 1577075107
    }

    local wall = util.TraceLine(tdata)
    tdata.start = ep 
    tdata.endpos = sp
    local wall2 = util.TraceLine(tdata)
    if 17.49 > (wall2.HitPos - wall.HitPos):Length2D() then
    	return true
    else
    	return false
    end
end

function ts.GetTarget()
	local vis
	ts.sp, ts.ep, ts.aat = nil, nil, nil

	for k,v in next, player.GetAll() do
		if !ts.vars["aimbot"]["enabled"]:GetBool() or !v or !v:IsPlayer() or 0 >= v:Health() or v:IsDormant() or v == me then continue end
		if ts.vars["aimbot"]["team"]:GetBool() and v:Team() == me:Team() then continue end
		if ts.vars["aimbot"]["friends"]:GetBool() and v:GetFriendStatus() == "friend" then continue end
		local sp, ep
		vis, sp, ep = ts.CheckVis(v)
		ts.aat = v
		if vis or (ts.vars["aimbot"]["autowall"]:GetBool() and ts.CanWallbang(sp, ep, v)) then ts.sp = sp ts.ep = ep break else continue end
	end
end

function ts.DoSilent(cmd)
	if !ts.fa then ts.fa = cmd:GetViewAngles() end
	ts.fa = ts.fa + Angle(cmd:GetMouseY() * ts.ys, cmd:GetMouseX() * -ts.ys, 0)
	ts.fa.p = math.Clamp(ts.fa.p, -89, 89)
	ts.fa.y = math.NormalizeAngle(ts.fa.y)
end

function ts.FixMove(cmd, ang)
	local angs = cmd:GetViewAngles()
	local fa = ts.fa
	if ang then
		fa = ang
	end

	local viewang = Angle(0, angs.y, 0)
	local fix = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), 0)
	fix = (fix:Angle() + (viewang - fa)):Forward() * fix:Length()
	
	if angs.p > 90 or angs.p < -90 then
		fix.x = -fix.x
	end
	
	cmd:SetForwardMove(fix.x)
	cmd:SetSideMove(fix.y)
end

function ts.GetCurTime()
	if IsFirstTimePredicted() then
		ts.ct = CurTime() + engine.TickInterval()
	end
end

function ts.CanFire(nextshot)
	if !nextshot then return true end
	if !ts.ct or ts.ct == 0 then return false end
	local wep = me:GetActiveWeapon() or NULL
	if !IsValid(wep) then return false end
	return wep:GetActivity() != ACT_RELOAD and ts.ct > wep:GetNextPrimaryFire()
end

ts.as_max = 10^4
ts.as_l = 400

function ts.AutoHop(cmd)
	if !ts.vars["misc"]["autohop"]:GetBool() or cmd:CommandNumber() == 0 then return end
	local autostrafe = ts.vars["misc"]["autostrafe"]:GetBool()
	if me:IsOnGround() and cmd:KeyDown(IN_JUMP) then
		cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_JUMP))
		if autostrafe then
			cmd:SetForwardMove(ts.as_max)
		end
	else
		if autostrafe and cmd:KeyDown(IN_JUMP) then
			local mousex = cmd:GetMouseX()
			if -1 > mousex or mousex > 1 then
				cmd:SetSideMove((mousex > 0) and 400 or -400)
			else
				cmd:SetForwardMove(5850 / me:GetVelocity():Length2D())
				cmd:SetSideMove((cmd:CommandNumber() % 2 == 0) and ts.as_l or -ts.as_l)
			end
		end

		cmd:RemoveKey(IN_JUMP)
	end
end

function ts.Aimbot(cmd)
	local autoshoot = ts.vars["aimbot"]["autoshoot"]:GetBool()
	local nextshot = ts.vars["aimbot"]["nextshot"]:GetBool()
	local silent = ts.vars["aimbot"]["silent"]:GetBool()
	local fakelag = ts.vars["hvh"]["fakelag"]:GetBool()
	local antiaim = ts.vars["hvh"]["antiaim"]:GetBool()
	local static = ts.vars["aimbot"]["static"]:GetBool()
	ts.DoSilent(cmd)
	if cmd:CommandNumber() == 0 and !ts.vars["misc"]["thirdperson"]:GetBool() and (silent or antiaim or ts.vars["misc"]["walkbot"]:GetBool()) then cmd:SetViewAngles(ts.fa) return end

	if !fakelag then
		bSendPacket = true
	end

	if ts.sp and ts.ep then
		local aafix = false
		local ap = ts.Compensate(cmd, (ts.ep - ts.sp):Angle())
		ap.p, ap.y = math.NormalizeAngle(ap.p), math.NormalizeAngle(ap.y)
		if ts.CanFire(nextshot) and (autoshoot or cmd:KeyDown(IN_ATTACK)) then
			if static then
				aafix = true
				ap.p = -ap.p - 540
				ap.y = ap.y + 180
			end
			
			cmd:SetViewAngles(ap)
			if autoshoot then
				if nextshot then
					cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_ATTACK))
				else
					if ts.atk then
						cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_ATTACK))
					else
						cmd:RemoveKey(IN_ATTACK)
					end

					ts.atk = !ts.atk
				end
			end

			if silent then
				ts.FixMove(cmd)
			end

			if !fakelag then
				bSendPacket = false
			end
		else
			if autoshoot and nextshoot then
				cmd:RemoveKey(IN_ATTACK)
			end

			if antiaim then
				ts.AntiAim(cmd, true)
			elseif silent then
				cmd:SetViewAngles(ts.fa)
			end

			if !fakelag then
				bSendPacket = true
			end
		end

		return
	end

	if antiaim or silent or ts.vars["misc"]["walkbot"]:GetBool() then
		cmd:SetViewAngles(ts.fa)
	end
end

ts.aa_as = false
ts.aa_a = 0
ts.as_y = 0

function ts.AntiAim(cmd, force)
	if cmd:CommandNumber() == 0 and !ts.vars["misc"]["thirdperson"]:GetBool() then return end
	if me:GetActiveWeapon() != NULL and me:GetActiveWeapon():GetClass():lower():find("knife") or 0 >= me:Health() then return end
	if !force and (ts.sp != nil or ts.ep != nil) then return end
	if !force and cmd:KeyDown(IN_ATTACK) then
		if ts.vars["aimbot"]["static"]:GetBool() then
			cmd:SetViewAngles(Angle(-ts.fa.p - 180, ts.fa.y + 180, 0))
			ts.FixMove(cmd)
		end

		return
	end

	if ts.vars["hvh"]["antiaim"]:GetBool() then
		local fakeangles = ts.vars["hvh"]["fakeangles"]:GetBool()
		local pitch = ts.vars["hvh"]["pitch"]:GetFloat() or 262
		if ts.vars["hvh"]["pitchrand"]:GetBool() then
			pitch = pitch + math.random(ts.vars["hvh"]["pitchrandmin"]:GetFloat(), ts.vars["hvh"]["pitchrandmax"]:GetFloat())
		end

		local yaw = ts.vars["hvh"]["yaw"]:GetFloat() or 450
		local roll = ts.vars["hvh"]["roll"]:GetFloat() or 0

		if ts.vars["hvh"]["adaptive"]:GetBool() then
			local adapmax = ts.vars["hvh"]["adapmax"]:GetInt()
			local adapspeed = ts.vars["hvh"]["adapspeed"]:GetInt()
			if ts.aa_a >= adapmax then
				ts.aa_a = adapmax
				ts.aa_as = false
			elseif -adapmax >= ts.aa_a then
				ts.aa_a = -adapmax
				ts.aa_as = true
			end

			if ts.aa_as then
				ts.aa_a = ts.aa_a + adapspeed
			else
				ts.aa_a = ts.aa_a - adapspeed
			end

			local adapyaw = ts.vars["hvh"]["adapyaw"]:GetFloat()
			local aay = (ts.aat and ts.aat != NULL) and ((ts.aat:GetPos() + ts.aat:OBBCenter()) - me:GetShootPos()):Angle().y or 0
			aay = aay + math.Rand(0.03, 0.08)
			if !fakeangles then
				cmd:SetViewAngles(Angle(pitch, aay + adapyaw + ts.aa_a, roll))
			else
				if bSendPacket then
					cmd:SetViewAngles(Angle(pitch, aay + adapyaw, roll))
				else
					cmd:SetViewAngles(Angle(pitch, aay + adapyaw - 90, roll))
				end
			end
		else
			if !fakeangles then
				cmd:SetViewAngles(Angle(pitch, yaw + math.Rand(0.03, 0.08), roll))
			else
				if bSendPacket then
					cmd:SetViewAngles(Angle(pitch, yaw + math.Rand(0.03, 0.08), roll))
				else
					cmd:SetViewAngles(Angle(pitch, yaw - 90 + math.Rand(0.03, 0.08) - 90, roll))
				end
			end
		end

		if ts.vars["hvh"]["edge"]:GetBool() then
			local setp = false
			local edge = false
			local ang = Angle(0, 0, 0)
			local eyepos = me:GetShootPos() - Vector(0, 0, 5)

			for y = 1, 8 do
				local tmp = Angle(0, y * 45, 0)
				local forward = tmp:Forward()
				forward = forward * 35

				local tdata
				local _filter = {}
				for k,v in next, player.GetAll() do
					_filter[k] = v
				end

				tdata = {start = eyepos, endpos = eyepos + forward, filter = _filter, mask = MASK_SOLID}
				local trace = util.TraceLine(tdata)
			
				if trace.Fraction != 1 then
					local negate = trace.HitNormal * -1
					tmp.y = negate:Angle().y
					
					local left = (tmp + Angle(0, 11.25, 0)):Forward() * 17.5
					local right = (tmp - Angle(0, 11.25, 0)):Forward() * 17.5
					tdata = {start = eyepos, endpos = eyepos + left, filter = _filter, mask = MASK_SOLID}
					local lt = util.TraceLine(tdata)
					tdata = {start = eyepos, endpos = eyepos + right, filter = _filter, mask = MASK_SOLID}
					local rt = util.TraceLine(tdata)
					local ltw = lt.Fraction == 1
					local rtw = rt.Fraction == 1

					local edgem = ts.vars["hvh"]["edgemet"]:GetInt()
					if edgem == 1 then
						if ltw or rtw then
							tmp.y = tmp.y + 180
						end

						ang.y = 270 - tmp.y + 360
					elseif edgem == 2 or edgem == 3 then
						ang.y = tmp.y + (edgem == 2 and 180 or 360)
					elseif edgem == 4 then
						if ltw or rtw then
							tmp.y = tmp.y + 180
						end

						ang.y = 270 - tmp.y + math.random(-15, 15) + math.Rand(0.03, 0.08)
					end

					edge = true
					break
				end
			end

			if edge then
				if !fakeangles then
					cmd:SetViewAngles(Angle(ang.p != 0 and ang.p or pitch, ang.y, roll))
				else
					if bSendPacket then
						cmd:SetViewAngles(Angle(ang.p != 0 and ang.p or pitch, ang.y, roll))
					else
						cmd:SetViewAngles(Angle(pitch, ang.y - 90, roll))
					end
				end
			end
		end

		pitch = cmd:GetViewAngles().p
		ts.aas = !ts.aas
		ts.FixMove(cmd)
	end
end

function ts.FakeLag(cmd)
	if cmd:CommandNumber() == 0 then return end
	local chtse = ts.vars["hvh"]["flchtse"]:GetInt()
	local send = ts.vars["hvh"]["flsend"]:GetInt()
	ts.fltm = chtse + send

	if ts.vars["hvh"]["fakelag"]:GetBool() then
		ts.flt = ts.flt + 1
		
		if ts.flt > ts.fltm then
			ts.flt = 1
		end

		if send >= ts.flt then
			bSendPacket = true
		else
			bSendPacket = false
		end
	end
end

function ts.CheckAAA(ply, ang)
	local pitch = ang.x
	local yaw = ang.y

	if pitch >= 90 and 180 > pitch then
		pitch = 89
	elseif pitch >= 180 then
		pitch = -89
	end

	if pitch > -0.1 and 0.1 > pitch and pitch != 0 then
		pitch = 89
		yaw = yaw + 180
	end

	ply:SetPoseParameter("aim_pitch", pitch)
	ply:SetPoseParameter("head_pitch", pitch)
	ply:SetRenderAngles(Angle(0, math.NormalizeAngle(yaw), 0))
	ply:InvalidateBoneCache()
end

function ts.HighJump(cmd)
	if !ts.vars["misc"]["highjump"]:GetBool() then return end
	local pos = me:GetPos()
	local tdata = {start = pos, endpos = pos - Vector(0, 0, 1337), mask = MASK_SOLID}
	local trace = util.TraceLine(tdata)
	local len = (pos - trace.HitPos).z
	if len > 25 and 51.5 > len then
		cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_DUCK))
	else
		cmd:RemoveKey(IN_DUCK)
	end
end

function ts.Visuals()
	if ts.vars["visuals"]["watermark"]:GetBool() then
		ts.er = math.sin(CurTime() * 4) * 127 + 128
		ts.eg = math.sin(CurTime() * 4 + 2) * 127 + 128
		ts.eb = math.sin(CurTime() * 4 + 4) * 127 + 128
		draw.SimpleText("TitaniumSmasher", "ts font #1", 4, 40, Color(ts.er, ts.eg, ts.eb), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	end

	for k,v in next, player.GetAll() do
		if !ts.vars["visuals"]["esp"]:GetBool() or !v:IsValid() or !v:IsPlayer() or !v:Alive() or 0 >= v:Health() then continue end
		if !ts.vars["misc"]["thirdperson"]:GetBool() and v == me then continue end
		local min, max = v:GetCollisionBounds()
		local pos = v:GetPos()
		local top, bottom = (pos + Vector(0, 0, max.z)):ToScreen(), (pos - Vector(0, 0, 8)):ToScreen()
		local middle = bottom.y - top.y
		local width = middle / 2.425

		if ts.vars["visuals"]["name"]:GetBool() then
			draw.SimpleText(v:Nick(), "ts font #2", bottom.x, top.y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end

		if ts.vars["visuals"]["box"]:GetBool() then
			surface.SetDrawColor(me:Team() == v:Team() and Color(0, 100, 255) or Color(200, 225, 0))
			surface.DrawOutlinedRect(bottom.x - width, top.y, width * 2, middle)
			surface.SetDrawColor(Color(0, 0, 0))
			surface.DrawOutlinedRect(bottom.x - width - 1, top.y - 1, width * 2 + 2, middle + 2)
			surface.DrawOutlinedRect(bottom.x - width + 1, top.y + 1, width * 2 - 2, middle - 2)
		end

		ts.drawpos = 0

		if ts.vars["visuals"]["weapon"]:GetBool() then
			local wep = v:GetActiveWeapon()
			if wep and wep != NULL then
				draw.SimpleText(wep.GetPrintName and wep:GetPrintName() or wep:GetClass(), "ts font #2", bottom.x, bottom.y + ts.drawpos, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				ts.drawpos = ts.drawpos + 10
			end
		end

		if ts.vars["visuals"]["rank"]:GetBool() then
			draw.SimpleText(v.GetUserGroup and v:GetUserGroup() or "__norank", "ts font #2", bottom.x, bottom.y + ts.drawpos, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			ts.drawpos = ts.drawpos + 10
		end

		if ts.vars["visuals"]["angles"]:GetBool() then
			if ts.rang[v] then
				local ang = ts.rang[v]
				draw.SimpleText("x: " .. tostring(math.Round(ang.x)) .. " y: " .. tostring(math.Round(ang.y)), "ts font #2", bottom.x, bottom.y + ts.drawpos, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				ts.drawpos = ts.drawpos + 10
			end
		end

		if ts.vars["visuals"]["health"]:GetBool() then
			local health = math.Clamp(v:Health(), 0, 100)
			local green = health * 2.55
			local red = 255 - green
			surface.SetDrawColor(Color(0, 0, 0))
			surface.DrawRect(bottom.x + width + 2, top.y - 1, 4, middle + 2)
			surface.SetDrawColor(Color(red, green, 0))
			local height = health * middle / 100
			surface.DrawRect(bottom.x + width + 3, top.y + (middle - height), 2, height)
		end
	end

	if ts.vars["visuals"]["snapline"]:GetBool() and ts.ep then
		local pos = ts.ep:ToScreen()
		if pos.visible then
			surface.SetDrawColor(Color(255, 255, 255))
			surface.DrawLine(ScrW() / 2, ScrH(), pos.x, pos.y)
		end
	end
end

ts.wepchams = CreateMaterial("wireless_weapon_mat", "VertexLitGeneric", {
	["$ignorez"] = 1,
	["$model"] = 1,
	["$basetexture"] = "models/debug/debugwhite"
})

ts.chams1 = CreateMaterial("wireless_gamer_mat", "VertexLitGeneric", {
	["$ignorez"] = 1,
	["$model"] = 1,
	["$basetexture"] = "models/debug/debugwhite"
})

ts.chams2 = CreateMaterial("wired_gamer_mat", "VertexLitGeneric", {
	["$ignorez"] = 0,
	["$model"] = 1,
	["$basetexture"] = "models/debug/debugwhite"
})

function ts.GetWepChamsColor()
	return 255 / 255, 255 / 255, 255 / 255
end

function ts.GetChamsColor(t, v)
	if t then
		if v then
			return 50 / 255, 200 / 255, 25 / 255
		else
			return 0, 100 / 255, 255 / 255
		end	
	else
		if v then
			return 200 / 255, 125 / 255, 0
		else
			return 200 / 255, 225 / 255, 0
		end
	end
end

function ts.Chams()
	for k,v in next, ents.GetAll() do
		if !ts.vars["visuals"]["wepchams"]:GetBool() or !v:IsValid() or !v:IsWeapon() then continue end
		cam.Start3D()
		render.MaterialOverride(ts.wepchams)
		render.SetColorModulation(ts.GetWepChamsColor(false))
		v:DrawModel()
		cam.End3D()
	end

	for k,v in next, player.GetAll() do
		if !ts.vars["visuals"]["chams"]:GetBool() or !v:IsValid() or !v:IsPlayer() or !v:Alive() or 0 >= v:Health() then continue end
		if !ts.vars["misc"]["thirdperson"]:GetBool() and v == me then continue end
		cam.Start3D()
		render.MaterialOverride(ts.chams1)
		render.SetColorModulation(ts.GetChamsColor(me:Team() == v:Team(), false))
		v:DrawModel()

		if v == me then
			render.SetColorModulation(ts.GetChamsColor(me:Team() == v:Team(), false))
		else
			render.SetColorModulation(ts.GetChamsColor(me:Team() == v:Team(), true))
		end

		render.MaterialOverride(ts.chams2)
		v:DrawModel()
		cam.End3D()
	end
end

function ts.CalcView(ply, pos, angle, fov, nearZ, farZ)
	local view = {}
	view.angles = (ts.vars["hvh"]["antiaim"]:GetBool() or ts.vars["aimbot"]["silent"]:GetBool() or ts.vars["misc"]["walkbot"]:GetBool()) and ts.fa or angle
	view.origin = ts.vars["misc"]["thirdperson"]:GetBool() and (pos - ts.fa:Forward() * 100) or pos
	view.fov = ts.vars["visuals"]["fov"]:GetInt()

	return view
end

function ts.ShouldDrawLocalPlayer()
	return ts.vars["misc"]["thirdperson"]:GetBool()
end

function ts.PreDrawOpaqueRenderables()
	for k,v in next, player.GetAll() do
		local ang = v:EyeAngles()
		ts.rang[v] = ang
		if ts.vars["hvh"]["aaa"]:GetBool() then
			ts.CheckAAA(v, ang)
		end
	end
end

function ts.ResetConsoleVars()
	for k,v in next, ts.cvars do
		me:ConCommand(k .. " " .. v)
		ts.Log("Reset convar: ", Color(255, 120, 5), k, Color(255, 0, 0), " (value: ", v, ")")
	end
end

function ts.FindPlayerWithID(userid)
	for k,v in next, player.GetAll() do
		if v:UserID() == userid then
			return v
		end
	end

	return false
end

function ts.PlayerHurt(data)
	if !ts.vars["misc"]["killspam"]:GetBool() or ts.vars["misc"]["ksmode"]:GetInt() == 2 then return end
	local health = data.health
	local id = data.userid
	local attackerid = data.attacker
	local target = ts.FindPlayerWithID(id)
	local attacker = ts.FindPlayerWithID(attackerid)
	if !target or !attacker then return end
	if attacker != NULL and target != NULL then
		if attacker == me then
			target.hits = target.hits and target.hits + 1 or 1
			target.hitsme = 0
			if health == 0 then
				if ts.vars["misc"]["robo"]:GetBool() then
					//MEGA.TextToSpeech("easy " .. tostring(target.hits) .. " tap")
				end

				me:ConCommand("say", "[SS] owned " .. target:Nick() .. " in " .. tostring(target.hits) .. " shot" .. (target.hits > 1 and "s" or ""))
				target.hits = 0
			end
		elseif target == me then
			attacker.hitsme = attacker.hitsme and attacker.hitsme + 1 or 1
			attacker.hits = 0
			if health == 0 then
				local pingadvantage = target:Ping() - attacker:Ping()
				if pingadvantage > 50 then
					me:ConCommand("say [SS] ping advantage: i have " .. tostring(pingadvantage) .. " more ping than " .. attacker:Nick())
				elseif attacker.hitsme > 1 then
					me:ConCommand("say [SS] it tots " .. attacker:Nick() .. " " .. tostring(attacker.hitsme) .. " shots to kill me")
					attacker.hitsme = 0
				else
					me:ConCommand("say [SS] i just got owned by " .. attacker:Nick())
				end
			end
		end
	end
end

function ts.EntityKilled(data)
	if !ts.vars["misc"]["killspam"]:GetBool() or ts.vars["misc"]["ksmode"]:GetInt() == 1 then return end
	local target = Entity(data.entindex_killed)
	local attacker = Entity(data.entindex_attacker)
	if !target or !attacker then return end
	if attacker != NULL and target != NULL then
		if attacker == me then
			if ts.vars["misc"]["robo"]:GetBool() then
				//MEGA.TextToSpeech("owned")
			end

			local str = "say [SS] owned"
			if target:IsPlayer() then
				str = str .. " " .. target:Nick()
			end

			me:ConCommand(str)
		elseif target == me then
			local str = "say [SS] i just got owned"
			if attacker:IsPlayer() then
				str = str .. " by " .. attacker:Nick()
			end

			me:ConCommand(str)
		end
	end
end

ts.ga_y = 0

function ts.AutoGain(cmd)
	if !ts.vars["misc"]["autogain"]:GetBool() or cmd:CommandNumber() == 0 then return end
	local min = ts.vars["misc"]["autogainmin"]:GetFloat()
	local max = ts.vars["misc"]["autogainmax"]:GetFloat()
	local mult = ts.vars["misc"]["autogainmult"]:GetFloat()
	ts.ga_y = ts.ga_y + math.Clamp((me:GetVelocity():Length2D() * mult), min, max)
	math.NormalizeAngle(ts.ga_y)

	local key = _G["KEY_" .. string.upper(ts.vars["misc"]["autogainkey"]:GetString())] or KEY_F
	if input.IsKeyDown(key) then
		cmd:SetForwardMove(10^4)
		cmd:SetSideMove(0)
		ts.FixMove(cmd, Angle(ts.fa.p, ts.ga_y, 0))
	end
end

ts.wbh = "x6Fkwbn"
ts.wbm = -1
ts.wbfs = nil
ts.wbwp = {}
ts.wbpd = 1
ts.wbnw = 1
ts.wblp = Vector()
ts.wbly = 0
ts.wbcm = nil

function ts.RecordVector(vec)
	ts.wbfs:WriteFloat(vec.x)
 	ts.wbfs:WriteFloat(vec.y)
  	ts.wbfs:WriteFloat(vec.z)
  	ts.wbfs:Flush()
end

function ts.Walkbot(cmd)
	local walkbot = ts.vars["misc"]["walkbot"]:GetBool()
	local wbrec = ts.vars["misc"]["walkbotrec"]:GetBool()
	if !walkbot and !wbrec then
		if ts.wfs then
			ts.wfs:Close()
		end

		ts.wbcm = nil
		ts.wbm = -1
		ts.wbnw = 1
		ts.wbpd = 1
		return
	end

	if wbrec then
		if !ts.wbfs then 
			ts.wbfs = file.Open("ts_wb_" .. util.CRC(game.GetMap()) .. ".dat", "wb", "DATA")
       
        	if ts.wbfs then
                ts.wbfs:Write(ts.wbh)
                ts.wbfs:Write(util.CRC(game.GetMap()))
                ts.wblp = me:GetPos()
            end
		end

		ts.wbcm = nil
		ts.wbm = 0
	elseif walkbot then
		if ts.wfs then
			ts.wfs:Close()
		end
		
		local fs = file.Open("ts_wb_" .. util.CRC(game.GetMap()) .. ".dat", "rb", "DATA")
        if fs and !ts.wbcm then
        	ts.wbcm = true
       		local head = fs:Read(#ts.wbh)
       		local mcrc = fs:Read(#util.CRC(game.GetMap()))
         	if head == ts.wbh then
            	if mcrc == util.CRC(game.GetMap()) then
                 	ts.wbpd = 1
                	ts.wbnd = 1
                   	ts.wbm = 1
                               
            		table.Empty(ts.wbwp) 
                 	local x = fs:ReadFloat()
                 	local y = fs:ReadFloat()
                	local z = fs:ReadFloat()
                               
                   	while x and y and z do
                       	table.insert(ts.wbwp, Vector(x, y, z))
                                       
                       	x = fs:ReadFloat()
                      	y = fs:ReadFloat()
                    	z = fs:ReadFloat()
                    end
              	else
                	ts.Log("Bad map crc for walkbot data file! Disabling")
                	ts.vars["misc"]["walkbot"]:SetBool(false)
                	ts.wbcm = nil
                	fs:Close()
                	return
            	end
          	else
           		ts.Log("Bad header for walkbot data file! Disabling")
           		ts.vars["misc"]["walkbot"]:SetBool(false)
           		ts.wbcm = nil
           		fs:Close()
           		return
         	end
               
         	fs:Close()
        elseif !fs then
        	ts.Log("Walkbot failed, no data for this map! Disabling")
        	ts.vars["misc"]["walkbot"]:SetBool(false)
        	ts.wbcm = nil
        	return
        end

		ts.wbm = 1
	end

   	local pos = me:GetPos()
  	if ts.wbfs then
      	if ts.wbm == 0 then
      		if math.abs(math.abs(ts.wbly) - math.abs(ts.fa.y)) > 10 and ts.wblp:Distance(pos) > 52 or ts.wblp:Distance(pos) > 392 then           
            	ts.wblp = pos
               	ts.wbly = ts.fa.y
                               
              	ts.RecordVector(util.QuickTrace(pos + me:OBBCenter(), pos - Vector(0, 0, 8192), me).HitPos)
          	end
      	end
  	end
       
  	if ts.wbm == 1 then
     	local vec = ts.wbwp[ts.wbnw] - pos
       	if vec:Length2D() < me:GetVelocity():Length2D() * 0.1 then
     		if ts.wbwp[ts.wbnw + ts.wbpd] then
       			ts.wbnw = ts.wbnw + ts.wbpd
        	else
        		if ts.wbpd == 1 then
        			ts.wbpd = -1
        		elseif ts.wbpd == -1 then
        			ts.wbpd = 1
        		end
          	end
     	end
       	
     	local ang = vec:Angle()
      	cmd:SetForwardMove(10^4)
      	cmd:SetSideMove(0)
      	ts.FixMove(cmd, Angle(ts.fa.p, ang.y, 0))
  	end
end

function ts.DrawWalkbotBox(v, c)
   	surface.SetDrawColor(c)
       
   	local b1 = (v + Vector(5, 5, 0)):ToScreen()
   	local b2 = (v + Vector(5, -5, 0)):ToScreen()
  	local b3 = (v + Vector(-5, 5, 0)):ToScreen()
  	local b4 = (v + Vector(-5, -5, 0)):ToScreen()
       
   	local t1 = (v + Vector(5, 5, 32)):ToScreen()
   	local t2 = (v + Vector(5, -5, 32)):ToScreen()
   	local t3 = (v + Vector(-5, 5, 32)):ToScreen()
  	local t4 = (v + Vector(-5, -5, 32)):ToScreen()
 
 	surface.DrawLine(b1.x, b1.y, b3.x, b3.y)
  	surface.DrawLine(b2.x, b2.y, b4.x, b4.y)
 	surface.DrawLine(b1.x, b1.y, b2.x, b2.y)
	surface.DrawLine(b3.x, b3.y, b4.x, b4.y)
       
 	surface.DrawLine(b1.x, b1.y, t1.x, t1.y)
  	surface.DrawLine(b2.x, b2.y, t2.x, t2.y)
  	surface.DrawLine(b3.x, b3.y, t3.x, t3.y)
  	surface.DrawLine(b4.x, b4.y, t4.x, t4.y)
       
  	surface.DrawLine(t1.x, t1.y, t3.x, t3.y)
  	surface.DrawLine(t2.x, t2.y, t4.x, t4.y)
  	surface.DrawLine(t1.x, t1.y, t2.x, t2.y)
  	surface.DrawLine(t3.x, t3.y, t4.x, t4.y)
end

function ts.DrawWalkbot()
 	if ts.wbm == 0 and ts.wbfs then
 		draw.SimpleText("WALKBOT RECORDING", "Trebuchet24", ScrW(), 0, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
 	elseif ts.wbm == 1 then
     	local prev
    	for k,v in next, ts.wbwp do
           	local scr = v:ToScreen()
         	if not scr.visible then continue end
                       
          	if prev and prev.x and prev.y then
           		surface.SetDrawColor(Color(255, 255, 255))
           		surface.DrawLine(prev.x, prev.y, scr.x, scr.y)
           	 end
                       
         	ts.DrawWalkbotBox(v, ts.wbnw == k and Color(50, 200, 25) or Color(225, 25, 10))
         	prev = scr
     	end
   	end
end

function ts.CreateMove(cmd)
	ts.AutoHop(cmd)
	ts.GetTarget()
	ts.Aimbot(cmd)
	ts.AntiAim(cmd)
	ts.FakeLag(cmd)
	ts.HighJump(cmd)
	ts.AutoGain(cmd)
	ts.Walkbot(cmd)
end

function ts.AddHots(htype, name, func)
	hook.Add(htype, name, func)
	ts.Log("Created ", Color(255, 120, 5), htype, Color(255, 190, 5), " hots: ", Color(255, 120, 5), name, Color(255, 0, 0), " (" .. tostring(func) .. ")")
end

ts.curtab = 0
ts.menuitems = {}

function ts.CreateTab(frame, name, index, max)
	local tab = vgui.Create("DButton", frame)
	tab:SetText("")
	tab:SetSize(frame:GetWide() / max - 1, 30)
	tab:SetPos((index - 1) * (tab:GetWide() + 1), 24)
	function tab.Paint(self, width, height)
		surface.SetDrawColor(Color(100, 100, 100))
		surface.DrawRect(0, 0, width, height)
		if ts.curtab == index then
			surface.SetDrawColor(Color(255, 255, 255, 15))
			surface.DrawRect(0, 0, width, height)
		end

		draw.SimpleText(name, "gamer tab", width / 2, height / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	function tab.DoClick()
		ts.curtab = index
		for i = 1, #ts.menuitems do
			local items = ts.menuitems[i]
			for k,v in next, items do
				v:SetVisible(i == index)
			end
		end
	end
end

function ts.CreateCheckbox(frame, name, tab, index, cvtab, cvname)
	local cvar = ts.vars[cvtab][cvname]
	local check = vgui.Create("DButton", frame)
	check:SetText("")
	surface.SetFont("gamer tab")
	local wid = surface.GetTextSize(name)
	check:SetSize(26 + wid, 18)
	local x = 10
	local y = 64 + (22 * (index - 1))
	if (y + 27) >= frame:GetTall() then
		local firstindex = 0
		for i = 1, index do
			local _y = 64 + (22 * (i - 1))
			if (_y + 27) >= frame:GetTall() then
				firstindex = i
				break
			end
		end

		x = (x * 2.5) + 192
		y = 64 + (22 * (index - (firstindex - 1) - 1))
	end

	check:SetPos(x, y)
	function check.Paint(self, width, height)
		surface.SetDrawColor(Color(100, 100, 100))
		surface.DrawOutlinedRect(0, 0, 18, height)
		if cvar:GetBool() then
			surface.DrawRect(0, 0, 18, height)
		end

		draw.SimpleText(name, "gamer tab", 24, height / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	function check.DoClick()
		cvar:SetBool(!cvar:GetBool())
	end

	if ts.curtab != tab then
		check:SetVisible(false)
	end

	ts.menuitems[tab][#ts.menuitems[tab] + 1] = check
end

function ts.CreateSlider(frame, name, tab, index, cvtab, cvname, min, max, dec)
	min = min * 10
	max = max * 10
	local cvar = ts.vars[cvtab][cvname]
	local slider = vgui.Create("DButton", frame)
	slider:SetText("")
	slider:SetSize(192, 32)
	local x = 10
	local y = 64 + (22 * (index - 1))
	if (y + 27) >= frame:GetTall() then
		local firstindex = 0
		for i = 1, index do
			local _y = 64 + (22 * (i - 1))
			if (_y + 27) >= frame:GetTall() then
				firstindex = i
				break
			end
		end

		x = (x * 2.5) + 192
		y = 64 + (22 * (index - (firstindex - 1) - 1))
	end

	slider:SetPos(x, y)
	function slider.Paint(self, width, height)
		draw.SimpleText(name .. " [" .. math.Round(cvar:GetFloat(), dec) .. "]", "gamer tab", width / 2, height / 2 - (height / 4), Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		surface.SetDrawColor(Color(100, 100, 100))
		surface.DrawRect(0, height / 1.25, width, 1)
		surface.DrawRect(math.Clamp(((cvar:GetFloat() * 10) - min) / (max - min) * width - 2, 0, width - 4), height / 1.25 - 4, 4, 8)
		if input.IsMouseDown(MOUSE_LEFT) then
			local fx, fy = frame:GetPos()
			local sx, sy = slider:GetPos()
			local rx = fx + sx
			local ry = fy + sy
			local ssx, ssy = slider:GetSize()
			local mx = gui.MouseX()
			local my = gui.MouseY()
			local rmx = mx - rx
			if ((mx >= rx) and ((rx + ssx) >= mx)) and ((my >= ry) and ((ry + ssy) >= my)) then
				cvar:SetFloat(math.Round(rmx / width * ((max / 10) - (min / 10)) + (min / 10), dec))
			end
		end
	end

	function slider.DoClick() end

	if ts.curtab != tab then
		slider:SetVisible(false)
	end

	ts.menuitems[tab][#ts.menuitems[tab] + 1] = slider
end

function ts.Menu()
	ts.menuitems = {{}, {}, {}, {}}
	local frame = vgui.Create("DFrame")
	frame:SetTitle("")
	frame:SetSize(600, 450)
	frame:SetPos(0, 0)
	frame:ShowCloseButton(false)
	frame:SetDraggable(false)
	frame:Center()
	frame:MakePopup()
	function frame.Paint(self, width, height)
		surface.SetDrawColor(Color(75, 75, 75))
		surface.DrawRect(0, 0, width, height)
		draw.SimpleText("TitaniumSmasher", "gamer title", width / 2, 12, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local close = vgui.Create("DButton", frame)
	close:SetText("")
	close:SetSize(24, 24)
	close:SetPos(frame:GetWide() - 24, 0)
	function close.Paint(self, width, height)
		surface.SetDrawColor(Color(255, 0, 0))
		surface.DrawRect(0, 0, width, height)
	end

	function close.DoClick()
		frame:Remove()
	end

	//// TABS \\
	ts.CreateTab(frame, "Aimbot", 1, 4)
	ts.CreateTab(frame, "Visuals", 2, 4)
	ts.CreateTab(frame, "Misc", 3, 4)
	ts.CreateTab(frame, "HvH", 4, 4)

	//// AIMBOT TAB \\
	ts.CreateCheckbox(frame, "Enabled", 1, 1, "aimbot", "enabled")
	ts.CreateSlider(frame, "Hitbox Point", 1, 2, "aimbot", "point", 0.01, 1, 2)
	ts.CreateCheckbox(frame, "Multi Point", 1, 4, "aimbot", "multipoint")
	ts.CreateSlider(frame, "Multi Point Mode", 1, 5, "aimbot", "mpmode", 1, 2, 0)
	ts.CreateCheckbox(frame, "AutoWall", 1, 7, "aimbot", "autowall")
	ts.CreateCheckbox(frame, "Silent", 1, 8, "aimbot", "silent")
	ts.CreateCheckbox(frame, "NoSpread", 1, 9, "aimbot", "nospread")
	ts.CreateCheckbox(frame, "BodyAim", 1, 10, "aimbot", "bodyaim")
	ts.CreateCheckbox(frame, "Static AA", 1, 11, "aimbot", "static")
	ts.CreateCheckbox(frame, "NextShot", 1, 12, "aimbot", "nextshot")
	ts.CreateCheckbox(frame, "AutoShoot", 1, 13, "aimbot", "autoshoot")
	ts.CreateCheckbox(frame, "Ignore Team", 1, 14, "aimbot", "team")
	ts.CreateCheckbox(frame, "Ignore Friends", 1, 15, "aimbot", "friends")

	//// VISUALS TAB \\
	ts.CreateCheckbox(frame, "ESP Enabled", 2, 1, "visuals", "esp")
	ts.CreateCheckbox(frame, "Name ESP", 2, 2, "visuals", "name")
	ts.CreateCheckbox(frame, "Box ESP", 2, 3, "visuals", "box")
	ts.CreateCheckbox(frame, "Weapon ESP", 2, 4, "visuals", "weapon")
	ts.CreateCheckbox(frame, "Rank ESP", 2, 5, "visuals", "rank")
	ts.CreateCheckbox(frame, "Angle ESP", 2, 6, "visuals", "angles")
	ts.CreateCheckbox(frame, "Healthbar", 2, 7, "visuals", "health")
	ts.CreateCheckbox(frame, "Snapline", 2, 8, "visuals", "snapline")
	ts.CreateCheckbox(frame, "Player Chams", 2, 9, "visuals", "chams")
	ts.CreateCheckbox(frame, "Weapon Chams", 2, 10, "visuals", "wepchams")
	ts.CreateCheckbox(frame, "Watermark", 2, 11, "visuals", "watermark")
	ts.CreateCheckbox(frame, "Fullbright", 2, 12, "visuals", "fullbright")
	ts.CreateCheckbox(frame, "ASUS Walls", 2, 13, "visuals", "asus")
	ts.CreateSlider(frame, "Viewmodel", 2, 14, "visuals", "viewmodel", 0, 2, 0)
	ts.CreateSlider(frame, "FOV", 2, 16, "visuals", "fov", 65, 125, 0)

	//// MISC TAB \\
	ts.CreateCheckbox(frame, "AutoHop", 3, 1, "misc", "autohop")
	ts.CreateCheckbox(frame, "HighJump", 3, 2, "misc", "highjump")
	ts.CreateCheckbox(frame, "Third Person", 3, 3, "misc", "thirdperson")
	ts.CreateCheckbox(frame, "KillSpam", 3, 4, "misc", "killspam")
	ts.CreateSlider(frame, "KillSpam Mode", 3, 5, "misc", "ksmode", 1, 2, 0)
	ts.CreateCheckbox(frame, "KillSpam TTS", 3, 7, "misc", "robo")
	ts.CreateCheckbox(frame, "AutoStrafe", 3, 8, "misc", "autostrafe")
	ts.CreateCheckbox(frame, "AutoGain", 3, 9, "misc", "autogain")
	ts.CreateSlider(frame, "AutoGain Min", 3, 10, "misc", "autogainmin", 0.75, 1.25, 2)
	ts.CreateSlider(frame, "AutoGain Max", 3, 12, "misc", "autogainmax", 4.25, 5.75, 2)
	ts.CreateSlider(frame, "AutoGain Multiplier", 3, 14, "misc", "autogainmult", 0.01, 0.035, 3)
	ts.CreateCheckbox(frame, "Walkbot", 3, 16, "misc", "walkbot")
	ts.CreateCheckbox(frame, "Record Path", 3, 17, "misc", "walkbotrec")

	//// HVH TAB \\
	ts.CreateCheckbox(frame, "AntiAim", 4, 1, "hvh", "antiaim")
	ts.CreateCheckbox(frame, "Edge AntiAim", 4, 2, "hvh", "edge")
	ts.CreateSlider(frame, "Edge Method", 4, 3, "hvh", "edgemet", 1, 4, 0)
	ts.CreateCheckbox(frame, "Adaptive AntiAim", 4, 5, "hvh", "adaptive")
	ts.CreateSlider(frame, "Adaptive Yaw", 4, 6, "hvh", "adapyaw", 270, 540, 0)
	ts.CreateSlider(frame, "Adaptive Max", 4, 8, "hvh", "adapmax", 2, 30, 0)
	ts.CreateSlider(frame, "Adaptive Speed", 4, 10, "hvh", "adapspeed", 1, 15, 0)
	ts.CreateSlider(frame, "AntiAim Pitch", 4, 12, "hvh", "pitch", -250, 250, 0)
	ts.CreateSlider(frame, "AntiAim Yaw", 4, 14, "hvh", "yaw", 270, 541, 0)
	ts.CreateSlider(frame, "AntiAim Roll", 4, 16, "hvh", "roll", -720, -360, 0)
	ts.CreateCheckbox(frame, "Add Rand Pitch", 4, 18, "hvh", "pitchrand")
	ts.CreateSlider(frame, "Rand Min", 4, 19, "hvh", "pitchrandmin", -15, 15, 0)
	ts.CreateSlider(frame, "Rand Max", 4, 21, "hvh", "pitchrandmax", 0, 45, 0)
	ts.CreateCheckbox(frame, "FakeLag", 4, 23, "hvh", "fakelag")
	ts.CreateSlider(frame, "FakeLag Chtse", 4, 24, "hvh", "flchtse", 2, 14, 0)
	ts.CreateSlider(frame, "FakeLag Send", 4, 26, "hvh", "flsend", 1, 14, 0)
	ts.CreateCheckbox(frame, "Anti-AntiAim", 4, 28, "hvh", "aaa")
end

ts.lmc = false
function ts.PreRender()
	if !ts.vars["visuals"]["fullbright"]:GetBool() then return end
	render.SetLightingMode(1)
	ts.lmc = true
end

function ts.PostRender()
	if !ts.vars["visuals"]["fullbright"]:GetBool() then return end
	if ts.lmc then
		render.SetLightingMode(0)
		ts.lmc = false
	end
end

function ts.PatchViewModel(vm, ply, wep)
	if !vm or !ply then return end
	local viewmodel = ts.vars["visuals"]["viewmodel"]:GetInt()
	if 0 >= viewmodel then return end
   	render.MaterialOverride((viewmodel == 1) and Material("models/wireframe") or Material("models/debug/debugwhite"))
   	render.SetColorModulation(0, 100 / 255, 255 / 255)
end

function ts.RenderScene()
	for k,v in next, game.GetWorld():GetMaterials() do
		local mat = Material(v)
		if ts.vars["visuals"]["asus"]:GetBool() then
			mat:SetFloat("$alpha", 0.75)
		else
			mat:SetFloat("$alpha", 1)
		end
	end
end

function ts.PostDraw2DSkyBox(ply, pos)
	if ts.vars["visuals"]["asus"]:GetBool() then
		render.Clear(0, 0, 0, 0, true, true)
	end
end

function ts.SetTickIntervalHots()
	ts.SetTickInterval()
end

ts.AddHots("Think", "ts.SetTickIntervalHots", ts.SetTickIntervalHots)
ts.AddHots("Move", "ts.GetCurTime", ts.GetCurTime)
ts.AddHots("DrawOverlay", "ts.Visuals", ts.Visuals)
ts.AddHots("RenderScreenspaceEffects", "ts.Chams", ts.Chams)
ts.AddHots("CreateMove", "ts.CreateMove", ts.CreateMove)
ts.AddHots("CalcView", "ts.CalcView", ts.CalcView)
ts.AddHots("ShouldDrawLocalPlayer", "ts.ShouldDrawLocalPlayer", ts.ShouldDrawLocalPlayer)
ts.AddHots("PreDrawOpaqueRenderables", "ts.PreDrawOpaqueRenderables", ts.PreDrawOpaqueRenderables)
ts.AddHots("PreRender", "ts.PreRender", ts.PreRender)
ts.AddHots("PostRender", "ts.PostRender", ts.PostRender)
ts.AddHots("PreDrawHUD", "ts.PostRender", ts.PostRender) // gmod becomes satanic without this
ts.AddHots("PreDrawViewModel", "ts.PatchViewModel", ts.PatchViewModel)
ts.AddHots("RenderScene", "ts.RenderScene", ts.RenderScene)
ts.AddHots("PostDraw2DSkyBox", "ts.PostDraw2DSkyBox", ts.PostDraw2DSkyBox)
ts.AddHots("DrawOverlay", "ts.DrawWalkbot", ts.DrawWalkbot)
gameevent.Listen("player_hurt")
ts.AddHots("player_hurt", "ts.PlayerHurt", ts.PlayerHurt)
gameevent.Listen("entity_killed")
ts.AddHots("entity_killed", "ts.EntityKilled", ts.EntityKilled)
concommand.Add("ts_menu", ts.Menu)
ts.Log("Created concommand: ", Color(255, 120, 5), "ts_menu", Color(255, 0, 0), " (" .. tostring(ts.Menu) .. ")")
concommand.Add("ts_resetcv", ts.ResetConsoleVars)
ts.Log("Created concommand: ", Color(255, 120, 5), "ts_resetcv", Color(255, 0, 0), " (" .. tostring(ts.ResetConsoleVars) .. ")")
ts.Log("Loaded!")