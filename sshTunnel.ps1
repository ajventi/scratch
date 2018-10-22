<#
.SYNOPSIS
    Control SSH Tenneling to remote Server
.DESCRIPTION
    Uses Linux bash to establish SSH tunnel.
.PARAMETER command 
    must be one of START, STOP, RESTART OR STATUS
.PARAMETER RemotePort 
    Remote port to forward to loacl computer Default is 5432
.PARAMETER LocalPort
    Local Port for forwarding Default 5432
.PARAMETER RemoteHost
    DEFAULT is vinho
#>

## TODO:
# Manipulate desktop shortcut

[CmdletBinding()]
param (
    [string]$command="status",
    [int]$RemotePort=5432,
    [int]$LocalPort=5432,
    [string]$RemoteHost="vinho"
)

# The wrapper to the bash script
# $validCommand = ("start","stop","restart","status") -contains $command
# if ($validCommand) { 
#     bash -c "/home/ajventi/pgtunnel $command"
# } else {
#     Write-Output "INVALID COMMAND $validCommand $command"
# }

# Doing it in powershell:

$TunnelCmd="ssh -fTNL localhost:${LocalPort}:localhost:${RemotePort} $RemoteHost"

function get-TunnelStatus {
    Get-Process | Where-Object { $_.ProcessName -eq "ssh" }
}


switch ($command) {
    "start" { 
        bash -c $TunnelCmd
        Write-Output "Opened Tunnel to $RemoteHost on port $LocalPort"
    }
    "stop"  {
        $proc = get-TunnelStatus
        if ($null -ne $proc) { 
            $proc.kill()
        }
        Write-Output "Tunnel is closed"
    }
    "restart" {
        # I guess this is where other functions are needed
        Write-Debug "restart" 
    }
    "status" { 
        $proc = get-TunnelStatus 
        if ( $null -eq $proc ) {
            Write-Output "Tunnel is not running"
        } else {
            $id = $proc.Id
            Write-Output "Tunnel is running Id: $id"
        }
    }
    default { Write-Output "INVALID COMMAND"}
}