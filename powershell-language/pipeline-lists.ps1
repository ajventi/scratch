<#
This script is an attempt to reproduce a strange "feature"

Namely I am working on a funtion that is returning tables for SQL queries.
Each query returns an array of hash tables representing a table.

Sent through a pipeline all the arrays from separate commands are being returned as a single array
#>

function New-ListFromPipeline {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        $InputString
    )

    Begin {
        $Count = 1
        $tables = @()
    }

    Process {
        # Make some sort of Table
        $table = @()
        for ($i=0; $i -lt $Count; $i++) {
            $table += @{ num = $i + $Count; val = $_ }
        }
        $Count++
        Write-Verbose "Table Length: $($table.length) :: $($table)"
        # return @($table)
        # Let's try making an object
        # return [PSCustomObject]@{
        #     Name = $InputString
        #     rows = $table
        # }
        # I think this is it!

        # The '+' operator is the problem, so we have to append like this:
        $tables += $null 
        $tables[$table.length-1]=$table
    }

    End {
        return $tables
    }
}