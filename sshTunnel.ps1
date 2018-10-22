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

# These should be parameters ...
# $RemotePort = 5432
# $LocalPort = $RemotePort
# $RemoteHost = "vinho"
$TunnelCmd="ssh -fTNL localhost:${LocalPort}:localhost:${RemotePort} $RemoteHost"


# function check_status {
#     PID=`ps aux | grep "$TUNNEL" | grep -v 'grep' | awk '{print $2}'`
# }

function get-TunnelStatus (){
    Get-Process | Where-Object { $_.ProcessName -eq "ssh" }
}

switch ($command){
    "start" { Write-Output "start" }
    "stop"  { Write-Output "Stop" }
    "restart" { Write-Output "restart" }
    "status" { 
        $proc = get-TunnelStatus(1) #Why do I have to pass $Null?
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

