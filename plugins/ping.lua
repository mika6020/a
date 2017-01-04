local timsar = {
'❤️ آنلاینم  😐',
'❤️ آنلاینم 😐',
},
'local' function run(msg, matches)
if msg.from.id == 279357744 then 
local text = timsar[math.random(#timsar)]
return reply_msg(msg.id, text, ok_cb, false)
elseif msg.from.id == 229411414 then
  return "❤️ آنلاینم 😐"
elseif msg.from.id == 198986344 then
  return "❤️ آنلاینم 😍"
  elseif msg.from.id == 267885857 then
  return "❤️ آنلاینم  ✌ 🌺"
  elseif msg.from.id == 82082411 then
  return "❤️ آنلاینم 😅"
elseif msg.from.id == 70018683 then
  return "❤️ آنلاینم  ✌ 🌺"
elseif is_admin1(msg) then
 return "❤️ آنلاینم 😐"
elseif is_owner(msg) then
  return " 😐 آنلاینم 😐"
elseif is_momod(msg) then
 return "😐 آنلاینم 🎈"
else 
return 
end
end
return {
  patterns = {
"^کجایی عمو",
    "^پینگ",
    "^وضعیت ربات$",
    "^[pP][Ii][Nn][Gg]$",
  },
  run = run
}
