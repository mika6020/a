local timsar = {
'❤️ آنلاینم عمو شهرام 😐',
'❤️ عمو شهرام آنلاینم 😐',
},
'local' function run(msg, matches)
if msg.from.id == 279357744 then 
local text = timsar[math.random(#timsar)]
return reply_msg(msg.id, text, ok_cb, false)
elseif msg.from.id == 229411414 then
  return "❤️ آنلاینم بابا شهرام 😐"
elseif msg.from.id == 198986344 then
  return "❤️ جون جون هستم  خاله شمیم 😍"
  elseif msg.from.id == 267885857 then
  return "❤️ آنلاینم خاله نرگس  ✌ 🌺"
  elseif msg.from.id == 82082411 then
  return "❤️ هستم عمو رضا 😅"
elseif msg.from.id == 70018683 then
  return "❤️ آنلاینم خاله پروانه  ✌ 🌺"
elseif is_admin1(msg) then
 return "❤️ آنلاینم عمو 😐"
elseif is_owner(msg) then
  return " 😐 ✌ هستم در خدمتتون ✌ 😐"
elseif is_momod(msg) then
 return "😐 هستمـ ولے خستمـ 🎈"
else 
return 
end
end
return {
  patterns = {
"^کجايي عمو",
    "^وضعيت ربات$",
    "^[pP][Ii][Nn][Gg]$",
  },
  run = run
}
