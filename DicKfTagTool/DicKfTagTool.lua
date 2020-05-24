local tr = aegisub.gettext
script_name = tr"DicKfTagTool"
script_description = tr"average kf timing based on NLP split"
script_author = "chenKyulin based by SuJiKiNen code"
script_version = "1"
script_created = "2016/03/09"
script_last_updated = "2020/05/01"

local SLAXML = require 'slaxdom' 
local ffi = require('ffi')
local mecab = ffi.load("MeCabL")

ffi.cdef[[
void mecab_create();
char * mecab_parse(const char * input);
void mecab_free();
void free( void *memblock );
]]

function element_text(el)
  local pieces = {}
  for _,n in ipairs(el.kids) do
    if n.type=='element' then pieces[#pieces+1] = element_text(n)
    elseif n.type=='text' then pieces[#pieces+1] = n.value
    end
  end
  return table.concat(pieces)
end

function get_surface(word)
	for _,n in ipairs (word.el) do
		if n.name == "surface" then
			return element_text(n)
		end
	end
	return ""
end

function auto_time(subs,sel)
	local kf_tag = "\\kf"
	mecab.mecab_create()
	for _,i in ipairs(sel) do
		aegisub.progress.set(i/#sel*100)
		local line = subs[i]
		line.text = string.gsub(line.text," ","　")
		local str_p = ffi.gc(mecab.mecab_parse(line.text),ffi.C.free)
		local xml_str = ffi.string(str_p)
		local doc = SLAXML:dom(xml_str)
		local mecab_result = doc.root
		line.duration = line.end_time - line.start_time
		local av_time = math.floor( line.duration/(#mecab_result.el*10) )
		line.text = ""
		for __,word in ipairs(mecab_result.el) do
			surface = get_surface(word)
			if surface then 
				line.text = line.text..string.format("{%s%d}%s",kf_tag,av_time,surface)
			end
		end
		subs[i] = line
		str_p = nil
	end
	mecab.mecab_free()
end

aegisub.register_macro(script_name, script_description,auto_time)
