using System.Diagnostics;
using System.IO.Enumeration;

var consoleArguments = Environment.GetCommandLineArgs();

if (consoleArguments.Length < 2)
{
    Console.Error.WriteLine("Usage: SyncthingWindowsLauncher.exe <executable> [arguments...]");
    Environment.Exit(-1);
}

string program = "cmd.exe";
var arguments = consoleArguments[1..]
    .Prepend("/c").ToArray();

if (File.Exists(arguments[1]))
{
    program = Path.GetFullPath(arguments[1]);
    arguments = arguments[2..];
}

var processInfo = new ProcessStartInfo
{
    FileName = program,
    Arguments = string.Join(" ", arguments),
    CreateNoWindow = arguments.Contains("--no-console"),
    WindowStyle = ProcessWindowStyle.Hidden,
    UseShellExecute = false
};

try
{
    using var process = Process.Start(processInfo);

    if (process is null)
    {
        Console.Error.WriteLine("Failed to start process.");
        Environment.Exit(-1);
    }
}
catch (Exception ex)
{
    Console.Error.WriteLine($"Error: {ex.Message}");
    Environment.Exit(-1);
}