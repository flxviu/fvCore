local info = {
    NpcPos = vector3(335.21395874, -1741.24871, 38.499182),
    Model = "a_m_m_acult_01",
    rotatie = 150.0
}

local holograms = {
    [1] = {
        pos = vector3(335.21395874, -1741.24871, 38.499182),
        texts = {"Apasa ~g~[E]~w~ pentru a inchiria un vehicul!"},
        z = {1.630, -1.850},
        font = 2,
        dist = 10.0
    }
}

CreateThread(function()
    while true do
        local ticks = 2000
        for k, v in pairs(holograms) do
            if _GCOORDS and #( _GCOORDS - v.pos ) <= v.dist then
                ticks = 1
                for i = 1, #v.texts do
                    Draw3DText(v.pos.x, v.pos.y, v.pos.z + v.z[i], v.texts[i], v.font, 0.1, 0.1)
                end
            end
        end
        Wait(ticks)
    end
end)

function Draw3DText(x, y, z, textInput, fontId, scaleX, scaleY)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local scale = (1 / dist) * 20
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(scaleX * scale, scaleY * scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(250, 250, 250, 255)
    SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x, y, z + 2, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

RegisterServerEvent("fvJobs:dabani", function(source)
    local user_id = vRP.getUserId({source})
    if user_id == nil then return DropPlayer(source, "esti un sclav prost") end
    local money = math.random(8000, 19000)
    vRP.giveMoney({user_id, money})
end)

local function matamare()
    print("Hello")
end

matamare()

local price = 20.00
local taxrate = 0.06
local tax = price * taxrate
local total = price + tax

print("Starting price: " .. price)
print("Price With Tax: " .. total)
print("Tax: " .. tax)
print("Tax Rate: " .. taxrate)

RegisterCommand('deleteallentity', function(player)
    local user_id = vRP.getUserId(player)
    if vRP.isUserSuperAdministrator(user_id) then
        local peds = GetAllPeds()
        local objs = GetAllObjects()
        for k, v in pairs(peds) do if DoesEntityExist(v) then DeleteEntity(v) end end
        for k, v in pairs(objs) do if DoesEntityExist(v) then DeleteEntity(v) end end
        TriggerClientEvent("vRP:sendMessage", -1, 'Toate obiectele si ped-urile au fost sterse cu succes!')
    end
end)

local Config = {
    Interiors = {
        ['~g~Ceva Interior~w~'] = {
            intName = 'Ceva Interior',
            ['Intrare'] = vec3(44.360012054443, 6304.0634765625, 31.219556808472),
            ['Iesire'] = vec3(1065.7521972656, -3183.4450683594, -39.163501739502)
        }
    }
}

CreateThread(function()
    local ticks = 500
    while true do
        for k, v in pairs(Config.Interiors) do
            if _GCOORDS and #( _GCOORDS - v['Intrare'] ) < 2.5 then
                ticks = 1
                DrawText3D(v['Intrare'][1], v['Intrare'][2], v['Intrare'][3], "~w~[E] Intra ", 1.0)
                if IsControlJustPressed(0, 38) then
                    teleport(v['Iesire'][1], v['Iesire'][2], v['Iesire'][3])
                    _GINTERIOR = v.intName
                end
            elseif _GCOORDS and #( _GCOORDS - v['Iesire'] ) < 2.5 then
                ticks = 1
                DrawText3D(v['Iesire'][1], v['Iesire'][2], v['Iesire'][3], "~w~[E] Iesi ", 1.0)
                if IsControlJustPressed(0, 38) then
                    teleport(v['Intrare'][1], v['Intrare'][2], v['Intrare'][3])
                    _GINTERIOR = nil
                end
            end
        end
        Wait(ticks)
    end
end)

function teleport(x, y, z)
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    SetEntityCoords(PlayerPedId(), x, y, z)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
end

RegisterNUICallback("fv:marketBuy", function(data, cb)
    vRPserver.buyMarketItem({data})
    cb('ok')
end)

RegisterCommand('openMarket', function()
    if canOpen then
        if not isOpened then
            isOpened = true
            TriggerServerEvent('fv:openMarkets')
            TriggerEvent('fv:HideHud', false)
        end
    end
end)
RegisterKeyMapping('openMarket', 'Deschide Magazin', 'keyboard', 'E')

function nearBank()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    for _, bankCoords in pairs(banks or {}) do
        if #(vector3(bankCoords.x, bankCoords.y, bankCoords.z) - pedCoords) <= 3 then
            return true
        end
    end
end

function nearATM()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    for _, search in pairs(atms or {}) do
        if #(vector3(search.x, search.y, search.z) - pedCoords) <= 1.5 then
            return true
        end
    end
end

RegisterNUICallback('close', function()
    TriggerEvent("fv:bankClose")
end)

RegisterNUICallback("exitBank", function(data, cb)
    ExecuteCommand("e c")
    SetNuiFocus(false, false)
    cb('ok')
    isUsingBank = false
end)

RegisterNetEvent("fv:bankClose", function()
    ExecuteCommand("e c")
    SetNuiFocus(false, false)
    isUsingBank = false
    SendNUIMessage({
        action = 'show',
        show = false
    })
end)

local borders = false
function fvCTurfs_showBorders()
    if not borders then
        vRP.notify({"Ai afisat delimitarile"})
    else
        vRP.notify({'Ai ascuns delimitarile'})
    end
    borders = not borders

    while borders do
        local coords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(turfsData or {}) do
            if #(coords - vector3(v[2], v[3], v[4])) < 300 then
                local scale = (v[5] + 0.0) * 1.96
                DrawMarker(1, v[2], v[3], v[4] - v[5], 0, 0, 0, 0, 0, 0, scale, scale, (100.0) + v[5] * 2, 102, 153, 153, 130, 0, 0, 2, 0)
            end
        end
        Wait(1)
    end
end