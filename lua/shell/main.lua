
local http = require("socket.http")
local ltn12 = require("ltn12")
local url = arg[1]

local proxy = {}

local function forward(method, url, body)
    local response = {}
    local body_reader = nil
    if body then
        body_reader = function()
            return body
        end
    end
    local res, code, headers = http.request {
        url = url,
        method = method,
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = #body,
        },
        source = body_reader,
        sink = ltn12.sink.table(response),
    }
    return table.concat(response), code, headers
end

-- requests
proxy.GET = function(url, body)
    return forward("GET", url, body)
end

proxy.POST = function(url, body)
    return forward("POST", url, body)
end

proxy.PUT = function(url, body)
    return forward("PUT", url, body)
end

proxy.DELETE = function(url, body)
    return forward("DELETE", url, body)
end


local function main()
    local method = arg[2]
    local url = arg[3]
    local body = arg[4]
    if not method or not url then
        print("usage: proxy.lua <method> <url> [body]")
        return
    end
    local response, code, headers = proxy[method](url, body)
    print(response)
end

main()


