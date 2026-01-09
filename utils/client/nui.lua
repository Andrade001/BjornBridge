local Keys = Bridge.Config.Keys or {}

local promptState = {
    requestId = nil
}

local requestState = nil

local acceptCommand = "bjornbridge_accept" .. math.random(10000, 99999)
local declineCommand = "bjornbridge_decline" .. math.random(10000, 99999)
local acceptDefault = Keys.RequestAccept or "Y"
local declineDefault = Keys.RequestDecline or "N"

local function getUiStrings()
    return {
        promptTitle = Lang.promptTitle,
        requestTitle = Lang.requestTitle,
        inputLabel = Lang.inputLabel,
        acceptTitle = Lang.acceptTitle,
        declineTitle = Lang.declineTitle,
        acceptKey = acceptDefault,
        declineKey = declineDefault
    }
end

local function closePrompt(result)
    if not promptState.requestId then return end
    local requestId = promptState.requestId
    promptState.requestId = nil
    SendNUIMessage({ action = "close" })
    SetNuiFocus(false, false)
    TriggerServerEvent("BjornBridge:callbackClientResult", requestId, result)
end

local function closeRequest(result)
    if not requestState or not requestState.requestId then return end
    local requestId = requestState.requestId
    requestState = nil
    SendNUIMessage({ action = "close" })
    TriggerServerEvent("BjornBridge:callbackClientResult", requestId, result)
end

local function startRequestTimeout(requestId, timeoutMs)
    if timeoutMs and timeoutMs > 0 then
        SetTimeout(timeoutMs, function()
            if requestState and requestState.requestId == requestId then
                closeRequest(false)
            end
        end)
    end
end

Bridge.Callback.RegisterClient("bridge:prompt", function(requestId, message, placeholder)
    if promptState.requestId then
        closePrompt(nil)
    end
    promptState.requestId = requestId
    SendNUIMessage({
        action = "open",
        mode = "prompt",
        requestId = requestId,
        message = message,
        placeholder = placeholder or "",
        strings = getUiStrings()
    })
    SetNuiFocus(true, true)
end)

Bridge.Callback.RegisterClient("bridge:request", function(requestId, message, timeoutMs)
    if requestState and requestState.requestId then
        closeRequest(false)
    end
    requestState = { requestId = requestId }
    SendNUIMessage({
        action = "open",
        mode = "request",
        requestId = requestId,
        message = message,
        timeoutMs = timeoutMs,
        strings = getUiStrings()
    })
    startRequestTimeout(requestId, timeoutMs)
end)

RegisterNUICallback("promptSubmit", function(data, cb)
    if promptState.requestId and data and data.requestId == promptState.requestId then
        closePrompt(data.value)
    end
    cb({})
end)

RegisterNUICallback("promptCancel", function(data, cb)
    if promptState.requestId and data and data.requestId == promptState.requestId then
        closePrompt(nil)
    end
    cb({})
end)

RegisterCommand(acceptCommand, function()
    if requestState and requestState.requestId then
        closeRequest(true)
    end
end, false)

RegisterCommand(declineCommand, function()
    if requestState and requestState.requestId then
        closeRequest(false)
    end
end, false)

RegisterKeyMapping(acceptCommand, "BjornBridge: Aceitar request", "keyboard", acceptDefault)
RegisterKeyMapping(declineCommand, "BjornBridge: Recusar request", "keyboard", declineDefault)
