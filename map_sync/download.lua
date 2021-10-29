function map_sync:download_map(force)
    map_sync:print_state(function(state) self:perform_map_download(state, force) end)
end

function map_sync:perform_map_download(state, force)
    if not force and map_sync.current_version == state.version then
        cecho("\n <orange> Map Sync: Masz najnowsza mape\n")
        return
    end

    cecho("\n <orange> Map Sync: Twoja wersja: " .. map_sync.current_version .. ", wersja na serwerze: " .. state.version .. ". Pobieram mape...\n")
    map_sync:download_map_file(state.download_path, state.version)
end

function map_sync:download_map_file(download_path, version)
    local fileUrl = map_sync.maps_url .. download_path
    local fileName = getMudletHomeDir() .. "/" .. map_sync.map_filename
    local progressHandler = registerAnonymousEventHandler("sysDownloadFileProgress", function(_, url, bytes, total)
        if fileUrl ~= url then
            return
        end
        if total ~= 0 then
           self:report_progress(bytes, total)
        end
    end)
    registerAnonymousEventHandler("sysDownloadDone", function(_, file)
        if fileName ~= file then
            return
        end
        self:process_downloaded_map(version)
        killAnonymousEventHandler(progressHandler)
    end, true)
    downloadFile(getMudletHomeDir() .. "/" .. map_sync.map_filename, fileUrl)
end

function map_sync:report_progress(bytes, total)
    local lines = 0
    while selectString("Pobieram mape:", 1) == -1 and lines < 10 do
        moveCursor(0, getLastLineNumber() - lines)
        lines = lines + 1
    end
    if selectString("Pobieram mape:", 1) > -1 then
        deleteLine()
    end
    moveCursorEnd()
    local progress_bar = "["
    for i = 0, 10, 1 do
        local char = (bytes / total) * 10 >= i and "#" or " "
        progress_bar = progress_bar .. char
    end
    progress_bar = progress_bar .. "]"
    scripts:print_log(string.format("Pobieram mape: %sKB/%sKB %s", scripts.utils.str_pad(tostring(math.floor(bytes / 1024)), string.len(total), "right"), math.floor(total / 1024), progress_bar))
end

function map_sync:process_downloaded_map(version)
    loadMap(getMudletHomeDir() .. "/" .. map_sync.map_filename)
    cecho("\n <orange> Map Sync: Mapa pobrana i zaladowana\n")
    map_sync.current_version = version
    setMapUserData("map_sync_version", version)
end

