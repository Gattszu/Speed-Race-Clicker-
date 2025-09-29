local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local petModule = require(ReplicatedStorage.ModuleScripts.petModule)
local inventoryUI = require(ReplicatedStorage.ModuleScripts.InventoryUI)
local updateEquipped = ReplicatedStorage.Remotes.UpdateEquipped
local updateIsHatching = ReplicatedStorage.Remotes.UpdateIsHatching
local equipPet = ReplicatedStorage.Remotes.EquipPet
local unequipPet = ReplicatedStorage.Remotes.UnequipPet
local deletePet = ReplicatedStorage.Remotes.DeletePet
local removePetButton = game.ReplicatedStorage.Remotes.RemovePetButton

local playerPets = workspace:WaitForChild("PlayerPets")

--> listen for player's pet equip request and equip the pet if they have enough space
equipPet.OnServerEvent:Connect(function(player, selectedPet)
	petModule.EquipPet(player, selectedPet)
end)

--> listen for player's pet unequip request and unequip the pet
unequipPet.OnServerEvent:Connect(function(player, selectedPet)
	petModule.UnequipPet(player, selectedPet)
end)

--> listen for player's pet delete request and delete the pet
deletePet.OnServerEvent:Connect(function(player, petData)
	removePetButton:FireClient(player, petData)
	petModule.DeletePetFromWorkspace(player, petData)
	task.wait(3)
	petData:Destroy()
	petModule.PositionPets(player)
end)

--> listen for player's pet equip status update request and update the pet's equip status
updateEquipped.OnServerEvent:Connect(function(player, pet)
	pet.Equipped.Value = not pet.Equipped.Value
end)

--> listen for when the player is no longer hatching an egg and reset the isHatching state so they can hatch another
updateIsHatching.OnServerEvent:Connect(function(player)
	player.isHatching.Value = false
end)


