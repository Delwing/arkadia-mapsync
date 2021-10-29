map_sync = map_sync or {
    plugin_id = "arkadia-mapsync",
    repository = "Delwing/arkadia-mapsync",
    version = "2.0",
    auth_token = "unknown",
    map_filename = "map_master3.dat",
    current_version = 'unk',
    server_url = "http://mapsync.kamerdyner.net",
    maps_url = "http://maps.kamerdyner.net/",
    api_response_filename = ".map_sync_response.json",
    download_automatically = false,
    update_automatically = true,
    gps_initialized = false,
}

local state = scripts.state_store:get(map_sync.plugin_id)
map_sync.version = state or map_sync.version

map_sync.auth_url = map_sync.server_url .. "/map_sync/auth.py"
map_sync.api_endpoint = map_sync.server_url .. "/map_sync/api.py"
map_sync.help_url = map_sync.maps_url .. "hi.html"

function alias_func_map_sync_check_ver()
    map_sync:print_state()
end

function alias_func_map_sync_changelog()
    map_sync:print_changelog()
end

function alias_func_map_sync_mapsync()
    map_sync:download_map(false)
end

function alias_func_map_sync_mapsync_force()
    map_sync:download_map(true)
end

function alias_func_map_sync_mapsync_help()
    map_sync:print_help()
end

function alias_func_map_sync_mapup()
    map_sync:show_upload_link()
end

function alias_func_map_sync_add_gps()
    if amap.curr.id then
        map_sync.gps:add_gps_to_room(amap.curr.id, matches[2], nil, nil, nil)
    end
end

function alias_func_map_sync_add_gps_area()
    if amap.curr.id then
        map_sync.gps:add_gps_to_room(amap.curr.id, matches[2], nil, amap.curr.area, nil)
    end
end

function alias_func_map_sync_add_gps_within_rooms()
    local within_room_ids = string.split(matches[2], ",")

    if amap.curr.id then
        map_sync.gps:add_gps_to_room(amap.curr.id, matches[3], nil, nil, within_room_ids)
    end
end

function alias_func_map_sync_remove_gps()
    map_sync.gps:remove_gps(matches[2])
end

function alias_func_map_sync_install_update()
    map_sync:update_mapsync_scripts_if_necessary(false)
end

function alias_func_map_sync_install_update_force()
    map_sync:update_mapsync_scripts_if_necessary(true)
end

function alias_func_map_sync_show_gps()
    if amap.curr.id then
        map_sync.gps:print_room_gps(amap.curr.id)
    end
end

function alias_func_map_sync_show_gps_room()
    map_sync.gps:print_room_gps(tonumber(matches[2]))
end

function alias_func_map_sync_rysuj()
    map_sync.draw_tools.draw_tools_switch()
end

