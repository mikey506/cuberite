-- /Plugins/ZombieSurvival/main.lua

local isHordeActive = false
local zombieList = {}

-- Initialize the plugin
function Initialize(Plugin)
  Plugin:SetName("ZombieSurvival")
  Plugin:SetVersion(1)

  -- Register Hooks
  cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_JOINED, OnPlayerJoined)
  cPluginManager:AddHook(cPluginManager.HOOK_TICK, OnTick)

  -- Register commands
  cPluginManager.BindCommand("/zombie", "zombiesurvival.command", HandleZombieCommand, " - Manage the zombie horde")

  LOG("Initialized ZombieSurvival v" .. Plugin:GetVersion())
  return true
end

-- Announce the zombie horde and prepare the event
function OnPlayerJoined(Player)
  Player:SendMessage(cChatColor.Red .. "A zombie horde is on its way!")
end

-- Handle /zombie commands
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

-- Simulate changing the sky color to red
function ChangeSkyColor(World)
  -- Placeholder for changing sky color
  World:BroadcastChat(cChatColor.Red .. "The sky turns red as blood...")

  -- Simulate with red blocks above each player
  World:ForEachPlayer(function(Player)
    local PosX = math.floor(Player:GetPosX())
    local PosY = math.floor(Player:GetPosY()) + 50
    local PosZ = math.floor(Player:GetPosZ())
    for x = -10, 10 do
      for z = -10, 10 do
        Player:GetWorld():SetBlock(PosX + x, PosY, PosZ + z, E_BLOCK_REDSTONE_BLOCK)
      end
    end
  end)
end

-- Spawn a larger number of zombies at specified locations
function SpawnZombies(World)
  local SpawnX, SpawnY, SpawnZ = World:GetSpawnX(), World:GetSpawnY(), World:GetSpawnZ()
  
  -- Debug print statements
  LOG("Spawn coordinates: X=" .. tostring(SpawnX) .. ", Y=" .. tostring(SpawnY) .. ", Z=" .. tostring(SpawnZ))

  local zombieTypes = {cMonster.mtZombie, cMonster.mtHusk, cMonster.mtDrowned}
  
  -- Check if zombieTypes is not empty
  if #zombieTypes == 0 then
    LOG("Error: zombieTypes array is empty!")
    return
  end

  for i = 1, 200 do  -- Increased the number of zombies
    local x = SpawnX + math.random(-100, 100)
    local y = SpawnY
    local z = SpawnZ + math.random(-100, 100)
    local zombieTypeIndex = math.random(#zombieTypes)
    local zombieType = zombieTypes[zombieTypeIndex]
    
    -- Additional debug statements
    LOG("Spawning zombie type index: " .. tostring(zombieTypeIndex) .. ", type: " .. tostring(zombieType) .. " at coordinates: X=" .. tostring(x) .. ", Y=" .. tostring(y) .. ", Z=" .. tostring(z))
    
    local Zombie = World:SpawnMob(x, y, z, zombieType)
    if Zombie then
      CustomizeZombie(Zombie)
      table.insert(zombieList, Zombie:GetUniqueID())
    else
      LOG("Error: Failed to spawn zombie at coordinates: X=" .. tostring(x) .. ", Y=" .. tostring(y) .. ", Z=" .. tostring(z))
    end
  end
end

-- Customize zombie behavior
function CustomizeZombie(Zombie)
  local weapons = {E_ITEM_WOODEN_SWORD, E_ITEM_STONE_SWORD, E_ITEM_IRON_SWORD}
  local names = {"Ferocious Zombie", "Bloody Walker", "Undead Menace"}

  -- Set random weapon
  local weapon = weapons[math.random(#weapons)]
  Zombie:GetInventory():SetEquippedItem(cItem(weapon))

  -- Set random name
  local name = names[math.random(#names)]
  Zombie:SetCustomName(name)

  -- Customize speed
  local speed = math.random(5, 15) / 10.0
  Zombie:SetSpeed(Zombie:GetSpeedX() * speed, Zombie:GetSpeedY() * speed, Zombie:GetSpeedZ() * speed)

  -- Additional behaviors
  Zombie:SetCustomNameAlwaysVisible(true)
end

-- Prepare and start the zombie horde event
function PrepareZombieHorde(World)
  ChangeSkyColor(World)
  SpawnZombies(World)
end

-- Handle the server tick to manage the event
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

-- Make zombies break blocks in their path
function BreakBlocks(Zombie)
  local World = Zombie:GetWorld()
  local Pos = Zombie:GetPosition()

  for x = -1, 1 do
    for y = -1, 1 do
      for z = -1, 1 do
        local BlockX = Pos.x + x
        local BlockY = Pos.y + y
        local BlockZ = Pos.z + z
        local BlockType = World:GetBlock(BlockX, BlockY, BlockZ)
        if BlockType ~= E_BLOCK_AIR then
          World:DigBlock(BlockX, BlockY, BlockZ)
        end
      end
    end
  end
end
