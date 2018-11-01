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

