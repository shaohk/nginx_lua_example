-- 通过content lua获取请求的url，参数，来源地址等，先做access处理，然后根据url和参数做rewrite处理，再做upstream处理
--
local cnfcache

local log = ngx.log
local ERR = ngx.ERR
local cjson = require("cjson") 
local var = require("workvar")

local function errlog(...)
    log(ERR, "Contant lua:", ...)
end

-- 从共享内存中取数据
local function getFromCache(key)
    local cache_ngx = ngx.shared.globle_cache
    local value = cache_ngx:get(key)
    return value
end

-- 获取url 参数 来源IP
local function getParameter()
end

-- access处理
local function accessHandler()
end

-- rewrite 处理
local function rewriteHandler()
end

-- upstream处理
local function upstreamHandler()
end

local function locationHandler(localtion)
    if not localtion["pass"] then
        return
    end
    if localtion["access"] then
    end
    if localtion["rewrite"] then
    end
    pass = localtion["pass"]
    if pass == "root" then
        ngx.say(localtion[pass].. localtion["url"])
        return
    end
    if pass == "upstream" then
        upstream = localtion[pass]
        
        ngx.var.upaddr = "127.0.0.1:8080"
    end
end

local function handler()

    -- 根据servername获取url
    local servername = ngx.var.host
    local requri = ngx.var.request_uri

    -- 精确url处理
    -- 获取精确url的列表
    -- accurate_url = getFromCache(servername .. "=")
    local cnf = var.getGlobleCnf()
    local accurate_url = cnf[servername]["="]

    -- errlog(cjson.encode(accurate_url))

    if accurate_url[requri] then
        location = cnf[servername][requri]
        locationHandler(localtion)
        return
    end


    -- 匹配url处理

    -- 正则url处理
    
end

handler()
