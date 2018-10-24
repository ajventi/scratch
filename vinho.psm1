
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
        [Parameter(Mandatory = $false)]
        [string]
        $database,
        # User name
        [Parameter(Mandatory = $false)]
        [string]
        $uid,
        # Optional config file for database and uid
        [Parameter (Mandatory = $false)]
        [string]
        $IdFile
    )

    Process {

        # Ensure we have valid database and uid
        # Look for config files
        $Conn = New-Object System.Data.Odbc.OdbcConnection
        $Conn.ConnectionString = "Driver={PostgreSQL UNICODE(x64)};database=$database;uid=$uid;"
        if ($PSCmdlet.ShouldProcess("Connect to DB", "foo:$Conn.ConnectionString")) {
            $Conn.Open()
            return $Conn
        } else { return $false }
    }
}

Export-ModuleMember -Function New-DBConnection
