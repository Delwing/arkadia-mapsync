function map_sync:show_upload_link()
    map_sync["api_response"] = nil
    map_sync:print_state(function(response)
        map_sync:show_upload_msg(response)
    end)
end

function map_sync:show_upload_msg(response)
   if response.version == map_sync.current_version then
        cecho("\n <orange> Map Sync Upload\n\n  (1) Musisz miec uprawnienia do wrzucania map\n  (2) Pamietaj aby po rozpoczeciu locka pobrac aktualna wersje mapy z serwera.\n  (3) Twoja wersja: <green>" .. map_sync.current_version .. "<orange>, wersja na serwerze: <green>" .. response.version .. "<orange>\n  (4) Kliknij ")
        echoLink("tutaj", [[ map_sync_open_upload_www() ]], "klik")
        cecho(" <orange>aby wrzucic mape\n")
    else
        cecho("\n <orange> Map Sync - pobierz aktualna wersje mapy przed zalozeniem locka. Twoja wersja: <green>" .. map_sync.current_version .. "<orange>, wersja na serwerze: <green>" .. response.version .. "<reset>")
    end
end

function map_sync_open_upload_www()
    openUrl(map_sync["auth_url"] .. "?auth_token=" .. map_sync.auth_token)
end

