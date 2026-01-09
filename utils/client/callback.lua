Bridge.Callback = Bridge.Callback or {}

local handlers = {}

function Bridge.Callback.RegisterClient(name, fn)
    handlers[name] = fn
end

RegisterNetEvent("BjornBridge:callbackClient", function(requestId, name, ...)
    local handler = handlers[name]
    if handler then
        handler(requestId, ...)
    else
        TriggerServerEvent("BjornBridge:callbackClientResult", requestId, nil)
    end
end)
