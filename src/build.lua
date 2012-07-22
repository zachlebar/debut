#!/usr/bin/lua

-- DEBUT BUILD SCRIPT
-- 
-- Dynamically generate an HMTL files from parts found in partials/
--
-- USAGE: ./build.lua
-- 
-- METHODOLOGY: within partials/ are subfolders, each representing
-- a page to be built. Special exception being what's found in 
-- all/. Those files will be applied to every page.
-- 

-- FUNCTION: parse_map("path/to/map.lua")
-- Used to dynamically build pages based on layout information in
-- the associated map file.
function parse_map(map)
	local t = {}
	local f = io.open(map, "r")
	while true do
		local line = f:read("*line")
		if not line then break end
		t[#t+1] = string.match(line, "%S+")
	end
	
	return t
end

-- FUNCTION: fetch_pages("/path/to/pages/src/dir")
-- Crawl through source directory and create table elements
-- for each folder found (each one will become a page).
function fetch_pages(dir) 
	local t = {}
	
	local f = io.popen("ls "..dir)
	while true do
		local line = f:read("*line")
		if not line then break end
		if line ~= "all" then
			t[line] = ""
		end
	end
	f:close()

	return t
end

-- code that will appear on all pages, building block of future pages
function parse_all_pages_code(src_dir, map_flag)
	local t = {}
	local t_map = parse_map(src_dir.."/all/map.lua")

	for i,part in ipairs(t_map) do
		t[part] = io.open(src_dir.."/all/"..part..".part.html", "r")
		if t[part] ~= nil then
			t[part] = t[part]:read("*all")
		else
			t[part] = ""
		end
	end

	if map_flag then
		return t_map
	else
		return t
	end
end

function build_pages(p_table)
	for k,v in pairs(p_table) do
		local t = {}
		local t_map = parse_map("partials/"..k.."/map.lua")

		local f = io.popen("ls partials/"..k)
		while true do
			local line = f:read("*line")
			if not line then break end
			if line ~= "map.lua" then
				t[line] = ""
			end
		end
		f:close()
		
		for a,b in pairs(t) do
			local g = io.open("partials/"..k.."/"..a, "r")
			t[a] = g:read("*all")
		end

		local all = parse_all_pages_code("partials")

		for i,v in ipairs(t_map) do
			all.body = all.body..t[v..".part.html"]
		end

		p_table[k] = all
	end

	return p_table
end

-------------------------------------------------------------------------------------------------------------------

local pages = fetch_pages("partials")
local pages = build_pages(pages)
local map = parse_all_pages_code("partials", true)

for page,data in pairs(pages) do
	for order,part in ipairs(map) do
		print(data[part])
	end
end
