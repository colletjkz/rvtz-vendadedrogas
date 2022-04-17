local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("buyDrugs", src)
vCLIENT = Tunnel.getInterface("buyDrugs")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECK ESTOQUE
-----------------------------------------------------------------------------------------------------------------------------------------
function VerificarMembro(fac, perm)
    if fac == 'groove' then
        return true
    elseif fac == 'vagos'  then
        return true
    elseif fac == 'Ballas' then
        return true
    end
    return false
end

function checkEstoque(fac)
    local source = source 
    local user_id = vRP.getUserId(source)
    local value = vRP.getSData('rvtz:EstoqueDroga'..fac)
    local saldofac = json.decode(value) or 0
    if saldofac > 0 then
        return true
    else
        TriggerClientEvent('Notify',source,'importante',"Importante",'Sem Estoque de Droga No Momento')
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADIÇÃO ESTOQUE
-----------------------------------------------------------------------------------------------------------------------------------------
function src.addEstoque()
    local source = source
    
    local user_id = vRP.getUserId(source)

    if not vRP.hasPermission(user_id, 'Drugs') then
        return false
    end

    local qtd = vRP.prompt(source, "Quantas Unidades Deseja Estocar:", "")

    if qtd == '' then

        return

    end

    if vRP.hasPermission(user_id, 'Grove') then
        local value = vRP.getSData('rvtz:EstoqueDroga'..'Groove')

        local saldofac = json.decode(value) or 0
        qtd = tonumber(qtd)

        
        if vRP.tryGetInventoryItem(user_id, 'cocaina', qtd) then
            vRP.setSData('rvtz:EstoqueDroga'..'Groove',saldofac+qtd)
            local saldofacn = json.decode(value) or 0
            TriggerClientEvent('Notify',source,'aviso',"Aviso",'Estoque de cocaína atual >>> '..saldofacn)
        end

    elseif vRP.hasPermission(user_id, 'Ballas') then

        local value = vRP.getSData('rvtz:EstoqueDroga'..'Ballas')

        local saldofac = json.decode(value) or 0

        qtd = tonumber(qtd)

        if vRP.tryGetInventoryItem(user_id, 'maconha', qtd) then

            vRP.setSData('rvtz:EstoqueDroga'..'Ballas',saldofac+qtd)
            TriggerClientEvent('Notify',source,'aviso', "Aviso", 'Estoque de Maconha atual >>> '..saldofac)

        end
        
    elseif vRP.hasPermission(user_id, 'Vagos') then

        local value = vRP.getSData('rvtz:EstoqueDroga'..'Vagos')

        local saldofac = json.decode(value) or 0

        qtd = tonumber(qtd)

        if vRP.tryGetInventoryItem(user_id, 'metanfetamina', qtd) then

            vRP.setSData('rvtz:EstoqueDroga'..'Vagos',saldofac+qtd)
            TriggerClientEvent('Notify',source,'aviso', "Aviso", 'Estoque de Lsd atual >>> '..saldofac)

        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RETIRADA DE ESTOQUE
-----------------------------------------------------------------------------------------------------------------------------------------
function retirarQTD(fac,valor)

    local value = vRP.getSData('rvtz:EstoqueDroga'..fac)

    local saldofac = json.decode(value) or 0
    valor = tonumber(valor)

    if tonumber(valor) > saldofac then
        return false
    else
        vRP.setSData('rvtz:EstoqueDroga'..fac,saldofac-valor)
        return true
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VENDA DE DROGAS
-----------------------------------------------------------------------------------------------------------------------------------------
local delayVMochila = {}
local PrecoDaDroga = 2500

function src.buyDrugs(TipoDaVenda)

    local user_id = vRP.getUserId(source)

    local qtd = vRP.prompt(source, "Quantas Unidades Deseja Comprar:", "")

    if qtd == '' then

        return

    end

    --qtd = tonumber(qtd)

    if not delayVMochila[user_id] or os.time() > (delayVMochila[user_id] + 1) then

        delayVMochila[user_id] = os.time()


        if user_id then

            print(type(qtd))

            if vRP.tryFullPayment(user_id, parseInt(qtd) * PrecoDaDroga)  then
                local pagamento = qtd*PrecoDaDroga

                TriggerClientEvent("cancelando", source, true)

                if TipoDaVenda == 'groove' then

                    if checkEstoque('Groove') then
                        
                        if retirarQTD('Groove',qtd) then
                            paymentFac('Groove',pagamento)

                            vRP.giveInventoryItem(user_id, "cocaina", qtd)
                        end

                    end

                elseif TipoDaVenda == 'ballas' then
                    if checkEstoque('Ballas') then

                        if retirarQTD('Ballas',qtd) then

                            vRP.giveInventoryItem(user_id, "cigarromaconha", qtd)
                        end
                    end

                elseif TipoDaVenda == 'vagos' then
                    if checkEstoque('Vagos') then
                        if retirarQTD('Vagos',qtd) then
                        
                            vRP.giveInventoryItem(user_id, "lsd", qtd)
                        end
                    end

                end
                TriggerClientEvent("cancelando", source, false)


            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENT
-----------------------------------------------------------------------------------------------------------------------------------------
function paymentFac(QualFac,qtd)
    local source = source
    local user_id = vRP.getUserId(source)
    local value = vRP.getSData('rvtz:EstoqueDroga'..QualFac)
    local resultado = json.decode(value) or 0

    if QualFac == 'Groove' then
        vRP.setSData('rvtz:salario'..'Groove',resultado+qtd)

    elseif QualFac == 'Vagos' then
        vRP.setSData('rvtz:salario'..'Vagos',resultado+qtd)

    elseif QualFac == 'Ballas' then
        vRP.setSData('rvtz:salario'..'Ballas',resultado+qtd)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SACAR
-----------------------------------------------------------------------------------------------------------------------------------------
function src.sacarDinDin()
    local source = source
    local user_id = vRP.getUserId(source)

    if vRP.hasPermission(user_id, 'Grove') then
        local value = vRP.getSData('rvtz:salario'..'Groove')
        local resultado = json.decode(value) or 0
        TriggerClientEvent('Notify', source, 'aviso', "Aviso", 'Saldo De Vendas: $'..vRP.format(parseInt(resultado)))
        local qtd = vRP.prompt(source, "Digite o valor  que deseja Sacar:", "")

        if qtd == '' then

            return

        end

         if resultado > 0 then
            qtd = tonumber(qtd)
            vRP.setSData('rvtz:salario'..'Groove',resultado-qtd)
            vRP.giveMoney(user_id,qtd)
            TriggerClientEvent('Notify', source, 'aviso', "Aviso", 'Você Sacou: $'..vRP.format(parseInt(qtd)))
         else
            TriggerClientEvent('Notify',source,'sucesso','Sem saldo disponivel.')
         end

    elseif vRP.hasPermission(user_id, 'Ballas') then
        local value = vRP.getSData('rvtz:salario'..'Ballas')
        local resultado = json.decode(value) or 0
        TriggerClientEvent('Notify', source, 'aviso', "Aviso", 'Saldo De Vendas: $'..vRP.format(parseInt(resultado)))
        local qtd = vRP.prompt(source, "Digite o valor  que deseja Sacar:", "")

        if qtd == '' then

            return

        end
        if resultado > 0 then
            qtd = tonumber(qtd)
            vRP.setSData('rvtz:salario'..'Groove',resultado-qtd)
            vRP.giveMoney(user_id,qtd)
            TriggerClientEvent('Notify', source, 'aviso', "Aviso", 'Você Sacou: $'..vRP.format(parseInt(qtd)))
        else
            TriggerClientEvent('Notify',source,'sucesso', "Sucesso", 'Sem saldo disponivel.')
        end
    elseif vRP.hasPermission(user_id, 'Vagos') then
        local value = vRP.getSData('rvtz:salario'..'Vagos')
        local resultado = json.decode(value) or 0
        TriggerClientEvent('Notify', source, 'aviso', "Aviso", 'Saldo De Vendas: $'..vRP.format(parseInt(resultado)))
        local qtd = vRP.prompt(source, "Digite o valor  que deseja Sacar:", "")

        if qtd == '' then

            return

        end
        if resultado > 0 then
            qtd = tonumber(qtd)
            vRP.setSData('rvtz:salario'..'Vagos',resultado-qtd)
            vRP.giveMoney(user_id,qtd)
            TriggerClientEvent('Notify', source, 'aviso', "Aviso", 'Você Sacou: $'..vRP.format(parseInt(qtd)))
        else
            TriggerClientEvent('Notify',source,'importante', "Importante", 'Sem saldo disponivel.')
        end
    end
end






function returnar(algo)
    if type(algo) == 'string' then
        return
    end
end