# See https://blogs.technet.microsoft.com/heyscriptingguy/2014/08/01/ive-got-a-powershell-secret-adding-a-gui-to-scripts/

try {
    Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase, system.windows.forms
} catch {
    "Failed to load WPF Assemblies"
}

[xml]$xmlWPF = Get-Content -path "first-gui.xaml"

$gui = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $xmlWPF))

$xmlWPF.SelectNodes("//*[@Name]") | ForEach-Object {
    Set-Variable -Name ($_.Name) -Value $gui.FindName($_.Name) -Scope Global
}

