--
-- Configuration : edit as needed
--
return {
	-- TOOLS
	ldoc = "/home/thothonegan/.luarocks/bin/ldoc",
	ldocExtraArgs = { 
		"-f", "markdown",
		"-s", "/home/thothonegan/Hackerguild/Source/Endless@master/Documentation/LDoc/",
		"-p", "Endless"
	},
	sqlite3 = "sqlite3",

	-- Paths
	inputDir = "/home/thothonegan/Hackerguild/Source/Endless@master/Endless/Resources/Endless.tek/Scripts/",
	outputDir = "/home/thothonegan/out/",

	-- Information
	docsetIdentifier = "com.hackerguild.endless.lua",
	docsetName = "Endless-Lua",
	docsetPlatformFamily = "endless-lua",
	docsetIcon = "/home/thothonegan/Hackerguild/Source/Endless@master/logo.png"
}

