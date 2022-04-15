require("combustor")

CombustionController = {combustor_list = {}, entity_sensor = nil}

function CombustionController:new(o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    self.combustor_list = {}
    self.entity_sensor = nil
    return o
end

local function calculate_chamber_is_empty(combustor_list, entity_sensor)
    print("Sensing entities")
    local entities = entity_sensor.sense()
    coroutine.yield()
    for _, combustor in ipairs(combustor_list) do
        combustor.get_chamber()
        combustor.chamber_is_empty = true
    end
    for _, entity in ipairs(entities) do
        if string.match(entity.displayName, "^item%..+") then
            print("Item " , entity.displayName , " found at " , entity.x, "," , entity.z , "," , entity.y)
            for _, combustor in ipairs(combustor_list) do
                if combustor.chamber_is_empty then
                    local chamber = combustor.get_chamber()
                    if math.floor(entity.x) == chamber.x and
                        math.floor(entity.z) == chamber.z and
                        math.floor(entity.y) == chamber.y then
                            combustor.chamber_is_empty = false
                    end
                end
            end
        end
    end
end

local function find_entity_sensor()
    local entity_sensor = peripheral.find("manipulator", function(name, manip)
        return manip.hasModule("plethora:sensor")
    end)
    if entity_sensor ~= nil and #entity_sensor > 1 then
        entity_sensor = entity_sensor[1]
    end
    return entity_sensor
end

function CombustionController:add_combustor(x, z, y, input_inv, block_inv_direction, dropper, redstone_integrator, redstone_direction)
    local c = Combustor:new(nil, x, z, y, input_inv, block_inv_direction, dropper, redstone_integrator, redstone_direction)
    table.insert(self.combustor_list, c)
    print("Added combustor at ", x, ",", z, ",", y)
end

function CombustionController:setup()
    self.entity_sensor = find_entity_sensor()
end

local threads = {}

local function dispatcher()
    while true do
        local n = table.getn(threads)
        if n == 0 then break end -- no more threads to run
        for i = 1, n do
            print("[" , os.epoch() , "]" , "Work thread number ", i)
            local status, res, output = coroutine.resume(threads[i])
            if output then
                print(output)
            end
            if not res then -- thread finished its task?
                table.remove(threads, i)
                break
            end
        end
        sleep(0)
    end
end

function CombustionController:run()
    if self.entity_sensor == nil then
        self:setup()
    end
    --coroutine for entity sensor, that updates chamber_is_empty
    local co = coroutine.create(
        function()
            while true do
                print("Check chambers")
                calculate_chamber_is_empty(self.combustor_list, self.entity_sensor)
                coroutine.yield()
            end
        end)
    table.insert(threads, co)
    --coroutines for the combustion chambers
    for index, combustor in ipairs(self.combustor_list) do
        co = coroutine.create(
            function()
                --combustor worker
                while true do
                    print("wait_for_input")
                    combustor.wait_for_input()
                    coroutine.yield("worker - wait for input")
                    print("block_input")
                    combustor.block_input()
                    coroutine.yield("worker - block input")
                    print("drop_items")
                    combustor.drop_items()
                    coroutine.yield("worker - drop items")
                    print("combust?")
                    while not combustor.chamber_is_empty do
                        print("combust!")
                        combustor.combust()
                        coroutine.yield("worker - combust")
                    end
                    --TODO from collector to output??
                    print("free_input")
                    combustor.free_input()
                    coroutine.yield("worker - free input")
                end
                --end combustor worker
            end
        )
        table.insert(threads, co)
    end
    --run the thread dispatcher
    dispatcher()
end

return CombustionController