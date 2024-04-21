require("combustion.combustor")

CombustionController = {combustor_list = {}, state_list = {}, entity_sensor = nil, output_window = nil}

function CombustionController:new(o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    o.combustor_list = {}
    o.state_list = {}
    o.entity_sensor = nil
    o.output_window = nil
    return o
end

local function calculate_chamber_is_empty(combustor_list, entity_sensor)
    --print("Sensing entities")
    local entities = entity_sensor.sense()
    coroutine.yield()
    for _, combustor in ipairs(combustor_list) do
        combustor:get_chamber()
        combustor.chamber_is_empty = true
    end
    for _, entity in ipairs(entities) do
        if string.match(entity.displayName, "^item%..+") then
            --print("Item " , entity.displayName , " found at " , entity.x, "," , entity.z , "," , entity.y)
            for _, combustor in ipairs(combustor_list) do
                if combustor.chamber_is_empty then
                    local chamber = combustor:get_chamber()
                    if math.floor(entity.x) == chamber.x and
                        math.floor(entity.z) == chamber.z and
                        math.floor(entity.y) == chamber.y then
                            --print("item is in chamber")
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

function CombustionController:add_combustor(x, z, y, input_inv, block_inv_direction, dropper, redstone_integrator, redstone_direction, collector, output_inv)
    local c = Combustor:new({}, x, z, y, input_inv, block_inv_direction, dropper, redstone_integrator, redstone_direction, collector, output_inv)
    table.insert(self.combustor_list, c)
    print("Added combustor at ", x, ",", z, ",", y, " inv:" , peripheral.getName(c:get_input_inv()) , " XX")
    table.insert(self.state_list, "added")
end

function CombustionController:setup()
    self.entity_sensor = find_entity_sensor()
    self.output_window = window.create(term.current(),1,1,50,19)
end

local threads = {}
local thread_functions = {}

local function dispatcher()
    repeat
      local n = table.getn(threads)
      local events = table.pack(os.pullEvent())
      for i = 1, n do
        --print("[" , os.epoch() , "]" , "Work thread number ", i)
        local success, output = coroutine.resume(threads[i], table.unpack(events, 1, events.n))
        --print("co.status:" , coroutine.status(threads[i]) , "success:" , success, " output:" , output)
        if coroutine.status(threads[i]) == "dead" or not success then -- thread finished its task?
            print("remove thread " , i)
            table.remove(threads, i)
            break
        end
      end
    until n == 0
end

function CombustionController:run()
    if self.entity_sensor == nil then
        self:setup()
    end
    os.startTimer(2)
    --sleep(5)

    --endless timer coroutine
    local co = coroutine.create(
        function()
            local w = self.output_window
            while true do
                w.clear()
                w.setCursorPos(1,1)
                w.write("Combustion Controller")
                w.setCursorPos(1,2)
                w.write("----------------------------------")
                for index, combustor in ipairs(self.combustor_list) do
                    w.setCursorPos(1,index+2)
                    w.write("C" .. index .. ": " .. self.state_list[index])
                end
                sleep(0)
            end
        end)
    table.insert(threads, co)
    --coroutine for entity sensor, that updates chamber_is_empty
    table.insert(thread_functions, function()
        while true do
            --print("Check chambers")
            calculate_chamber_is_empty(self.combustor_list, self.entity_sensor)
            coroutine.yield("sense - calculate_chamber_is_empty")
        end
    end)
    co = coroutine.create(thread_functions[#thread_functions])
    table.insert(threads, co)
    --coroutines for the combustion chambers
    for index, combustor in ipairs(self.combustor_list) do
        table.insert(thread_functions, function()
            --combustor worker
            while true do
                --print("wait_for_input")
                self.state_list[index] = "waiting for input"
                combustor:wait_for_input()
                coroutine.yield("worker - wait for input")
                --print("block_input")
                self.state_list[index] = "blocking input"
                combustor:block_input()
                coroutine.yield("worker - block input")
                while combustor:input_count() > 1 do
                    self.state_list[index] = "dropping items"
                    --print("drop_items")
                    local dropped = combustor:drop_items()
                    self.state_list[index] = ""
                    coroutine.yield("worker - drop items")
                    if dropped > 0 then
                        self.state_list[index] = "waiting for items in chamber"
                        while combustor.chamber_is_empty do
                            sleep(0.05)
                            coroutine.yield("worker - wait for items in chamber")
                        end
                    end
                end
                while not combustor.chamber_is_empty do
                    --print("combust!")
                    self.state_list[index] = "combusting"
                    --gracefully recover by freeing the collector before combusting
                    while not combustor:collector_is_empty() do
                        combustor:move_output()
                    end
                    combustor:combust()
                    coroutine.yield("worker - combust")
                    combustor:move_output()
                    coroutine.yield("worker - move output")
                end
                
                --print("free_input")
                self.state_list[index] = "removing blocker"
                combustor:free_input()
                coroutine.yield("worker - free input")
            end
            --end combustor worker
        end)
        co = coroutine.create(thread_functions[#thread_functions])
        table.insert(threads, co)
    end
    --run the thread dispatcher
    dispatcher()
    --parallel.waitForAll(table.unpack(thread_functions))
end

return CombustionController