local datebase = {
"😇 آنلاینم کارم داشتی 😉",
""
  }
local function run(msg, matches) 
 send_document(get_receiver(msg), "/root/telediamond/data/sticker.webp", ok_cb, false)
return datebase[math.random(#datebase)]
end
return {
  patterns = {
   "^انلاینی",
  },
  run = run
}

