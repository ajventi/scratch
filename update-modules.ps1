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

