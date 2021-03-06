local function get_previous_quickbar(player)
  local quickbar_slots = {}
  for i = 1, 100 do
    quickbar_slots[i] = player.get_quick_bar_slot(i)
  end
  return quickbar_slots
end

local function fill_in_quickbar(player, previous_quickbar, new_stack)
  for i = 1, 100 do
    if previous_quickbar[i] then 
      if not player.get_quick_bar_slot(i) then
      -- The quickbar filter has been lost since last check, therefore it contained the replaced item
       player.set_quick_bar_slot(i, new_stack)
      end
    end
  end
end


local function convert_remote(stack, new_name, player, item_location)
  if stack and stack.valid_for_read and stack.name ~= new_name and contains({"spidertron-remote", "spidertron-remote-patrol", "spidertron-remote-waypoint"}, stack.name) then
    local connected_spidertron = stack.connected_entity
    local hand_location = player.hand_location

    if item_location then
      local slot_filter = item_location.inventory.get_filter(item_location.slot)
      if slot_filter == stack.name then
        -- The item to convert is in a filtered slot, so leave it alone
        return
      end
    end


    local previous_quickbar = get_previous_quickbar(player)
    local change_successful = stack.set_stack{name=new_name, count=1}
    if not change_successful then
      log("Couldn't convert remote")
    end
    stack.connected_entity = connected_spidertron
    fill_in_quickbar(player, previous_quickbar, stack)
    if hand_location and not player.get_inventory(hand_location.inventory)[hand_location.slot].count then
      player.hand_location = hand_location
    end

  end
end

local function switch_to_mode(player_index, mode, toggle)
  -- Toggle the shortcuts
  if not contains({"spidertron-remote", "spidertron-remote-waypoint", "spidertron-remote-patrol"}, mode) then return end

  local player = game.get_player(player_index)
  local stack = player.cursor_stack

  if toggle and contains({"spidertron-remote-waypoint", "spidertron-remote-patrol"}, mode) then
    -- Called when shortcut is toggled
    if player.is_shortcut_toggled(mode) then
      -- Shortcut already on, so turn off
      convert_remote(stack, "spidertron-remote", player)
      player.set_shortcut_toggled(mode, false)
      return
    end
  end

  convert_remote(stack, mode, player)
  log("Player " .. player.name .. " switching to mode " .. mode)
  if mode == "spidertron-remote-waypoint" then
    player.set_shortcut_toggled("spidertron-remote-waypoint", true)
    player.set_shortcut_toggled("spidertron-remote-patrol", false)
  elseif mode == "spidertron-remote-patrol" then
    player.set_shortcut_toggled("spidertron-remote-waypoint", false)
    player.set_shortcut_toggled("spidertron-remote-patrol", true)
  else
    player.set_shortcut_toggled("spidertron-remote-waypoint", false)
    player.set_shortcut_toggled("spidertron-remote-patrol", false)
  end

end
script.on_event(defines.events.on_lua_shortcut, function(event) switch_to_mode(event.player_index, event.prototype_name, true) end)
script.on_event("waypoints-waypoint-mode-toggle", function(event) switch_to_mode(event.player_index, "spidertron-remote-waypoint", true) end)
script.on_event("waypoints-patrol-mode-toggle", function(event) switch_to_mode(event.player_index, "spidertron-remote-patrol", true) end)
script.on_event("waypoints-go-to-direct-mode", function(event) switch_to_mode(event.player_index, "spidertron-remote") end)
script.on_event("waypoints-go-to-waypoint-mode", function(event) switch_to_mode(event.player_index, "spidertron-remote-waypoint") end)
script.on_event("waypoints-go-to-patrol-mode", function(event) switch_to_mode(event.player_index, "spidertron-remote-patrol") end)


--[[
local function press_if_holding_remote(player_index, shortcut_name)
  local player = game.get_player(player_index)
  local stack = player.cursor_stack
  if stack and stack.valid_for_read then
    if contains({"spidertron-remote", "spidertron-remote-patrol"}, stack.name) then
      shortcut_pressed(player_index, shortcut_name)
    end
  end
end
]]

local function on_mode_scrolled(player_index, direction)
  local player = game.get_player(player_index)
  local stack = player.cursor_stack
  if stack and stack.valid_for_read and stack.type == "spidertron-remote" then
    local modes = global.scroll_modes
    if #modes == 1 then
      return
    end

    local index
    local waypoint_on = player.is_shortcut_toggled("spidertron-remote-waypoint")
    local patrol_on = player.is_shortcut_toggled("spidertron-remote-patrol")
    for i, mode in pairs(modes) do
      if (mode == "spidertron-remote" and not waypoint_on and not patrol_on) or (mode == "spidertron-remote-waypoint" and waypoint_on) or (mode == "spidertron-remote-patrol" and patrol_on) then
        index = i
        break
      end
    end
    if index then
      local offset
      -- Strange offsets because of 1-indexing
      if direction == "forwards" then offset = 0 else offset = -2 end
      local next_index = (index + offset) % #modes + 1
      local next_mode = modes[next_index]
      switch_to_mode(player_index, next_mode)
    end
  end
end
script.on_event("waypoints-mode-scroll-forwards", function(event) on_mode_scrolled(event.player_index, "forwards") end)
script.on_event("waypoints-mode-scroll-backwards", function(event) on_mode_scrolled(event.player_index, "backwards") end)
script.on_event("waypoints-mode-scroll-forwards-key", function(event) on_mode_scrolled(event.player_index, "forwards") end)
script.on_event("waypoints-mode-scroll-backwards-key", function(event) on_mode_scrolled(event.player_index, "backwards") end)


--script.on_event("waypoints-patrol-mode-click", function(event) press_if_holding_remote(event.player_index, "waypoints-patrol-mode") end)
--script.on_event("waypoints-patrol-mode-scroll", function(event) press_if_holding_remote(event.player_index, "waypoints-patrol-mode") end)
--script.on_event("waypoints-waypoint-mode-click", function(event) press_if_holding_remote(event.player_index, "waypoints-waypoint-mode") end)
--script.on_event("waypoints-waypoint-mode-scroll", function(event) press_if_holding_remote(event.player_index, "waypoints-waypoint-mode") end)

--script.on_event("pick-item-custom", function(event) game.print("Pickted item! " .. serpent.block(event)) end)


local function convert_remotes_in_player(player)
  local inventory = player.get_main_inventory()
  for i = 1, #inventory do
    local stack = inventory[i]
    convert_remote(stack, "spidertron-remote", player, {inventory = inventory, slot = i})
  end
end
script.on_event(defines.events.on_player_main_inventory_changed, function (event) convert_remotes_in_player(game.get_player(event.player_index)) end)

script.on_event(defines.events.on_player_cursor_stack_changed,
  function(event)
    local player = game.get_player(event.player_index)
    if player.is_shortcut_toggled("spidertron-remote-waypoint") then
      -- Only convert to waypoint remote if waypoint mode is on
      convert_remote(player.cursor_stack, "spidertron-remote-waypoint", player)
    end
    if player.is_shortcut_toggled("spidertron-remote-patrol") then
      -- Only convert to patrol remote if patrol mode is on
      convert_remote(player.cursor_stack, "spidertron-remote-patrol", player)
    end
  end
)


script.on_event("waypoints-disconnect-remote",
  function(event)
    local player = game.get_player(event.player_index)
    local remote = player.cursor_stack
    if remote and remote.valid_for_read and remote.type == "spidertron-remote" then
      remote.connected_entity = nil
    end
  end
)