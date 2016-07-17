-- gibt die laenge der tabelle zurueck
function LmMinion.Util.tableLength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

-- ala in array
function LmMinion.Util.tableHasValue (tab, val)
    for index, value in ipairs (tab) do
        if value == val then
            return true
        end
    end

    return false
end