[CmdletBinding()]
Param()

./load-gui.ps1 -Xamlpath '.\first-gui.xaml' -verbose

$button1.add_Click({
    $Label1.Content = "Hello World"
})

$xamGui.ShowDialog() | Out-Null
