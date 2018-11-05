
[CmdLetBinding(SupportsShouldProcess=$true)]
Param ()

$OneDrivePath = "$HOME/OneDrive"

$fileCSV = @"
path, destination
$HOME/.vim/vimrc, vimrc
$HOME/.config/powershell/profile.ps1, profile.ps1
$HOME/src/Publish-OneDriveFiles.ps1, Publish-OneDriveFiles.ps1
$HOME/src/ado.net/DataSetTo-XML.ps1, DataSetTo-XML.ps1
"@

$fileCSV | ConvertFrom-CSV | ForEach-Object {
	if (Test-Path $_.path) {
		$LocalFile = Get-Item $_.path
		$ODPath = Join-Path $OneDrivePath $_.destination
		$copy = ! (Test-Path $ODPath) 
		if (! $copy) {
			$ODFile = Get-Item $ODPath
			$copy = $ODFile.LastWriteTime -lt $LocalFile.LastWriteTime
			if (! $copy) { Write-Verbose "$($_.destination) is already up-to-date" } 
		} 
		$msg = "Copy: $($_.path) to $($_.destination)"
		if ($copy -and $PSCmdlet.ShouldProcess($msg)) {
			#Write-Verbose $msg
			Copy-Item $LocalFile $ODPath
		}
	} else {
		Write-Error "$_.path not found"
	}
}
