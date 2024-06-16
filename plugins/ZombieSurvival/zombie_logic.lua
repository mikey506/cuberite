-- /Plugins/ZombieSurvival/zombie_logic.lua

function ChangeSkyColor(World)
  World:BroadcastChat(cChatColor.Red .. "The sky turns red as blood...")
  
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

function SpawnZombies(World)
  local SpawnX, SpawnY, SpawnZ = World:GetSpawnX(), World:GetSpawnY(), World:GetSpawnZ()
  
  LOG("Spawn coordinates: X=" .. tostring(SpawnX) .. ", Y=" .. tostring(SpawnY) .. ", Z=" .. tostring(SpawnZ))

  local zombieTypes = {cMonster.mtZombie, cMonster.mtHusk, cMonster.mtDrowned}
  
  if #zombieTypes == 0 then
    LOG("Error: zombieTypes array is empty!")
    return
  end

  for i = 1, 200 do
    local x = SpawnX + math.random(-100, 100)
    local y = SpawnY
    local z = SpawnZ + math.random(-100, 100)
    local zombieTypeIndex = math.random(#zombieTypes)
    local zombieType = zombieTypes[zombieTypeIndex]
    
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

function CustomizeZombie(Zombie)
  local weapons = {E_ITEM_WOODEN_SWORD, E_ITEM_STONE_SWORD, E_ITEM_IRON_SWORD}
  local names = {"Ferocious Zombie", "Bloody Walker", "Undead Menace"}

  local weapon = weapons[math.random(#weapons)]
  Zombie:GetInventory():SetEquippedItem(cItem(weapon))

  local name = names[math.random(#names)]
  Zombie:SetCustomName(name)

  local speed = math.random(5, 15) / 10.0
  Zombie:SetSpeed(Zombie:GetSpeedX() * speed, Zombie:GetSpeedY() * speed, Zombie:GetSpeedZ() * speed)

  Zombie:SetCustomNameAlwaysVisible(true)
end

function PrepareZombieHorde(World)
  ChangeSkyColor(World)
  SpawnZombies(World)
end

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
