local drawUtils = require('utils.drawUtils')

gameItemId = 1

function createWeaponItem(xPos, yPos, weaponId)
	local id = gameItemId
	local itemType = "weapon"
	local weaponId = weaponId
	local xPos = xPos
	local yPos = yPos
	local itemRadius = 35
	gameItemId = gameItemId + 1
	local itemWeapon = nil
	for index, weapon in ipairs(weapons) do
		if index == weaponId then
			itemWeapon = weapon
		end
	end

	return {
		getId = function() return id end,
		getItemType = function() return itemType end,
		getX = function() return xPos end,
		getY = function() return yPos end,
		getRadius = function() return itemRadius end,
		getWeaponId = function() return weaponId end,
		getItemWeapon = function() return itemWeapon end,
		draw = function () 
			love.graphics.setColor(255, 148, 77,0.5)
			love.graphics.circle("fill", xPos, yPos, itemRadius )
			love.graphics.setColor(255, 148, 77,1)
			love.graphics.circle("line", xPos, yPos, itemRadius )
			love.graphics.setColor(255,0,0)
			love.graphics.draw(itemWeapon.getIcon(), xPos - itemRadius + 10, yPos - itemRadius + 10, 0, drawUtils.getImageScaleForNewDimensions(itemWeapon.getIcon(), 50,50))
		end,
		update = function (dt)

		end
	}
end

local bulletType1Icon = love.graphics.newImage("img/pumpBulletIcon.png")
local bulletType2Icon = love.graphics.newImage("img/ak47BulletIcon.png")
local bulletType3Icon = love.graphics.newImage("img/sniperBulletIcon.png")

function createBulletItem(xPos, yPos, itemId, amount)
	local id = gameItemId
	local itemType = "bullet"
	local itemId = itemId
	local xPos = xPos
	local yPos = yPos
	local amount = amount
	local itemRadius = 25
	local itemIcon = nil

	if itemId == 1 then
		itemIcon = bulletType1Icon
	elseif itemId == 2 then
		itemIcon = bulletType2Icon
	else
		itemIcon = bulletType3Icon
	end

	gameItemId = gameItemId + 1
	return {
		getId = function() return id end,
		getItemType = function() return itemType end,
		getAmount = function() return amount end,
		getX = function() return xPos end,
		getY = function() return yPos end,
		getRadius = function() return itemRadius end,
		getItemId = function() return itemId end,
		draw = function () 
			love.graphics.setColor(255, 148, 77,0.5)
			love.graphics.circle("fill", xPos, yPos, itemRadius )
			love.graphics.setColor(255, 148, 77,1)
			love.graphics.circle("line", xPos, yPos, itemRadius )
			love.graphics.setColor(255,0,0)
			love.graphics.draw(itemIcon, xPos - itemRadius + 10, yPos - itemRadius + 10, 0, drawUtils.getImageScaleForNewDimensions(itemIcon, 30,30))
		end,
		update = function (dt)

		end
	}
end

function loadItems()
	table.insert(gameItems, createWeaponItem(50,50,1))
	table.insert(gameItems, createWeaponItem(150,50,2))
	table.insert(gameItems, createWeaponItem(250,50,3))
	table.insert(gameItems, createWeaponItem(50,150,4))
	table.insert(gameItems, createWeaponItem(150,150,1))
	table.insert(gameItems, createWeaponItem(250,150,2))
	table.insert(gameItems, createWeaponItem(50,250,2))
	table.insert(gameItems, createWeaponItem(150,250,3))
	table.insert(gameItems, createWeaponItem(250,250,3))
	
	table.insert(gameItems, createBulletItem(50,350,1, 10))
	table.insert(gameItems, createBulletItem(50,450,2, 60))
	table.insert(gameItems, createBulletItem(50,550,2, 20))
	table.insert(gameItems, createBulletItem(150,350,1, 10))
	table.insert(gameItems, createBulletItem(150,450,2, 60))
	table.insert(gameItems, createBulletItem(150,550,1, 20))
	table.insert(gameItems, createBulletItem(250,350,1, 10))
	table.insert(gameItems, createBulletItem(250,450,2, 60))
	table.insert(gameItems, createBulletItem(250,550,3, 20))
end

local M = {}
M.createWeaponItem = createWeaponItem
M.createBulletItem = createBulletItem
M.loadItems = loadItems
return M