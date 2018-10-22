# How to get command line arguments
# Should be start|stop|restart|status
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
        if ($proc -ne $NULL) { 
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
        if ($proc -eq $Null) {
            Write-Output "Tunnel is not running"
        } else {
            $id = $proc.Id
            Write-Output "Tunnel is running Id: $id"
        }
    }
    default { Write-Output "INVALID COMMAND"}
}


# function open_tunnel {
#     $TUNNEL && \
# 	echo "Opened ssh postgresql Tunnel to $HOST on port $LOCAL_PORT"
# }

# function close_tunnel {
#     kill $PID && echo "closed ssh tunnel to $HOST on port $LOCAL_PORT"
# }

