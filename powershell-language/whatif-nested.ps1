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




