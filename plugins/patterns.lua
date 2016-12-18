do
-- Returns true if is not empty
local function has_usage_data(dict)
  if (dict.patterns == nil or dict.patterns == '') then
    return false
  end
  return true
end

-- Get commands for that plugin
local function plugin_help(name)
  local plugin = plugins[name]
  if not plugin then return nil end

  local text = ""
  if (type(plugin.patterns) == "table") then
    for ku,patterns in pairs(plugin.patterns) do
      text = text..patterns..'\n'
    end
    text = text..'\n'
  elseif has_usage_data(plugin) then -- Is not empty
    text = text..plugin.patterns..'\n\n'
  end
  return text
end

-- !help command
local function telegram_help()
  local text = "🔱 لیست پلاگین ها 🔱 \n\n"
  -- Plugins names
  for name in pairs(plugins) do
    text = text..name..'\n'
  end
  text = text..'\n'..'🔱 دستورات پلاگینی که میخواهید ببینید را طبق زیر عمل کنید 🔱'
  text = text..'\n'..'���� : ������� muteall'
  return text
end
-- @sudo_tm
-- !help all command
local function help_all()
  local ret = ""
  for name in pairs(plugins) do
    ret = ret .. plugin_help(name)
  end
  return ret
end

local function run(msg, matches)
  if matches[1] == "�������" then
    return telegram_help()
  elseif matches[1] == "لیست پلاگین" then
    return help_all()
  else 
    local text = plugin_help(matches[1])
    if not text then
      text = telegram_help()
    end
    return text
  end
end

return {
  patterns = {
    "^�������$",
    "^لیست پلاگین",
    "^������� (.+)"
  }, 
  run = run 
}

end

