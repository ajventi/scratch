# MIT License
# 
# Copyright (c) [2018] [Anthony J. Ventimiglia]
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# See https://blogs.technet.microsoft.com/heyscriptingguy/2014/08/01/ive-got-a-powershell-secret-adding-a-gui-to-scripts/
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true, Position=1)]
    [string] $XamlPath
)

[xml]$Global:xmlWPF = Get-Content -path $XamlPath -Verbose

try {
    Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase, system.windows.forms
} catch {
    "Failed to load WPF Assemblies"
}

$Global:xamGui = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $xmlWPF))

$xmlWPF.SelectNodes("//*[@Name]") | ForEach-Object {
    Set-Variable -Name ($_.Name) -Value $xamGui.FindName($_.Name) -Scope Global
}

