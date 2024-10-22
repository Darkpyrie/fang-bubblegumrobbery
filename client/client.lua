local models = {
    785076010, 
    1243022785, 
    462203053 ,
}

local function progressBar(data)
    local modelCoords = data.coords
    local pedCoords = GetEntityCoords(PlayerPedId())
    if #(pedCoords - modelCoords) > 0.75 then
        lib.notify({
            title = 'You ape',
            description = 'You ain\'t plastic man. Get next to it',
            type = 'error'
        }) 
        return
    end
    if lib.progressBar({
        duration = 5000,
        label = 'Stealing those coins',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true
        },
        anim = {
            dict = 'mp_common_heist',
            clip = 'pick_door',
        },
    }) then 
        local success = lib.callback.await('fang-bubblegumrobbery:server:setRobbedStatus', false, data, true)
        if not success then
            lib.notify({
                title = 'Error',
                description = 'Well bro, wtf? You tryna rob a robbed machine?',
                type = 'error'
            })
            return 
        end
        lib.callback.await('fang-bubblerobbery:server:giveMoney', false, data)
        lib.notify({
            title = 'Success',
            description = 'You stole change... wtf is wrong with you',
            type = 'success'
        }) 
    end
end


-- Function to set up targets
local function setupBuyTargets()
    exports.ox_target:addModel(models, {
        {
            label = 'Buy a random ball',
            icon = 'fa-solid fa-dollar-sign',
            onSelect = function(data)
                lib.callback.await('fang-bubblerobbery:server:giveItem', false, data)
            end
        },
        {
            label = 'Steal some change',
            icon = 'fa-solid fa-sack-dollar',
            items = 'lockpick',
            canInteract = function(entity)
                local isRobbed = lib.callback.await('fang-bubblegumrobbery:server:getRobbedMachines', false, entity)
                return not isRobbed
            end,
            onSelect = function(data)
                local isRobbed = lib.callback.await('fang-bubblegumrobbery:server:getRobbedMachines', false, data.entity)
                if isRobbed then
                   return lib.notify({
                        title = 'You\'re blind!',
                        description = 'The machine is broken. Come back later',
                        type = 'error'
                    }) 
                end
                local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}}, {'1', '2', '3', '4'})
                if not success then
                    lib.notify({
                        title = 'Failed',
                        description = 'How you failed this is beyond me',
                        type = 'error'
                    }) return
                end
                progressBar(data)
            end
        }
    })
end

CreateThread(function()
    setupBuyTargets() --sets up targets to buy gumballs
end)
