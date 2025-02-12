-- Runs an R script and returns errors if any occur
on runRScriptHandler(input)
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "|"
	
	-- rscript path is the path to your Rscript installation
	-- scriptPath is the pathe to the R script that you want to run
	-- params is the params string to pass to the script	
	
	-- Extract parameters from VBA
	set rscriptPath to text item 1 of input
	set scriptPath to text item 2 of input
	set params to text item 3 of input
	
	set AppleScript's text item delimiters to oldDelims
	
	-- Construct the shell command (stderr redirected)
	set shellCommand to rscriptPath & " " & scriptPath & " " & params & " 2>&1"
	
	try
		-- Run the command and capture output
		set output to do shell script shellCommand
	on error errorMessage
		-- Return the error message instead
		return "ERROR caught in applescript: " & errorMessage & "ERROR"
	end try
	
	return output
end runRScriptHandler
