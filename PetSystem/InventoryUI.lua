local InventoryUI = {}

local updateEquipped = game.ReplicatedStorage.Remotes.UpdateEquipped
local petModule = require(game.ReplicatedStorage.ModuleScripts.petModule)

--> gets the xp needed for a specific pet to level up
local function xpNeeded(level)
	return 100 * level
end

--> creates a button for a pet in the inventory petItemFrame
function InventoryUI.createPetButton(pet, petItemFrame)
	local petButton = Instance.new("ImageButton")
	petButton.Image = "rbxassetid://" .. pet.ImageID.Value
	petButton.BackgroundColor3 = Color3.new(0.168627, 0.171176, 0.17319)
	local uiStroke = Instance.new("UIStroke", petButton)
	uiStroke.Thickness = 2
	local uiCorner = Instance.new("UICorner", petButton)
	petButton.Parent = petItemFrame
	local UniqueID = Instance.new("IntValue", petButton)
	UniqueID.Name = "UniqueID"
	UniqueID.Value = pet.UniqueID.Value
	return petButton
end

--> Removes the pet button from the inventory
function InventoryUI.RemovePetButton(selectedPet)
	local gui = game.Players.LocalPlayer.PlayerGui.InventoryGui
	local petItemFrame = gui.InventoryFrame.PetItemFrame
	local uniqueID = selectedPet.UniqueID.Value
	for i, child in ipairs(petItemFrame:GetChildren()) do
		if child.Name == "ImageButton" then
			if child.UniqueID.Value == uniqueID then
				child:Destroy()
			end
		end
	end
end

--> updates the selection fram according to the selected pet
function InventoryUI.UpdateSelectionFrame(pet, selectionFrame)
	local petImageLabel = selectionFrame.PetImageLabel
	local petNameLabel = selectionFrame.NameLabel
	local petRarityLabel = selectionFrame.RarityLabel
	local levelLabel = selectionFrame.LevelLabel
	local xpBar = selectionFrame.XPBar
	local xpFill = xpBar.XPFill
	local equipButton = selectionFrame.EquipButton

	--> updates the xp bar according to the pet's current xp
	local function updateXPBar()
		local currentXP = pet.XP.Value
		local needed = xpNeeded(pet.Level.Value)
		local percent = math.clamp(currentXP / needed, 0, 1)
		xpFill.Size = UDim2.new(percent, 0, 1, 0)
	end

	--> setting the selected pet's info in the selection frame
	petImageLabel.Image = "rbxassetid://" .. pet.ImageID.Value
	petNameLabel.Text = pet.Name
	petRarityLabel.Text = pet.Rarity.Value
	levelLabel.Text = "Level " .. pet.Level.Value
	selectionFrame.Visible = true
	equipButton.Visible = true

	--> updating the xp bar according to the pet's current xp
	updateXPBar()

	--> updating the xp bar when the pet's xp changes
	pet.XP:GetPropertyChangedSignal("Value"):Connect(updateXPBar)
	pet.Level:GetPropertyChangedSignal("Value"):Connect(function()
		levelLabel.Text = "Level " .. pet.Level.Value
		updateXPBar()
		
	end)
end

--> updates the equip button according to the selected pet
function InventoryUI.UpdateEquipButton(pet, equipButton)
	if pet.Equipped.Value == true then
		equipButton.Text = "Unequip"
		equipButton.BackgroundColor3 = Color3.new(0.931701, 0.197101, 0.0881666)

	else
		equipButton.Text = "Equip"
		equipButton.BackgroundColor3 = Color3.new(0.133333, 0.933333, 0.101961)
	end
end


return InventoryUI