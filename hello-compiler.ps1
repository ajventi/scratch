

$source = @"
    using System;
    class Hello {
        static void Main() {
            Console.WriteLine("Hello, World!");
        }
    }
"@
Add-Type -TypeDefinition $source -Language CSharp -OutputAssembly "hello.exe" -OutputType ConsoleApplication
