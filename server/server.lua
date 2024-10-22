local config = require('config.config')
local robbedMachines = {}
local resetTimers = {}

lib.callback.register('fang-bubblegumrobbery:server:getRobbedMachines', function(_, machineEntity)
    return robbedMachines[machineEntity]
end)

lib.callback.register('fang-bubblegumrobbery:server:setRobbedStatus', function(source, entityID, state)
    if robbedMachines[entityID] then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with robbed machine')
        return false
    end
    if #(GetEntityCoords(GetPlayerFromServerId(source)) - GetEntityCoords(entityID)) > config.Distance then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with invalid distance')
        return false
    end

    robbedMachines[entityID] = state
    if state and not resetTimers[entityID] then
        resetTimers[entityID] = lib.timer((config.Cooldown * 1000), function()
            robbedMachines[entityID] = nil
            resetTimers[entityID] = nil 
        end, true)
    end

    return (robbedMachines[entityID] == state)
end)

lib.callback.register('fang-bubblerobbery:server:giveItem', function(source, entity)
    local items = config.Items
    local itemSelect = math.random(1,5)
    local prizeItem = items[itemSelect].item
    if robbedMachines[entity] then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with robbed machine')
        return false
    end
    if #(GetEntityCoords(GetPlayerFromServerId(source)) - GetEntityCoords(entity)) > config.Distance then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with invalid distance')
        return false
    end
    if not exports.ox_inventory:RemoveItem(source, 'money', config.Price) then 
        return TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'You are too broke...',
            type = 'error'
        })
    end
    exports.ox_inventory:AddItem(source, prizeItem, items[itemSelect].count)
end)

lib.callback.register('fang-bubblerobbery:server:giveMoney', function(source, entity)
    if robbedMachines[entity] then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with robbed machine')
        return false
    end
    if #(GetEntityCoords(GetPlayerFromServerId(source)) - GetEntityCoords(entity)) > config.Distance then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with invalid distance')
        return false
    end
    if not exports.ox_inventory:RemoveItem(source, 'lockpick', 1) then
        lib.print.warn('[WARNING] Player triggered giveMoney callback without lockpick')
        return false
    end
    exports.ox_inventory:AddItem(source, 'money', math.random(10,30))
    return true
end)
