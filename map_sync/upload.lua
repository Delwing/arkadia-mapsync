map_sync.orgSaveMap = map_sync.orgSaveMap or scripts.installer.save_map

function scripts.installer:save_map()
    map_sync.orgSaveMap(self)
    if Github.hasLock then
        scripts:print_url("Masz zalozonego locka. Kliknij <blue>tutaj<reset>, aby zaktualizowac mape.", function()
            Github.hasLock = false
            Github:upload_changes()
        end, "Zaktualizuj mape")
    end
end

function map_sync:show_upload_link()
    map_sync["api_response"] = nil
    map_sync:print_state(function(response)
        map_sync:show_upload_msg(response)
    end)
end

function map_sync:show_upload_msg(response)
   if response.version == map_sync.current_version then
        cecho("\n <orange> Map Sync Upload\n\n  (1) Musisz miec uprawnienia do wrzucania map\n  (2) Pamietaj aby po rozpoczeciu locka pobrac aktualna wersje mapy z serwera.\n  (3) Twoja wersja: <green>" .. map_sync.current_version .. "<orange>, wersja na serwerze: <green>" .. response.version .. "<orange>\n  (4) Kliknij ")
        echoLink("tutaj", function() Github:lock() end, "klik")
        cecho(" <orange>aby zalozyc locka\n")
    else
        cecho("\n <orange> Map Sync - pobierz aktualna wersje mapy przed zalozeniem locka. Twoja wersja: <green>" .. map_sync.current_version .. "<orange>, wersja na serwerze: <green>" .. response.version .. "<reset>")
    end
end


