#!/usr/bin/env lua

-- See https://kapeli.com/docsets#dashDocset for the basic idea

-- NOTE: If you're using luarocks, make sure you ran 'eval $(luarocks path --bin)' if needed

Config = require ('config')

pl = require ('pl.import_into')() -- this should be a dep of ldoc. If you error, make sure its installed properly.

-- Template isnt in the autoloader for some reason, so load it manually
pl.template = require ('pl.template')

pl.stringx.import() -- add our string functions

-- setup locations
ldocOutputPath = Config.outputDir .. "/ldoc/"
docsetCompressed = Config.outputDir .. "/" .. Config.docsetIdentifier .. ".docset.tgz"
docsetRoot = Config.outputDir .. "/" .. Config.docsetIdentifier .. ".docset"
docsetContentRoot = docsetRoot .. "/Contents/Resources/Documents/"

-- Lets write this in lua just cause

-- First, check that our tools exist
-- TODO


print (">> Cleaning output dir ")
if pl.path.isdir(ldocOutputPath) then pl.dir.rmtree (ldocOutputPath) end
if pl.path.isdir(docsetRoot) then pl.dir.rmtree (docsetRoot) end

print (">> Running ldoc")

outputArgs = "-d " .. ldocOutputPath
extraArgs = (' '):join (Config.ldocExtraArgs)
ldocWithoutOutput = Config.ldoc .. " " .. extraArgs .. " " .. Config.inputDir
ldocFull = ldocWithoutOutput .. " " .. outputArgs

print ("-- " .. ldocFull)
res = pl.utils.execute(ldocFull)

if not res then error ("Error when running ldoc") end

print (">> Setting up docset structure")

res, err = pl.dir.makepath (docsetContentRoot)
if not res then error ("Error when creating docset path : " .. err) end

print (">> Copying over html")
pl.dir.clonetree (Config.outputDir .. "/ldoc", docsetContentRoot,
	function(input, output) -- called on each file
		pl.file.copy(input, output)
		return true
	end,
	true -- verbose
)


print (">> Setting up Info.plist")
local scriptDir = pl.path.dirname(arg[0])
 
tmpl = pl.file.read(scriptDir .. "/templates/Info.plist.tmpl")
tmplDone, err = pl.template.substitute (tmpl, {
	Config = Config
})

if tmplDone == nil then error ("Error when subsituting: " .. err) end

pl.file.write (docsetRoot .. "/Contents/Info.plist", tmplDone)

print (">> Setting up SQLite database")
sqlDB = docsetRoot .. "/Contents/Resources/docSet.dsidx"

function runSQL (sql)

	res = pl.utils.execute (Config.sqlite3 .. " " .. sqlDB .. " " .. "\"" .. sql .. "\"")
	if not res then
		error ("Error when running sqlite3")
	end
end

runSQL("CREATE TABLE searchIndex (id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT)")
runSQL("CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path)")

print (">> Populating SQLite database")

-- get all the data as lua data

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

function p_insertIntoDB (name, typeName, path)
	runSQL ("INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('" .. name .. "', '" .. typeName .. "', " .. "'" .. path .. "')")
end

-- process a module
function p_handleModule (moduleInfo)
	local moduleName = moduleInfo.name
	local path = "ldoc/modules/" .. moduleName .. ".html"

	p_insertIntoDB (moduleName, "Module", path)

	-- now look at its children
	for index,child in pairs(moduleInfo.items) do
		local childName = child.name
		local childType = child.type

		if childType == "function" then
			p_insertIntoDB (childName, "Function", path .. "#" .. childName)
		elseif childType == "field" then
			p_insertIntoDB (childName, "Field", path .. "#" .. childName)
		elseif childType == "table" then
			p_insertIntoDB (childName, "Struct", path .. "#" .. childName) -- not sure what would be better
		else
			print ("WW Unknown child type to index: " .. childType)
		end
	end
end

-- this is lua, so we can parse it ourself
output = os.capture(ldocWithoutOutput .. " --filter pl.pretty.dump")
chunk,err = pl.utils.load("ldocResult = " .. output, "ldoc")
if not chunk then
	print ("!!!!!!! An error occured when asking ldoc for its actual data (loadchunk).")
	print ("!!!!!!! Docset wont have any information about functions or be searchable.")
	print ("!!!!!!! Error was: " .. err)
else
	status, err = pcall(chunk)
	if status then
		-- ldocResult now has the parsed information
		for index, moduleInfo in pairs(ldocResult) do
			p_handleModule(moduleInfo)
		end
	else
		print ("!!!!!!! An error occured when asking ldoc for its actual data.")
		print ("!!!!!!! Docset wont have any information about functions or be searchable.")
		print ("!!!!!!! Error was: " .. err)
	end
end

-- TODO: print (">> Adding Table Of Contents support")

if Config.docsetIcon then
	print (">> Adding custom icon")
	pl.file.copy (Config.docsetIcon, docsetRoot .. "/icon.png")
end

print (">> Creating archived version for use in docfeeds")
archiveCommand = "cd " .. docsetRoot .. "/.. " .. " && tar --exclude='.DS_Store' -cvzf " .. docsetCompressed .. " " .. Config.docsetIdentifier .. ".docset"
pl.utils.execute (archiveCommand)

