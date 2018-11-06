# MIT License
# 
# Copyright (c) [2018] [Anthony J. Ventimiglia]
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
