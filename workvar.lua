local _M

local globleCnf

local function setGlobleCnf(cnf)
    globleCnf = cnf
end

local function getGlobleCnf()
    return globleCnf
end

_M = {
    setGlobleCnf = setGlobleCnf,
    getGlobleCnf = getGlobleCnf
}

return _M
