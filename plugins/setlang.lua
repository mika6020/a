do
local function run(msg, matches, callback, extra)
local hash = 'group:'..msg.to.id
local group_lang = redis:hget(hash,'lang')
if matches[1] == 'setlang' and  matches[2] == 'en' or matches[1] =='تنظیم زبان' and matches[2] =='انگلیسی' and is_owner(msg) then 
    
   redis:hdel(hash,'lang')
        return 'group lang set to : en'
end



if matches[1] == 'setlang' and matches[2] == 'fa' or matches[1] =='تنظیم زبان' and matches[2] =='فارسی' and is_owner(msg) then
redis:hset(hash,'lang',matches[2])
        return 'زبان گروه تنظیم شد به : فارسی'
end
if matches[1] == 'lang' or matches[1] =='زبان گروه' then
if group_lang then 
return "زبان گروه شما هم اکنون بر روی فارسی قرار دارد"
else
return "Group lang : en"
end
end
end
return {
  patterns = {
    "^([Ss][Ee][Tt][Ll][Aa][Nn][Gg]) ([Ff][Aa])$",
  "^([Ss][Ee][Tt][Ll][Aa][Nn][Gg]) ([Ee][Nn])$",
   "^(تنظیم زبان) (فارسی)$",
  "^(تنظیم زبان) (انگلیسی)$",
  "^(زبان گروه)",
  "^([Ll][Aa][Nn][Gg])"
  },
  run = run
}
end
