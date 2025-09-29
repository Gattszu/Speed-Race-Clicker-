local MPS = game:GetService("MarketplaceService")
local player = game.Players.LocalPlayer
local frame = script.Parent

--[[
- Each button inside frame is linked to a specific developer product.
- That product’s ID is stored inside an IntValue child of the button called ProductID.
- When a player clicks the button, it tells Roblox to open the purchase window for that specific product.
]]

for i, child in ipairs(frame:GetChildren()) do
	if child:IsA("TextButton") then
		local productID = child.ProductID.Value
		child.MouseButton1Click:Connect(function()
			print(child.Name)
			MPS:PromptProductPurchase(player, productID)
		end)
	end
end

