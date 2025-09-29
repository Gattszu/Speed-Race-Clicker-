local replicatedStorage = game:GetService("ReplicatedStorage")
local generalModule = require(game.ReplicatedStorage.ModuleScripts.GeneralModule)

local module = {}

--> attaches pets to the player's character via weld constraints
local function AttachPetsToCharacter(player, hrp, pets)
	
	for i, pet in ipairs(pets) do
		local weld = Instance.new("WeldConstraint")
		weld.Name = "PlayerWeld"
		weld.Part0 = pet.PrimaryPart
		weld.Part1 = hrp
		weld.Parent = pet.PrimaryPart

		pet.PrimaryPart.Anchored = false
		pet.PrimaryPart:SetNetworkOwner(player)
	end
end

--> detatches pets from the player's character via weld constraints
local function DetatchPetsFromCharacter(player, pets)
	for i, pet in ipairs(pets) do
		if pet.PrimaryPart:FindFirstChild("PlayerWeld") then
			pet.PrimaryPart.PlayerWeld:Destroy()
			pet.PrimaryPart:SetNetworkOwner(nil)
		end
	end
end

--> Positions pets in a circle around the player's character
function module.PositionPets(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local petFolder = game.Workspace.PlayerPets:WaitForChild(player.Name)
	if not character or not petFolder then return end
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local circle = math.pi * 2
	local minimumRadius = 4

	local pets = petFolder:GetChildren()
	local petCount = #pets
	if petCount == 0 then return end
	
	DetatchPetsFromCharacter(player, pets)
	for i, pet in ipairs(pets) do
		if not pet.PrimaryPart then
			warn(pet.Name .. " has no PrimaryPart set")
			continue
		end

		local radius = minimumRadius + petCount
		local angle = i * (circle / petCount)
		local x = math.cos(angle) * radius
		local yOffset = pet:FindFirstChild("yOffset") and pet.yOffset.Value or 0
		local z = math.sin(angle) * radius

		-- FIXED position relative to HRP (no lerp)
		local targetCFrame = hrp.CFrame * CFrame.new(x, yOffset, z)
		pet:PivotTo(targetCFrame)
	end
	AttachPetsToCharacter(player, hrp, pets)
end

--> add the given pet to the player's inventory
function module.AddPetToInventory(player, pet)
	local Inventory = player.Inventory
	player.UniqueIDCounter.Value += 1
	local UniqueIDCounter = player.UniqueIDCounter.Value
	local petData = Instance.new("Folder", Inventory)
	petData.Name = pet.Name
	local petNameValue = Instance.new("StringValue", petData)
	petNameValue.Name = "Name"
	petNameValue.Value = pet.Name
	local petLevel = Instance.new("IntValue", petData)
	petLevel.Name = "Level"
	petLevel.Value = 1
	local petXP = Instance.new("IntValue", petData)
	petXP.Name = "XP"
	petXP.Value = 0
	local petImageID = Instance.new("StringValue", petData)
	petImageID.Name = "ImageID"
	petImageID.Value = pet.ImageID.Value
	local petRarity = Instance.new("StringValue", petData)
	petRarity.Name = "Rarity"
	petRarity.Value = pet.Rarity.Value
	local equippedState = Instance.new("BoolValue", petData)
	equippedState.Name = "Equipped"
	equippedState.Value = false
	local UniqueID = Instance.new("IntValue", petData)
	UniqueID.Name = "UniqueID"
	UniqueID.Value += UniqueIDCounter
	return petData
end

--> equip the given pet to the player's character
function module.EquipPet(player, pet)
	local petFolders = replicatedStorage.PetFolders
	local playerPets = workspace.PlayerPets:FindFirstChild(player.Name)
	
	if playerPets == nil or #playerPets:GetChildren() >= 4 then return end
	
	local petObject = nil
	for i, folder in ipairs(petFolders:GetChildren()) do
		petObject = folder:FindFirstChild(pet.Name)
		if petObject then break end
	end
	
	local spawnPet = petObject:Clone()
	spawnPet.Level.Value = pet.Level.Value
	spawnPet.XP.Value = pet.XP.Value
	spawnPet.Parent = playerPets
	
	--> give pet its uniqueID
	local currentID = player.UniqueIDCounter.Value
	local uniqueID = Instance.new("IntValue")
	uniqueID.Name = "UniqueID"
	uniqueID.Value = pet.UniqueID.Value
	uniqueID.Parent = spawnPet
	currentID += 1
	
	module.PositionPets(player)
	
	return spawnPet
end

--> unequip the given pet from the player's character
function module.UnequipPet(player, pet)
	local petFolder = workspace.PlayerPets:FindFirstChild(player.Name)

	if petFolder == nil then return end

	petFolder:FindFirstChild(pet.Name):Destroy()
	module.PositionPets(player)
end

--> sset the pet's level billboard GUI
function module.SetPetLevelGui(spawnPet, petLevel)
	local petLevelGui = spawnPet:FindFirstChild("BillboardGui")
	if petLevelGui then
		local levelText = petLevelGui:FindFirstChild("LevelText")
		if levelText then
			levelText.Text = "Level: " .. petLevel.Value
			petLevel.Changed:Connect(function(newValue)
				levelText.Text = "Level: " .. tostring(newValue)
			end)
		end
	end
end

--> increase each equipped pet's XP by 10 and/or level up if needed
function module.IncreasePetXP(player)
	
	local function increasePetLevel(pet)
		pet.XP.Value -= pet.Level.Value * 100
		pet.Level.Value += 1	
	end
	
	local equippedPets = generalModule.GetEquippedPets(player)
	
	for i, pet in pairs(equippedPets) do
		if pet.XP.Value >= pet.Level.Value * 100 then
			increasePetLevel(pet)
		else
			pet.XP.Value += 10
		end
	end
end

--> Remove pet from workspace and reposition the remaining pets
function module.DeletePetFromWorkspace(player, petData)
	if not petData.Equipped.Value then return end
	
	
	local playerPets = workspace.PlayerPets:FindFirstChild(player.Name)
	local uniqueID = petData:FindFirstChild("UniqueID").Value
	
	for i, pet in ipairs(playerPets:GetChildren()) do
		local idValue = pet:FindFirstChild("UniqueID").Value
		if idValue and idValue == uniqueID then --> check if ID matches
			pet:Destroy()
			break
		end
	end
	module.PositionPets(player)
end

return module
