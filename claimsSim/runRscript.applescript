-- runs an R script.
on runRScriptHandler(input)
	set oldDelims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "|"
	
	-- rscript path is the path to your Rscript installation
	-- scriptPath is the pathe to the R script that you want to run
	-- params is the params string to pass to the script	
	set rscriptPath to text item 1 of input
	set scriptPath to text item 2 of input
	set params to text item 3 of input
	
	set AppleScript's text item delimiters to oldDelims
	
	do shell script rscriptPath & " " & scriptPath & " " & params
end runRScriptHandler