
local function run(msg, matches)
    if matches[1] == "-" and is_sudo(msg) then
text = io.popen("cd plugins && rm "..matches[2]..".lua")
return 'Plugin '..matches[2]..' has been deleted.'
end 
end

return { 
patterns = {
 
'^(-) (.*)$' 
},
run = run,
}
