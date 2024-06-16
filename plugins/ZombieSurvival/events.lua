-- /Plugins/ZombieSurvival/events.lua

function OnPlayerJoined(Player)
  Player:SendMessage(cChatColor.Red .. "A zombie horde is on its way!")
end

function OnTick(TimeDelta)
  if not isHordeActive then
    return
  end

  local World = cRoot:Get():GetDefaultWorld()
  World:ForEachPlayer(
    function(Player)
      for _, uniqueID in ipairs(zombieList) do
        World:DoWithEntityByID(uniqueID, function(Entity)
          local Zombie = tolua.cast(Entity, "cMonster")
          if Zombie then
            -- Make zombie break blocks and head towards the player
            local x, y, z = Player:GetPosX(), Player:GetPosY(), Player:GetPosZ()
            Zombie:MoveToPosition(x, y, z)
            BreakBlocks(Zombie)
          end
        end)
      end
    end
  )
end
