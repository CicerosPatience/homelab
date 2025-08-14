using System.Diagnostics;

var arguments = Environment.GetCommandLineArgs();

if (arguments.Length < 2)
{
    Console.Error.WriteLine("Usage: SyncthingWindowsLauncher <executable> [arguments...]");
    Environment.Exit(-1);
}

string program = Path.GetFullPath(arguments[1]);

if (!File.Exists(program))
{
    Console.Error.WriteLine($"Executable not found: {program}");
    Environment.Exit(-1);
}

var processInfo = new ProcessStartInfo
{
    FileName = program,
    WorkingDirectory = Path.GetDirectoryName(program),
    Arguments = string.Join(" ", arguments[2..]),
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