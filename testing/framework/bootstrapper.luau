--!nocheck
type options = {
	context: any,
}

type set<T> = { T | { T } }

local function testDirectory(dir: set<ModuleScript>, options: options)
	local dirResults = {}

	for _, child in dir do
		if child:IsA("ModuleScript") and child.Name:match("%.spec$") then
			local module = require(child)

			dirResults[child.Name] = {}

			local currentTestCase = dirResults[child.Name]

			for caseName, caseFunction in module do
				local ok, err = pcall(caseFunction, options.context)

				currentTestCase[caseName] = { ok = ok, err = err }
			end
		elseif child:IsA("Folder") then
			dirResults[child.Name] = testDirectory(child:GetChildren(), options)
		end
	end

	return dirResults
end

local function isSuccessful(folder)
	local numOfFails = 0
	local numOfSuccess = 0

	for _, value in folder do
		if value.ok ~= nil then
			if value.ok then
				numOfSuccess += 1
			else
				numOfFails += 1
			end
		else
			local wins, fails = isSuccessful(value)
			numOfSuccess += wins
			numOfFails += fails
		end
	end

	return numOfSuccess, numOfFails
end

local function readiyDirectory(dir, spaceStr)
	local finalString = ""

	for name, value in dir do
		if value.ok ~= nil then
			local marker = value.ok and "+" or "-"
			finalString ..= "\n"
			finalString ..= spaceStr .. string.format("[%s] ", marker)
			finalString ..= name
		else
			local _, fails = isSuccessful(value)
			local marker = fails > 0 and "-" or "+"
			finalString ..= "\n"
			finalString ..= spaceStr .. string.format("[%s] ", marker)
			finalString ..= name
			finalString ..= readiyDirectory(value, spaceStr .. "  ")
		end
	end

	return finalString
end

local function readifyDirectoryErrs(dir)
	local finalString = ""

	for _, value in dir do
		if value.ok ~= nil then
			if value.ok == false then
				finalString ..= "\n"
				finalString ..= value.err
			end
		elseif typeof(value) == "table" then
			finalString ..= readifyDirectoryErrs(value)
		end
	end

	return finalString
end

local bootstrapper = {}

function bootstrapper:start(configuration: { directories: { Instance }, options: options })
	local testResults = {}

	for _, directory in configuration.directories do
		testResults[directory.Name] = testDirectory(directory:GetChildren(), configuration.options)
	end

	print(testResults)

	local finalString = "\nTesting results"

	for dirName, dirValue in testResults do
		finalString ..= "\n "
		finalString ..= "[!] " .. dirName
		finalString ..= readiyDirectory(dirValue, "    ")
	end

	print(finalString)

	local errMessage = ""

	for _, dirValue in testResults do
		errMessage ..= readifyDirectoryErrs(dirValue)
	end

	if #errMessage > 2 then
		error(errMessage, 0)
	end
end
return bootstrapper
