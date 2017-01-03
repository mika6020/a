local function run (msg, matches)
local data = load_data(_config.moderation.data)
   if matches[1] == 'chat_add_user_link' then
   if matches[1] == 'chat_add_user' then
        local user_id = msg.from.id
        if data[tostring(msg.to.id)] then
        if data[tostring(msg.to.id)]['settings'] then
        if data[tostring(msg.to.id)]['settings']['lock_tgservice'] == 'yes' then
      del_msg (user_id, msg.to.id)
    end
   end
end   
 end
 end
return {
  patterns = {
    "^!!tgservice (chat_add_user_link)$",
    "^!!tgservice (chat_add_user)$",
  },
  run = run
}
