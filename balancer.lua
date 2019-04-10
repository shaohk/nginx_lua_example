local _M

local function handler()
    local balancer = require "ngx.balancer"
    local ok, err = balancer.set_current_peer(ip, port)
    if not ok then  
    end
end

_M = {
    handler = handler
}
return _M
