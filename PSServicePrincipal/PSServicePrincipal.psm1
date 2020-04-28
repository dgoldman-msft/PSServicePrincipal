# This will call GetChild item on the script root path (chained specifically to the Functions folder) to only find items here and scoped to ps1 files
$functions = Get-ChildItem -Path $PSScriptRoot\Functions -Recurse -Filter *.ps1

foreach($item in $functions)
{
	# This will loop through all items and load them from the full path
	. $item.FullName
}

$files = Get-ChildItem -Path $PSScriptRoot\Scripts -Recurse -Filter *.ps1

foreach($item in $files)
{
	# This will loop through all items and load them from the full path
	. $item.FullName
}