function map_sync:print_state(callback)
    map_sync.ApiCall:new(map_sync.api_endpoint):call(function(response)
        cecho("\n <orange> Map Sync: Twoja wersja: " .. map_sync.current_version .. ", wersja na serwerze: " .. response.version .. "\n")
        if callback then
            callback(response)
        end
    end)
end

function map_sync:print_changelog()
    map_sync.ApiCall:new(map_sync.api_endpoint, "changelog=1"):call(function(response)
        cecho("\n <orange>Wersja  <grey>|  <orange>Data<grey>             |  <orange>Zmiany<grey>\n")
        cecho("         |                   |\n")
        for k, v in pairs(response.map_update_entries) do
            cecho("  " .. string.sub(v.rev .. "        ", 0, 7) .. "|  " .. os.date("%Y-%m-%d %H:%M", v.created) .. " |  ")
            lines = string.split(v.comment, "\r\n")
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
   scripts.plugins_installer:install_from_url("https://github.com/Delwing/arkadia-mapsync/releases/latest/download/arkadia-mapsync.zip")
end