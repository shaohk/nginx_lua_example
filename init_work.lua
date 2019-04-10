local _M
local delay = 5
local handler

local log = ngx.log
local ERR = ngx.ERR

local redis = require("resty.redis")
local red
local confstr

local var = require("workvar")

local function errlog(...)
    log(ERR, "InitWork:", ...)
end

-- 从redis中读取配置
local function getConfigByRedis()
    red = redis:new()
    red:set_timeout(1000)
    local ok, err = red:connect("127.0.0.1", 6391)
    if not ok then
        errlog("redis connect faild:" .. err)
        return
    end

    local _conf, err = red:get("ngx.conf")

    if err then
        errlog("redis faild to get conf" .. err)
        return
    end

    if not _conf then
        errlog("redis get conf is nil")
        return
    end

    confstr = _conf

    local ok, err = red:set_keepalive(10000, 100)
    if not ok then
        errlog("redis set keepalive " .. err)
    end
end

-- 从文本文件中读取配置
local function getConfigByFile()
end

-- 往共享内存中塞数据
local function set2Cache(key, value, exptime)
    if not exptime then
        exptime = 0
    end
    local cache_ngx = ngx.shared.globle_cache
    local succ, err, forcible = cache_ngx:set(key, value, exptime)
    -- errlog("---" .. err)
    return succ
end

-- 解析配置
local function parseConf()
    if not confstr then
        errlog("ngx conf is nil")
        return
    end
    local cjson = require("cjson") 
    local confobj = cjson.decode(confstr)
    -- 检测配置是否为空或长度为0
    if not confobj and #confobj == 0 then
        errlog("ngx conf is invalid:" .. confstr)
        return 
    end

	local _newcnf = {}
    for i = 1, #confobj do
        local _cnf = confobj[i]
        
        if not _cnf.expr or _cnf.expr == "" then
            _cnf.expr = "="
        end

        if not _newcnf[_cnf.servername] then
            _newcnf[_cnf.servername] = {}
        end
        if not _newcnf[_cnf.servername][_cnf.expr] then
            _newcnf[_cnf.servername][_cnf.expr] = {}
        end
		-- table.insert(_newcnf[_cnf.servername][_cnf.expr], _cnf.url)
		_newcnf[_cnf.servername][_cnf.expr][_cnf.url] =  true
        _newcnf[_cnf.servername][_cnf.url] = _cnf
    end

    var.setGlobleCnf(_newcnf)

    -- for sname, vobj in pairs(_newcnf) do
    --     -- k 是expr或url，v是数组或者_cnf
    --     for k, v in pairs(vobj) do
    --         -- errlog(sname .. k .. cjson.encode(v))
    --         set2Cache(sname .. k, v)
    --     end
    -- end
end

handler = function(premature)
    if not premature then
        ngx.log(ngx.ERR, os.date("%Y-%m-%d %H:%M:%S", ngx.time()).." create timer success!")

        getConfigByRedis()
        parseConf()

        local ok,err = ngx.timer.at(delay, handler)
        if not ok then
            ngx.log(ngx.ERR, "failed to create timer:", err)
        end
    end
end

function init_work()
    local ok,err = ngx.timer.at(delay, handler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create timer:", err)
    end
end

_M = {
    init_work = init_work, 
}

return _M
