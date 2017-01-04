do
    
function run(msg, matches)
  local help = [[
        درود
من یک ربات لینک پاک کنم . 
        ربات محافظ گروه با امکانات 
        قفل گروه و ....
     

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
