local a = {
    ["ESC"] = 322,
    ["F1"] = 288,
    ["F2"] = 289,
    ["F3"] = 170,
    ["F5"] = 166,
    ["F6"] = 167,
    ["F7"] = 168,
    ["F8"] = 169,
    ["F9"] = 56,
    ["F10"] = 57,
    ["~"] = 243,
    ["1"] = 157,
    ["2"] = 158,
    ["3"] = 160,
    ["4"] = 164,
    ["5"] = 165,
    ["6"] = 159,
    ["7"] = 161,
    ["8"] = 162,
    ["9"] = 163,
    ["-"] = 84,
    ["="] = 83,
    ["BACKSPACE"] = 177,
    ["TAB"] = 37,
    ["Q"] = 44,
    ["W"] = 32,
    ["E"] = 38,
    ["R"] = 45,
    ["T"] = 245,
    ["Y"] = 246,
    ["U"] = 303,
    ["P"] = 199,
    ["["] = 39,
    ["]"] = 40,
    ["ENTER"] = 18,
    ["CAPS"] = 137,
    ["A"] = 34,
    ["S"] = 8,
    ["D"] = 9,
    ["F"] = 23,
    ["G"] = 47,
    ["H"] = 74,
    ["K"] = 311,
    ["L"] = 182,
    ["LEFTSHIFT"] = 21,
    ["Z"] = 20,
    ["X"] = 73,
    ["C"] = 26,
    ["V"] = 0,
    ["B"] = 29,
    ["N"] = 249,
    ["M"] = 244,
    [","] = 82,
    ["."] = 81,
    ["LEFTCTRL"] = 36,
    ["LEFTALT"] = 19,
    ["SPACE"] = 22,
    ["RIGHTCTRL"] = 70,
    ["HOME"] = 213,
    ["PAGEUP"] = 10,
    ["PAGEDOWN"] = 11,
    ["DELETE"] = 178,
    ["LEFT"] = 174,
    ["RIGHT"] = 175,
    ["TOP"] = 27,
    ["DOWN"] = 173,
    ["NENTER"] = 201,
    ["N4"] = 108,
    ["N5"] = 60,
    ["N6"] = 107,
    ["N+"] = 96,
    ["N-"] = 97,
    ["N7"] = 117,
    ["N8"] = 61,
    ["N9"] = 118
}
function SetFieldValueFromNameEncode(b, c)
    SetResourceKvp(b, json.encode(c))
end
function GetFieldValueFromName(b)
    local c = GetResourceKvpString(b)
    return c and json.decode(c) or {}
end
local d = nil;
local e = false;
local f = false;
ESX = nil;
local g = GetFieldValueFromName('Clippy_Slots').name and GetFieldValueFromName('Clippy_Slots').name or {}
print("^2Clippy Inventory")
local h = false;
local i = false;
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent("esx:getSharedObject", function(j)
            ESX = j
        end)
        Citizen.Wait(0)
    end
end)
function openInventory()
    loadPlayerInventory()
    e = true;
    f = true;
    SendNUIMessage({
        action = "display",
        type = "normal"
    })
    SetNuiFocus(true, true)
    SetCanMooveInInv(true)
    TriggerEvent("ESX:RebuildLoadout")
end
RegisterKeyMapping("openinv", "Ouvrir l'inventaire", "keyboard", "TAB")
RegisterCommand("openinv", function()
    if not f then
        Citizen.Wait(150)
        openInventory()
    else
        closeInventory()
    end
end, false)
function openTrunkInventory()
    loadPlayerInventory()
    f = true;
    e = true;
    SendNUIMessage({
        action = "display",
        type = "trunk"
    })
    SetNuiFocus(true, true)
    SetCanMooveInInv(true)
end
RegisterNetEvent('clp_closeinventory')
AddEventHandler('clp_closeinventory', function()
    if i then
        i = false;
        ClearPedTasks(GetPlayerPed(-1))
    end
    closeInventory()
end)
function closeInventory()
    if i then
        i = false;
        ClearPedTasks(GetPlayerPed(-1))
    end
    e = false;
    f = false;
    SendNUIMessage({
        action = "hide"
    })
    SetNuiFocus(false, false)
    SetCanMooveInInv(false)
end
RegisterNUICallback("NUIFocusOff", function()
    closeInventory()
    Citizen.Wait(50)
end)
RegisterNUICallback("GetNearPlayers", function(k, l)
    local m = PlayerPedId()
    local n, o = ESX.Game.GetPlayersInArea(GetEntityCoords(m), 3.0)
    local p = false;
    local q = {}
    for r = 1, #n, 1 do
        if n[r] ~= PlayerId() then
            p = true;
            table.insert(q, {
                label = GetPlayerName(n[r]),
                player = GetPlayerServerId(n[r])
            })
        end
    end
    if not p then
        ESX.ShowNotification(_U("players_nearby"))
    else
        SendNUIMessage({
            action = "nearPlayers",
            foundAny = p,
            players = q,
            item = k.item
        })
    end
    l("ok")
end)
RegisterNUICallback("PutIntoTrunk", function(k, l)
    local m = GetPlayerPed(-1)
    if type(k.number) == "number" and math.floor(k.number) == k.number then
        local s = tonumber(k.number)
        if k.item.type == "item_weapon" then
            s = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(k.item.name))
        end
        TriggerServerEvent("esx_trunk:putItem", d.plate, k.item.type, k.item.name, s, d.max, d.myVeh, k.item.label)
    end
    Wait(50)
    loadPlayerInventory()
    l("ok")
end)
RegisterNUICallback("TakeFromTrunk", function(k, l)
    local m = GetPlayerPed(-1)
    if type(k.number) == "number" and math.floor(k.number) == k.number then
        TriggerServerEvent("esx_trunk:getItem", d.plate, k.item.type, k.item.name, tonumber(k.number), d.max, d.myVeh)
    end
    Wait(50)
    loadPlayerInventory()
    l("ok")
end)
RegisterNUICallback("UseItem", function(k, l)
    TriggerServerEvent("esx:useItem", k.item.name)
    Citizen.Wait(10)
    loadPlayerInventory()
    l("ok")
end)
RegisterNUICallback("DropItem", function(k, l)
    local m = GetPlayerPed(-1)
    if IsPedSittingInAnyVehicle(m) then
        return
    end
    if type(k.number) == "number" and math.floor(k.number) == k.number then
        TriggerServerEvent("esx:removeInventoryItem", k.item.type, k.item.name, k.number)
    end
    Wait(10)
    loadPlayerInventory()
    l("ok")
end)
RegisterNUICallback("GiveItem", function(k, l)
    local m = PlayerPedId()
    local n, o = ESX.Game.GetPlayersInArea(GetEntityCoords(m), 3.0)
    local t = false;
    for r = 1, #n, 1 do
        if n[r] ~= PlayerId() then
            if GetPlayerServerId(n[r]) == k.player then
                t = true
            end
        end
    end
    if k.item.type == "item_weapon" then
        return ESX.ShowNotification("~r~Vous ne pouvez pas ce type d'arme.")
    end
    if t then
        local s = tonumber(k.number)
        if k.item.type == "item_weapon" then
            s = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(k.item.name))
        end
        TriggerServerEvent("esx:giveInventoryItem", k.player, k.item.type, k.item.name, s)
        Wait(10)
        loadPlayerInventory()
    else
        ESX.ShowNotification(_U("player_nearby"))
    end
    l("ok")
end)
function shouldCloseInventory(u)
    for v, w in ipairs(Config.CloseUiItems) do
        if w == u then
            return true
        end
    end
    return false
end
function shouldSkipAccount(x)
    for v, w in ipairs(Config.ExcludeAccountsList) do
        if w == x then
            return true
        end
    end
    return false
end
local y = false;
function getInventoryWeight(inventory)
    local z = 0;
    local A = 0;
    if inventory ~= nil then
        for r = 1, #inventory, 1 do
            if inventory[r] ~= nil then
                A = Config.DefaultWeight;
                if arrayWeight[inventory[r].name] ~= nil then
                    A = arrayWeight[inventory[r].name]
                end
                z = z + A * (inventory[r].count or 1)
            end
        end
    end
    return z
end
local B = 30000;
local C = false;
local D = {}
local E = {}
local F;
function loadPlayerInventory()
    ESX.TriggerServerCallback("c_inventaire:getPlayerInventory", function(k)
        items = {}
        fastItems = {}
        inventory = k.inventory;
        accounts = k.accounts;
        money = k.money;
        weapons = k.weapons;
        E = inventory;
        if not Config.UseLastVersionESX then 
            if Config.IncludeCash and money ~= nil and money > 0 then
                for G, w in pairs(accounts) do
                    moneyData = {
                        label = _U("cash"),
                        name = "cash",
                        type = "item_money",
                        count = money,
                        usable = false,
                        rare = false,
                        limit = -1,
                        canRemove = true
                    }
                    table.insert(items, moneyData)
                end
            end
            if Config.IncludeAccounts and accounts ~= nil then
                for G, w in pairs(accounts) do
                    if not shouldSkipAccount(accounts[G].name) then
                        local H = accounts[G].name ~= "bank"
                        if accounts[G].money > 0 then
                            accountData = {
                                label = accounts[G].label,
                                count = accounts[G].money,
                                type = "item_account",
                                name = accounts[G].name,
                                usable = false,
                                rare = false,
                                limit = -1,
                                canRemove = H
                            }
                            table.insert(items, accountData)
                        end
                    end
                end
            end
        elseif Config.UseLastVersionESX then 
            if Config.IncludeCash then
                for G, w in pairs(accounts) do
                    if w.name ~= "bank" and w.money >= 1 then
                        moneyData = {
                            label = w.name == Config.Cash and Config.CashLabel or w.name == Config.Blackmoney and Config.BlackmoneyLabel,
                            name = w.name,
                            type = "item_money",
                            count = w.money,
                            usable = false,
                            rare = false,
                            limit = -1,
                            canRemove = true
                        }
                        table.insert(items, moneyData)
                    end
                end
            end
        end
        for n, y in pairs(g) do
            for G, w in pairs(inventory) do
                if inventory[G].count <= 0 then
                    inventory[G] = nil
                else
                    inventory[G].type = "item_standard"
                    if y == inventory[G].name then
                        table.insert(fastItems, {
                            label = inventory[G].label,
                            count = inventory[G].count,
                            limit = -1,
                            type = inventory[G].type,
                            name = inventory[G].name,
                            usable = true,
                            rare = false,
                            canRemove = true,
                            slot = n
                        })
                        break
                    end
                end
            end
        end
        if inventory ~= nil then
            for G, w in pairs(inventory) do
                if inventory[G].count <= 0 then
                    inventory[G] = nil
                else
                    if json.encode(fastItems) ~= "[]" then
                        for n, y in pairs(fastItems) do
                            if y.name == inventory[G].name then
                                D[G] = true;
                                break
                            else
                                D[G] = false
                            end
                        end
                    else
                        D = {}
                    end
                    if not D[G] then
                        inventory[G].type = "item_standard"
                        table.insert(items, inventory[G])
                    end
                end
            end
        end
        local arrayWeight = Config.localWeight;
        local z = 0;
        local A = 0;
        local I = 0;
        if items ~= nil then
            for r = 1, #items, 1 do
                if items[r] ~= nil then
                    A = Config.DefaultWeight;
                    A = A / items[1].count * 0.0;
                    if arrayWeight[items[r].name] ~= nil then
                        A = arrayWeight[items[r].name]
                        items[r].limit = A / 1000
                    end
                    z = z + A * (items[r].count or 1)
                end
            end
        end
        local J = _U("player_info", z / 1000, B / 1000)
        local K = z / 1000;
        if z > 50000 then
            ESX.ShowNotification('~r~Vous êtes trop lourd.')
            J = _U("player_info_full", z / 1000, Config.Limit / 1000)
            pasmarcher1 = true
        elseif z > B then
            print('trop lourd')
            ESX.ShowNotification('~r~Vous êtes trop lourd.')
            y = true;
            pasmarcher1 = false;
            J = _U("player_info_full", z / 1000, Config.Limit / 1000)
        elseif z <= B then
            y = false;
            if pasmarcher1 then
                FreezeEntityPosition(GetPlayerPed(-1), false)
            end
            pasmarcher1 = false;
            J = _U("player_info", z / 1000, Config.Limit / 1000)
        end
        SendNUIMessage({
            action = "setItems",
            itemList = items,
            fastItems = fastItems,
            text = J
        })
    end, GetPlayerServerId(PlayerId()))
end
function setHurt()
    FreezeEntityPosition(GetPlayerPed(-1), true)
end
function setNotHurt()
    FreezeEntityPosition(GetPlayerPed(-1), false)
end
Citizen.CreateThread(function()
    while true do
        local L = 400;
        if y then
            L = 1;
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 21, true)
        end
        if pasmarcher1 then
            L = 1;
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 21, true)
            FreezeEntityPosition(GetPlayerPed(-1), true)
        end
        Wait(L)
    end
end)
RegisterNetEvent("c_inventaire:openTrunkInventory")
AddEventHandler("c_inventaire:openTrunkInventory", function(k, M, inventory, weapons)
    setTrunkInventoryData(k, M, inventory, weapons)
    openTrunkInventory()
end)
RegisterNetEvent("c_inventaire:refreshTrunkInventory")
AddEventHandler("c_inventaire:refreshTrunkInventory", function(k, M, inventory, weapons)
    setTrunkInventoryData(k, M, inventory, weapons)
end)
function setTrunkInventoryData(k, M, inventory, weapons)
    d = k;
    SendNUIMessage({
        action = "setInfoText",
        text = k.text
    })
    items = {}
    if M > 0 then
        accountData = {
            label = _U("black_money"),
            count = M,
            type = "item_account",
            name = "black_money",
            usable = false,
            rare = false,
            limit = -1,
            canRemove = false
        }
        table.insert(items, accountData)
    end
    if inventory ~= nil then
        for G, w in pairs(inventory) do
            if inventory[G].count <= 0 then
                inventory[G] = nil
            else
                inventory[G].type = "item_standard"
                inventory[G].usable = false;
                inventory[G].rare = false;
                inventory[G].limit = -1;
                inventory[G].canRemove = false;
                table.insert(items, inventory[G])
            end
        end
    end
    if Config.IncludeWeapons and weapons ~= nil then
        for G, w in pairs(weapons) do
            local N = GetHashKey(weapons[G].name)
            local m = PlayerPedId()
            if weapons[G].name ~= "WEAPON_UNARMED" then
                table.insert(items, {
                    label = weapons[G].label,
                    count = weapons[G].ammo,
                    limit = -1,
                    type = "item_weapon",
                    name = weapons[G].name,
                    usable = false,
                    rare = false,
                    canRemove = false
                })
            end
        end
    end
    SendNUIMessage({
        action = "setSecondInventoryItems",
        itemList = items
    })
end
function openTrunkInventory()
    loadPlayerInventory()
    e = true;
    local m = GetPlayerPed(-1)
    SendNUIMessage({
        action = "display",
        type = "trunk"
    })
    SetNuiFocus(true, true)
    SetCanMooveInInv(true)
end
Citizen.CreateThread(function()
    Citizen.Wait(2000)
    while true do
        Citizen.Wait(0)
        HudWeaponWheelIgnoreSelection()
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)
        DisableControlAction(0, 37, true)
        DisableControlAction(0, 12, true)
        DisableControlAction(0, 13, true)
        DisableControlAction(0, 14, true)
        DisableControlAction(0, 15, true)
        DisableControlAction(0, 16, true)
        DisableControlAction(0, 17, true)
    end
end)
RegisterNUICallback("PutIntoFast", function(k, l)
    if k.item.slot ~= nil then
        g[k.item.slot] = nil
    end
    g[k.slot] = k.item.name;
    TriggerServerEvent("c_inventaire:changeFastItem", k.slot, k.item.name)
    SetFieldValueFromNameEncode('Clippy_Slots', {
        name = g
    })
    loadPlayerInventory()
    l("ok")
end)
RegisterNUICallback("TakeFromFast", function(k, l)
    g[k.item.slot] = nil;
    SetFieldValueFromNameEncode('Clippy_Slots', {
        name = g
    })
    TriggerServerEvent("c_inventaire:changeFastItem", 0, k.item.name)
    loadPlayerInventory()
    l("ok")
end)
RegisterKeyMapping("equipone", "Équiper armes (Slot 1)", "keyboard", "1")
RegisterKeyMapping("equiptwo", "Équiper armes (Slot 2)", "keyboard", "2")
RegisterKeyMapping("equipthree", "Équiper armes (Slot 3)", "keyboard", "3")
RegisterKeyMapping("equipfor", "Équiper armes (Slot 4)", "keyboard", "4")
RegisterKeyMapping("equipfive", "Équiper armes (Slot 5)", "keyboard", "5")
RegisterCommand("equipone", function()
    UseKey(1)
end)
RegisterCommand("equiptwo", function()
    UseKey(2)
end)
RegisterCommand("equipthree", function()
    UseKey(3)
end)
RegisterCommand("equipfor", function()
    UseKey(4)
end)
RegisterCommand("equipfive", function()
    UseKey(5)
end)
function UseKey(n)
    if g[n] ~= nil then
        for O, y in pairs(E) do
            if y.name == g[n] then
                if y.type == "item_weapon" then
                elseif y.type == "item_standard" then
                    if string.find(y.name, "weapon_") then
                        UseWeapon(n, y.label)
                        break
                    elseif string.find(y.name, "gadget_") then
                        UseWeapon(n, y.label)
                        break
                    else
                        TriggerServerEvent("esx:useItem", y.name)
                        break
                    end
                end
            end
        end
    end
end
local P;
local Q;
function UseWeapon(n, R)
    local S = PlayerPedId()
    if IsPedInAnyVehicle(S, false) then
        return ESX.ShowNotification("~r~Vous ne pouvez pas équiper votre arme en véhicule.")
    end
    if P == g[n] then
        RemoveWeapon(P)
        P = nil;
        Q = nil;
        return
    elseif P ~= nil then
        RemoveWeapon(P)
        P = nil;
        Q = nil
    end
    P = g[n]
    GiveWeapon(P, R)
    ClearPedTasks(S)
end
function RemoveWeapon(T)
    local m = GetPlayerPed(-1)
    local U = GetHashKey(T)
    RemoveWeaponFromPed(m, U)
end
local V = {GetHashKey("weapon_pistol"), GetHashKey("weapon_combatpistol"), GetHashKey("weapon_pistol50"),
           GetHashKey("weapon_snspistol"), GetHashKey("weapon_heavypistol"), GetHashKey("weapon_vintagepistol"),
           GetHashKey("weapon_flaregun"), GetHashKey("weapon_revolver"), GetHashKey("weapon_doubleaction"),
           GetHashKey("weapon_microsmg"), GetHashKey("weapon_minismg"), GetHashKey("weapon_machinepistol")}
function GiveWeapon(T, R)
    local m = GetPlayerPed(-1)
    local U = GetHashKey(T)
    if R ~= nil then
        ESX.ShowNotification("Vous avez équipé votre ~g~" .. R .. "~s~.")
    end
    if TableGetValue(V, U) then
        GiveWeaponToPed(m, U, 0, false, true)
    else
        GiveWeaponToPed(m, U, 0, false, true)
    end
end
RegisterNetEvent('c_inventaire:client:addItem')
AddEventHandler('c_inventaire:client:addItem', function(W, X)
    local k = {
        name = W,
        label = X
    }
    SendNUIMessage({
        type = "addInventoryItem",
        addItemData = k
    })
end)
function TableGetValue(Y, Z, n)
    if not Y or not Z or type(Y) ~= "table" then
        return
    end
    for O, y in pairs(Y) do
        if n and y[n] == Z or y == Z then
            return true, O
        end
    end
end
local a = false;
local d = false;
local e = {1, 2, 3, 4, 5, 6, 18, 24, 25, 37, 68, 69, 70, 91, 92, 142, 182, 199, 200, 245, 257}
function SetCanMooveInInv(f)
    if SetNuiFocusKeepInput then
        SetNuiFocusKeepInput(f)
    end
    a = f;
    if not d and f then
        d = true;
        Citizen.CreateThread(function()
            while a do
                Wait(0)
                for g, h in pairs(e) do
                    DisableControlAction(0, h, true)
                end
            end
            d = false
        end)
    end
end
