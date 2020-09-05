Spidertron Waypoints
==================

Have more control over your spidertrons with waypoints! Set up your spidertrons with one-time waypoints or permanent patrols.

Waypoints
-----
![Waypoints gif](https://i.imgur.com/lSvtJP8.gif)

-----
Patrols
-----
![Patrols gif](https://i.imgur.com/leZ8QTK.gif)

-----
Features
-----

- In waypoint mode, *click* with the spidertron remote to add a waypoint
- In patrol mode, *click* to mark the position sequence, *click* on the **1** to finish the sequence and the spidertron will start following it
- Press *Y* after placing a waypoint to set the wait duration for it
- *Shift + Click* whilst holding a spidertron remote to clear all waypoints for that spidertron
- *Control + Click* whilst holding a spidertron remote to disconnect it from its spidertron
- Switch to direct, waypoint and patrol modes with *Shift + F*, *Shift + C*, *Shift + X* respectively (notice the 'circle' that they make around *WASD*!)
- Cycle through all 3 modes with *Shift + Scroll* or configure your own hotkeys (you can remove modes from this cycle in the mod settings)
- Enable the shortcuts in the shortcut bar to switch modes by mouse and easily view which mode is active
- Thank you to [danatron1](https://www.reddit.com/r/factorio/comments/iitlvi/i_made_a_mod_that_allows_you_to_set_waypoints/g3dzt1h) for creating the patrol remote icon (which also doubles up as a cool thumbnail!)

-----
Recommendations
-----

- *Shift + Scroll* controls are derived from **Blueprint book next** and **Blueprint book previous**. If you have rebound these controls, this mod's shift-scrolling will not work
- Remove *Shift + Mouse wheel up* and *Shift + Mouse wheel down* from **Zoom in** and **Zoom out** controls if you are using the *Shift + Scroll* controls
- Use [Equipment Grid Logistic Module](https://mods.factorio.com/mod/EquipmentGridLogisticModule) to autofill your patrolling spidertrons

-----
Known Bugs / Limitations
-----

- Only place remotes in the quickbar when in direct (i.e. vanilla) mode, otherwise, they will disappear from the quickbar (will be fixed in Factorio 1.1 - requires [this API addition](https://forums.factorio.com/viewtopic.php?f=28&t=88867))
- Waypoint markers cannot be seen in map view (requires [this API addition](https://forums.factorio.com/viewtopic.php?f=28&t=76539&p=510027) - no dev response)

-----
Future Updates
-----

- Show total and remaining wait time under each waypoint
- Allow waiting at waypoint until a condition is met (eg no weapons fired for x seconds, inventory not changed for y seconds)
- *Alt + Click* to complete patrol setup (as an alternative to clicking on **1**)
- Compatibility with [Spidertron squad control](https://mods.factorio.com/mod/Spider_Control) (you can follow the development of that [here](https://github.com/npc-strider/spidertron-squad-control/pull/2))
- New waypoint remote icon and better looking shortcut icons (help would be appreciated!)
- Improved remote interface that allows other mods to send a spidertron and a list of waypoints for it to visit

-----
Mod Compatibility
-----

For compatibility with other mods that use `on_player_used_spider_remote`, this mod provides a remote interface. The new event `on_spidertron_given_new_destination` is raised when a spidertron has been given a new `autopilot_target`, and comes with an `event` table containing `player_index`, `vehicle`, `position`, and `success` (always set to true). Note that `event.player` does not exist. The following example should be placed in `on_init` and `on_load`:

```
if game.active_mods["SpidertronWaypoints"] then
    local event_ids = remote.call("SpidertronWaypoints", "get_event_ids")
    local on_spidertron_given_new_destination = event_ids.on_spidertron_given_new_destination
    script.on_event(on_spidertron_given_new_destination, function(event)
        -- Do stuff here instead of in `on_player_used_spider_remote`
    end)
end
```

Let me know if you need help implementing this or if you need additional compatibility features.

-----

Please leave feedback and bug reports in the mod discussion tab.
Thank you to [Qon](https://mods.factorio.com/user/Qon) for all of his design feedback and input!