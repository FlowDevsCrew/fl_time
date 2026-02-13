local currentTime = nil

RegisterNetEvent("fl_time:setTime", function(hour, minute, second)
  currentTime = {
    hour = tonumber(hour) or 0,
    minute = tonumber(minute) or 0,
    second = tonumber(second) or 0
  }
end)

CreateThread(function()
  while true do
    if currentTime then
      NetworkOverrideClockTime(currentTime.hour, currentTime.minute, currentTime.second)
    end
    Wait(1000)
  end
end)
