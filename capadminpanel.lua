--[[
Factorio 0.12.x CAP Admin Panel
by tetryon
Version - 2016-03-31a
Version: 0.0.1 pre-alpha-beta-gamma
No warranties. No promises. No whining. No locale.
]]

require "defines"
local sha2 = require "sha256"

local shapass = {}

function authorizeadmin(adminplayer,adminpw)

	shapass["tetryon"] = "bbec9df8dc048afc1c6ec5ca75adc35d0780ae1e730cb267347a1a643e5b48c2" -- p1 yeah!
	shapass["NoPantsMcDance"] = "3e2b8f7655a269367d0503ead3d27ef7e070fa31a0ccdff6d3150c67cc5c789e"
	--shapass["test"] = '5cf6be08383ce46b2f78e936e97a143429ac0c650e45ae1db7de5cc02daa7a2e'
	for adminnamestring,shastring in pairs(shapass) do
		if shastring == adminpw then
			adminplayer.print("Hi ".. adminnamestring .. ".  Please proceed.")
			return true
		end
	end
	adminplayer.print("Wrong password.")
	return false	
end

function capadminbutton()
	for _, player in pairs(game.players) do
		if player.gui.left.AdminGUI == nil then
			local admingui_button = player.gui.left.add{name = "AdminGUI", type = "button", caption = "AdminGUI"}
			admingui_button.style.top_padding = 0
			admingui_button.style.right_padding = 0
			admingui_button.style.bottom_padding = 0
			admingui_button.style.left_padding = 0
		end
	end
end

function check_admin_gui(adminplayer, event)
	local name = event.element.name
	if (name == "AdminGUI") then
		--adminplayer.print(debug.traceback())
		expand_login_panel(adminplayer)
	elseif (name == "ps_button_close") then
		expand_login_panel(adminplayer)
	elseif (string.starts(name, "button_force_")) then
		switch_and_set(adminplayer,event)
	elseif (name == adminpw.name and adminpw.text == "Password?") then
		adminpw.text = ""
	elseif (name == "ps_button_auth") then
		local encpw = sha2.hash256(adminpw.text)
		--adminplayer.print("Pass:".. adminpw.text.."   SHA:" .. encpw)
		adminpw.text = ''
		local authorized = authorizeadmin(adminplayer,encpw)
		--adminplayer.print("Authorized?"..tostring(authorized))
		expand_login_panel(adminplayer) -- close the admin panel
		if authorized == true then
			expand_main_gui(adminplayer)
		end
		
	end
end



function test()
end

function switch_and_set(adminplayer,event)
	--Which player is this for?
	local evelname = event.element.name
	userplayerindexstring = string.sub(evelname,string.len("button_force_")+1,string.len(evelname))
	--adminplayer.print("userplayernamestring:"..userplayerindexstring	)
	userplayer = game.players[tonumber(userplayerindexstring)]
	--adminplayer.print("test print"..tostring(userplayer))
	--adminplayer.print("userplayer:"..userplayer.name	)

	event.element.caption = (function() if (event.element.caption == "player") then return "untrusted" else return "player" end end)()

	--adminplayer.print("string.sub = ".. userplayer.name .. " caption:"..event.element.caption)

	set_trust(adminplayer,userplayer,event.element.caption)
end

function set_trust(adminplayer,userplayer,trust_level)
	--adminplayer.print("CHECKING player:"..userplayer.name .. " force:"..userplayer.force.name)

	if (game.forces['untrusted'] == nil) then
		--adminplayer.print("untrusted does not exist")
		game.create_force('untrusted')
	end
	userplayer.force = game.forces[trust_level]
	--adminplayer.print("userplayer:"..userplayer.name .. " force:" .. userplayer.force.name)

end

function expand_login_panel(adminplayer)
	mainflow = adminplayer.gui.left["admin-panel"] -- try to get this GUI element

	loginflow = adminplayer.gui.center["login-panel"]
	if (loginflow) then -- If there's a login panel, kill it
		loginflow.destroy()
		return
	end
	
	if (mainflow == nil) then -- If there's no main screen, add a login panel
		loginflow = adminplayer.gui.center.add{type="flow", name="login-panel", caption="Center", direction="horizontal"}
		
		frame1 = loginflow.add{type="frame", name="login-panel-frame1", direction="vertical"}
		frame1.add{type="flow", name="flow1", direction="horizontal"}
		frame1["flow1"].add{type="label", name="ps_label1", caption="Admin password:"}
		adminpw = frame1["flow1"].add{type="textfield", name="ps_textbox_pw", caption="test-textbox", text="Password?"}
		frame1["flow1"].add{type="button", name="ps_button_auth", caption="Login"}
		frame1["flow1"].add{type="button", name="ps_button_close", caption="Close"}
		return
	end
	
	if (mainflow) then -- If there's a main screen, kill it
		adminplayer.gui.left["admin-panel"].destroy()
		--adminplayer.print("expand_gui called: destroying frame")
		return
	end
end
	
function expand_main_gui(adminplayer)
	--mainflow = adminplayer.gui.left["admin-panel"] -- try to get this GUI element

	mainflow = adminplayer.gui.left.add{type="flow", name="admin-panel", caption="Center", direction="horizontal"}

	frame2 = mainflow.add{type="frame", name="main-panel-frame2", direction="vertical"}

	frame2.add{type="table", name="ps_table", colspan=3}
	frame2["ps_table"].add{type="label", name="table_label1", caption="Player Name"}
	frame2["ps_table"].add{type="label", name="table_label2", caption="    "}
	
	frame2["ps_table"].add{type="label", name="table_label3", caption="Player or Untrusted"}
	
	for index,eachplayer in ipairs(game.players) do
		--adminplayer.print("adding:"..eachplayer.name.."  index:"..index)
		frame2["ps_table"].add{type="label", name="player:"..eachplayer.name, caption="("..index..") "..eachplayer.name}
		frame2["ps_table"].add{type="label", name="table_label2x"..eachplayer.name, caption="    "}

		local btrustedstate = eachplayer.force.name == "player"
		frame2["ps_table"].add{type="button", name="button_force_"..eachplayer.index, caption=eachplayer.force.name}
	end

end

-- Helper Functions
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end
