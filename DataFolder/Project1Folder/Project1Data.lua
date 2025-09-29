local DSS = game:GetService("DataStoreService")
local petInventoryStore = DSS:GetDataStore("PetInventory")

local petModule = require(game.ReplicatedStorage.ModuleScripts.petModule)


game.Players.PlayerAdded:Connect(function(player)
	--> create player inventory
	local petInventory = Instance.new("Folder")
	petInventory.Name = "Inventory"
	petInventory.Parent = player
	
	--> create unique ID counter to reference each pet
	local UniqueIDCounter = Instance.new("IntValue")
	UniqueIDCounter.Name = "UniqueIDCounter"
	UniqueIDCounter.Value = 0
	UniqueIDCounter.Parent = player
	
	--> create a hatching state to prevent multiple hatches at once
	local isHatching = Instance.new("BoolValue")
	isHatching.Name = "isHatching"
	isHatching.Value = false
	isHatching.Parent = player
	
	
	--> load player pet data
	local success, err = pcall(function()
		local storedPets = petInventoryStore:GetAsync(player.UserId) 
		
		if storedPets then 
			for i, pet in pairs(storedPets) do
				local petFolder = Instance.new("Folder", petInventory)
				petFolder.Name = pet.Name
				local petName = Instance.new("StringValue", petFolder)
				petName.Name = "Name"
				petName.Value = pet.Name
				local petLevel = Instance.new("IntValue", petFolder)
				petLevel.Name = "Level"
				petLevel.Value = pet.Level
				local petXP = Instance.new("IntValue", petFolder)
				petXP.Name = "XP"
				petXP.Value = pet.XP
				local petImageID = Instance.new("StringValue", petFolder)
				petImageID.Name = "ImageID"
				petImageID.Value = pet.ImageID
				local petRarity = Instance.new("StringValue", petFolder)
				petRarity.Name = "Rarity"
				petRarity.Value = pet.Rarity
				local equippedState = Instance.new("BoolValue", petFolder)
				equippedState.Name = "Equipped"
				equippedState.Value = pet.Equipped
				local UniqueID = Instance.new("IntValue", petFolder)
				UniqueID.Name = "UniqueID"
				UniqueID.Value += UniqueIDCounter.Value + 1
				UniqueIDCounter.Value += 1
			end
		end
	end)
	
	if not success then
		warn("Error loading pet data for player " .. player.Name .. ": " .. err)
	end
	
	--> create a folder to store equipped pets parented to the workspace folder (PlayerPets)
	local equippedPets = Instance.new("Folder")
	equippedPets.Name = player.Name
	equippedPets.Parent = workspace.PlayerPets
	
	--> spawn player pre quipped pets
	for i, petData in pairs(petInventory:GetChildren()) do
		if petData.Equipped.Value == true then
			local spawnPet = petModule.EquipPet(player, petData)
			 petModule.SetPetLevelGui(spawnPet, petData.Level)
		end
	end
end)

--> save player pet data when they leave the game
game.Players.PlayerRemoving:Connect(function(player)
	--> Get player inventory
	local Inventory = player.Inventory
	local tempInventory = {}
	
	--> save player pet data to a temporary table
	local success, err = pcall(function()
		for i, pet in ipairs(Inventory:GetChildren()) do
			table.insert(tempInventory, {
				Name = pet.Name,
				Level = pet.Level.Value,
				XP = pet.XP.Value,
				ImageID = pet.ImageID.Value,
				Rarity = pet.Rarity.Value,
				Equipped = pet.Equipped.Value
			})
		end
		--> save player pet data to the datastore
		petInventoryStore:SetAsync(player.UserId, tempInventory)
	end)
	
	if success then
		print("successfully saved " .. player.Name .. "'s pets data")

	else 
		warn("error saving" .. player.Name .. "'s pets data: " .. err)
	end
	
	--> remove player pets folder from the workspace
	local folder = Inventory
	if folder == nil then return end 
	folder:Destroy()
end)