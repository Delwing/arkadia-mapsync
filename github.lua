Github = Github or {}

local base64 = require("arkadia-crowdmap.base64")

local client_id = "Iv1.69a5bcc964a15d53"
local code_url = "https://github.com/login/device/code"
local token_url = "https://github.com/login/oauth/access_token"
local store_key = "github"
local data = {client_id = client_id, scope = "repo"}
local json_headers = {
    ["Accept"] = "application/json",
    ["Content-Type"] = "application/json"
}
local basicApi = "https://api.github.com/"
local repository = "https://api.github.com/repos/Delwing/arkadia-crowdmap"
local lockURL = "https://arkadia-crowdmap-default-rtdb.europe-west1.firebasedatabase.app/lock.json"
local detailsURL = "https://arkadia-crowdmap-default-rtdb.europe-west1.firebasedatabase.app/lock/details.json"

function Github:init()
    
end

function Github:authorize(routine)
    local state = scripts.state_store:get(store_key)
    if state and state.token then
        self.token = state.token
        coroutine.resume(routine)
    else 
        HttpClient:post(code_url, data, json_headers, function(response) self:on_code_receive(response, routine) end)
    end
end

function Github:on_code_receive(response, routine)
    tempTimer(1, function() openUrl(response.verification_uri) end)

    setClipboardText(response.user_code)

    cecho("=========================================================================\n")
    cecho(" Wklej ponizszy kod w przegladarce (zostal wlasnie skopiowany do schowka)\n")
    cecho("\n")
    cecho("  <yellow>" .. response.user_code .. "<reset>\n")
    cecho("\n")
    cecho("=========================================================================\n")

    self.timer = tempTimer(response.interval + 1, function() self:poll_for_code(response.device_code, routine) end, true)
    self.timer2 = tempTimer(response.expires_in + 1, function() if self.timer then killTimer(self.timer) end end)
end

function Github:poll_for_code(device_code, routine)
    HttpClient:post(token_url, {
        device_code = device_code,
        client_id = client_id,
        grant_type = "urn:ietf:params:oauth:grant-type:device_code"
    }, json_headers, function(response) self:accept_token(response.access_token, routine) end, function(er) display(er) end)
end

function Github:accept_token(token, routine)
    if token then
        killTimer(self.timer)
        killTimer(self.timer2)
        self.token = token
        scripts.state_store:set(store_key, { token = self.token })
        if routine then
            tempTimer(0.1, function() coroutine.resume(routine) end)
        end
    end
end

function Github:authorized_call(callback)
    self:authorize(callback)
end

function Github:get_headers()
    return {
        ["Authorization"] = "Bearer " .. self.token
    }
end

function Github:getDataBasicApi(location, callback, queryParams)
    local routine = coroutine.create(function()
        HttpClient:get(string.format("%s/%s", basicApi, location), self:get_headers(), callback)
    end)
    self:authorize(routine)
end

function Github:getData(location, callback, queryParams)
    local routine = coroutine.create(function()
        HttpClient:get(string.format("%s/%s", repository, location), self:get_headers(), callback)
    end)
    self:authorize(routine)
end

function Github:postData(location, content, callback, queryParams)
    local routine = coroutine.create(function()
        HttpClient:post(string.format("%s/%s", repository, location), content, self:get_headers(), callback)
    end)
    self:authorize(routine)
end

function Github:putData(location, content, callback, queryParams)
    local routine = coroutine.create(function()
        HttpClient:put(string.format("%s/%s", repository, location), content, self:get_headers(), callback)
    end)
    self:authorize(routine)
end

function Github:upload_changes()
    local branch_name = "development"
    self:create_branch(branch_name, function(response)
        local sha = response.object.sha
        self:get_current_map_sha(sha, function(file_sha) self:upload_map(file_sha, branch_name) end)
    end)
end

function Github:create_branch(branch_name, callback)
    scripts.installer:save_map()
    self:getData("git/refs/heads/master", function(response)
        self:postData("git/refs", {
            ["ref"] = "refs/heads/" .. branch_name,
            ["sha"] = response.object.sha
        }, function(response)
            callback(response)
        end)
    end)
end

function Github:get_current_map_sha(sha, callback)
    self:getData("contents/map_master3.dat?ref=" .. sha, function(response)
        callback(response.sha)
    end)
end

function Github:upload_map(sha, branch_name)
    local map = io.open(getMudletHomeDir() .. "/" .. "map_master3.dat", "rb")
    if map then
        scripts:print_log("Wysylam mape i tworze PR")
        local content = base64.encode(map:read("*a"))
        self:putData("contents/map_master3.dat", {
                content = content,
                message = "update map",
                branch = branch_name,
                sha = sha
        }, function()
            self:create_pr(branch_name)
            self:release()
        end)
        map:close()
    end
end

function Github:create_pr(branch_name)
    -- self:postData("pulls", {
    --     base = "master",
    --     head = branch_name,
    --     title = "PR - map change"
    -- }, function(response)
    --     if response and response.html_url then
    --         openUrl(response.html_url)
    --     end
    -- end)
    openUrl(string.format("https://github.com/Delwing/arkadia-crowdmap/compare/master...%s?quick_pull=1&title=Map%20update", branch_name))
end

function Github:get_user(callback)
    if not self.username then
        self:getDataBasicApi("user", function(response)
            self.username = response.login
            callback(self.username)
        end)
    else
        callback(self.username)
    end
end

function Github:lock()
    self:get_user(function()
        Github:getData("git/blobs/b9a80304b85139939c6925fd105cae2a9f848010", function(response)
            local key = base64.decode(response.content)
            HttpClient:put(lockURL, {
                details = {
                    created = {
                        [".sv"] = "timestamp",
                    },
                    lock = 60 * 60 * 1000,
                    user = self.username
                },
                secret = key,
            }, {}, function(response)
                scripts:print_log("Lock zalozony.")
                self.hasLock = true
            end, function(response)
                scripts:print_log("Lock juz istnieje.")
            end)
        end)
    end)
end

function Github:get_lock(callback)
    HttpClient:get(detailsURL, {}, function(response)
        if callback then
            callback(response)
        end
    end)
end

function Github:release()
    self:get_user(function(user)
        self:get_lock(function(lock)
            if type(lock) == "userdata" then
                scripts:print_log("Lock nie istnieje.")
            elseif lock.user == user then
                HttpClient:delete(lockURL, {}, function()
                    self.hasLock = false
                    scripts:print_log("Lock zdjety")
                end)
            else
                scripts:print_log("Nie jestes wlascicielem locka.")
            end
        end)
    end)
end

Github:init()



