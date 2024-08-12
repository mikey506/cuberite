-- File: main.lua
-- Initialize the plugin and register the event handlers

local CUSTOM_BOW_NAME = "Clear Bow"
local playersWithCustomBow = {}

function Initialize(Plugin)
    Plugin:SetName(g_PluginInfo.Name)
    Plugin:SetVersion(g_PluginInfo.Version)

    -- Register the command
    cPluginManager.BindCommand("/bow", "*", HandleBowCommand, " - Get the Clear Bow")

    -- Register the correct hooks
    cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_SHOOTING, OnPlayerShooting)
    cPluginManager:AddHook(cPluginManager.HOOK_PROJECTILE_HIT_BLOCK, OnProjectileHitBlock)
    cPluginManager:AddHook(cPluginManager.HOOK_PROJECTILE_HIT_ENTITY, OnProjectileHitEntity)

    LOG("Initialized " .. Plugin:GetName() .. " v" .. Plugin:GetVersion())
    return true
end

-- Command handler for /bow get
function HandleBowCommand(Split, Player)
    if Split[2] == "get" then
        local BowItem = cItem(E_ITEM_BOW, 1)
        BowItem.m_CustomName = CUSTOM_BOW_NAME
        Player:GetInventory():AddItem(BowItem)
        Player:SendMessageSuccess("You have been given the Clear Bow!")
        return true
    end

    Player:SendMessageInfo("Usage: /bow get")
    return true
end

-- Event handler for when a player shoots (to check for the custom bow)
function OnPlayerShooting(Player)
    local HeldItem = Player:GetEquippedItem()

    if HeldItem.m_ItemType == E_ITEM_BOW and HeldItem.m_CustomName == CUSTOM_BOW_NAME then
        -- Mark this player as having shot with the custom bow
        playersWithCustomBow[Player:GetUniqueID()] = true
    end
end

-- Event handler for when a projectile hits a block
function OnProjectileHitBlock(Projectile, BlockX, BlockY, BlockZ, HitFace)
    local Shooter = Projectile:GetCreatorUniqueID()

    if Shooter and playersWithCustomBow[Shooter] then
        -- Clear blocks in a 20-block radius from the hit position
        local World = Projectile:GetWorld()
        ClearBlocks(World, BlockX, BlockY, BlockZ)
        playersWithCustomBow[Shooter] = nil -- Reset the state
    else
        LOG("[CustomBowPlugin] This projectile was not recognized as a custom one.")
    end
    return false
end

-- Event handler for when a projectile hits an entity
function OnProjectileHitEntity(Projectile, HitEntity)
    local Shooter = Projectile:GetCreatorUniqueID()

    if Shooter and playersWithCustomBow[Shooter] then
        -- Clear blocks in a 20-block radius from the entity's position
        local World = Projectile:GetWorld()
        local BlockX, BlockY, BlockZ = HitEntity:GetPosition():Unpack()
        ClearBlocks(World, BlockX, BlockY, BlockZ)
        playersWithCustomBow[Shooter] = nil -- Reset the state
    else
        LOG("[CustomBowPlugin] This projectile was not recognized as a custom one.")
    end
    return false
end

-- Function to clear specific blocks in a 20-block radius
function ClearBlocks(World, CenterX, CenterY, CenterZ)
    local Radius = 20
    for x = CenterX - Radius, CenterX + Radius do
        for y = CenterY - Radius, CenterY + Radius do
            for z = CenterZ - Radius, CenterZ + Radius do
                local BlockPos = Vector3i(x, y, z)
                local BlockType = World:GetBlock(BlockPos)
                if BlockType == E_BLOCK_DIRT or
                   BlockType == E_BLOCK_GRASS or
                   BlockType == E_BLOCK_SAND or
                   BlockType == E_BLOCK_GRAVEL or
                   BlockType == E_BLOCK_COARSE_DIRT then
                    World:SetBlock(BlockPos, E_BLOCK_AIR, 0)  -- Using vector-parametered SetBlock
                end
            end
        end
    end
end
