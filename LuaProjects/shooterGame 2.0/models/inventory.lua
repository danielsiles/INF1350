local weaponItem = require("models.item")
local json = require('libs.json')
local drawUtils = require('utils.drawUtils')

function createInventory()
	local inventoryWidth = 200
	local inventoryHeight = 50
	local slotHeight = 50
	local slotWidth = 50

	local selectedSlot = 3
	local slots = {}
	local medicKit = 0
	local bandage = 0
	local bullet1 = 0
	local bullet2 = 0
	local bullet3 = 0
	local bullets = {}
	local shield = 0
	local helmet = 0

	local function pickWeaponItem(item)
		local playerItem = slots[selectedSlot]
		if playerItem == nil then
			slots[selectedSlot] = item
		else 
			-- table.insert(gameItems, weaponItem.createWeaponItem(player.getX(),player.getY(), playerItem.getWeaponId()))
			local itemData = {
				x = player.getX(),
				y = player.getY(),
				weaponId = playerItem.getWeaponId()
			}
			mqtt_client:publish("1311291returnItem", json.encode(itemData))
			slots[selectedSlot] = item
		end

		return true
	end

	local function pickBulletItem(item)	
		print(bullets[item.getItemId()])
		if bullets[item.getItemId()] == nil then
			bullets[item.getItemId()] = item.getAmount()
		else 
			bullets[item.getItemId()] = bullets[item.getItemId()] + item.getAmount()
		end
		print(bullets[item.getItemId()])
		return true
	end
	
	local function getWeapon()
		if slots[selectedSlot] ~= nil then
	 		return weapons[slots[selectedSlot].getWeaponId()]
		end
		return nil
	end

	local function reloadWeapon()
		local playerItem = slots[selectedSlot]
		if playerItem == nil then
			return false
		end

		local weapon  = getWeapon()
		if weapon ~= nil then
			local bullet = bullets[weapon.getAmmoType()]
			if bullet == nil then
				return false
			else				if weapon.getMagCapacity() - weapon.getBulletsInMag() > bullet then
					weapon.setBulletsInMag(bullet + weapon.getBulletsInMag())
					bullets[weapon.getAmmoType()] = 0
				else
					bullets[weapon.getAmmoType()] = bullets[weapon.getAmmoType()] - (weapon.getMagCapacity() - weapon.getBulletsInMag())
					weapon.setBulletsInMag(weapon.getMagCapacity())
				end
				print(bullet)
				return true 

			end
		end
	end

	

	return {	
		reloadWeapon = function() return reloadWeapon() end,
		pickWeaponItem = function(item) return pickWeaponItem(item) end,
		pickBulletItem = function(item) return pickBulletItem(item) end,
		getWeapon = function() return getWeapon() end,
		draw = function () 
			local windowHeight = love.graphics.getHeight()
			local windowWidth = love.graphics.getWidth()
			love.graphics.setColor(255,255,255,0.5)
			love.graphics.rectangle("fill", (windowWidth / 2) - (inventoryWidth / 2), windowHeight - inventoryHeight, inventoryWidth, inventoryHeight)
			love.graphics.setColor(255,255,255,0.8)
			love.graphics.setLineWidth(2)
			love.graphics.rectangle("line", (windowWidth / 2) - (inventoryWidth / 2), windowHeight - inventoryHeight, inventoryWidth, inventoryHeight)
			love.graphics.setColor(255,255,255,1)
			for i = 1, 3 do
				love.graphics.setLineWidth(2)
				love.graphics.line((windowWidth / 2) - (inventoryWidth / 2) + 50 * i, windowHeight - inventoryHeight, (windowWidth / 2) - (inventoryWidth / 2) + 50 * i, windowHeight)
			end
			

			love.graphics.rectangle("fill", (windowWidth / 2) - (inventoryWidth / 2) + (selectedSlot - 1) * slotWidth, windowHeight - inventoryHeight, slotWidth, slotHeight)
			love.graphics.setColor(255,255,255,0.3)

			for i = 1, 4 do
				if slots[i] ~= nil then
					love.graphics.setColor(255,0,0)
					love.graphics.draw(slots[i].getItemWeapon().getIcon(), (windowWidth / 2) - (inventoryWidth / 2) + 50 * (i - 1),windowHeight - inventoryHeight, 0, drawUtils.getImageScaleForNewDimensions(slots[i].getItemWeapon().getIcon(), 50, 50))
					-- love.graphics.print(slots[i].getWeaponId(), (windowWidth / 2) - (inventoryWidth / 2) + 50 * (i - 1),windowHeight - inventoryHeight/2, 0, 2, 2, 0,0,0,0)
				end
			end
			local weapon = getWeapon()
			if weapon ~= nil then
				love.graphics.setColor(48/255,48/255,48/255)
				love.graphics.print(getWeapon().getBulletsInMag() .. "/" .. getWeapon().getMagCapacity(), (windowWidth / 2) - (inventoryWidth / 2) + 250,windowHeight - inventoryHeight/2, 0, 2, 2, 0,0,0,0)
			end
			for i = 1, 3 do
				local bulCount = 0
				if bullets[i] ~= nil then
					bulCount = bullets[i]
				end
				love.graphics.setColor(48/255,48/255,48/255)
				love.graphics.print("B"..i..":"..bulCount, (windowWidth / 2) - (inventoryWidth / 2) + 250 + i * 100,windowHeight - inventoryHeight/2, 0, 2, 2, 0,0,0,0)
			end
		end,
		update = function (dt)
			if love.keyboard.isDown("1") then selectedSlot = 1 
			elseif love.keyboard.isDown("2") then selectedSlot = 2 
			elseif love.keyboard.isDown("3") then selectedSlot = 3 
			elseif love.keyboard.isDown("4") then selectedSlot = 4	end
		end
	}
end

local M = {}
M.createInventory = createInventory
return M