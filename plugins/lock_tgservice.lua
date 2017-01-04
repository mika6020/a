local function run(msg, matches)
    if is_momod(msg) then
        return
    end
    local data = load_data(_config.moderation.data)
    if data[tostring(target)] then
        if data[tostring(target)]['settings'] then
            if data[tostring(target)]['settings']['lock_tgservice'] then
                lock_link = data[tostring(target)]['settings']['lock_tgservice']
            end
        end
    end
    local chat = get_receiver(msg)
    local user = "user#id"..msg.from.id
    if lock_tgservice == "yes" then
       delete_msg(msg, data, target)
    end
end
 
return {
  patterns = {
"^!!tgservice (.+)$",
  },
  run = run
}
