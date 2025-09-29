local MPS = game:GetService("MarketplaceService")
local players = game:GetService("Players")

local productFunctions = {}

-- 10 wins
productFunctions[3409099009] = function(receipt, player)
	player.Stats.Wins.Value += 10
	return true 
end

-- 50 wins
productFunctions[3409099835] = function(receipt, player)
	player.Stats.Wins.Value += 50
	return true 
end

-- 100 wins
productFunctions[3409100345] = function(receipt, player)
	player.Stats.Wins.Value += 100
	return true 
end

-- 500 wins
productFunctions[3409100781] = function(receipt, player)
	player.Stats.Wins.Value += 100
	return true 
end

-- 1K wins
productFunctions[3409100779] = function(receipt, player)
	player.Stats.Wins.Value += 1000
	return true 
end

-- 5K wins
productFunctions[3409102137] = function(receipt, player)
	player.Stats.Wins.Value += 5000
	return true 
end

-- 100 Speed
productFunctions[3411258366] = function(receipt, player)
	player.Stats.Speed.Value += 10
	return true 
end

-- 1K Speed
productFunctions[3411258461] = function(receipt, player)
	player.Stats.Speed.Value += 100
	return true 
end

-- 10K Speed
productFunctions[3411258537] = function(receipt, player)
	player.Stats.Speed.Value += 1000
	return true 
end

-- 50K Speed
productFunctions[3411258610] = function(receipt, player)
	player.Stats.Speed.Value += 5000
	return true 
end

-- 100K Speed
productFunctions[3411259658] = function(receipt, player)
	player.Stats.Speed.Value += 10000
	return true 
end

-- 500K Speed
productFunctions[3411260320] = function(receipt, player)
	player.Stats.Speed.Value += 50000
	return true 
end

-- 1M Speed
productFunctions[3411260458] = function(receipt, player)
	player.Stats.Speed.Value += 100000
end

local function processReciept(recieptInfo)
	local userID = recieptInfo.PlayerId
	local productID = recieptInfo.ProductId
	
	local player = players:GetPlayerByUserId(userID)
	
	if player then
		local handler = productFunctions[productID]
		
		local success, result = pcall(handler, recieptInfo, player)
		if success then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			warn("Failed to process receipt:" .. recieptInfo)
		end 
	end
	
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

MPS.ProcessReceipt = processReciept