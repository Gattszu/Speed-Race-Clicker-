local ReplicatedStorage = game:GetService("ReplicatedStorage")
local processEggRoll = ReplicatedStorage.Remotes.ProcessEggRoll
local updateInventory = ReplicatedStorage.Remotes.UpdateInventory
local petFolders = ReplicatedStorage.PetFolders
local hatchEgg = ReplicatedStorage.Remotes.HatchEgg
local petModule = require(ReplicatedStorage.ModuleScripts.petModule)

--> Randomly choose a pet based on the given pet table
local function choosePet(petTable)
	local totalWeight = 0
	for _, pet in pairs(petTable) do
		totalWeight += pet.Weight.Value
	end

	local roll = math.random(1, totalWeight)
	local current = 0

	for _, pet in ipairs(petTable) do
		current += pet.Weight.Value
		if roll <= current then
			return pet
		end
	end
end

--> Process the egg roll and return the chosen pet
processEggRoll.OnServerEvent:Connect(function(player, eggType)
	--> check if player is already hatching an egg 
	if player.isHatching.Value then return end
	
	--> player is not already hatching so set the isHatching state to true 
	player.isHatching.Value = true
	
	local petTable = {}
	local eggImageLink = nil
	
	if eggType == "Common" then
		petTable = petFolders.CommonPets:GetChildren()
		eggImageLink = "rbxassetid://119920751956964"
	end
	
	if eggType == "Rare" then
		petTable = petFolders.RarePets:GetChildren()
		eggImageLink = "rbxassetid://125656401243609"
	end
	
	if eggType == "Epic" then
		petTable = petFolders.EpicPets:GetChildren()
		eggImageLink = "rbxassetid://104299235220849"
	end
	
	if eggType == "Legendary" then
		petTable = petFolders.LegendaryPets:GetChildren()
		eggImageLink = "rbxassetid://117404772908987"
	end
	
	if eggType == "Monster" then
		petTable = petFolders.MonsterPets:GetChildren()
	end
	
	--> choose a random pet from the egg type as afore stated
	local pet = choosePet(petTable)
	
	--> add the chosen pet to the player's inventory
	local petData = petModule.AddPetToInventory(player, pet)
	
	--> update player's inventory now that they have a new pet
	updateInventory:FireClient(player, petData)
	
	--> initiate hatching sequence
	hatchEgg:FireClient(player, eggImageLink, pet)
end)