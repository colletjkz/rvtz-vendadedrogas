local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
--------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
--------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("buyDrugs", src)
vSERVER = Tunnel.getInterface("buyDrugs")

local marcacoesVenda = {
	{-171.5,-1682.35,32.98,'groove'},  -- GROOVE
	{99.53,-1988.74,20.62,'ballas'},  -- BALLAS
	{394.85,-2056.92,21.4,'vagos'}  -- VAGOS
}

local Estoque = {
	{-197.58,-1699.94,33.5},  -- GROOVE
	{131.65,-1961.67,18.86},  -- BALLAS
	{392.03,-2044.03,23.42	}  -- VAGOS
}
local Banquinhos = {
	{-161.08,-1638.81,34.03,'Groove'},  -- GROOVE
	{111.63,-1978.61,20.99,'Ballas'},  -- BALLAS
	{371.54,-2040.61,22.2,'Vagos'	}  -- VAGOS
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMPRA DE DROGA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		for _,mark in pairs(marcacoesVenda) do
			local x,y,z,text = table.unpack(mark)
			local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),x,y,z,true)
			local ped = PlayerPedId()
			if distance <= 2.0 then	
				DrawText3D(x,y,z+0.1,"~r~E~w~   COMPRAR")
				if IsControlJustPressed(0,38) then
					vSERVER.buyDrugs(text)
					TriggerEvent('cancelando', true)
					vRP.playAnim(false, {{"amb@world_human_security_shine_torch@male@exit", "exit"}}, false)
					Wait(1000)
					TriggerEvent('cancelando', false)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDESTOQUE
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread( function()
	while true do
		Citizen.Wait(1)
		for _,mark in pairs(Estoque) do
			local x,y,z = table.unpack(mark)
			local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),x,y,z,true)
			local ped = PlayerPedId()
			if distance <= 2.0  then 	
				DrawText3D(x,y,z+0.1,"~r~E~w~   ADICIONAR ESTOQUE")
				if IsControlJustPressed(0,38) then
					if vSERVER.addEstoque() then
						TriggerEvent('cancelando', true)
						vRP.playAnim(false,{{"mp_common","givetake1_a"}},false)
						Wait(1000)
						TriggerEvent('cancelando', false)
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SACAR DIN DIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("retirar",function(source,args,rawCommand)
	for _,mark in pairs(Banquinhos) do
		local x,y,z,text = table.unpack(mark)
		local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),x,y,z,true)
		local ped = PlayerPedId()

		if distance <= 2.0  then
			vSERVER.sacarDinDin()
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DRAWTEXT3D
-----------------------------------------------------------------------------------------------------------------------------------------
function DrawText3D(x,y,z,text)
	SetTextFont(4)
	SetTextCentre(1)
	SetTextEntry("STRING")
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,150)
	AddTextComponentString(text)
	SetDrawOrigin(x,y,z,0)
	DrawText(0.0,0.0)
	local factor = (string.len(text) / 450) + 0.01
	DrawRect(0.0,0.0125,factor,0.03,40,36,52,240)
	ClearDrawOrigin()
end

local pedlist = {
	{ ['x'] = -171.26, ['y'] = -1681.83, ['z'] = 32.98, ['h'] = 167.97, ['hash'] = 0x303638A7, ['hash2'] = "a_f_m_beach_01" },
	{ ['x'] = 99.53, ['y'] = -1988.74, ['z'] = 20.62, ['h'] = 204.47, ['hash'] = 0xFAB48BCB, ['hash2'] = "a_f_m_fatbla_01" },
	{ ['x'] = 394.85, ['y'] = -2056.92, ['z'] = 21.4, ['h'] = 245.46, ['hash'] = 0xD172497E, ['hash2'] = "a_m_m_afriamer_01" }
}

Citizen.CreateThread(function()
	for k,v in pairs(pedlist) do
		RequestModel(GetHashKey(v.hash2))
		while not HasModelLoaded(GetHashKey(v.hash2)) do
			Citizen.Wait(10)
		end

		local ped = CreatePed(4,v.hash,v.x,v.y,v.z-1,v.h,false,true)
		FreezeEntityPosition(ped,true)
		SetEntityInvincible(ped,true)
		SetBlockingOfNonTemporaryEvents(ped,true)
	end
end)