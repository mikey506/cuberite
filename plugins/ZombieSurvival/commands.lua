-- /Plugins/ZombieSurvival/commands.lua

function HandleZombieCommand(Split, Player)
  if #Split < 2 then
    Player:SendMessage(cChatColor.Red .. "Usage: /zombie <start/status/stop>")
    return true
  end

  local action = Split[2]
  if action == "start" then
    if not isHordeActive then
      isHordeActive = true
      PrepareZombieHorde(Player:GetWorld())
      Player:SendMessage(cChatColor.Green .. "Zombie horde started!")
    else
      Player:SendMessage(cChatColor.Red .. "Zombie horde is already active.")
    end
  elseif action == "status" then
    local status = isHordeActive and "active" or "inactive"
    Player:SendMessage(cChatColor.Green .. "Zombie horde is currently " .. status .. ".")
  elseif action == "stop" then
    if isHordeActive then
      isHordeActive = false
      zombieList = {}
      Player:GetWorld():BroadcastChat(cChatColor.Red .. "Zombie horde has been stopped!")
    else
      Player:SendMessage(cChatColor.Red .. "No active zombie horde to stop.")
    end
  else
    Player:SendMessage(cChatColor.Red .. "Invalid action. Use /zombie <start/status/stop>")
  end

  return true
end
