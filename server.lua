local function dayOfWeek(y, m, d)
  local t = {0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4}
  if m < 3 then
    y = y - 1
  end
  return (y + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400) + t[m] + d) % 7
end

local function lastSunday(year, month)
  for d = 31, 24, -1 do
    if dayOfWeek(year, month, d) == 0 then
      return d
    end
  end
  return 31
end

local function isDstEuropeBerlin(utc)
  local year = utc.year
  local month = utc.month
  local day = utc.day
  local hour = utc.hour

  if month < 3 or month > 10 then
    return false
  end
  if month > 3 and month < 10 then
    return true
  end

  local lastSunMarch = lastSunday(year, 3)
  local lastSunOct = lastSunday(year, 10)

  if month == 3 then
    if day > lastSunMarch then return true end
    if day < lastSunMarch then return false end
    return hour >= 1
  end

  if month == 10 then
    if day > lastSunOct then return false end
    if day < lastSunOct then return true end
    return hour < 1
  end

  return false
end

local timePresets = {
  { hour = 8, minute = 0, second = 0 },
  { hour = 12, minute = 0, second = 0 },
  { hour = 18, minute = 0, second = 0 },
  { hour = 23, minute = 0, second = 0 }
}
local timeIndex = 0
local manualTime = nil

local function broadcastTime(hour, minute, second)
  TriggerClientEvent("fl_time:setTime", -1, hour, minute, second)
end

RegisterNetEvent("fl_time:cycleTime", function()
  timeIndex = timeIndex + 1
  if timeIndex > #timePresets then
    timeIndex = 0
    manualTime = nil
    return
  end

  manualTime = timePresets[timeIndex]
  if manualTime then
    broadcastTime(manualTime.hour, manualTime.minute, manualTime.second)
  end
end)

CreateThread(function()
  while true do
    if manualTime then
      broadcastTime(manualTime.hour, manualTime.minute, manualTime.second)
    else
      local utc = os.date("!*t")
      local offset = isDstEuropeBerlin(utc) and 2 or 1
      local hour = (utc.hour + offset) % 24
      local minute = utc.min
      local second = utc.sec
      broadcastTime(hour, minute, second)
    end
    Wait(5000)
  end
end)
