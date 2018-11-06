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

<#
.SYNOPSIS
    Developer helper script to install modules from a development path into a real module location.
#>

[CmdletBinding(SupportsShouldProcess=$true)]

Param (
    [Parameter(Mandatory=$true)]
    [string]
    $modulePath,

    [Parameter(Mandatory=$true)]
    [ValidateSet("install", "remove", "update")]
    [string]
    $operation
)

if ( Test-Path -Path $modulePath -PathType Leaf ) {
    $moduleFiles = @(get-item $modulePath)
    $moduleDirName = $moduleFiles[0].Directory.name
} elseif ( Test-Path -Path $modulePath -PathType Container ) {
    $moduleFiles = (get-childItem -Path $modulePath -File).FullName
    $moduleDirName = $modulePath
}

$installPath = "$HOME\Documents\WindowsPowerShell\Modules\$moduleDirName"
if ( !(Test-Path -Path $installPath -PathType Container) -and
     ($PSCmdlet.ShouldProcess(
        "Module Directory $installPath does not exist, create?"))) {
        New-Item -Path $installPath -ItemType Directory
} 

# I am dumb, so I will just install / remove / update everything in the diresctory for now

switch ($operation) {
    "install" { 
        $moduleFiles | ForEach-Object { 
            if ($PSCmdlet.ShouldProcess("Copy $_ to $installPath")) {
                Copy-Item -Path $_ -Destination $installPath
            }
        }
        break 
    }
    "remove" { 
        write-error "Not yet implemented"
        break 
    }
    "update" { 
        Write-Error "Not Yet Implemented"
        break 
    }
}

