using System.Text.RegularExpressions;

namespace TMake;

internal static class Program
{
    private const string ReleasePath = "./release";
    private static readonly Dictionary<string, Stack<string>> MakeData = new();
    private static readonly HashSet<string> RenameCache = new();

    private static string _makeFilePath = "./TMakeList.txt";

    private static void Main(string[] args)
    {
        try
        {
            var fullPath = Path.GetFullPath("./");
            if (args.Length > 0)
            {
                if (File.Exists(args[0])) _makeFilePath = args[0];
                else if (args[0].Trim().StartsWith('-'))
                {
                    _makeFilePath = "./release/unpack/TMakeList.txt";
                    Console.WriteLine("Start to unpack");
                    UnpackFile();
                    return;
                }
            }

            if (!File.Exists(_makeFilePath)) throw new Exception($"Failure to find makeFile in path: '{_makeFilePath}'");
            using var makeFile = File.OpenRead(_makeFilePath);
            using var makeStream = new StreamReader(makeFile);

            var curFile = string.Empty;
            while (!makeStream.EndOfStream)
            {
                var line = makeStream.ReadLine()?.Trim();
                if (string.IsNullOrEmpty(line)) continue;

                if (line.StartsWith("-o", StringComparison.CurrentCultureIgnoreCase))
                {
                    curFile = line[2..].Trim();
                    continue;
                }
                if (string.IsNullOrEmpty(curFile)) continue;

                if (!MakeData.TryGetValue(curFile, out var v))
                    MakeData[curFile] = v = new Stack<string>();
                v.Push(line);
            }

            var dimReg = new Regex("\\bDim\\s+([_a-zA-z][_a-zA-Z0-9]*)\\s+As\\b", RegexOptions.IgnoreCase);
            var scriptReg = new Regex("(Export\\s+)?(?:Script)\\s+([_a-zA-z][_a-zA-Z0-9]*)\\s*\\(", RegexOptions.IgnoreCase);

            var fileDict = new Dictionary<Guid, string>();
            foreach (var (dest, src) in MakeData)
            {
                fileDict.Clear();
                var idx = 0;
                if (!Directory.Exists(ReleasePath)) Directory.CreateDirectory(ReleasePath);
                using var destFile = File.Open($"{ReleasePath}/{dest}", FileMode.Create, FileAccess.Write);
                using var destString = new StreamWriter(destFile);

                foreach (var srcPath in src)
                {
                    if (File.Exists(srcPath) && Path.GetExtension(srcPath) == "smt")
                    {
                        using var f = File.OpenRead(srcPath);
                        using var fs = new StreamReader(f);

                        WriteFile(fs, srcPath);
                    }
                    else if (Directory.Exists(srcPath))
                    {
                        foreach (var filePath in Directory.EnumerateFiles(srcPath, "*.smt"))
                        {
                            using var f = File.OpenRead(filePath);
                            using var fs = new StreamReader(f);
                            WriteFile(fs, filePath);
                        }
                    }
                    else throw new Exception($"Failure to collecting file from: {srcPath}");
                }

                destString.WriteLine(CommonDivideTag);
                destString.WriteLine(CommonDivideTag);
                destString.WriteLine(MetadataDivideStartTag);
                foreach (var (guid, fileSrc) in fileDict)
                {
                    var p = Path.GetFullPath(fileSrc);
                    p = Path.GetRelativePath(fullPath, p);
                    destString.WriteLine($"{Prefix}{guid:D}:{p}");
                }
                destString.WriteLine(MetadataDivideEndTag);
                destString.WriteLine(CommonDivideTag);
                destString.WriteLine(CommonDivideTag);

                void WriteFile(StreamReader fs, string path)
                {
                    idx++;
                    RenameCache.Clear();
                    var uuid = Guid.NewGuid();
                    fileDict[uuid] = path;
                    destString.WriteLine(CommonDivideTag);
                    destString.WriteLine(Prefix + uuid.ToString("D"));
                    destString.WriteLine(CommonDivideTag);

                    while (!fs.EndOfStream)
                    {
                        var line = fs.ReadLine();
                        if (line == null) break;

                        var m = dimReg.Match(line);
                        while (m.Success)
                        {
                            if (m.Groups.Count == 2) RenameCache.Add(m.Groups[1].Value);
                            m = m.NextMatch();
                        }

                        m = scriptReg.Match(line);
                        while (m.Success)
                        {
                            if (m.Groups.Count == 3 && string.IsNullOrEmpty(m.Groups[1].Value)) RenameCache.Add(m.Groups[2].Value);
                            m = m.NextMatch();
                        }

                        line = RenameCache.Aggregate(line,
                            (current, reg) => new Regex($"\\b{reg}\\b")
                                .Replace(current, $"{reg}__tmake_{idx}"));
                        destString.WriteLine(line);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine(ex.Message);
            Console.ForegroundColor = ConsoleColor.White;
        }
    }

    private static void UnpackFile()
    {
        var fileDict = new Dictionary<Guid, string>();
        var metaDataReg = new Regex(Prefix + "\\s*([0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12})\\s*:\\s*([\\S\\s]+\\.smt)");
        var fileUuidReg = new Regex(Prefix + "\\s*([0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12})");
        var renameReg = new Regex("__tmake_[0-9]+\\b");

        const string unpackPath = "./release/unpack";
        if (Directory.Exists(ReleasePath))
        {
            if (Directory.Exists(unpackPath)) Directory.Delete(unpackPath, true);
            Directory.CreateDirectory(unpackPath);
            foreach (var file in Directory.EnumerateFiles(ReleasePath, "*.smt", new EnumerationOptions { RecurseSubdirectories = false }))
            {
                fileDict.Clear();
                if (!File.Exists(file)) continue;

                using var fileSteam = File.OpenRead(file);
                using var stream = new StreamReader(fileSteam);

                ReadMetadata(stream);
                fileSteam.Position = 0;

                var isInFile = false;
                var isInMetadata = false;
                var newFileStream = (FileStream?)null;
                var newFileWriteStream = (StreamWriter?)null;

                while (!stream.EndOfStream)
                {
                    var line = stream.ReadLine();
                    if (line == null) break;

                    if (isInMetadata)
                    {
                        if (line.StartsWith(MetadataDivideEndTag)) isInMetadata = false;
                        continue;
                    }

                    if (!isInFile)
                    {
                        CheckFile();
                        continue;
                    }

                    if (line.StartsWith(MetadataDivideStartTag))
                    {
                        isInMetadata = true;
                        continue;
                    }

                    if (line.StartsWith(CommonDivideTag)) continue;

                    line = renameReg.Replace(line, string.Empty);
                    newFileWriteStream?.WriteLine(line);

                    CheckFile();
                    void CheckFile()
                    {
                        if (fileUuidReg.Match(line) is not { Success: true, Groups.Count: > 1 } fileMatch)
                            return;

                        isInFile = false;
                        var uuid = new Guid(fileMatch.Groups[1].Value);
                        if (!fileDict.TryGetValue(uuid, out var path)) return;

                        newFileWriteStream?.Dispose();
                        newFileStream?.Dispose();

                        var dirPath = path.Replace(Path.GetFileName(path), string.Empty);
                        if (!Directory.Exists(dirPath)) Directory.CreateDirectory(dirPath);

                        newFileStream = File.Open(path, FileMode.Create, FileAccess.Write);
                        newFileWriteStream = new StreamWriter(newFileStream);
                        isInFile = true;
                    }
                }

                newFileWriteStream?.Dispose();
                newFileStream?.Dispose();
            }
        }

        void ReadMetadata(StreamReader reader)
        {
            var isInMetadataBlock = false;
            while (!reader.EndOfStream)
            {
                var str = reader.ReadLine();
                if (string.IsNullOrEmpty(str)) continue;

                if (!str.StartsWith(MetadataDivideStartTag) && !isInMetadataBlock) continue;
                isInMetadataBlock = true;

                var match = metaDataReg.Match(str);
                if (match is { Success: true, Groups.Count: > 2})
                {
                    var uuid = new Guid(match.Groups[1].Value);
                    if (uuid == Guid.Empty) continue;
                    fileDict[uuid] = $"{unpackPath}/{match.Groups[2].Value}";
                }

                if (str.StartsWith(MetadataDivideEndTag)) return;
            }
        }
    }

    private const string Prefix = "' \u200b;; ";
    private const string CommonDivideTag =        Prefix + "=====================================================================";
    private const string MetadataDivideStartTag = Prefix + "================================================== ;;Metadata Begin;;";
    private const string MetadataDivideEndTag =   Prefix + "==================================================== ;;Metadata End;;";
}