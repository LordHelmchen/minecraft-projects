--setup directions and rename to startup

local altar = peripheral.wrap("back")
local input = "north"
local output = "south"

local item = nil

function tryPull()
	local item = nil
	if altar.pullItems(input, 1, 1) == 1 then
		item = altar.getItemMeta(1)
		if item then
			item = item.displayName
			print("Transforming " .. item)
		end
	end
	return item
end

function push()
	return altar.pushItems(output, 1, 1)
end

while true do
	-- when no item and full tank, check input mini chest
	local t = altar.getTanks()[1]
	
	if item == nil and #altar.list() == 0 then
		if t.amount == t.capacity then
			item = tryPull()
		else
			print(t.amount .. "/" .. t.capacity .. " LP")
		end
	end
	if item then
		local currentItem = altar.getItemMeta(1)
		if currentItem then
			currentItem = currentItem.displayName
		end
		if item ~= currentItem  then
			print("Crafted " .. currentItem)
			push()
			item = nil
		end
	end
	sleep(1)
end