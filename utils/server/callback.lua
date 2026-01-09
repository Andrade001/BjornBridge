Bridge.Callback = Bridge.Callback or {}

local pending = {}

local function generateRequestId(src)
    local requestId
    repeat
        requestId = string.format("%s:%s:%d", src or 0, GetGameTimer(), math.random(100000, 999999))
    until not pending[requestId]
    return requestId
end

function Bridge.Callback.AwaitClient(source, name, timeoutMs, ...)
    local requestId = generateRequestId(source)
    local p = promise.new()

    pending[requestId] = { promise = p, source = source }

    TriggerClientEvent("BjornBridge:callbackClient", source, requestId, name, ...)

    if timeoutMs and timeoutMs > 0 then
        SetTimeout(timeoutMs, function()
            local entry = pending[requestId]
            if entry then
                pending[requestId] = nil
                entry.promise:resolve(nil)
            end
        end)
    end

    return Citizen.Await(p)
end

RegisterNetEvent("BjornBridge:callbackClientResult", function(requestId, ...)
    local entry = pending[requestId]
    if entry then
        pending[requestId] = nil
        entry.promise:resolve(...)
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
    for requestId, entry in pairs(pending) do
        if entry.source == src then
            pending[requestId] = nil
            entry.promise:resolve(nil)
        end
    end
end)
