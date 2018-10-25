
<#
.DESCRIPTION
    Working with the vinho database.
#>

<#
TODO: 
* give option for User profile file to store database and uid info
#>

function New-DBConnection {
    <#
    .SYNOPSIS
        Create, open and return a new connection
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([System.Data.Odbc.OdbcConnection])]
    Param (
        # Database name
        [Parameter(Mandatory = $true,
            ParameterSetName = "Common")]
        [ValidateNotNull()]
        [string]
        $database,

        # User name
        [Parameter(Mandatory = $true,
            ParameterSetName = "Common")]
        [ValidateNotNull()]
        [string]
        $uid,

        # Optional config file for database and uid
        [Parameter (Mandatory = $true,
            ParameterSetName = "ConfigFiles")]
        [string]
        $IdFile
    )

    Begin {
        # determine database and username
        if (($IdFile -ne $null) -and (Test-Path -Path $IdFile -PathType Leaf)) {
            write-debug "Reading login information from $IdFile"
            $args = Get-Content -Path $IdFile | ConvertFrom-Json
            $database = $args.database
            $uid = $args.uid
        }
        # Maybe oneday have something like a .vinho file 
    }

    Process {
        $Conn = New-Object System.Data.Odbc.OdbcConnection
        $cs = "Driver={PostgreSQL UNICODE(x64)};database=$database;uid=$uid;"
        if ($PSCmdlet.ShouldProcess("Connect to DB", $cs)) {
            trap {
                "OdbcConnection Error: $_" 
                break
            }
            $Conn.ConnectionString = $cs
            $Conn.Open()
            return $Conn
        } 
        return $false 
    }
}


#Export-ModuleMember -Function New-DBConnection
