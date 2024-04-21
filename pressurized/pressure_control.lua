local c_side = "top"
local compressor = peripheral.wrap(c_side)
local maxPressure = 4.9
local checkDelay = 1 --seconds

while(true) do
    if compressor.getPressure() >= maxPressure then
        rs.setOutput(c_side, false)
    else
        rs.setOutput(c_side, true)
    end
    sleep(checkDelay)
end
