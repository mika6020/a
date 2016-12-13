local function check_member_super(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if success == 0 then
	send_large_msg(receiver, "Promote me to admin first!")
  end
  for k,v in pairs(result) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- SuperGroup configuration
      data[tostring(msg.to.id)] = {
        group_type = 'SuperGroup',
		long_id = msg.to.peer_id,
		moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.title, '_', ' '),
		  lock_arabic = 'no',
		  lock_link = "no",
                  flood = 'yes',
		  lock_spam = 'yes',
		  lock_sticker = 'no',
		  member = 'no',
		  public = 'no',
		  lock_rtl = 'no',
		  lock_tgservice = 'yes',
		  lock_contacts = 'no',
		  strict = 'no'
        }
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
	  local text = '🤖 با موفقیت نصب شد . ✨ در گروه :'..msg.to.title
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Check Members #rem supergroup
local function check_member_superrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result) do
    local member_id = v.id
    if member_id ~= our_id then
	  -- Group configuration removal
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local text = '🤖 با موفقیت حذف شد . ✨ در گروه :'..msg.to.title
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Function to Add supergroup
local function superadd(msg)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_super,{receiver = receiver, data = data, msg = msg})
end

--Function to remove supergroup
local function superrem(msg)
	local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_superrem,{receiver = receiver, data = data, msg = msg})
end

--Get and output admins and bots in supergroup
local function callback(cb_extra, success, result)
local i = 1
local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
local member_type = cb_extra.member_type
local text = member_type.." for "..chat_name..":\n"
for k,v in pairsByKeys(result) do
if not v.first_name then
	name = " "
else
	vname = v.first_name:gsub("‮", "")
	name = vname:gsub("_", " ")
	end
		text = text.."\n"..i.." - "..name.."["..v.peer_id.."]"
		i = i + 1
	end
    send_large_msg(cb_extra.receiver, text)
end

--Get and output info about supergroup
local function callback_info(cb_extra, success, result)
local title ="🌐 اطلاعات سوپر گروه : 🏵"..result.title.."🏵\n\n"
local admin_num = "👮 تعداد مدیران : "..result.admins_count.."\n"
local user_num = "🗣 تعداد اعضای گروه : "..result.participants_count.."\n"
local kicked_num = "👞 تعداد کاربر اخراج شده : "..result.kicked_count.."\n"
local channel_id = "🏵 ایدی سوپرگروه : "..result.peer_id.."\n"
if result.username then
	channel_username = "Username: @"..result.username
else
	channel_username = ""
end
local text = title..admin_num..user_num..kicked_num..channel_id..channel_username
    send_large_msg(cb_extra.receiver, text)
end

--Get and output members of supergroup
local function callback_who(cb_extra, success, result)
local text = "📋 لیست اعضای گروه : "..cb_extra.receiver
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		username = " @"..v.username
	else
		username = ""
	end
	text = text.."\n"..i.." - "..name.." "..username.." [ "..v.peer_id.." ]\n"
	--text = text.."\n"..username Channel : - -
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/"..cb_extra.receiver..".txt", ok_cb, false)
	post_msg(cb_extra.receiver, text, ok_cb, false)
end

--Get and output list of kicked users for supergroup
local function callback_kicked(cb_extra, success, result)
--vardump(result)
local text = "📋 لیست افراد اخراج شده گروه : "..cb_extra.receiver.."\n\n"
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		name = name.." @"..v.username
	end
	text = text.."\n"..i.." - "..name.." [ "..v.peer_id.." ]\n"
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", ok_cb, false)
	--send_large_msg(cb_extra.receiver, text)
end

--expiretime
local function pre_process(msg)
	local timetoexpire = 'unknown'
	local expiretime = redis:hget ('expiretime', get_receiver(msg))
	local now = tonumber(os.time())
	if expiretime then    
		timetoexpire = math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1
		if tonumber("0") > tonumber(timetoexpire) and not is_sudo(msg) then
		if msg.text:match('/') then
			return send_large_msg(get_receiver(msg), 'تاريخ اتقضاي گروه به پايان رسيد.')
		else
			return
		end
	end
	if tonumber(timetoexpire) == 0 then
		if redis:hget('expires0',msg.to.id) then return msg end
		send_large_msg(get_receiver(msg), '0 روز تا پايان تاريخ انقضاي گروه باقي مانده است\nنسبت به تمديد اقدام کنيد.')
		redis:hset('expires0',msg.to.id,'5')
	end
	if tonumber(timetoexpire) == 1 then
		if redis:hget('expires1',msg.to.id) then return msg end
		send_large_msg(get_receiver(msg), '1 روز تا پايان تاريخ انقضاي گروه باقي مانده است\nنسبت به تمديد اقدام کنيد.')
		redis:hset('expires1',msg.to.id,'5')
	end
	if tonumber(timetoexpire) == 2 then
		if redis:hget('expires2',msg.to.id) then return msg end
		send_large_msg(get_receiver(msg), '2 روز تا پايان تاريخ انقضاي گروه باقي مانده است\nنسبت به تمديد اقدام کنيد.')
		redis:hset('expires2',msg.to.id,'5')
	end
	if tonumber(timetoexpire) == 3 then
		if redis:hget('expires3',msg.to.id) then return msg end
		send_large_msg(get_receiver(msg), '3 روز تا پايان تاريخ انقضاي گروه باقي مانده است\nنسبت به تمديد اقدام کنيد.')
		redis:hset('expires3',msg.to.id,'5')
	end
	if tonumber(timetoexpire) == 4 then
		if redis:hget('expires4',msg.to.id) then return msg end
		send_large_msg(get_receiver(msg), '4 روز تا پايان تاريخ انقضاي گروه باقي مانده است\nنسبت به تمديد اقدام کنيد.')
		redis:hset('expires4',msg.to.id,'5')
	end
	if tonumber(timetoexpire) == 5 then
		if redis:hget('expires5',msg.to.id) then return msg end
		send_large_msg(get_receiver(msg), '5 روز تا پايان تاريخ انقضاي گروه باقي مانده است\nنسبت به تمديد اقدام کنيد.')
		redis:hset('expires5',msg.to.id,'5')
	end
end
return msg
end
function run(msg, matches)
	if matches[1]:lower() == 'تمديد' then
		if not is_sudo(msg) then return end
		local time = os.time()
		local buytime = tonumber(os.time())
		local timeexpire = tonumber(buytime) + (tonumber(matches[2]) * 86400)
		redis:hset('expiretime',get_receiver(msg),timeexpire)
		return "تاريخ انقضاي گروه:\nبه "..matches[2].. " روز ديگر تنظيم شد."
	end
	if matches[1]:lower() == 'تاريخ انقضا' then
		local expiretime = redis:hget ('expiretime', get_receiver(msg))
		if not expiretime then return 'تاريخ ست نشده است' else
			local now = tonumber(os.time())
			return (math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1) .. " روز ديگر"
		end
	end

end

--Begin supergroup locks


local function lock_group_cmds(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_cmds_lock = data[tostring(target)]['settings']['cmds']
  if group_cmds_lock == 'yes' then
   local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
   return '🔐 دستورات قفل بود .🔒'
   else
    return '🔐cmds Posting is already locked🔒'
    end
    end
    data[tostring(target)]['settings']['cmds'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 دستورات قفل شد .🔒'
     else
    return '🔐cmds Posting Has Been Locked🔒'
  end
end

local function unlock_group_cmds(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_cmds_lock = data[tostring(target)]['settings']['cmds']
  if group_cmds_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 دستورات غیرفعال بود .🔓'
    else 
    return '🔐cmds Posting is already Unlocked🔓'
    end
    end
    data[tostring(target)]['settings']['cmds'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل دستورات غیرفعال شد .🔓'
     else 
     return '🔐cmds Posting Hasbeen unLocked🔓'
  end
end


local function lock_group_inline(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_inline_lock = data[tostring(target)]['settings']['inline']
  if group_inline_lock == 'yes' then
   local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
   return '🔐 تبلیغات قفل بود .🔒'
   else
    return '🔐Inline Posting is already locked🔒'
    end
    end
    data[tostring(target)]['settings']['inline'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 تبلیغات قفل شد .🔒'
     else
    return '🔐Inline Posting Has Been Locked🔒'
  end
end

local function unlock_group_inline(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_inline_lock = data[tostring(target)]['settings']['inline']
  if group_inline_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 تبلیغات غیرفعال بود .🔓'
    else 
    return '🔐Inline Posting is already Unlocked🔓'
    end
    end
    data[tostring(target)]['settings']['inline'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل تبلیغات غیرفعال شد .🔓'
     else 
     return '🔐Inline Posting Hasbeen unLocked🔓'
  end
end


local function lock_group_number(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_number_lock = data[tostring(target)]['settings']['number']
  if group_number_lock == 'yes' then
   local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
   return '🔐 ارسال شماره قفل بود .🔒'
   else
    return '🔐Number Posting is already locked🔒'
    end
    end
    data[tostring(target)]['settings']['number'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ارسال شماره قفل شد .🔒'
     else
    return '🔐Number Posting Has Been Locked🔒'
  end
end

local function unlock_group_number(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_number_lock = data[tostring(target)]['settings']['number']
  if group_number_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ارسال شماره غیرفعال بود .🔓'
    else 
    return '🔐Number Posting is already Unlocked🔓'
    end
    end
    data[tostring(target)]['settings']['number'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل ارسال شماره غیرفعال شد .🔓'
     else 
     return '🔐Number Posting Hasbeen unLocked🔓'
  end
end

local function lock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'yes' then
   local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
   return reply_msg(msg.id,'🔐 ضدلینک قفل بود .🔒', ok_cb, false)
   else
    return reply_msg(msg.id,'🔐Link Posting is already locked🔒', ok_cb, false)
    end
    end
    data[tostring(target)]['settings']['lock_link'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return reply_msg(msg.id,'🔐 ضدلینک قفل شد .🔒', ok_cb, false)
     else
    return reply_msg(msg.id,'🔐Link Posting Has Been Locked🔒', ok_cb, false)
  end
end

local function unlock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
   return reply_msg(msg.id,'🔐 ضدلینک غیرفعال بود .🔓', ok_cb, false)
    else 
   return reply_msg(msg.id,'🔐Link Posting is already Unlocked🔓', ok_cb, false)
    end
    end
    data[tostring(target)]['settings']['lock_link'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return reply_msg(msg.id,'🔐 قفل ضدلینک غیرفعال شد .🔓', ok_cb, false)
     else 
   return reply_msg(msg.id,'🔐Link Posting Hasbeen unLocked🔓', ok_cb, false)
  end
end

local function lock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_all_lock = data[tostring(target)]['settings']['all']
  if group_all_lock == 'yes' then
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
	return '🔐 همه تنظیمات قفل بود .🔒'
  else
  return '🔐All Settings Already Locked🔐'
  end
  end
    data[tostring(target)]['settings']['all'] = 'yes'
    save_data(_config.moderation.data, data)
     local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
	return '🔐 همه تنظیمات قفل شد .🔒'
  else
  retuen '🔐All Settings HasBeen Locked🔐'
  end
end

local function unlock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_all_lock = data[tostring(target)]['settings']['all']
  if group_all_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then   
   return '🔐 همه تنظیمات غیرفعال بود .🔓'
  else
  return '🔓All Setings Already Unlocked🔓'
  end
  end
    data[tostring(target)]['settings']['all'] = 'no'
    save_data(_config.moderation.data, data)
local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then     
  return '🔐 قفل همه تنظیمات غیرفعال شد .🔓'
  else
  return 'All Settings HasBeen Unlocked'
  end
end


local function lock_group_ax(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_ax_lock = data[tostring(target)]['settings']['lock_photo']
  if group_ax_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then 
    return '🔐 ارسال عکس ممنوع بود .🔒'
  else
  return '🔐Photo Post Already Locked🔐'
  end
  end
    data[tostring(target)]['settings']['lock_photo'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then 
	return '🔐 ارسال عکس ممنوع شد .🔒'
  else
  return '🔐Photo Post Has Been Locked🔐'
  end
end

local function unlock_group_ax(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_ax_lock = data[tostring(target)]['settings']['lock_photo']
  if group_ax_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then 
    return '🔐 ارسال عکس آزاد بود .🔓'
  else
  return '🔓Photo Post Not Locked🔓'
  end
  end
    data[tostring(target)]['settings']['lock_photo'] = 'no'
    save_data(_config.moderation.data, data)
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then    
   return '🔐 ارسال عکس آزاد شد .🔓'
  else 
  return '🔓Photo Post HasBeen UNlocked🔓'
  end
end

local function lock_group_video(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_video_lock = data[tostring(target)]['settings']['lock_video']
  if group_video_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then 
    return '🔐 ارسال فیلم ممنوع بود .🔒'
  else
  return '🔐Video Post Already Locked🔐'
  end
  end
    data[tostring(target)]['settings']['lock_video'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then 
	return '🔐 ارسال فیلم ممنوع شد .🔒'
  else
  return '🔐Video Post Has Been Locked🔐'
  end
end

local function unlock_group_video(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_video_lock = data[tostring(target)]['settings']['lock_video']
  if group_video_lock == 'no' then
 local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then    
   return '🔐 ارسال فیلم آزاد بود .🔓'
  else
  return '🔓Video Post Not Locked🔓'
  end
  end
    data[tostring(target)]['settings']['lock_video'] = 'no'
    save_data(_config.moderation.data, data)
     local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then 
	return '🔐 ارسال فیلم آزاد شد .🔓'
    else
	return '🔓Video Post HasBeen UNlocked🔓'
  end
end

local function lock_group_audio(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_audio_lock = data[tostring(target)]['settings']['lock_audio']
  if group_audio_lock == 'yes' then
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then    
   return '🔐 ارسال صدا ممنوع بود .🔒'
  else
  return '🔐Audio Post Already Locked🔐'
  end 
  end
    data[tostring(target)]['settings']['lock_audio'] = 'yes'
    save_data(_config.moderation.data, data)
     local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then 
	return '🔐 ارسال صدا ممنوع شد .🔒'
    else
	return '🔐Audio Post Has Been Locked🔐'
  end
end

local function unlock_group_audio(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_audio_lock = data[tostring(target)]['settings']['lock_audio']
  if group_audio_lock == 'no' then
 local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then    
   return '🔐 ارسال صدا آزاد بود .🔓'
  else
  return '🔓Audio Post Not Locked🔓'
  end 
  end
    data[tostring(target)]['settings']['lock_audio'] = 'no'
    save_data(_config.moderation.data, data)
     local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then 
	return '🔐 ارسال صدا آزاد شد .🔓'
  else
  return '🔓Adio Post HassBeen Unlocked🔓'
  end
end


local function lock_group_gif(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_gif_lock = data[tostring(target)]['settings']['lock_gif']
  if group_gif_lock == 'yes' then
     local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then 
	return '🔐 ارسال گیف ممنوع بود .🔒'
  else
  return '🔐Gifs Post Already Locked🔐'
  end 
  end
    data[tostring(target)]['settings']['lock_gifs'] = 'yes'
    save_data(_config.moderation.data, data)
     local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then 
	return '🔐 ارسال گیف ممنوع شد .🔒'
   else
   return '🔐Gifs Post HassBeen Locked🔐'
  end
end

local function unlock_group_gif(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_gif_lock = data[tostring(target)]['settings']['lock_gif']
  if group_gif_lock == 'no' then
     local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then    
   return '🔐 ارسال گیف آزاد بود .🔓'
  else
  return '🔓Gifs Post Not Locked🔓'
  end 
  end
    data[tostring(target)]['settings']['lock_gif'] = 'no'
    save_data(_config.moderation.data, data)
     local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then 
	return '🔐 ارسال گیف آزاد شد .🔓'
      else
  return '🔓Gifs Post HassBeen Unlocked🔓'	  
  end
end

local function lock_group_leave(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_leave_lock = data[tostring(target)]['settings']['leave']
  if group_leave_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 ترک گروه ممنوع بود .🔒'
  else
    return '🔐leave is already locked🔐'
    end
    end
    data[tostring(target)]['settings']['leave'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return ' 🔐 ترک گروه ممنوع شد .🔒'
  else
    return '🔐leave has been locked🔐'
  end
end

local function unlock_group_leave(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_leave_lock = data[tostring(target)]['settings']['leave']
  if group_leave_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 ترک گروه آزاد بود .🔓'
  else
    return '🔓leave is not locked🔓'
  end
  end
    data[tostring(target)]['settings']['leave'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 ترک گروه آزاد شد .🔓'
  else
    return '🔓leave has been unlocked🔓'
  end
end

local function lock_group_operator(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_operator_lock = data[tostring(target)]['settings']['operator']
  if group_operator_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 اپراتور قفل بود .🔒'
  else
    return '🔐Operator is already locked🔐'
  end
  end
    data[tostring(target)]['settings']['operator'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 اپراتور قفل شد .🔒'
  else
    return '🔐Operator has been locked🔐'
  end
end

local function unlock_group_operator(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_operator_lock = data[tostring(target)]['settings']['operator']
  if group_operator_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 اپراتور غیرفعال بود .🔓'
  else
    return '🔓Operator is not locked🔓'
  end
  end
    data[tostring(target)]['settings']['operator'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 قفل اپراتور غیرفعال شد .🔓'
  else
    return '🔓Operator has been unlocked🔓'
  end
end


local function lock_group_reply(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_reply_lock = data[tostring(target)]['settings']['reply']
  if group_reply_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  retuen '🔐 ریپلی قفل بود .🔒'
  else
    return '🔐Reply is already locked🔐'
  end
  end
    data[tostring(target)]['settings']['reply'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 ریپلی قفل شد .🔒'
  else
    return '🔐Reply has been locked🔐'
  end
end

local function unlock_group_reply(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_reply_lock = data[tostring(target)]['settings']['reply']
  if group_reply_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 ریپلی غیرفعال بود .🔓'
  else
    return '🔓Reply is not locked🔓'
  end
  end
    data[tostring(target)]['settings']['reply'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 قفل ریپلی غیرفعال شد .🔓'
  else
    return '🔓Reply has been unlocked🔓'
  end
end

local function lock_group_username(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_username_lock = data[tostring(target)]['settings']['username']
  if group_username_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 یوزرنیم (@) قفل بود .🔒'
  else
    return '🔒Username is already locked🔒'
  end
  end
    data[tostring(target)]['settings']['username'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 یوزرنیم (@) قفل شد .🔒'
  else
    return '🔒Username has been locked🔒'
  end
end

local function unlock_group_username(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_username_lock = data[tostring(target)]['settings']['username']
  if group_username_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 یوزرنیم (@) غیرفعال بود .🔓'
  else
    return '🔓Username is not locked🔓'
  end
  end
    data[tostring(target)]['settings']['username'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 قفل یوزرنیم (@) غیرفعال شد .🔓'
  else
    return '🔓Username has been unlocked🔓'
  end
end

local function lock_group_media(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_media_lock = data[tostring(target)]['settings']['media']
  if group_media_lock == 'yes' then
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 فیلم عکس اهنگ قفل بود .🔒'
    else
    return '🔒Media is already locked🔒'
  end
  end
    data[tostring(target)]['settings']['media'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 فیلم عکس اهنگ قفل شد .🔒'
    else 
    return '🔒Media has been locked🔒'
  end
end

local function unlock_group_media(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_media_lock = data[tostring(target)]['settings']['media']
  if group_media_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
   return  '🔐 فیلم عکس اهنگ غیرفعال بود .🔓'
   else
    return '🔓Media is not locked🔓'
    end
    end
    data[tostring(target)]['settings']['media'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 فیلم عکس اهنگ غیرفعال شد .🔓'
    else
    return '🔓Media has been unlocked🔓'
  end
end

local function lock_group_fosh(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fosh_lock = data[tostring(target)]['settings']['fosh']
  if group_fosh_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 کلمات +18 قفل بود .🔒'
    else
    return '🔒Fosh is already locked🔒'
  end
  end
    data[tostring(target)]['settings']['fosh'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 کلمات +18 قفل شد .🔒'
    else
    return '🔒Fosh has been locked🔒'
  end
end

local function unlock_group_fosh(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fosh_lock = data[tostring(target)]['settings']['fosh']
  if group_fosh_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 کلمات +18 غیرفعال بود .🔓'
  else
  return '🔓Fosh is not locked🔓'
  end
  end
    data[tostring(target)]['settings']['fosh'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 کلمات +18 غیرفعال شد .🔓'
    else
    return '🔓Fosh has been unlocked🔓'
  end
end

local function lock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐  متن راستچین قفل بود .🔒'
  else
   return '*RTL is already locked'
  end
  end
    data[tostring(target)]['settings']['lock_rtl'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 متن راستچین قفل شد .🔒⚠️ اخطار : کاربران نمیتوانند فارسی تایپ کنند . ⚠️'
  else
    return '*RTL has been locked'
  end
end

local function unlock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 متن راستچین غیرفعال بود .🔓'
  else
    return '*RTL is already unlocked'
  end
  end
    data[tostring(target)]['settings']['lock_rtl'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 متن راستچین غیرفعال شد .🔓'
  else
    return '*RTL has been unlocked'
  end
end


local function lock_group_join(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_join_lock = data[tostring(target)]['settings']['join']
  if group_join_lock == 'yes' then
   local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐  ورود اعضا جدید ممنوع بود .🔒'
    else
    return '🔒Join is already locked🔒'
    end
    end
    data[tostring(target)]['settings']['join'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ورود اعضا جدید ممنوع شد .🔒⚠️ اخطار : کاربران نمیتوانند عضو گروه شوند . ⚠️'
    else
    return '🔒Join has been locked🔒'
  end
end

local function unlock_group_join(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_join_lock = data[tostring(target)]['settings']['join']
  if group_join_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ورود اعضا جدید آزاد بود .🔓'
    else
    return '🔓Join is not locked🔓'
    end
    end
    data[tostring(target)]['settings']['join'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ورود اعضا جدید آزاد شد .🔓'
    else
    return '🔓Join has been unlocked🔓'
  end
end

local function lock_group_welcome(msg, data, target)
      if not is_momod(msg) then
        return "👐 شما مدیر گروه نیستید . 👐"
      end
  local welcoms = data[tostring(target)]['settings']['welcome']
  if welcoms == 'yes' then
    return '😍 پیام خوش آمد گویی فعال بود . 😍'
  else
    data[tostring(target)]['settings']['welcome'] = 'yes'
    save_data(_config.moderation.data, data)
    return '😍پیام خوش آمد گویی فعال شد 👏\n 🖊برای تغییر این پیام از دستور زیر استفاده کنید🖊  \n تنظیم خوشامدگویی (متن خوش امد گویی )'
  end
end
local function unlock_group_welcome(msg, data, target)
      if not is_momod(msg) then
        return "👐 شما مدیر گروه نیستید . 👐"
      end
  local welcoms = data[tostring(target)]['settings']['welcome']
  if welcoms == 'no' then
    return '😔 پیام خوش آمد گویی غیرفعال بود . 😔'
  else
    data[tostring(target)]['settings']['welcome'] = 'no'
    save_data(_config.moderation.data, data)
    return '😢 پیام خوش آمد گویی غیرفعال شد . 😢'
  end
end

local function lock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  if group_fosh_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐  فوروارد قفل بود .🔒'
  else
    return 'fwd posting is already locked'
  end
  end
    data[tostring(target)]['settings']['lock_fwd'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 فوروارد قفل شد .🔒'
    else
    return ' 🔐Fwd has been locked🔐'
  end
end

local function unlock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  if group_fwd_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 فوروارد غیرفعال بود .🔓'
  else
  return ' 🔓Fwd is not locked🔓'
  end
  end
    data[tostring(target)]['settings']['lock_fwd'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل فوروارد غیرفعال شد .🔓'
    else
    return ' 🔓Fwd has been unlocked🔓'
  end
end

local function lock_group_english(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_english_lock = data[tostring(target)]['settings']['english']
  if group_english_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐  زبان لاتین قفل بود .🔒'
  else
    return '🔒English is already locked🔒'
  end
  end
    data[tostring(target)]['settings']['english'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
   return '🔐 زبان لاتین قفل شد .🔒⚠️ اخطار : کاربران نمیتوانند به زبان انگلیسی چت کنند . ⚠️'
   else
    return '🔒English has been locked🔒'
  end
end

local function unlock_group_english(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_english_lock = data[tostring(target)]['settings']['english']
  if group_english_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 زبان لاتین غیرفعال بود .🔓'
  else
    return '🔓English is not locked🔓'
  end
  end
    data[tostring(target)]['settings']['english'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 زبان لاتین غیرفعال شد .🔓'
  else
    return '🔓English has been unlocked🔓'
  end
end

local function lock_group_emoji(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_emoji_lock = data[tostring(target)]['settings']['lock_emoji']
  if group_emoji_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐  ارسال شکلک ممنوع بود .🔒'
  else
  return '🔒emoji is already locked🔒'
  end
  end
    data[tostring(target)]['settings']['lock_emoji'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ارسال شکلک ممنوع شد .🔒'
    else 
    return '🔒emoji has been locked🔒'
  end
end

local function unlock_group_emoji(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_emoji_lock = data[tostring(target)]['settings']['lock_emoji']
  if group_emoji_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ارسال شکلک آزاد بود .🔓'
  else
  return '🔓emoji is not locked🔓'
  end
  end
    data[tostring(target)]['settings']['lock_emoji'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ارسال شکلک آزاد شد .🔓'
    else
    return '🔓emoji has been unlocked🔓'
  end
end

local function lock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tag_lock = data[tostring(target)]['settings']['tag']
  if group_tag_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐  هشتگ (#) قفل بود .🔒'
  else
    return '🔒Tag is already locked🔒'
  end
  end
    data[tostring(target)]['settings']['tag'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 هشتگ (#) قفل شد .🔒'
  else
    return '🔒Tag has been locked🔒'
  end
end

local function unlock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_tag_lock = data[tostring(target)]['settings']['tag']
  if group_tag_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 هشتگ (#) غیرفعال بود .🔓'
  else
    return 'Tag is not locked'
  end
  end
    data[tostring(target)]['settings']['tag'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 قفل هشتگ (#) غیرفعال شد .🔓'
  else
    return '🔓Tag has been unlocked🔓'
  end
end

local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  if not is_owner(msg) then
    return "👑 این دستور فقط برای صاحب ربات است . 👑"
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐  ضداسپم قفل بود .🔒'
  else
  return '🔒spam posting is already locked🔒'
  end
  end
    data[tostring(target)]['settings']['lock_spam'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ضداسپم قفل شد .🔒'
    else
    return '🔒spam posting hasBeen locked🔒'
  end
end

local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ضداسپم غیرفعال بود .🔓'
  else
  return '🔒spam posting is already Unlocked🔓'
  end
  end
    data[tostring(target)]['settings']['lock_spam'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ضداسپم غیرفعال شد .🔓'
    else
    return '🔒spam posting HasBeen Unlocked🔓'
  end
end

local function lock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐  ارسال پست رگباری قفل بود .🔒'
  else
  return '🔒flood is already locked🔒'
  end
  end
    data[tostring(target)]['settings']['flood'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ارسال پست رگباری قفل شد .🔒'
    else
    return '🔒flood has been locked🔒'
  end
end

local function unlock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ارسال پست رگباری غیرفعال بود .🔓'
  else
  return '🔓flood is not locked🔓'
  end
  end
    data[tostring(target)]['settings']['flood'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل ارسال پست رگباری غیرفعال شد .🔓'
    else
    return '🔓flood has been unlocked🔓'
  end
end


local function lock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐  چت فارسی قفل بود .🔒'
  else
  return '🔒arabic posting is already locked🔒'
  end
  end
    data[tostring(target)]['settings']['lock_arabic'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 چت فارسی قفل شد .🔒⚠️ اخطار : کاربران نمیتوانند به زبان فارسی چت کنند . ⚠️'
    else 
    return '🔒arabic posting hasBeen locked🔒'
  end
end

local function unlock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل چت فارسی غیرفعال بود .🔓'
  else
  return '🔒arabic posting is already Unlocked🔓'
  end
  end
    data[tostring(target)]['settings']['lock_arabic'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل چت فارسی غیرفعال شد .🔓'
    else
    return '🔒arabic posting HasBeen Unlocked🔓'
  end
end

local function lock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐  افزودن کاربر قفل بود .🔒'
  else
  return ' 🔒addMember is already locked🔒'
  end
  end
    data[tostring(target)]['settings']['lock_member'] = 'yes'
    save_data(_config.moderation.data, data)
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 افزودن کاربر قفل شد .🔒⚠️ اخطار : کاربران نمیتوانند دوستان خود را اضافه کنند . ⚠️'
  else
  return '🔒addMember HasBeen locked🔒'
end
end

local function unlock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل افزودن کاربر غیرفعال بود .🔓'
  else
  return '🔓AddMember is not locked🔓'
  end
  end
    data[tostring(target)]['settings']['lock_member'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل افزودن کاربر غیرفعال شد .🔓'
    else
    return ' 🔓AddMember hasBeen UNlocked🔓'
  end
end

local function lock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐  پیامهای سیستمی قفل بود .🔒'
  else
    return '*TGservice is already locked'
  end
  end
    data[tostring(target)]['settings']['lock_tgservice'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 پیامهای سیستمی قفل شد .🔒'
  else
    return '*TGservice has been locked'
  end
end

local function unlock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 قفل پیامهای سیستمی غیرفعال بود .🔓'
  else
    return '*TGService Is Not Locked!'
  end
  end
    data[tostring(target)]['settings']['lock_tgservice'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 قفل پیامهای سیستمی غیرفعال شد .🔓'
  else
    return '*TGservice has been unlocked'
  end
end

local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐  ارسال استیکر قفل بود .🔒'
  else
  return '🔒sticker posting is already locked🔒'
  end
  end
    data[tostring(target)]['settings']['lock_sticker'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ارسال استیکر قفل شد .🔒'
    else
    return '🔒sticker posting HasBeen locked🔒'
  end
end
local function unlock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل ارسال استیکر غیرفعال بود .🔓'
  else
  return '🔒sticker posting is already Unlocked🔓'
  end
  end
    data[tostring(target)]['settings']['lock_sticker'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل ارسال استیکر غیرفعال شد .🔓'
    else
    return '🔒sticker posting HasBeen Unlocked🔓'
  end
end

local function lock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐  ورود ربات ها قفل بود .🔒'
  else
  return ' 🔐Bots protection is already enabled🔐'
  end
  end
    data[tostring(target)]['settings']['lock_bots'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ورود ربات ها قفل شد .🔒'
    else
    return ' 🔐Bots protection has been enabled🔐'
  end
end

local function unlock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل ورود ربات ها غیرفعال بود .🔓'
  else
  return ' 🔓Bots protection is already disabled🔓'
  end
  end
    data[tostring(target)]['settings']['lock_bots'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل ورود ربات ها غیرفعال شد .🔓'
    else
    return ' 🔓Bots protection has been disabled🔓'
  end
end

local function lock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐  ارسال مخاطب قفل بود .🔒'
  else
  return ' 🔒Contact posting is already locked🔒'
  end
  end
    data[tostring(target)]['settings']['lock_contacts'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 ارسال مخاطب قفل شد .🔒'
    else
    return ' 🔒Contact posting HasBeen locked🔒'
  end
end

local function unlock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل ارسال مخاطب غیرفعال بود .🔓'
  else
  return ' 🔒contact  posting is already Unlocked🔓'
  end
  end
    data[tostring(target)]['settings']['lock_contacts'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
    return '🔐 قفل ارسال مخاطب غیرفعال شد .🔓'
    else
    return ' 🔒contact posting HasBeen Unlocked🔓'
  end
end

local function enable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == 'yes' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐  تنظیمات سختگیرانه فعال بود .🔒'
  else
    return '*Settings are already strictly enforced'
  end
  end
    data[tostring(target)]['settings']['strict'] = 'yes'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 تنظیمات سختگیرانه فعال شد .🔒'
  else
    return '*Settings will be strictly enforced'
  end
end

local function disable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == 'no' then
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 قفل تنظیمات سختگیرانه غیرفعال بود .🔓'
  else
    return '*Settings are not strictly enforced'
  end
  end
    data[tostring(target)]['settings']['strict'] = 'no'
    save_data(_config.moderation.data, data)
    local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
  return '🔐 قفل تنظیمات سختگیرانه غیرفعال شد .🔓'
  else
    return '*Settings will not be strictly enforced'
  end
end
--End supergroup locks

local function callback_clean_bots (extra, success, result)
	local msg = extra.msg
	local receiver = 'channel#id'..msg.to.id
	local channel_id = msg.to.id
	for k,v in pairs(result) do
		local bot_id = v.peer_id
		kick_user(bot_id,channel_id)
	end
end

--'Set supergroup rules' function
local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return '👐 شما مدیر گروه نیستید . 👐'
end

--'Get supergroup rules' function
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    return '📢 قوانینی برای گروه ثبت نشده است . 📢'
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  local group_name = data[tostring(msg.to.id)]['settings']['set_name']
  local rules = group_name..' rules:\n\n'..rules:gsub("/n", " ")
  return rules
end

--Set supergroup to public or not public function
local function set_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return "👐 شما مدیر گروه نیستید . 👐"
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'yes' then
    return '🔏گروه عمومی بود .🔏'
  else
    data[tostring(target)]['settings']['public'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return '🔏گروه عمومی شد .🔏'
end

local function unset_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'no' then
    return '🔏گروه خصوصی بود .🔏'
  else
    data[tostring(target)]['settings']['public'] = 'no'
	data[tostring(target)]['long_id'] = msg.to.long_id
    save_data(_config.moderation.data, data)
    return '🔏گروه خصوصی شد .🔏'
  end
end

--Show supergroup settings; function
function show_supergroup_settingsmod(msg, target)
 	if not is_momod(msg) then
    	return
  	end
	local data = load_data(_config.moderation.data)
    if data[tostring(target)] then
     	if data[tostring(target)]['settings']['flood_msg_max'] then
        	NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
        	print('custom'..NUM_MSG_MAX)
      	else
        	NUM_MSG_MAX = 5
      	end
    end
    local bots_protection = "Yes"
    if data[tostring(target)]['settings']['lock_bots'] then
    	bots_protection = data[tostring(target)]['settings']['lock_bots']
   	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['public'] then
			data[tostring(target)]['settings']['public'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_rtl'] then
			data[tostring(target)]['settings']['lock_rtl'] = 'no'
		end
        end
      if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tgservice'] then
			data[tostring(target)]['settings']['lock_tgservice'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['tag'] then
			data[tostring(target)]['settings']['tag'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['emoji'] then
			data[tostring(target)]['settings']['emoji'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['english'] then
			data[tostring(target)]['settings']['english'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['fwd'] then
			data[tostring(target)]['settings']['fwd'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['reply'] then
			data[tostring(target)]['settings']['reply'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['join'] then
			data[tostring(target)]['settings']['join'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['fosh'] then
			data[tostring(target)]['settings']['fosh'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['username'] then
			data[tostring(target)]['settings']['username'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['media'] then
			data[tostring(target)]['settings']['media'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['leave'] then
			data[tostring(target)]['settings']['leave'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_member'] then
			data[tostring(target)]['settings']['lock_member'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['all'] then
			data[tostring(target)]['settings']['all'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['operator'] then
			data[tostring(target)]['settings']['operator'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['etehad'] then
			data[tostring(target)]['settings']['etehad'] = 'no'
		end
	end
	if is_muted(tostring(target), 'Audio: yes') then
 Audio = 'yes'
 else
 Audio = 'no'
 end
    if is_muted(tostring(target), 'Photo: yes') then
 Photo = 'yes'
 else
 Photo = 'no'
 end
    if is_muted(tostring(target), 'Video: yes') then
 Video = 'yes'
 else
 Video = 'no'
 end
    if is_muted(tostring(target), 'Gifs: yes') then
 Gifs = 'yes'
 else
 Gifs = 'no'
 end
 if is_muted(tostring(target), 'Documents: yes') then
 Documents = 'yes'
 else
 Documents = 'no'
 end
 if is_muted(tostring(target), 'Text: yes') then
 Text = 'yes'
 else
 Text = 'no'
 end
  if is_muted(tostring(target), 'All: yes') then
 All = 'yes'
 else
 All = 'no'
 end
   local gp_type = data[tostring(msg.to.id)]['group_type']

  local settings = data[tostring(target)]['settings']
  local hash = 'group:'..msg.to.id
  local group_lang = redis:hget(hash,'lang')
  if group_lang then
 return reply_msg(msg.id,"📋 لیست تنظیمات گروه 📋\n➖➖➖➖➖➖➖\n🌟 قفل لینک : "..settings.lock_link.." \n🌟 قفل تبلیغات : "..settings.inline.." \n🌟 قفل دستورات : "..settings.cmds.." \n🌟 قفل شماره : "..settings.number.." \n🌟 قفل مخاطب : "..settings.lock_contacts.." \n🌟 قفل فلود : "..settings.flood.." \n🌟 حساسیت : "..NUM_MSG_MAX.." \n🌟 قفل اسپم : "..settings.lock_spam.." \n🌟 قفل فارسی : "..settings.lock_arabic.." \n🌟 قفل ممبر : "..settings.lock_member.." \n🌟 قفل راستچین : "..settings.lock_rtl.." \n🌟 قفل سیستم : "..settings.lock_tgservice.." \n🌟 قفل استیکر : "..settings.lock_sticker.." \n🌟 قفل تگ : "..settings.tag.." \n🌟 قفل شکلک : "..settings.emoji.." \n🌟 قفل انگلیسی : "..settings.english.." \n🌟 قفل فوروارد : "..settings.fwd.." \n🌟 قفل ریپلی : "..settings.reply.." \n🌟 قفل اعضا : "..settings.join.." \n🌟 قفل یوزرنیم : "..settings.username.." \n🌟 قفل مدیا : "..settings.media.." \n🌟 قفل فحش : "..settings.fosh.." \n🌟 قفل خروج : "..settings.leave.." \n🌟 قفل ربات : "..bots_protection.." \n🌟 قفل اپراتور : "..settings.operator.." \n🌟 قفل سختگیرانه : "..settings.strict.." \n🌟 قفل همه تنظیمات : "..settings.all.." \n🌟 عمومی : "..settings.public.." \n➖➖➖➖➖➖➖\n📝 قفل متن  : "..Text.."\n🖼قفل عکس : "..Photo.."\n🎞قفل گیف : "..Gifs.."\n🎤قفل صدا : "..Audio.."\n📽قفل فیلم : "..Video.."\n🗂قفل فایل : "..Documents.."\n🔐 قفل همه  : "..All.." \n➖➖➖➖➖➖➖\n💫نوع گروه : "..gp_type.." \n👤مالک گروه : "..group_owner.." \nتاریخ انقضا گروه : "..expiretime.." \n➖➖➖➖➖➖➖\n🏵 @SKORT_TM 🏵\n➖➖➖➖➖➖➖\n", ok_cb, false)
 else
return reply_msg(msg.id,"📋 لیست تنظیمات گروه 📋\n➖➖➖➖➖➖➖\n🌟 قفل لینک : "..settings.lock_link.." \n🌟 قفل تبلیغات : "..settings.inline.." \n🌟 قفل دستورات : "..settings.cmds.." \n🌟 قفل شماره : "..settings.number.." \n🌟 قفل مخاطب : "..settings.lock_contacts.." \n🌟 قفل فلود : "..settings.flood.." \n🌟 حساسیت : "..NUM_MSG_MAX.." \n🌟 قفل اسپم : "..settings.lock_spam.." \n🌟 قفل فارسی : "..settings.lock_arabic.." \n🌟 قفل ممبر : "..settings.lock_member.." \n🌟 قفل راستچین : "..settings.lock_rtl.." \n🌟 قفل سیستم : "..settings.lock_tgservice.." \n🌟 قفل استیکر : "..settings.lock_sticker.." \n🌟 قفل تگ : "..settings.tag.." \n🌟 قفل شکلک : "..settings.emoji.." \n🌟 قفل انگلیسی : "..settings.english.." \n🌟 قفل فوروارد : "..settings.fwd.." \n🌟 قفل ریپلی : "..settings.reply.." \n🌟 قفل اعضا : "..settings.join.." \n🌟 قفل یوزرنیم : "..settings.username.." \n🌟 قفل مدیا : "..settings.media.." \n🌟 قفل فحش : "..settings.fosh.." \n🌟 قفل خروج : "..settings.leave.." \n🌟 قفل ربات : "..bots_protection.." \n🌟 قفل اپراتور : "..settings.operator.." \n🌟 قفل سختگیرانه : "..settings.strict.." \n🌟 قفل همه تنظیمات : "..settings.all.." \n🌟 عمومی : "..settings.public.." \n➖➖➖➖➖➖➖\n📝 قفل متن  : "..Text.."\n🖼قفل عکس : "..Photo.."\n🎞قفل گیف : "..Gifs.."\n🎤قفل صدا : "..Audio.."\n📽قفل فیلم : "..Video.."\n🗂قفل فایل : "..Documents.."\n🔐 قفل همه  : "..All.." \n➖➖➖➖➖➖➖\n💫نوع گروه : "..gp_type.." \n👤مالک گروه : "..group_owner.." \nتاریخ انقضا گروه : "..expiretime.." \n➖➖➖➖➖➖➖\n🏵 @SKORT_TM 🏵\n➖➖➖➖➖➖➖\n", ok_cb, false)
end
end 

local function promote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' is already a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function demote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' is not a moderator.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
end

local function promote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return send_large_msg(receiver, 'SuperGroup is not added.')
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' 👮 همچنان مدیر است . 👮 :')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' 👏 تبریک ترفیع گرفتید . 👏 :.')
end

local function demote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'Group is not added.')
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' 😒 قبلا هم مدیر نبود 😐 :')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' 😒 ازمدیریت اعزل شدید . 😐 :')
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "groups"
  if not data[tostring(groups)][tostring(msg.to.id)] then
    return 'SuperGroup is not added.'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then
    return '👮مدیری برای گروه انتخاب نشده است .👮'
  end
  local i = 1
  local message = '\n📋 لیست مدیران گروه : ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message ..i..' - '..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end

-- Start by reply actions
function get_message_callback(extra, success, result)
	local get_cmd = extra.get_cmd
	local msg = extra.msg
	local data = load_data(_config.moderation.data)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
    if get_cmd == "id" and not result.action then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for: ["..result.from.peer_id.."]")
		id1 = send_large_msg(channel, result.from.peer_id)
	elseif get_cmd == 'id' and result.action then
		local action = result.action.type
		if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
			if result.action.user then
				user_id = result.action.user.peer_id
			else
				user_id = result.peer_id
			end
			local channel = 'channel#id'..result.to.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id by service msg for: ["..user_id.."]")
			id1 = send_large_msg(channel, user_id)
		end
    elseif get_cmd == "idfrom" then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for msg fwd from: ["..result.fwd_from.peer_id.."]")
		id2 = send_large_msg(channel, result.fwd_from.peer_id)
    elseif get_cmd == 'channel_block' and not result.action then
		local member_id = result.from.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply")
		kick_user(member_id, channel_id)
local kickedhash = 'kicked:'..msg.from.id..':'..msg.to.id
        redis:incr(kickedhash)
        local kickedhash = 'kicked:'..msg.from.id..':'..msg.to.id
        local kicked = redis:get(kickedhash)
	elseif get_cmd == 'channel_block' and result.action and result.action.type == 'chat_add_user' then
		local user_id = result.action.user.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply to sev. msg.")
		kick_user(user_id, channel_id)
local kickedhash = 'kicked:'..msg.from.id..':'..msg.to.id
        redis:incr(kickedhash)
        local kickedhash = 'kicked'..msg.from.id..':'..msg.to.id
        local kicked = redis:get(kickedhash)
	elseif get_cmd == "del" then
		delete_msg(result.id, ok_cb, false)
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] deleted a message by reply")
	elseif get_cmd == "setadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		channel_set_admin(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." 👏 تبریک ادمین گروه شد :"
		else
			text = "[ "..user_id.." ]👏 تبریک ادمین گروه شد :"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..user_id.."] as admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "demoteadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		if is_admin2(result.from.peer_id) then
			return send_large_msg(channel_id, "You can't demote global admins!")
		end
		channel_demote(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." has been demoted from admin"
		else
			text = "[ "..user_id.." ] has been demoted from admin"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted: ["..user_id.."] from admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "setowner" then
		local group_owner = data[tostring(result.to.peer_id)]['set_owner']
		if group_owner then
		local channel_id = 'channel#id'..result.to.peer_id
			if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
				local user = "user#id"..group_owner
				channel_demote(channel_id, user, ok_cb, false)
			end
			local user_id = "user#id"..result.from.peer_id
			channel_set_admin(channel_id, user_id, ok_cb, false)
			data[tostring(result.to.peer_id)]['set_owner'] = tostring(result.from.peer_id)
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..result.from.peer_id.."] as owner by reply")
			if result.from.username then
				text = "@"..result.from.username.." [ "..result.from.peer_id.." ] added as owner"
			else
				text = "[ "..result.from.peer_id.." ] added as owner"
			end
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "promote" then
		local receiver = result.to.peer_id
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
		if result.from.username then
			member_username = '@'.. result.from.username
		end
		local member_id = result.from.peer_id
		if result.to.peer_type == 'channel' then
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted mod: @"..member_username.."["..result.from.peer_id.."] by reply")
		promote2("channel#id"..result.to.peer_id, member_username, member_id)
	    --channel_set_mod(channel_id, user, ok_cb, false)
		end
	elseif get_cmd == "demote" then
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
    if result.from.username then
		member_username = '@'.. result.from.username
    end
		local member_id = result.from.peer_id
		--local user = "user#id"..result.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted mod: @"..member_username.."["..user_id.."] by reply")
		demote2("channel#id"..result.to.peer_id, member_username, member_id)
		--channel_demote(channel_id, user, ok_cb, false)
	elseif get_cmd == 'mute_user' then
		if result.service then
			local action = result.action.type
			if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
				if result.action.user then
					user_id = result.action.user.peer_id
				end
			end
			if action == 'chat_add_user_link' then
				if result.from then
					user_id = result.from.peer_id
				end
			end
		else
			user_id = result.from.peer_id
		end
		local receiver = extra.receiver
		local chat_id = msg.to.id
		print(user_id)
		print(chat_id)
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."]➖["..chat_id.."] 📋 به لیست سکوت اضافه شد : ")
		elseif is_admin1(msg) then
			mute_user(chat_id, user_id)
		local mutedhash = 'muted:'..msg.from.id..':'..msg.to.id
        redis:incr(mutedhash)
        local mutedhash = 'muted:'..msg.from.id..':'..msg.to.id
        local muted = redis:get(mutedhash)
	send_large_msg(receiver, " ["..user_id.."]➖["..chat_id.."] 📋 از لیست سکوت حذف شد :")
		end
	end
end
-- End by reply actions

--By ID actions
local function cb_user_info(extra, success, result)
	local receiver = extra.receiver
	local user_id = result.peer_id
	local get_cmd = extra.get_cmd
	local data = load_data(_config.moderation.data)
	--[[if get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		channel_set_admin(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
		else
			text = "[ "..result.peer_id.." ] has been set as an admin"
		end
			send_large_msg(receiver, text)]]
	if get_cmd == "demoteadmin" then
		if is_admin2(result.peer_id) then
			return send_large_msg(receiver, "You can't demote global admins!")
		end
		local user_id = "user#id"..result.peer_id
		channel_demote(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been demoted from admin"
			send_large_msg(receiver, text)
		else
			text = "[ "..result.peer_id.." ] has been demoted from admin"
			send_large_msg(receiver, text)
		end
	elseif get_cmd == "promote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		promote2(receiver, member_username, user_id)
	elseif get_cmd == "demote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		demote2(receiver, member_username, user_id)
	end
end

-- Begin resolve username actions
local function callbackres(extra, success, result)
  local member_id = result.peer_id
  local member_username = "@"..result.username
  local get_cmd = extra.get_cmd
	if get_cmd == "res" then
		local user = result.peer_id
		local name = string.gsub(result.print_name, "_", " ")
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user..'\n'..name)
		return user
	elseif get_cmd == "id" then
		local user = result.peer_id
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user)
		return user
  elseif get_cmd == "invite" then
    local receiver = extra.channel
    local user_id = "user#id"..result.peer_id
    channel_invite(receiver, user_id, ok_cb, false)
	--[[elseif get_cmd == "channel_block" then
		local user_id = result.peer_id
		local channel_id = extra.channelid
    local sender = extra.sender
    if member_id == sender then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
		if is_momod2(member_id, channel_id) and not is_admin2(sender) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		kick_user(user_id, channel_id)
	elseif get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		channel_set_admin(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been set as an admin"
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "setowner" then
		local receiver = extra.channel
		local channel = string.gsub(receiver, 'channel#id', '')
		local from_id = extra.from_id
		local group_owner = data[tostring(channel)]['set_owner']
		if group_owner then
			local user = "user#id"..group_owner
			if not is_admin2(group_owner) and not is_support(group_owner) then
				channel_demote(receiver, user, ok_cb, false)
			end
			local user_id = "user#id"..result.peer_id
			channel_set_admin(receiver, user_id, ok_cb, false)
			data[tostring(channel)]['set_owner'] = tostring(result.peer_id)
			save_data(_config.moderation.data, data)
			savelog(channel, name_log.." ["..from_id.."] set ["..result.peer_id.."] as owner by username")
		if result.username then
			text = member_username.." [ "..result.peer_id.." ] added as owner"
		else
			text = "[ "..result.peer_id.." ] added as owner"
		end
		send_large_msg(receiver, text)
  end]]
	elseif get_cmd == "promote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		--local user = "user#id"..result.peer_id
		promote2(receiver, member_username, user_id)
		--channel_set_mod(receiver, user, ok_cb, false)
	elseif get_cmd == "demote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		local user = "user#id"..result.peer_id
		demote2(receiver, member_username, user_id)
	elseif get_cmd == "demoteadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		if is_admin2(result.peer_id) then
			return send_large_msg(channel_id, "You can't demote global admins!")
		end
		channel_demote(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been demoted from admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been demoted from admin"
			send_large_msg(channel_id, text)
		end
		local receiver = extra.channel
		local user_id = result.peer_id
		demote_admin(receiver, member_username, user_id)
	elseif get_cmd == 'mute_user' then
		local user_id = result.peer_id
		local receiver = extra.receiver
		local chat_id = string.gsub(receiver, 'channel#id', '')
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] removed from muted user list")
		elseif is_owner(extra.msg) then
			mute_user(chat_id, user_id)
local mutedhash = 'muted:'..msg.from.id..':'..msg.to.id
        redis:incr(mutedhash)
        local mutedhash = 'muted:'..msg.from.id..':'..msg.to.id
        local muted = redis:get(mutedhash)
			send_large_msg(receiver, " ["..user_id.."] added to muted user list")
		end
	end
end
--End resolve username actions

--Begin non-channel_invite username actions
local function in_channel_cb(cb_extra, success, result)
  local get_cmd = cb_extra.get_cmd
  local receiver = cb_extra.receiver
  local msg = cb_extra.msg
  local data = load_data(_config.moderation.data)
  local print_name = user_print_name(cb_extra.msg.from):gsub("‮", "")
  local name_log = print_name:gsub("_", " ")
  local member = cb_extra.username
  local memberid = cb_extra.user_id
  if member then
    text = 'No user @'..member..' in this SuperGroup.'
  else
    text = 'No user ['..memberid..'] in this SuperGroup.'
  end
if get_cmd == "channel_block" then
  for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
     local user_id = v.peer_id
     local channel_id = cb_extra.msg.to.id
     local sender = cb_extra.msg.from.id
      if user_id == sender then
        return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
      end
      if is_momod2(user_id, channel_id) and not is_admin2(sender) then
        return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
      end
      if is_admin2(user_id) then
        return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
      end
      if v.username then
        text = "."
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..v.username.." ["..v.peer_id.."]")
      else
        text = "."
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..v.peer_id.."]")
      end
      kick_user(user_id, channel_id)
local kickedhash = 'kicked:'..msg.from.id..':'..msg.to.id
        redis:incr(kickedhash)
        local kickedhash = 'kicked:'..msg.from.id..':'..msg.to.id
        local kicked = redis:get(kickedhash)
      return
    end
  end
elseif get_cmd == "setadmin" then
   for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
      local user_id = "user#id"..v.peer_id
      local channel_id = "channel#id"..cb_extra.msg.to.id
      channel_set_admin(channel_id, user_id, ok_cb, false)
      if v.username then
        text = "@"..v.username.." ["..v.peer_id.."] has been set as an admin"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..v.username.." ["..v.peer_id.."]")
      else
        text = "["..v.peer_id.."] has been set as an admin"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin "..v.peer_id)
      end
	  if v.username then
		member_username = "@"..v.username
	  else
		member_username = string.gsub(v.print_name, '_', ' ')
	  end
		local receiver = channel_id
		local user_id = v.peer_id
		promote_admin(receiver, member_username, user_id)

    end
    send_large_msg(channel_id, text)
    return
 end
 elseif get_cmd == 'setowner' then
	for k,v in pairs(result) do
		vusername = v.username
		vpeer_id = tostring(v.peer_id)
		if vusername == member or vpeer_id == memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
					local user_id = "user#id"..v.peer_id
					channel_set_admin(receiver, user_id, ok_cb, false)
					data[tostring(channel)]['set_owner'] = tostring(v.peer_id)
					save_data(_config.moderation.data, data)
					savelog(channel, name_log.."["..from_id.."] set ["..v.peer_id.."] as owner by username")
				if result.username then
					text = member_username.." ["..v.peer_id.."] added as owner"
				else
					text = "["..v.peer_id.."] added as owner"
				end
			end
		elseif memberid and vusername ~= member and vpeer_id ~= memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
				data[tostring(channel)]['set_owner'] = tostring(memberid)
				save_data(_config.moderation.data, data)
				savelog(channel, name_log.."["..from_id.."] set ["..memberid.."] as owner by username")
				text = "["..memberid.."] added as owner"
			end
		end
	end
 end
send_large_msg(receiver, text)
end
--End non-channel_invite username actions

--'Set supergroup photo' function
local function set_supergroup_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
      return
  end
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/channel_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    channel_set_photo(receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, '🖼 تصویر تنظیم شد . 🖼', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'Failed, please try again!', ok_cb, false)
  end
end

--Run function
local function run(msg, matches)
	if msg.to.type == 'chat' then
		if matches[1] == 'tosuper' or matches[1] =='تبدیل' then
			if not is_admin1(msg) then
				return
			end
			local receiver = get_receiver(msg)
			chat_upgrade(receiver, ok_cb, false)
		end
	elseif msg.to.type == 'channel' then
		if matches[1] == 'tosuper' or matches[1] =='تبدیل' then
			if not is_admin1(msg) then
				return
			end
			return "🏵 گروه از قبل سوپر گروه است . 🏵"
		end
	end
	if msg.to.type == 'channel' then
	local support_id = msg.from.id
	local receiver = get_receiver(msg)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	local data = load_data(_config.moderation.data)
		if matches[1] == 'add' or matches[1] =='نصب' and not matches[2] then
			if not is_admin1(msg) and not is_support(support_id) then
				return
			end
			if is_super_group(msg) then
				return reply_msg(msg.id, '👽 از قبل در گروه نصب شده بود .👽', ok_cb, false)
			end
			print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") added")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] added SuperGroup")
			superadd(msg)
			set_mutes(msg.to.id)
			channel_set_admin(receiver, 'user#id'..msg.from.id, ok_cb, false)
		end

		 if matches[1] == 'rem' and is_admin1(msg) and not matches[2] then
   if not is_super_group(msg) then
    return reply_msg(msg.id, '👽 از قبل غیرفعال شده بود . 👽', ok_cb, false)
   end

   print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") removed")
   superrem(msg)
   rem_mutes(msg.to.id)
  end

		 if matches[1] == 'حذف شو' and is_admin1(msg) and not matches[2] then
   if not is_super_group(msg) then
    return reply_msg(msg.id, '👽 از قبل غیرفعال شده بود . 👽', ok_cb, false)
   end

   print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") removed")
   superrem(msg)
   rem_mutes(msg.to.id)
  end

		if not data[tostring(msg.to.id)] then
			return
		end
		if matches[1] == "gpinfo" or matches[1] =='اطلاعات گروه' then
			if not is_owner(msg) then
				return
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup info")
			channel_info(receiver, callback_info, {receiver = receiver, msg = msg})
		end

		if matches[1] == "admins" or matches[1] =="ادمین ها" then
			if not is_owner(msg) and not is_support(msg.from.id) then
				return
			end
			member_type = 'Admins'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup Admins list")
			admins = channel_get_admins(receiver,callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "owner" or matches[1] =="ایدی صاحب" then
			local group_owner = data[tostring(msg.to.id)]['set_owner']
			if not group_owner then
				return "no owner,ask admins in support groups to set owner for your SuperGroup"
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] used /owner")
			return "🆔 آیدی صاحب : ["..group_owner..']'
		end

		if matches[1] == "modlist" or matches[1] =="مدیران" then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group modlist")
			return modlist(msg)
			-- channel_get_admins(receiver,callback, {receiver = receiver})
		end

		if matches[1] == "bots" or matches[1] =="ربات ها" and is_momod(msg) then
			member_type = 'Bots'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup bots list")
			channel_get_bots(receiver, callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "who" or matches[1] =="افراد" and not matches[2] and is_momod(msg) then
			local user_id = msg.from.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup users list")
			channel_get_users(receiver, callback_who, {receiver = receiver})
		end

		if matches[1] == "kicked" or matches[1] =="اخراجی ها" and is_momod(msg) then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested Kicked users list")
			channel_get_kicked(receiver, callback_kicked, {receiver = receiver})
		end

		if matches[1] == 'del'or matches[1] =='پاک' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'del',
					msg = msg
				}
				delete_msg(msg.id, ok_cb, false)
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			end
		end

		if matches[1] == 'block' or matches[1] =='بن' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'channel_block',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'block' or matches[1] =='بن' and string.match(matches[2], '^%d+$') then
				--[[local user_id = matches[2]
				local channel_id = msg.to.id
				if is_momod2(user_id, channel_id) and not is_admin2(user_id) then
					return send_large_msg(receiver, "You can't kick mods/owner/admins")
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: [ user#id"..user_id.." ]")
				kick_user(user_id, channel_id)]]
				local	get_cmd = 'channel_block'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif msg.text:match("@[%a%d]") then
			--[[local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'channel_block',
					sender = msg.from.id
				}
			    local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
			local get_cmd = 'channel_block'
			local msg = msg
			local username = matches[2]
			local username = string.gsub(matches[2], '@', '')
			channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'id'or matches[1] =='ایدی' then
			if type(msg.reply_id) ~= "nil" and is_momod(msg) and not matches[2] then
				local cbreply_extra = {
					get_cmd = 'id',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif type(msg.reply_id) ~= "nil" and matches[2] == "from" and is_momod(msg) then
				local cbreply_extra = {
					get_cmd = 'idfrom',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif msg.text:match("@[%a%d]") then
				local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'id'
				}
				local username = matches[2]
				local username = username:gsub("@","")
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested ID for: @"..username)
				resolve_username(username,  callbackres, cbres_extra)
			else
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup ID")
				text = "👤 نام : " ..string.gsub(msg.from.print_name, "_", " ").. "\n👤 یوزرنیم : @"..(msg.from.username or '----').."\n🆔 ایدی شما : "..msg.from.id.."\n-------------------------------------\n🏵 اسم گروه : " ..string.gsub(msg.to.print_name, "_", " ").. "\n🆔 آیدی گروه : "..msg.to.id
	reply_msg(msg.id, text, ok_cb, false)
end
		end

		if matches[1] == 'kickme' then
			if msg.to.type == 'channel' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] left via kickme")
				channel_kick("channel#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
			end
		end

		if matches[1] == 'newlink'or matches[1] =='لینک جدید' and is_momod(msg)then
			local function callback_link (extra , success, result)
			local receiver = get_receiver(msg)
				if success == 0 then
					send_large_msg(receiver, '⚠️خطا: ناموفق بودن ربات هنگام دریافت لینک⚠️ \n⚠️دلیل: صاحب اصلی #سوپرگروه نبودن⚠️\n➖➖➖➖➖\n🌐 اگر شما لینک را دارید با دستور تنظیم لینک آنرا تنظیم کنید . 🌐')
					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
				else
					send_large_msg(receiver, "Created a new link")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
					save_data(_config.moderation.data, data)
				end
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to create a new SuperGroup link")
			export_channel_link(receiver, callback_link, false)
		end

		if matches[1] == 'setlink'or matches[1] =='تنظیم لینک' and is_owner(msg) then
			data[tostring(msg.to.id)]['settings']['set_link'] = 'waiting'
			save_data(_config.moderation.data, data)
			return '🌐 لطفا لینک جدید را ارسال کنید . 🌐'
		end

		if msg.text then
			if msg.text:match("^(https://telegram.me/joinchat/%S+)$") and data[tostring(msg.to.id)]['settings']['set_link'] == 'waiting' and is_owner(msg) then
				data[tostring(msg.to.id)]['settings']['set_link'] = msg.text
				save_data(_config.moderation.data, data)
				return "🌐 لینک جدید تنظیم شد . 🌐"
			end
		end

		if matches[1] == 'link'or matches[1] =='لینک' then
			if not is_momod(msg) then
				return
			end
			local group_link = data[tostring(msg.to.id)]['settings']['set_link']
			 if not group_link then
				return "⚠️خطا: ناموفق بودن ربات هنگام دریافت لینک⚠️ \n⚠️دلیل : لینکی ثبت نشده است . ⚠️\n➖➖➖➖➖\n🌐 برای ساختن لینک جدید ابتدا دستور 'لینک جدید' را بزنید . 🌐\n🌐 درصورتی که ربات سازنده گروه نیست دستور 'تنظیم لینک' را بزنید. 🌐"
			end 
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group link ["..group_link.."]")
			return "🌐 لینک گروه 🌐 :\n"..group_link
		end

		if matches[1] == "invite"or matches[1] =='دعوت' and is_sudo(msg) then
			local cbres_extra = {
				channel = get_receiver(msg),
				get_cmd = "invite"
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] invited @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		if matches[1] == 'res' and is_owner(msg) then
			local cbres_extra = {
				channelid = msg.to.id,
				get_cmd = 'res'
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] resolved username: @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		--[[if matches[1] == 'kick'or matches[1] =='اخراج' and is_momod(msg) then
			local receiver = channel..matches[3]
			local user = "user#id"..matches[2]
			chaannel_kick(receiver, user, ok_cb, false)
		end]] 

			 if matches[1] == 'setadmin'or matches[1] =='ادمین' then
				if not is_support(msg.from.id) and not is_owner(msg) then
					return
				end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setadmin',
					msg = msg
				}
				setadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'setadmin' and string.match(matches[2], '^%d+$') then
			--[[]	local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'setadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})]]
				local	get_cmd = 'setadmin'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'setadmin'or matches[1] =='ادمین' and not string.match(matches[2], '^%d+$') then
				--[[local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'setadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
				local	get_cmd = 'setadmin'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'demoteadmin'or matches[1] =='عزل ادمین' then
			if not is_support(msg.from.id) and not is_owner(msg) then
				return
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demoteadmin',
					msg = msg
				}
				demoteadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'demoteadmin'or matches[1] =='عزل ادمین' and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demoteadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'demoteadmin'or matches[1] =='عزل ادمین' and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demoteadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted admin @"..username)
				resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'setowner'or matches[1] =='صاحب' and is_owner(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setowner',
					msg = msg
				}
				setowner = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'setowner' and string.match(matches[2], '^%d+$') then
		--[[	local group_owner = data[tostring(msg.to.id)]['set_owner']
				if group_owner then
					local receiver = get_receiver(msg)
					local user_id = "user#id"..group_owner
					if not is_admin2(group_owner) and not is_support(group_owner) then
						channel_demote(receiver, user_id, ok_cb, false)
					end
					local user = "user#id"..matches[2]
					channel_set_admin(receiver, user, ok_cb, false)
					data[tostring(msg.to.id)]['set_owner'] = tostring(matches[2])
					save_data(_config.moderation.data, data)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set ["..matches[2].."] as owner")
					local text = "[ "..matches[2].." ] added as owner"
					return text
				end]]
				local	get_cmd = 'setowner'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'setowner'or matches[1] =='صاحب' and not string.match(matches[2], '^%d+$') then
				local	get_cmd = 'setowner'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		 if matches[1] == 'promote' then
		  if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "Only owner/admin can promote"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'promote',
					msg = msg
				}
				promote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'promote' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'promote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'promote' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'promote',
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'mp' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_set_mod(channel, user_id, ok_cb, false)
			return "ok"
		end
		if matches[1] == 'md' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_demote(channel, user_id, ok_cb, false)
			return "ok"
		end

		if matches[1] == 'demote' then
			if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "Only owner/support/admin can promote"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demote',
					msg = msg
				}
				demote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'demote' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'demote' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demote'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

        if matches[1] == 'ترفیع' then
		  if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "Only owner/admin can promote"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'promote',
					msg = msg
				}
				promote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'ترفیع' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'promote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'ترفیع' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'promote',
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'عزل' then
			if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "Only owner/support/admin can promote"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demote',
					msg = msg
				}
				demote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'عزل' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'عزل' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demote'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == "setname"or matches[1] =="تنظیم اسم" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local set_name = string.gsub(matches[2], '_', '')
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..matches[2])
			rename_channel(receiver, set_name, ok_cb, false)
		end

		if msg.service and msg.action.type == 'chat_rename' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..msg.to.title)
			data[tostring(msg.to.id)]['settings']['set_name'] = msg.to.title
			save_data(_config.moderation.data, data)
		end

		if matches[1] == "setabout"or matches[1] =="تنظیم درباره" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local about_text = matches[2]
			local data_cat = 'description'
			local target = msg.to.id
			data[tostring(target)][data_cat] = about_text
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup description to: "..about_text)
			channel_set_about(receiver, about_text, ok_cb, false)
			return "🖊 درباره گروه تنظیم شد . 🖊"
		end

		if matches[1] == "setusername"or matches[1] =="تنظیم ایدی" and is_admin1(msg) then
			local function ok_username_cb (extra, success, result)
				local receiver = extra.receiver
				if success == 1 then
					send_large_msg(receiver, "SuperGroup username Set.\n\nSelect the chat again to see the changes.")
				elseif success == 0 then
					send_large_msg(receiver, "Failed to set SuperGroup username.\nUsername may already be taken.\n\nNote: Username can use a-z, 0-9 and underscores.\nMinimum length is 5 characters.")
				end
			end
			local username = string.gsub(matches[2], '@', '')
			channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
		end

		 if matches[1] == 'setrules'or matches[1] =='تنظیم قوانین' and is_momod(msg) then
			rules = matches[2]
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group rules to ["..matches[2].."]")
			return set_rulesmod(msg, data, target)
		end

		if msg.media then
			if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set new SuperGroup photo")
				load_photo(msg.id, set_supergroup_photo, msg)
				return
			end
		end
		if matches[1] == 'setphoto'or matches[1] =='تنظیم عکس' and is_momod(msg) then
			data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] started setting new SuperGroup photo")
			return '🖼 لطفا عکس مورد نظر خود را ارسال کنید .🖼'
		end

		if matches[1] == 'clean'or matches[1] =='پاکسازی' then
			if not is_momod(msg) then
				return
			end
			if not is_momod(msg) then
				return "Only owner can clean"
			end
			if matches[2] == 'modlist'or matches[2] =='مدیران' then
				if next(data[tostring(msg.to.id)]['moderators']) == nil then
					return '📋 لیست مدیران خالی بود . 📋'
				end
				for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
					data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned modlist")
				return '📋 لیست مدیران پاکسازی شد . 📋'
			end
			if matches[2] == 'rules'or matches[2] =='قوانین' then
				local data_cat = 'rules'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return "📝 قوانین گروه تنظیم نشده بود . 📝"
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned rules")
				return '📝 قوانین گروه پاکسازی شد . 📝'
			end
			if matches[2] == 'about'or matches[2] =='درباره' then
				local receiver = get_receiver(msg)
				local about_text = ' '
				local data_cat = 'description'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return '🖊 درباره گروه تنظیم نشده بود . 🖊'
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned about")
				channel_set_about(receiver, about_text, ok_cb, false)
				return "🖊 درباره گروه پاکسازی شد . 🖊"
			end
			if matches[2] == 'silentlist'or matches[2] =='لیست سکوت' then
				chat_id = msg.to.id
				local hash =  'mute_user:'..chat_id
					redis:del(hash)
				return "📋 لیست سکوت پاکسازی شد . 📋"
			end
			if matches[2] == 'username' and is_admin1(msg) then
				local function ok_username_cb (extra, success, result)
					local receiver = extra.receiver
					if success == 1 then
						send_large_msg(receiver, "SuperGroup username cleaned.")
					elseif success == 0 then
						send_large_msg(receiver, "Failed to clean SuperGroup username.")
					end
				end
				local username = ""
				channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
			end
		end 

	if matches[2] == "bots"or matches[2] =='ربات ها' and is_momod(msg) then
 	--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked all SuperGroup bots")
 		channel_get_bots(receiver, callback_clean_bots, {msg = msg})
 return "🤖 تمامی ربات ها پاکسازی شد . 🤖"
end

		if matches[1] == 'lock'or matches[1] =='قفل' and is_momod(msg) then
			local target = msg.to.id
			     if matches[2] == 'all'or matches[2] =='همه تنظیمات' then
      	local safemode ={
        lock_group_links(msg, data, target),
		lock_group_tag(msg, data, target),
		lock_group_spam(msg, data, target),
		lock_group_flood(msg, data, target),
		lock_group_arabic(msg, data, target),
		lock_group_membermod(msg, data, target),
		lock_group_rtl(msg, data, target),
		lock_group_tgservice(msg, data, target),
		lock_group_sticker(msg, data, target),
		lock_group_contacts(msg, data, target),
		lock_group_english(msg, data, target),
		lock_group_fwd(msg, data, target),
		lock_group_reply(msg, data, target),
		lock_group_join(msg, data, target),
		lock_group_emoji(msg, data, target),
		lock_group_username(msg, data, target),
		lock_group_fosh(msg, data, target),
		lock_group_media(msg, data, target),
		lock_group_leave(msg, data, target),
		lock_group_bots(msg, data, target),
		lock_group_operator(msg, data, target),
		lock_group_number(msg, data, target),
		lock_group_inline(msg, data, target),
		lock_group_cmds(msg, data, target),
      	}
      	return lock_group_all(msg, data, target), safemode
      end

			if matches[2] == 'links'or matches[2] =='لینک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_links(msg, data, target)
			end
			if matches[2] == 'join'or matches[2] =='اعضا' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked join ")
				return lock_group_join(msg, data, target)
			end
			if matches[2] == 'tag'or matches[2] =='تگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked tag ")
				return lock_group_tag(msg, data, target)
			end			
			if matches[2] == 'spam'or matches[2] =='اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked spam ")
				return lock_group_spam(msg, data, target)
			end
			if matches[2] == 'flood'or matches[2] =='فلود' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood ")
				return lock_group_flood(msg, data, target)
			end
			if matches[2] == 'arabic'or matches[2] =='فارسی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked arabic ")
				return lock_group_arabic(msg, data, target)
			end
			if matches[2] == 'member'or matches[2] =='ممبر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked member ")
				return lock_group_membermod(msg, data, target)
			end		    
			if matches[2]:lower() == 'rtl'or matches[2] =='راستچین' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked rtl chars. in names")
				return lock_group_rtl(msg, data, target)
			end
			if matches[2] == 'tgservice'or matches[2] =='سیستم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked Tgservice Actions")
				return lock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'sticker'or matches[2] =='استیکر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked sticker posting")
				return lock_group_sticker(msg, data, target)
			end
			if matches[2] == 'contacts'or matches[2] =='مخاطب' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_contacts(msg, data, target)
			end
			if matches[2] == 'strict'or matches[2] =='سختگیرانه' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked enabled strict settings")
				return enable_strict_rules(msg, data, target)
			end
			if matches[2] == 'english'or matches[2] =='انگلیسی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked english")
				return lock_group_english(msg, data, target)
			end
			if matches[2] == 'fwd'or matches[2] =='فوروارد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked fwd")
				return lock_group_fwd(msg, data, target)
			end
			if matches[2] == 'reply'or matches[2] =='ریپلی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked reply")
				return lock_group_reply(msg, data, target)
			end
			if matches[2] == 'emoji'or matches[2] =='شکلک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked emoji")
				return lock_group_emoji(msg, data, target)
			end
			if matches[2] == 'fosh'or matches[2] =='فحش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked fosh")
				return lock_group_fosh(msg, data, target)
			end
			if matches[2] == 'media'or matches[2] =='مدیا' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked media")
				return lock_group_media(msg, data, target)
			end
			if matches[2] == 'username'or matches[2] =='یوزرنیم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked username")
				return lock_group_username(msg, data, target)
			end
			if matches[2] == 'leave'or matches[2] =='خروج' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked leave")
				return lock_group_leave(msg, data, target)
			end
			if matches[2] == 'bots'or matches[2] =='ربات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked bots")
				return lock_group_bots(msg, data, target)
			end
			if matches[2] == 'operator'or matches[2] =='اپراتور' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked operator")
				return lock_group_operator(msg, data, target)
			end
			if matches[2] == 'number'or matches[2] =='شماره' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked number")
				return lock_group_number(msg, data, target)
			end
			if matches[2] == 'inline'or matches[2] =='تبلیغات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked inline")
				return lock_group_inline(msg, data, target)
			end
			if matches[2] == 'cmds'or matches[2] =='دستورات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked cmds")
				return lock_group_cmds(msg, data, target)
			end
		end

		if matches[1] == 'unlock'or matches[1] =='بازکردن' and is_momod(msg) then
			local target = msg.to.id
			     if matches[2] == 'all'or matches[2] =='همه تنظیمات' then
      	local dsafemode ={
        unlock_group_links(msg, data, target),
		unlock_group_tag(msg, data, target),
		unlock_group_spam(msg, data, target),
		unlock_group_flood(msg, data, target),
		unlock_group_arabic(msg, data, target),
		unlock_group_membermod(msg, data, target),
		unlock_group_rtl(msg, data, target),
		unlock_group_tgservice(msg, data, target),
		unlock_group_sticker(msg, data, target),
		unlock_group_contacts(msg, data, target),
		unlock_group_english(msg, data, target),
		unlock_group_fwd(msg, data, target),
		unlock_group_reply(msg, data, target),
		unlock_group_join(msg, data, target),
		unlock_group_emoji(msg, data, target),
		unlock_group_username(msg, data, target),
		unlock_group_fosh(msg, data, target),
		unlock_group_media(msg, data, target),
		unlock_group_leave(msg, data, target),
		unlock_group_bots(msg, data, target),
		unlock_group_operator(msg, data, target),
		unlock_group_number(msg, data, target),
		unlock_group_inline(msg, data, target),
		unlock_group_cmds(msg, data, target),
      	}
      	return unlock_group_all(msg, data, target), dsafemode
      end

			if matches[2] == 'links'or matches[2] =='لینک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_links(msg, data, target)
			end
			if matches[2] == 'join'or matches[2] =='اعضا' then 
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked join")
				return unlock_group_join(msg, data, target)
			end
			if matches[2] == 'tag'or matches[2] =='تگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tag")
				return unlock_group_tag(msg, data, target)
			end			
			if matches[2] == 'spam'or matches[2] =='اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked spam")
				return unlock_group_spam(msg, data, target)
			end
			if matches[2] == 'flood'or matches[2] =='فلود' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == 'arabic'or matches[2] =='فارسی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked Arabic")
				return unlock_group_arabic(msg, data, target)
			end
			if matches[2] == 'member'or matches[2] =='ممبر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked member ")
				return unlock_group_membermod(msg, data, target)
			end                   
			if matches[2]:lower() == 'rtl'or matches[2] =='راستچین' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked RTL chars. in names")
				return unlock_group_rtl(msg, data, target)
			end
				if matches[2] == 'tgservice'or matches[2] =='سیستم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tgservice actions")
				return unlock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'sticker'or matches[2] =='استیکر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked sticker posting")
				return unlock_group_sticker(msg, data, target)
			end
			if matches[2] == 'contacts'or matches[2] =='مخاطب' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_contacts(msg, data, target)
			end
			if matches[2] == 'strict'or matches[2] =='سختگیرانه' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled strict settings")
				return disable_strict_rules(msg, data, target)
			end
			if matches[2] == 'english'or matches[2] =='انگلیسی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked english")
				return unlock_group_english(msg, data, target)
			end
			if matches[2] == 'fwd'or matches[2] =='فوروارد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked fwd")
				return unlock_group_fwd(msg, data, target)
			end
			if matches[2] == 'reply'or matches[2] =='ریپلی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked reply")
				return unlock_group_reply(msg, data, target)
			end
			if matches[2] == 'emoji'or matches[2] =='شکلک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled emoji")
				return unlock_group_emoji(msg, data, target)
			end
			if matches[2] == 'fosh'or matches[2] =='فحش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked fosh")
				return unlock_group_fosh(msg, data, target)
			end
			if matches[2] == 'media'or matches[2] =='مدیا' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked media")
				return unlock_group_media(msg, data, target)
			end
			if matches[2] == 'username'or matches[2] =='یوزرنیم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled username")
				return unlock_group_username(msg, data, target)
			end
			if matches[2] == 'leave' or matches[2] =='خروج' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked leave")
				return unlock_group_leave(msg, data, target)
			end
			if matches[2] == 'bots'or matches[2] =='ربات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked bots")
				return unlock_group_bots(msg, data, target)
			end
			if matches[2] == 'operator'or matches[2] =='اپراتور' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked operator")
				return unlock_group_operator(msg, data, target)
			end
			if matches[2] == 'number'or matches[2] =='شماره' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked number")
				return unlock_group_number(msg, data, target)
			end
			if matches[2] == 'inline'or matches[2] =='تبلیغات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked inline")
				return unlock_group_inline(msg, data, target)
			end
			if matches[2] == 'cmds'or matches[2] =='دستورات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked cmds")
				return unlock_group_cmds(msg, data, target)
			end
		end

		if matches[1] == 'setflood'or matches[1] =='حساسیت' then
			if not is_momod(msg) then
				return
			end
			if tonumber(matches[2]) < 4 or tonumber(matches[2]) > 25 then
				return "📢 حساسیت را باید بین 4 تا 25 انتخاب کنید . 📢"
			end
			local flood_max = matches[2]
			data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set flood to ["..matches[2].."]")
			return '🤖 حساسیت تنظیم شد بر روی :'..matches[2]
		end
		if matches[1] == 'public'or matches[1] =='عمومی' and is_owner(msg) then
			local target = msg.to.id
			if matches[2] == 'yes'or matches[2] =='باشد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: public")
				return set_public_membermod(msg, data, target)
			end
			if matches[2] == 'no'or matches[2] =='نباشد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: not public")
				return unset_public_membermod(msg, data, target)
			end
		end

		if matches[1] == 'mute'or matches[1] =='قفل' and is_momod(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'audio'or matches[2] =='صدا' then
			local msg_type = 'Audio'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "🎤 ارسال صدا در گروه ممنوع شد . 🎤"
				else
					return "🎤 ارسال صدا در گروه ممنوع بود . 🎤"
				end
			end
			if matches[2] == 'photo'or matches[2] =='عکس' then
			local msg_type = 'Photo'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "🖼 ارسال عکس در گروه ممنوع شد . 🖼"
				else
					return "🖼 ارسال عکس در گروه ممنوع بود . 🖼"
				end
			end
			if matches[2] == 'video'or matches[2] =='فیلم' then
			local msg_type = 'Video'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "📽 ارسال فیلم در گروه ممنوع شد . 📽"
				else
					return "📽 ارسال فیلم در گروه ممنوع بود . 📽"
				end
			end
			if matches[2] == 'gifs'or matches[2] =='گیف' then
			local msg_type = 'Gifs'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "🎆 ارسال گیف در گروه ممنوع شد . 🎆"
				else
					return "🎆 ارسال گیف در گروه ممنوع بود . 🎆"
				end
			end
			if matches[2] == 'documents'or matches[2] =='فایل' then
			local msg_type = 'Documents'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "📂 ارسال فایل در گروه ممنوع شد . 📂"
				else
					return "📂 ارسال فایل در گروه ممنوع بود . 📂"
				end
			end
			if matches[2] == 'text'or matches[2] =='متن' then
			local msg_type = 'Text'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "📝 ارسال متن در گروه ممنوع شد . 📝"
				else
					return "📝 ارسال متن در گروه ممنوع بود . 📝"
				end
			end
			if matches[2] == 'all'or matches[2] =='همه' then
			local msg_type = 'All'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "🔐 ارسال محتوا عکس، فیلم، صدا، فایل، گیف و متن ممنوع شد . 🔐"
				else
					return "🔐 ارسال محتوا عکس، فیلم، صدا، فایل، گیف و متن ممنوع بود . 🔐"
				end
			end
		end
		if matches[1] == 'unmute'or matches[1] =='بازکردن' and is_momod(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'audio'or matches[2] =='صدا' then
			local msg_type = 'Audio'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "🎤 ارسال صدا در گروه آزاد شد . 🎤"
				else
					return "🎤 ارسال صدا در گروه آزاد بود . 🎤"
				end
			end
			if matches[2] == 'photo'or matches[2] =='عکس' then
			local msg_type = 'Photo'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "🖼 ارسال عکس در گروه آزاد شد . 🖼"
				else
					return "🖼 ارسال عکس در گروه آزاد بود . 🖼"
				end
			end
			if matches[2] == 'video'or matches[2] =='فیلم' then
			local msg_type = 'Video'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "📽 ارسال فیلم در گروه آزاد شد . 📽"
				else
					return "📽 ارسال فیلم در گروه آزاد بود . 📽"
				end
			end
			if matches[2] == 'gifs'or matches[2] =='گیف' then
			local msg_type = 'Gifs'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "🎆 ارسال گیف در گروه آزاد شد . 🎆"
				else
					return "🎆 ارسال گیف در گروه آزاد بود . 🎆"
				end
			end
			if matches[2] == 'documents'or matches[2] =='فایل' then
			local msg_type = 'Documents'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "📂 ارسال فایل در گروه آزاد شد . 📂"
				else
					return "📂 ارسال فایل در گروه آزاد بود . 📂"
				end
			end
			if matches[2] == 'text'or matches[2] =='چت' then
			local msg_type = 'Text'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute message")
					unmute(chat_id, msg_type)
					return "📝 ارسال متن در گروه آزاد شد . 📝"
				else
					return "📝 ارسال متن در گروه آزاد بود . 📝"
				end
			end
			if matches[2] == 'all'or matches[2] =='همه' then
			local msg_type = 'All'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "🔐 ارسال محتوا عکس، فیلم، صدا، فایل، گیف و متن آزاد شد . 🔐"
				else
					return "🔐 ارسال محتوا عکس، فیلم، صدا، فایل، گیف و متن آزاد بود . 🔐"
				end
			end
		end


		if matches[1] == "silent" or matches[1] =='سکوت' or matches[1] == "unsilent"or matches[1] =='رفع سکوت' and is_momod(msg) then
			local chat_id = msg.to.id
			local hash = "mute_user"..chat_id
			local user_id = ""
			if type(msg.reply_id) ~= "nil" then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				muteuser = get_message(msg.reply_id, get_message_callback, {receiver = receiver, get_cmd = get_cmd, msg = msg})
			elseif matches[1] == "silent"or matches[1] =='سکوت' or matches[1] == "unsilent"or matches[1] =='رفع سکوت' and string.match(matches[2], '^%d+$') then
				local user_id = matches[2]
				if is_muted_user(chat_id, user_id) then
					unmute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed ["..user_id.."] from the muted users list")
					return " ["..user_id.."]➖["..chat_id.."] 📋 از لیست سکوت حذف شد : "
				elseif is_momod(msg) then
					mute_user(chat_id, user_id)
				local mutedhash = 'muted:'..msg.from.id..':'..msg.to.id
        redis:incr(mutedhash)
        local mutedhash = 'muted:'..msg.from.id..':'..msg.to.id
        local muted = redis:get(mutedhash)
	--savelog(msg.to.id, name_log.." ["..msg.from.id.."] added ["..user_id.."] to the muted users list")
					return " ["..user_id.."]➖["..chat_id.."] 📋 به لیست سکوت اضافه شد : "
				end
			elseif matches[1] == "silent"or matches[1] =='سکوت' or matches[1] == "unsilent"or matches[1] =='رفع سکوت' and not string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				resolve_username(username, callbackres, {receiver = receiver, get_cmd = get_cmd, msg=msg})
			end
		end

		if matches[1] == "muteslist"or matches[1] =='لیست مدیا' and is_momod(msg) then
			local chat_id = msg.to.id
			if not has_mutes(chat_id) then
				set_mutes(chat_id)
				return mutes_list(chat_id)
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup muteslist")
			return mutes_list(chat_id)
		end
		if matches[1] == "silentlist"or matches[1] =='لیست سکوت' and is_momod(msg) then
			local chat_id = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup mutelist")
			return muted_user_list(chat_id)
		end

		if matches[1] == 'settings'or matches[1] =='تنظیمات' and is_momod(msg) then
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup settings ")
			return show_supergroup_settingsmod(msg, target)
		end

		if matches[1] == 'rules'or matches[1] =='قوانین' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group rules")
			return get_rules(msg, data)
		end

		if matches[1] == 'helps' and not is_momod(msg) then
			text = "Message /superhelp  in private for SuperGroup help"
			reply_msg(msg.id, text, ok_cb, false)
		elseif matches[1] == 'helps' and is_momod(msg) then
			local name_log = user_print_name(msg.from)
			--savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /superhelp")
			return super_help()


		end

		if matches[1] == 'peer_id' and is_admin1(msg)then
			text = msg.to.peer_id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		if matches[1] == 'msg.to.id' and is_admin1(msg) then
			text = msg.to.id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		--Admin Join Service Message
		if msg.service then
		local action = msg.action.type
			if action == 'chat_add_user_link' then
				if is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Admin ["..msg.from.id.."] joined the SuperGroup via link")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.from.id) and not is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Support member ["..msg.from.id.."] joined the SuperGroup")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
			if action == 'chat_add_user' then
				if is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Admin ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.action.user.id) and not is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Support member ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
		end
		if matches[1] == 'msg.to.peer_id' then
			post_large_msg(receiver, msg.to.peer_id)
		end
	end
end

local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end
  return msg
end

return {
  patterns = {
	"^([Aa]dd)$",
	"^([Rr]em)$",
	"^([Mm]ove) (.*)$",
	"^([Gg]pinfo)$",
	"^([Aa]dmins)$",
	"^([Oo]wner)$",
	"^([Mm]odlist)$",
	"^([Bb]ots)$",
	"^(مدیران)$",
	"^(نصب)$",
	"^(حذف شو)$",
	"^(اطلاعات گروه)$",
	"^(ادمین ها)$",
	"^(ایدی صاحب)$",
	"^(لیست مدیران)$",
	"^(ربات ها)$",
        "^(درباره)$",
	"^([Ww]ho)$",
	"^([Kk]icked)$",
        "^([Bb]lock) (.*)",
	"^([Bb]lock)",
	"^([Kk]ick) (.*)",
	"^([Kk]ick)",
	"^([Tt]osuper)$",
	"^([Ii][Dd])$",
	"^([Ii][Dd]) (.*)$",
	"^([Kk]ickme)$",
	"^([Nn]ewlink)$",
	"^([Ss]etlink)$",
	"^([Ll]ink)$",
	"^([Rr]es) (.*)$",
	"^([Ss]etadmin) (.*)$",
	"^([Ss]etadmin)",
	"^([Dd]emoteadmin) (.*)$",
	"^([Dd]emoteadmin)",
	"^([Ss]etowner) (.*)$",
	"^([Ss]etowner)$",
	"^([Pp]romote) (.*)$",
	"^([Pp]romote)",
	"^([Dd]emote) (.*)$",
	"^([Dd]emote)",
	"^([Ss]etname) (.*)$",
	"^([Ss]etabout) (.*)$",
	"^([Ss]etrules) (.*)$",
	"^([Ss]etphoto)$",
	"^(ادمین) (.*)$",
	"^(ادمین)",
	"^(عزل ادمین) (.*)$",
	"^(عزل ادمین)",
	"^(صاحب) (.*)$",
	"^(صاحب)$",
	"^(ترفیع) (.*)$",
	"^(ترفیع)",
	"^(عزل) (.*)$",
	"^(عزل)",
	"^(تنظیم اسم) (.*)$",
	"^(تنظیم درباره) (.*)$",
	"^(تنظیم قوانین) (.*)$",
	"^(تنظیم عکس)$",
	"^(افراد)$",
	"^(اخراجی ها)$",
        "^(بن) (.*)",
	"^(بن)",
	"^(اخراج) (.*)",
	"^(اخراج)",
	"^(تبدیل)$",
	"^(ایدی)$",
	"^(ایدی) (.*)$",
	"^(لینک جدید)$",
	"^(تنظیم لینک)$",
	"^(لینک)$",
        "^([Ss]etusername) (.*)$",
	"^(تنظیم ایدی) (.*)$",
	"^([Dd]el)$",
	"^(پاک)$",
	"^([Ll]ock) (.*)$",
	"^(قفل) (.*)$",
	"^(بازکردن) (.*)$",
	"^([Uu]nlock) (.*)$",
	"^([Mm]ute) ([^%s]+)$",
	"^([Uu]nmute) ([^%s]+)$",
	"^(قفل) ([^%s]+)$",
	"^(بازکردن) ([^%s]+)$",
	"^([Ss]ilent)$",
	"^([Ss]ilent) (.*)$",
	"^([Uu]nsilent)$",
	"^([Uu]nsilent) (.*)$",
	"^([Pp]ublic) (.*)$",
	"^(عمومی) (.*)$",
	"^([Ss]ettings)$",
	"^([Rr]ules)$",
	"^(سکوت)$",
	"^(سکوت) (.*)$",
	"^(رفع سکوت)$",
	"^(رفع سکوت) (.*)$",
	"^(تنظیمات)$",
	"^(قوانین)$",
	"^([Ss]etflood) (%d+)$",
        "^(حساسیت) (%d+)$",
	"^([Cc]lean) (.*)$",
	"^(پاکسازی) (.*)$",
	"^([Hh]elps)$",
	"^([Mm]uteslist)$",
	"^([Ss]ilentlist)$",
	"^(لیست مدیا)$",
	"^(لیست سکوت)$",
	"^(تمديد) (.*)$",
	"^(تاريخ انقضا)$",
        "(mp) (.*)",
	"(md) (.*)",
        "^(https://telegram.me/joinchat/%S+)$",
	"%[(document)%]",
	"%[(photo)%]",
	"%[(video)%]",
	"%[(audio)%]",
	"%[(contact)%]",
	"^!!tgservice (.+)$",
  },
  run = run,
  pre_process = pre_process 
}
