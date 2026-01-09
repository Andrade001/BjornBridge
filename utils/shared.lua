local resourceName = GetCurrentResourceName()

Bridge = {
    ResourceName = resourceName,
    Config = BridgeConfig,
    Functions = {},
    Framework = string.lower(BridgeConfig.Framework or "vrpex"),
    Language = string.lower(BridgeConfig.Language or "en"),
    Version = GetResourceMetadata(resourceName, "version", 0)
}


exports("GetBridge", function()
    return Bridge
end)
