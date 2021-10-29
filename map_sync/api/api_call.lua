map_sync.ApiCall = {}

function map_sync.ApiCall:new(url, params)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.url = url
    self.params = params or ""
    return o
end

function map_sync.ApiCall:call(handler, errorHandler)
    self:check_if_auth_token_set()
    local url = string.format("%s?%s&auth_token=%s", self.url, self.params, map_sync.auth_token)
       HttpClient:get(url, {}, function(response) self:handleSuccess(response, handler) end, errorHandler)
end

function map_sync.ApiCall:handleSuccess(response, handler)
    if self:is_allowed(response) then
        handler(response)
    end
end

function map_sync.ApiCall:is_allowed(response)
    if not response.allowed then
        cecho("\n <orange> Map Sync: Brak autoryzacji, kontakt z dzordzem\n")
        return false
    end
    return true
end


function map_sync.ApiCall:check_if_auth_token_set()
    if map_sync.auth_token == "unknown" then
        cecho("\n <orange> Map Sync: Brak kontaktu z serwerem (\"auth_token\" jest nieustawiony)\n")
        error("auth token not set in map sync api call")
    end
end
