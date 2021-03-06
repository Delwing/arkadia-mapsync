function map_sync:print_state(callback)
    map_sync.ApiCall:new(map_sync.api_endpoint):call(function(response)
        cecho("\n <orange> Map Sync: Twoja wersja: " .. map_sync.current_version .. ", wersja na serwerze: " .. response.version .. "\n")
        if callback then
            callback(response)
        end
    end)
end

function map_sync:print_changelog(limit)
    map_sync.ApiCall:new(map_sync.api_endpoint, "changelog=1"):call(function(response)
        cecho("\n <orange>Wersja  <grey>|  <orange>Data<grey>             |  <orange>Zmiany<grey>\n")
        cecho("         |                   |\n")
        local start = limit and #response.map_update_entries - limit or 1
        for i = start, #response.map_update_entries, 1 do
            local entry =response.map_update_entries[i]
            cecho("  " .. string.sub(entry.rev .. "        ", 0, 7) .. "|  " .. os.date("%Y-%m-%d %H:%M", entry.created) .. " |  ")
            local lines = string.split(entry.comment, "\r\n")
            for i, l in pairs(lines) do
                if i == 1 then
                    cecho(l .. "\n")
                else
                    cecho("         |                   |  " .. l .. "\n")
                end
            end
            cecho("         |                   |\n")
        end
    
        cecho("\n")
    end)
end

function map_sync:update_mapsync_scripts_if_necessary(force)
    HttpClient:get(string.format("https://api.github.com/repos/%s/releases/latest", map_sync.repository), {}, function(response)
        local tag = response.tag_name
        if map_sync.version ~= tag or force then
            scripts.plugins_installer:uninstall(map_sync.plugin_id)
            scripts.plugins_installer:install_from_url("https://github.com/Delwing/arkadia-mapsync/releases/latest/download/arkadia-mapsync.zip")
            scripts.state_store:set(map_sync.plugin_id, tag)
        end
    end)
end