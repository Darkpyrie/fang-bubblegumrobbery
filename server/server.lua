local config = require('config.config')
local robbedMachines = {}
local resetTimers = {}

lib.callback.register('fang-bubblegumrobbery:server:getRobbedMachines', function(_, machineEntity)
    return robbedMachines[machineEntity]
end)

lib.callback.register('fang-bubblegumrobbery:server:setRobbedStatus', function(source, entity, state)
    local model = entity.entity
    if robbedMachines[model] ~= nil then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with robbed machine')
        return false
    end
    if #(GetEntityCoords(GetPlayerPed(source)) - entity.coords) > config.Distance then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with invalid distance')
        return false
    end

    robbedMachines[model] = state
    if state and not resetTimers[model] then
        resetTimers[model] = lib.timer((config.Cooldown * 1000), function()
            robbedMachines[model] = nil
            resetTimers[model] = nil 
        end, true)
    end

    return (robbedMachines[model] == state)
end)

lib.callback.register('fang-bubblerobbery:server:giveItem', function(source, model)
    local entity = model.entity
    local items = config.Items
    local itemSelect = math.random(1,5)
    local prizeItem = items[itemSelect].item
    if robbedMachines[entity] ~= nil then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with robbed machine')
        return false
    end
    if #(GetEntityCoords(GetPlayerPed(source)) - model.coords) > config.Distance then
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

lib.callback.register('fang-bubblerobbery:server:giveMoney', function(source, model)
    --[[if robbedMachines[model.entity] ~= nil then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with robbed machine')
        return false
    end]]
    if #(GetEntityCoords(GetPlayerPed(source)) - model.coords) > config.Distance then
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
