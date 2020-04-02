

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["F"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil
local isSick = false
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	getSick()
	
end)
function getSick()
	SetTimeout(5 * 60000, function()
		if not isSick then
			local prob = Config.ChanceDoenca
			if prob < 0 then
				prob = 0
			elseif prob > 100 then
			prob = 100
			end
			local getSickChance = math.random(1,1/(prob/100))
			if getSickChance == (1/(prob/100)) then
				isSick = true
				changeStatus()
			end
		end
		getSick()
	end)
end
function startAttitude(lib, anim)
	Citizen.CreateThread(function()
	
		local playerPed = GetPlayerPed(-1)
		RequestAnimSet(anim)
		
		while not HasAnimSetLoaded(anim) do
			Citizen.Wait(1)
		end
		SetPedMovementClipset(playerPed, anim, true)
	end)
end
function changeStatus()
	if isSick then
		SetTimecycleModifier("spectator5")
		SetPedMotionBlur(GetPlayerPed(-1), true)
		SetPedIsDrunk(GetPlayerPed(-1), true)
	else
		ClearTimecycleModifier()
		SetPedIsDrunk(GetPlayerPed(-1), false)
		SetPedMotionBlur(GetPlayerPed(-1), false)
	end
end
RegisterNetEvent("esx_doencas:doenca")
AddEventHandler("esx_doencas:doenca",function()
	if isSick then
	isSick = false
	else
	isSick = true
	end
	changeStatus()
end)
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if isSick then
			DrawMissionText("You have Disease see a doctor or take pills!", 1000)
		end
	end
end)
function DrawMissionText(m_text, showtime)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(m_text)
    DrawSubtitleTimed(showtime, 1)
end
RegisterNetEvent("esx_doencas:healingPlayer")
AddEventHandler("esx_doencas:healingPlayer",function(target)
	ESX.ShowNotification("Estás a curar o individuo!")
	Citizen.CreateThread(function()
		RequestAnimDict('mini@repair')
		while not HasAnimDictLoaded( 'mini@repair') do
			Citizen.Wait(1)
		end
		FreezeEntityPosition(GetPlayerPed(-1), true)
		makeEntityFaceEntity(GetPlayerPed(-1),GetPlayerPed(target))
		TaskPlayAnim(GetPlayerPed(-1), 'mini@repair' ,'fixing_a_ped' ,8.0, -8.0, -1, 0, 0, false, false, false )
		Citizen.Wait(2700)
		ClearPedTasks(GetPlayerPed(-1))
		FreezeEntityPosition(GetPlayerPed(-1), false)
    end)
	Citizen.Wait(2700)
end)
function makeEntityFaceEntity( entity1, entity2 )
    local p1 = GetEntityCoords(entity1, true)
    local p2 = GetEntityCoords(entity2, true)

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading( entity1, heading )
end
RegisterNetEvent("esx_doencas:getHealedComp")
AddEventHandler("esx_doencas:getHealedComp",function()
	isSick = false
	changeStatus()
	startAttitude("move_m@shocked@a","move_m@shocked@a")
	ESX.ShowNotification("You were healed!")
end)
RegisterNetEvent("esx_doencas:getHealed")
AddEventHandler("esx_doencas:getHealed",function()
	ESX.ShowNotification("You are being healed!")
	Citizen.CreateThread(function()
	FreezeEntityPosition(GetPlayerPed(-1), true)
	Citizen.Wait(3000)
	FreezeEntityPosition(GetPlayerPed(-1), false)
	end)
	Citizen.Wait(3000)
	isSick = false
	changeStatus()
	startAttitude("move_m@shocked@a","move_m@shocked@a")
	ESX.ShowNotification("You were healed!")
end)
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if isSick then
			DisableControlAction(2, Keys['SPACE'], true) -- Jump
			DisableControlAction(0, Keys['LEFTSHIFT'], true) -- Jump
			DisableControlAction(2, Keys['Q'], true) -- Cover
			DisableControlAction(2, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 36, true) -- Disable going stealth
		else
			Citizen.Wait(500)
		end
	end
end)
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		if isSick then
			startAttitude("move_m@depressed@a","move_m@depressed@a")
		end
	end

end)