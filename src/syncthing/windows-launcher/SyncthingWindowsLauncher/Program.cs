using System.Diagnostics;
using System.IO.Enumeration;

var arguments = Environment.GetCommandLineArgs();

if (arguments.Length < 2)
{
    Console.Error.WriteLine("Usage: SyncthingWindowsLauncher <executable> [arguments...]");
    Environment.Exit(-1);
}

string program = Path.GetFullPath(arguments[1]);
arguments = arguments[2..];

if (!File.Exists(program))
{
    // asummwe the command is in PATH
    program = "cmd.exe";
    arguments = arguments.Prepend("syncthing").ToArray();
}

var processInfo = new ProcessStartInfo
{
    FileName = program,
    WorkingDirectory = Path.GetDirectoryName(program),
    Arguments = string.Join(" ", arguments),
    CreateNoWindow = arguments.Contains("--no-console"),
    WindowStyle = ProcessWindowStyle.Hidden,
    UseShellExecute = false
};

try
{
    using var process = Process.Start(processInfo);

    if (process is not null)
    {
        await process.WaitForExitAsync();
        Environment.Exit(process.ExitCode);
    }
    else
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