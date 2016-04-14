-- Color additions by daniel34
-- Death message code by NoPantsMcDance/Rseding91, messages by NoPants and tetryon
-- CAP additions by tetryon

require "defines"
local CAP = require "capadminpanel"
 
normal_attack_sent_event = script.generate_event_name()
landing_attack_sent_event = script.generate_event_name()
remote.add_interface("freeplay",
{
  set_attack_data = function(data)
    global.attack_data = data
  end,

  get_attack_data = function()
    return global.attack_data
  end,

  get_normal_attack_sent_event = function()
    return normal_attack_sent_event
  end,
})

init_attack_data = function()
  global.attack_data = {
    -- whether all attacks are enabled
    enabled = true,
    -- this script is allowed to change the attack values attack_count and until_next_attack
    change_values = true,
    -- what distracts the creepers during the attack
    distraction = defines.distraction.byenemy,
    -- number of units in the next attack
    attack_count = 5,
    -- time to the next attack
    until_next_attack = 60 * 60 * 60,
  }
end

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="basic-bullet-magazine", count=10}
  player.insert{name="burner-mining-drill", count = 1}
  player.insert{name="stone-furnace", count = 1}
  for _, player in ipairs(game.players) do
	player.print("Hello and welcome to Something Unique Gaming. Use the ~ key to chat. Be sure to read the rules on the forum. GL HF")
  end
  if (#game.players <= 1) then
    game.show_message_dialog{text = {"msg-intro"}}
  end
  player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
  
end)

local deathMessageTemplates =
{
  [1] = {[1] = "", [2] = " took a long walk off a short pier."},
  [2] = {[1] = "", [2] = " realized their requirements for survival much too late."},
  [3] = {[1] = "Oh noes! ", [2] = " was too stupid to continue living."},
  [4] = {[1] = "", [2] = " became a martyr."},
  [5] = {[1] = "Pieces of ", [2] = " fly past your face in slow motion."},
  [6] = {[1] = "Natural selection didn't choose ", [2] = ""},
  [7] = {[1] = "It's time to bury ", [2] = " again."},
  [8] = {[1] = "Looks like ", [2] = " will be needing a new set of Power Armor."},
  [9] = {[1] = "Want to see how not to do it?  Check out the shining example from ", [2] = ""},
  [10] = {[1] = "", [2] = " found a really quick way back to the spawn."},
  [11] = {[1] = "", [2] = " died, what a dumbass"},
  [12] = {[1] = "", [2] = " was caught with their pants down"},
  [13] = {[1] = "", [2] = " stepped on a grenade"},
  [14] = {[1] = "", [2] = " was processed for science"}
}
 
function printToAllPlayers(message)
  for k,player in pairs(game.players) do
    if player.connected then
      player.print(message)
    end
  end
end
 
function generateDeathMessage(playerName)
  local i = math.random(1,14)
  return deathMessageTemplates[i][1] .. playerName .. deathMessageTemplates[i][2]
end
 
script.on_event(defines.events.on_entity_died, function(event)
  if event.entity.name == "player" then
    for k,player in pairs(game.players) do
      if player and player.character == nil then -- if player check to resolve "User isn't connected; can't read character" upon death (MP, no server)
        printToAllPlayers(generateDeathMessage(player.name))
        break
      end
    end
  end
end)

script.on_init(function()
  init_attack_data()
end)

local colors = {}
colors["white"] = {r = 1, g = 1, b = 1}
colors["silver"] = {r = 0.75, g = 0.75, b = 0.75}
colors["gray"] = {r = 0.5, g = 0.5, b = 0.5}
colors["black"] = {r = 0, g = 0, b = 0}
colors["red"] = {r = 1, g = 0, b = 0}
colors["maroon"] = {r = 0.5, g = 0, b = 0}
colors["yellow"] = {r = 1, g = 1, b = 0}
colors["olive"] = {r = 0.5, g = 0.5, b = 0}
colors["lime"] = {r = 0, g = 1, b = 0}
colors["green"] = {r = 0, g = 0.5, b = 0}
colors["aqua"] = {r = 0, g = 1, b = 1}
colors["teal"] = {r = 0, g = 0.5, b = 0.5}
colors["blue"] = {r = 0, g = 0, b = 1}
colors["navy"] = {r = 0, g = 0, b = 0.5}
colors["fuchsia"] = {r = 1, g = 0, b = 1}
colors["purple"] = {r = 0.5, g = 0, b = 0.5}

script.on_event(defines.events.on_tick, function(event)
	if game.tick % 3600 == 0 then
		capadminbutton()

		for _, player in pairs(game.players) do
			if player.gui.left.color_button == nil and player.gui.left.color_frame == nil then
				local colbutton = player.gui.left.add{name = "color_button", type = "button", caption = "Player color"}
				colbutton.style.top_padding = 0
				colbutton.style.right_padding = 0
				colbutton.style.bottom_padding = 0
				colbutton.style.left_padding = 0
			end
		end
	end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.player_index]
	if event.element.name == "color_button" then
		player.gui.left.color_button.destroy();
		player.gui.left.add{name = "color_frame", type = "frame", direction = "vertical"}
		for colname, color in pairs(colors) do
			button_name =  "colors_"..colname
			local colbutton = player.gui.left.color_frame.add{name = button_name, type = "button", caption = colname}
			colbutton.style.top_padding = 0
			colbutton.style.right_padding = 0
			colbutton.style.bottom_padding = 0
			colbutton.style.left_padding = 0
			colbutton.style.minimal_width = 100
		end
		return
	elseif string.len(event.element.name) > 6 
	and string.sub(event.element.name, 1, 7) == "colors_" then
		local colname = string.sub(event.element.name, 8)
		player.color = colors[colname]
		player.gui.left.color_frame.destroy()
		return
	end
	
	check_admin_gui(player, event)
end)

-- for backwards compatibility
script.on_configuration_changed(function(data)
  if global.attack_data == nil then
    init_attack_data()
    if global.attack_count ~= nil then global.attack_data.attack_count = global.attack_count end
    if global.until_next_attacknormal ~= nil then global.attack_data.until_next_attack = global.until_next_attacknormal end
  end
  if global.attack_data.distraction == nil then global.attack_data.distraction = defines.distraction.byenemy end
  
end)

script.on_event(defines.events.on_rocket_launched, function(event)
  local force = event.rocket.force
  if event.rocket.get_item_count("satellite") > 0 then
    if global.satellite_sent == nil then
      global.satellite_sent = {}
    end
    if global.satellite_sent[force.name] == nil then
      game.set_game_state{game_finished=true, player_won=true, can_continue=true}
      global.satellite_sent[force.name] = 1
    else
      global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1
    end
    for index, player in pairs(force.players) do
      if player.gui.left.rocket_score == nil then
        local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption={"score"}}
        frame.add{name="rocket_count_label", type = "label", caption={"", {"rockets-sent"}, ""}}
        frame.add{name="rocket_count", type = "label", caption="1"}
      else
        player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
      end
    end
  else
    if (#game.players <= 1) then
      game.show_message_dialog{text = {"gui-rocket-silo.rocket-launched-without-satellite"}}
    else
      for index, player in pairs(force.players) do
        player.print({"gui-rocket-silo.rocket-launched-without-satellite"})
      end
    end
  end
end)
