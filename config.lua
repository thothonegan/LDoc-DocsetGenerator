--
-- Configuration : edit as needed
--
return {
	-- TOOLS
	
	-- Fill in how to run ldoc, if its not in path
	ldoc = "ldoc",
	ldocExtraArgs = {}, -- any extra arguments you want to pass to ldoc
	
	-- How to run the sqlite3 commandline tool
	sqlite3 = "sqlite3",

	-- Paths - must be absolute
	inputDir = "",
	outputDir = "",

	-- Information - will be inserted into the docset
	docsetIdentifier = "", -- generally reverse dns, uniquely identifies a docset
	docsetName = "", -- displayed name
	docsetPlatformFamily = "", -- used for search prefixes
	
	-- [optional] should be a path to a 32x32 pixel PNG icon, or a 16x16 icon. If nil we ignore.
	docsetIcon = nil
}
