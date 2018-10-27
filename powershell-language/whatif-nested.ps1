<#
.DESCRIPTION
Learning the dirty details of powershell. Just how do parameters like -whatif and -confirm work down deep. For example if I pass -whatif to a script or function, do functions called from the top level also get the message?

In other words running this script with -whatif will give the answer
#>

[CmdletBinding(SupportsShouldProcess=$true)]
Param (
    # Give a namne
    [Parameter(Mandatory=$false, Position = 0)]
    [string]
    $Name = "Nobody",

    # Just a string
    [Parameter(Mandatory=$false, Position = 1)]
    [string]
    $Message = "Hello, World!"
)

function New-Message {
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        [string] $Name,
        [string] $Message
    )
    Process {
        $PSCmdlet.ShouldProcess("New-Message says:", "$Message from $Name")
        return [PSCustomObject]@{
            name = $Name
            msg = $Message
        }
    }
}

    
$PSCmdlet.ShouldProcess("$Name says:", $Message)
New-Message $name $message




