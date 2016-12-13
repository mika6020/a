do
local function pre_process(msg)
 local hash = 'muteall:'..msg.to.id
  if redis:get(hash) and msg.to.type == 'channel' and not is_momod(msg)  then
   delete_msg(msg.id, ok_cb, false)
       end
    return msg
 end
 
local function run(msg, matches)
 if matches[1] == 'قفل گروه' and is_momod(msg) then
       local hash = 'muteall:'..msg.to.id
       if not matches[2] then
              redis:set(hash, true)
             return "🔐 قفل کردن گروه 🔐"
 else
-- by @Cyrus0098 
local hour = string.gsub(matches[2], 'h', '')
 local num1 = tonumber(hour) * 3600
local minutes = string.gsub(matches[3], 'm', '')
 local num2 = tonumber(minutes) * 60
local second = string.gsub(matches[4], 's', '')
 local num3 = tonumber(second) 
local num4 = tonumber(num1 + num2 + num3)
redis:setex(hash, num4, true)
 return "🔐گروه قفل شد برای\nساعت⏰ : "..matches[2].."\nدقیقه🕰  : "..matches[3].." \nثانیه⏲   : "..matches[4].."\n⚠️لطفا از چت کردن و ارسال مطالب خودداری فرمایید ⚠️"
 end
 end
if matches[1] == 'بازکردن گروه' and is_momod(msg) then
               local hash = 'muteall:'..msg.to.id
        redis:del(hash)
          return "🔓قفل گروه  باز شد .🔓"
  end
end
return {
   patterns = {
   '^(قفل گروه)$',
   '^(بازکردن گروه)$',
   '^(قفل گروه) (.*) (.*) (.*)$',
 },
run = run,
  pre_process = pre_process
}
end
-- our channel : @Cyrus0098
