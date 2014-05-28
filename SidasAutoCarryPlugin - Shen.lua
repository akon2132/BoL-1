local version = 2.0
if not VIP_USER or myHero.charName ~= "Shen" then return end
--{ Initiate Script (Checks for updates)
	function Initiate()
		local scriptName = "JKshen"
		printMessage = function(message) print("<font color=\"#00A300\"><b>"..scriptName..":</b></font> <font color=\"#FFFFFF\">"..message.."</font>") end
		if FileExist(LIB_PATH.."SourceLib.lua") then
			require 'SourceLib'
		else
			printMessage("Downloading SourceLib, please wait whilst the required library is being downloaded.")
			DownloadFile("https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua",LIB_PATH.."SourceLib.lua", function() printMessage("SourceLib successfully downloaded, please reload (double [F9]).") end)
			return true
		end
		local libDownloader = Require(scriptName)
		libDownloader:Add("VPrediction", "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua")
		libDownloader:Add("SOW",		 "https://raw.githubusercontent.com/Hellsing/BoL/master/common/SOW.lua")
		libDownloader:Check()
		if libDownloader.downloadNeeded then printMessage("Downloading required libraries, please wait whilst the required files are being downloaded.") return true end
	    SourceUpdater(scriptName, version, "raw.github.com", "/LegendBot/Scripts/master/JKShen.lua", SCRIPT_PATH..GetCurrentEnv().FILE_NAME, "/LegendBot/Scripts/master/Versions/LegendKarthus.version"):CheckUpdate()
		return false
	end
	if Initiate() then return end
	printMessage("Loaded")
	
	--{ Script Load
	function OnLoad()
		--{ Variables
			VP = VPrediction(true)
			OW = SOW(VP)
			TS = SimpleTS(STS_LESS_CAST_MAGIC)
		    SpellQ = Spell(_Q, Shen.Q["range"])
			SpellW = Spell(_W, Shen.W["range"])
			SpellE = Spell(_E, Shen.E["range"]):SetSkillshot(VP, SKILLSHOT_LINEAR, Shen.E["width"], Shen.E["delay"], Shen.E["speed"], Shen.E["collision"])
			SpellR = Spell(_R, Shen.R["range"])
			EnemyMinions = minionManager(MINION_ENEMY, Shen.Q["range"], myHero, MINION_SORT_MAXHEALTH_DEC)
		--}
		--{ DamageCalculator
			DamageCalculator = DamageLib()
			DamageCalculator:RegisterDamageSource(_Q, Shen.Q["DamageType"], Shen.Q["BaseDamage"], Shen.Q["DamagePerLevel"], Shen.Q["ScalingStat"], Shen.Q["PercentScaling"], Shen.Q["Condition"], Shen.Q["Extra"])
			DamageCalculator:RegisterDamageSource(_E, Shen.E["DamageType"], Shen.E["BaseDamage"], Shen.E["DamagePerLevel"], Shen.E["ScalingStat"], Shen.E["PercentScaling"], Shen.E["Condition"], Shen.E["Extra"])

		--}
				--{ Initiate Menu
			Menu = scriptConfig("Shen","JKShen")
			Menu:addParam("Author","Author: Jaikor",5,"")
			Menu:addParam("Version","Version: "..version,5,"")
			--{ General/Key Bindings
				Menu:addSubMenu("Shen: General","General")
				Menu.General:addParam("Combo","Combo",2,false,32)
				Menu.General:addParam("Harass","Harass (Mixed Mode)",2,false,string.byte("C"))
				Menu.General:addParam("LastHit","Last Hit Creeps",2,false,string.byte("X"))
				Menu.General:addParam("LaneClear","Lane Clear",2,false,string.byte("V"))
			--}
			--{ Target Selector			
				Menu:addSubMenu("Shen: Target Selector","TS")
				Menu.TS:addParam("TS","Target Selector",7,2,{ "AllClass", "SourceLib", "Selector", "SAC:Reborn", "MMA" })
				ts = TargetSelector(8,Shen.R["range"],1,false)
				ts.name = "AllClass TS"
				Menu.TS:addTS(ts)				
			--}
			--{ Orbwalking
				Menu:addSubMenu("Shen: Orbwalking","Orbwalking")
				OW:LoadToMenu(Menu.Orbwalking)
				Menu.Orbwalking.Mode0 = false
			--}
			--{	Combo Settings
				Menu:addSubMenu("Shen: Combo","Combo")
				Menu.Combo:addParam("Q","Use Q in 'Combo'",1,true)
				Menu.Combo:addParam("W","Use W in 'Combo'",1,true)
				Menu.Combo:addParam("E","Use E in 'Combo'",1,true)
			--}
			--{ Harass Settings
				Menu:addSubMenu("Shen: Harass (Mixed Mode)","Harass")
				Menu.Harass:addParam("Q","Use Q in 'Harass'",1,true)
			--}
			--{ Farm Settings
				Menu:addSubMenu("Shen: Farm","Farm")
				Menu.Farm:addParam("Energy","Minimum Energy Percentage",4,70,0,100,0)
				Menu.Farm:addParam("Q","Use Q in 'Farm'",1,true)
				Menu.Farm:addParam("Qclear","Use Q in 'Lane Clear'",1,true)
			--}
			--{ Extra Settings
				Menu:addSubMenu("Shen: Extra","Extra")
			    Menu.Extra:addSubMenu("Info - Ultimate Alert", "ultAlert")
				Menu.Extra:addParam("PercentofHealth", "Minimum Health %", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
			    Menu.Extra.ultAlert:addParam("Enable", "Enable Ultimate Alert", SCRIPT_PARAM_ONOFF, true)
			    Menu.Extra.ultAlert:addParam("alertTime", "Time to be shown: ", SCRIPT_PARAM_SLICE, 3, 1, 10, 0)
			    if VIP_USER then
				Menu.Extra.ultAlert:addParam("Pings", "Use Client-Side Pings to Alert", SCRIPT_PARAM_ONOFF, false)
			end
			    Menu.Extra.ultAlert:addParam("alertInfo", "It will print a text in the middle of the screen if an Enemy is Killable", SCRIPT_PARAM_INFO, "")
			--}
			--{ Draw Settings
				Menu:addSubMenu("Shen: Draw","Draw")
				DrawHandler = DrawManager()
				DrawHandler:CreateCircle(myHero,Karthus.Q["range"],1,{255, 255, 255, 255}):AddToMenu(Menu.Draw, "Q Range", true, true, true):LinkWithSpell(SpellQ, true)
				DrawHandler:CreateCircle(myHero,Karthus.W["range"],1,{255, 255, 255, 255}):AddToMenu(Menu.Draw, "W Range", true, true, true):LinkWithSpell(SpellW, true)
				DrawHandler:CreateCircle(myHero,Karthus.E["range"],1,{255, 255, 255, 255}):AddToMenu(Menu.Draw, "E Range", true, true, true):LinkWithSpell(SpellE, true)
				Menu.Draw:addSubMenu("Shen R","Ulti")
				Menu.Draw.Ulti:addParam("X","X position for Text",4,50,0,WINDOW_W,0)
				Menu.Draw.Ulti:addParam("Y","Y position for Text",4,50,0,WINDOW_H,0)
				DamageCalculator:AddToMenu(Menu.Draw,{_Q,_W,_E,_R,_AA})
			--}
			--{ Perma Show Settings
				Menu:addSubMenu("Shen: Perma Show","Perma")
				Menu.Perma:addParam("INFO","The following options require a restart [F9 x2] to take effect",5,"")
				Menu.Perma:addParam("GC","Perma Show 'General > Combo'",1,true)				
				Menu.Perma:addParam("GF","Perma Show 'General > Farm'",1,true)
				Menu.Perma:addParam("GH","Perma Show 'General > Harass'",1,true)
				if Menu.Perma.GC then Menu.General:permaShow("Combo") end
				if Menu.Perma.GF then Menu.General:permaShow("LastHit") end
				if Menu.Perma.GH then Menu.General:permaShow("Harass") end
				Menu.Perma:addParam("CQ","Perma Show 'Combo > Q'",1,false)
				Menu.Perma:addParam("CW","Perma Show 'Combo > W'",1,false)
				Menu.Perma:addParam("CE","Perma Show 'Combo > E'",1,false)
				if Menu.Perma.CQ then Menu.Combo:permaShow("Q") end
				if Menu.Perma.CW then Menu.Combo:permaShow("W") end
				if Menu.Perma.CE then Menu.Combo:permaShow("E") end
				if Menu.Perma.CR then Menu.Combo:permaShow("R") end
				Menu.Perma:addParam("HQ","Perma Show 'Harass > Q'",1,false)
				Menu.Perma:addParam("HF","Perma Show 'Harass > Qfarm'",1,false)
				Menu.Perma:addParam("HW","Perma Show 'Harass > W'",1,false)
				Menu.Perma:addParam("HE","Perma Show 'Harass > E'",1,false)
				if Menu.Perma.HQ then Menu.Harass:permaShow("Q") end
				if Menu.Perma.HF then Menu.Harass:permaShow("Qfarm") end
				if Menu.Perma.HW then Menu.Harass:permaShow("W") end
				if Menu.Perma.HE then Menu.Harass:permaShow("E") end
				Menu.Perma:addParam("FQ","Perma Show 'Farm > Q'",1,false)
				Menu.Perma:addParam("FC","Perma Show 'Farm > Qclear'",1,false)
				if Menu.Perma.FQ then Menu.Farm:permaShow("Q") end
				if Menu.Perma.FC then Menu.Farm:permaShow("Qclear") end
				Menu.Perma:addParam("EN","Perma Show 'Extra > Notify'",1,false)
				if Menu.Perma.EN then Menu.Extra:permaShow("Notify") end
			--}
		--}
	end
--}
--{ Script Loop
	function OnTick()
		--{ Variables
			QMANA = GetSpellData(_Q).mana
			WMANA = GetSpellData(_W).mana
			EMANA = GetSpellData(_E).mana
			RMANA = GetSpellData(_R).mana
			Farm = (Menu.General.LastHit or Menu.General.LaneClear) and Menu.Farm.Mana <= myHero.mana / myHero.maxMana * 100
			Combat = Menu.General.Combo or Menu.General.Harass
			QREADY = (SpellQ:IsReady() and ((Menu.General.Combo and Menu.Combo.Q) or (Menu.General.Harass and Menu.Harass.Q) or (Farm and (Menu.Farm.Q or Menu.Farm.Qclear)) ))
			WREADY = (SpellW:IsReady() and ((Menu.General.Combo and Menu.Combo.W) or (Menu.General.Harass and Menu.Harass.W) ))
			EREADY = (SpellE:IsReady() and ((Menu.General.Combo and Menu.Combo.E) or (Menu.General.Harass and Menu.Harass.E) or (Farm and Menu.Farm.E) ))
			RREADY = (SpellR:IsReady() and ((Menu.General.Combo and Menu.Combo.R) ) and Menu.Extra.RCount <= RCountEnemyHeroInRange(Karthus.R["range"], myHero))
			Target = GrabTarget()
		--}	
		--{ Combo and Harass
				if Target then
					if DamageCalculator:IsKillable(Target,{_Q,_E,_W,,_AA}) then
						if DamageCalculator:IsKillable(Target,{_Q}) and QREADY then
							SpellQ:Cast(Target) 
						elseif DamageCalculator:IsKillable(Target,{_E,_Q}) and EREADY and QREADY then
							SpellE:Cast(Target) 
							SpellQ:Cast(Target)
							--
						elseif DamageCalculator:IsKillable(Target,{_Q,_W,_E}) and QREADY and WREADY and EREADY then
					    	SpellQ:Cast(Target) 
						    SpellE:Cast(Target)
							SpellW:Cast
							--
						elseif DamageCalculator:IsKillable(Target,{_E,_Q,_W,}) and EREADY and QREADY and WREADY then
					    	SpellE:Cast(Target) 
						    SpellQ:Cast(Target)
							SpellW:Cast(Target)
						else
							if QREADY then
								SpellQ:Cast(Target) 
							end
							if EREADY then
								SpellE:Cast(Target)
							end
						end
					else
						if QREADY then
							SpellQ:Cast(Target) 
						end
						if EREADY then
							SpellE:Cast(Target)
						end
					end
					if Menu.Orbwalking.Enabled and (Menu.Orbwalking.Mode0 or Menu.Orbwalking.Mode1) then
						OW:ForceTarget(Target)
					end
				end
			end
		--}	
		--{ Mixed Mode
		    if Menu.General.Harass and not Target then
				if Menu.Harass.Qfarm and SpellQ:IsReady() then
	    			EnemyMinions:update()
					for i, Minion in pairs(EnemyMinions.objects) do
						if ValidTarget(Minion) and GetDistance(myHero,Minion) <= Shen.Q["range"] then
							if DamageCalculator:IsKillable(Minion,{_Q}) then
								SpellQ:Cast(Minion)
							end
						end
					end
    			end
		    end
		--}
		--{ Farming
			if Farm then
				EnemyMinions:update()
				for i, Minion in pairs(EnemyMinions.objects) do
					if ValidTarget(Minion) then
						if QREADY and (DamageCalculator:IsKillable(Minion,{_Q}) or Menu.General.LaneClear) then
							SpellQ:Cast(Minion)
						end
					end
				end
			end
		--}
		if GetTickCount() > (PingTick or 0) then
			PingTick = GetTickCount() + 500
			if Menu.Extra.Notify then
				for i = 1, heroManager.iCount, 1 do
					local hero = heroManager:getHero(i)
					if ValidTarget(hero) and DamageCalculator:IsKillable(hero,{_R}) then
						if PingOnce ~= true then
							PingSignal(PING_ALERT,hero.x,hero.y,hero.z,2) 
							PingOnce = true
							DelayAction(function() PingOnce = false end, 5)
						end
					end
				end
			end
		end
	end
--}
	function OnDraw()
		DrawText(RCountEnemyHeroInRange(Karthus.R["range"],myHero).." players can by killed by Requiem.",15,Menu.Draw.Ulti.X,Menu.Draw.Ulti.Y,ARGB(255,1,255,74))
	end
--{ Target Selector
	function GrabTarget()
		if _G.MMA_Loaded and Menu.TS.TS == 5 then
			return _G.MMA_ConsideredTarget(MaxRange()) 
		elseif _G.AutoCarry and Menu.TS.TS == 4 then
			return _G.AutoCarry.Crosshair:GetTarget()
		elseif _G.Selector_Enabled and Menu.TS.TS == 3 then
			return Selector.GetTarget(SelectorMenu.Get().mode, 'AP', {distance = MaxRange()})
		elseif Menu.TS.TS == 2 then
			return TS:GetTarget(MaxRange())
		elseif Menu.TS.TS == 1 then
			ts.range = MaxRange()
			ts:update()
			return ts.target
		end
	end
--}
--{ Target Selector Range
	function MaxRange()
		if WREADY then
			return Shen.W["range"]
		end
		if QREADY then
			return Shen.Q["range"]
		end
		if RREADY then
			return Shen.R["range"]
		end	
		if EREADY then
			return Shen.E["range"]
		end
		return myHero.range + 50
	end
--}

function GetKillable()
	for i = 1, allyCount do
		local ally = allyTable[i].player
		if ally.visible and ally ~= nil and not ally.dead then
			if ally.health < ally.maxHealth*(Menu.PercentofHealth/100) and RREADY then
				if not allyTable[i].ultAlert then
					PrintAlert(ally.charName.." Champeon in Danger use R ", Menu.Extra.ultAlert.alertTime, 128, 255, 0)

					if Menu.Extra.ultAlert.Pings and VIP_USER then
						Packet('R_PING',  { x = enemy.x, y = enemy.z, type = PING_FALLBACK }):receive()
					end

					allyTable[i].ultAlert = true
				end
			end
		else
			allyTable[i].ultAlert = false
		end
	end
end
