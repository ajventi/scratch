<#
MIT License

Copyright (c) [2018] [Anthony J. Ventimiglia]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
>#


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
