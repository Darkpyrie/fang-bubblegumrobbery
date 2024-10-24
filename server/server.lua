local config = require('config.config')
local robbedMachines = {}
local resetTimers = {}

lib.callback.register('fang-bubblegumrobbery:server:getRobbedMachines', function(_, machineEntity)
    return robbedMachines[machineEntity]
end)

lib.callback.register('fang-bubblegumrobbery:server:setRobbedStatus', function(source, model, state)
    if robbedMachines[model.entity] ~= nil then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with robbed machine')
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'Well bro, wtf? You tryna rob a robbed machine?',
            type = 'error'
        })
        return false
    end
    if #(GetEntityCoords(GetPlayerPed(source)) - model.coords) > config.Distance then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with invalid distance')
        return false
    end
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Success',
        description = 'You stole change... wtf is wrong with you',
        type = 'success'
    })
    robbedMachines[model.entity] = state
    if state and not resetTimers[model.entity] then
        resetTimers[model.entity] = lib.timer((config.Cooldown * 1000), function()
            robbedMachines[model.entity] = nil
            resetTimers[model.entity] = nil 
        end, true)
    end

    return (robbedMachines[model.entity] == state)
end)

lib.callback.register('fang-bubblerobbery:server:giveItem', function(source, model)
    local prizeItem = config.Items[math.random(1,5)]
    local itemcount = prizeItem.count
    if robbedMachines[model.entity] ~= nil then
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
    exports.ox_inventory:AddItem(source, prizeItem, itemcount)
end)

lib.callback.register('fang-bubblerobbery:server:giveMoney', function(source, model)
    if robbedMachines[model.entity] ~= nil then
        lib.print.warn('[WARNING] Player triggered giveMoney callback with robbed machine')
        return false
    end
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
