-- /Plugins/ZombieSurvival/info.lua

g_PluginInfo = 
{
  Name = "ZombieSurvival",
  Version = "1.0",
  Date = "2024-06-15",
  Description = "A plugin that spawns a zombie horde with custom behavior",
  Commands = 
  {
    ["/zombie"] = 
    {
      Permission = "zombiesurvival.command",
      Handler = HandleZombieCommand,
      HelpString = " - Manage the zombie horde",
    },
  },
  Permissions = 
  {
    ["zombiesurvival.command"] = 
    {
      Description = "Allows the player to manage the zombie horde",
      RecommendedGroups = "Admins",
    },
  },
}
