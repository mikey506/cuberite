-- /Plugins/ZombieSurvival/main.lua

-- Load plugin components
dofile(cPluginManager:GetPluginsPath() .. "/ZombieSurvival/info.lua")
dofile(cPluginManager:GetPluginsPath() .. "/ZombieSurvival/commands.lua")
dofile(cPluginManager:GetPluginsPath() .. "/ZombieSurvival/events.lua")
dofile(cPluginManager:GetPluginsPath() .. "/ZombieSurvival/zombie_logic.lua")

function Initialize(Plugin)
  Plugin:SetName(g_PluginInfo.Name)
  Plugin:SetVersion(g_PluginInfo.Version)

  -- Register hooks
  cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_JOINED, OnPlayerJoined)
  cPluginManager:AddHook(cPluginManager.HOOK_TICK, OnTick)

  -- Register commands
  for Command, Info in pairs(g_PluginInfo.Commands) do
    cPluginManager.BindCommand(Command, Info.Permission, Info.Handler, Info.HelpString)
  end

  LOG("Initialized " .. g_PluginInfo.Name .. " v" .. g_PluginInfo.Version)
  return true
end
