function map_sync:print_help()
    cecho("\n                     <tomato>Map Sync, v" .. map_sync.version .. "     \n")
    echo("                     --------------     \n")
    echo("\n")
    echo("  Pomoc, komendy i opis dzialania na tej stronie: ")
    echoLink("tutaj", function() openUrl(map_sync.help_url) end, "klik")
    echo("\n")

end
