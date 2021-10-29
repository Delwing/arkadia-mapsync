function map_sync_map_opened_event()
    local map_ver = getMapUserData("map_sync_version")
    if map_ver ~= nil and map_ver ~= "" then
        map_sync.current_version = map_ver
    end

    if not map_sync.gps_initialized then
        map_sync.gps:init_triggers()
        map_sync.gps_initialized = true
    end

    if map_sync.update_automatically then
        tempTimer(1.2, function()
            map_sync:update_mapsync_scripts_if_necessary()
        end)
    end

    if map_sync.download_automatically == true then
        tempTimer(7, function()
            map_sync:download_map(false)
        end)
    else
        tempTimer(7, function()
            map_sync:print_state()
        end)
    end
end

map_sync.login_handler = scripts.event_register:force_register_event_handler(map_sync.login_handler, "profileLoaded", function() map_sync_map_opened_event() end)

