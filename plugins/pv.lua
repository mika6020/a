do
    
function run(msg, matches)
  local help = [[🌟سلام🌟
🌹دوست گلم من یک ربات انتی اسپمم با قابلیت های زیر 🔰

لینک پاک کن 📌
تعطیل کردن گروه 🔐
و کلی امکان دیگر 😝


]]
    if not is_sudo(msg) and msg.to.type == 'user' then
       send_large_msg("user#id"..msg.from.id, help)      
  return 
    end
end 

return {
  patterns = {
    "(.*)"
  },
  run = run
}
end
