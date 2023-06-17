import ArgumentParser
import Foundation

struct BetterGenStrings: ParsableCommand {
  @Option(name: .shortAndLong, help: "The input .strings file")
  var input: String

  @Argument(help: "The path of output .strings file")
  var outputPath: String

  @Flag(help: "Dry run, without writing the result")
  var dryRun: Bool

  func run() throws {
    var outputPath = self.outputPath
    outputPath = refineOutPath(outputPath)

    print("Output path:", outputPath)

    let inputDict = NSDictionary(contentsOfFile: input)

    var inputString = try String(contentsOfFile: input, encoding: .utf16LittleEndian)

    let outputDict = NSDictionary(contentsOfFile: outputPath)

    if let inputDict = inputDict as? [String: String],
       let outputDict = outputDict as? [String: String]
    {
      for (_, entry) in inputDict.enumerated() {
        if let currentValue = outputDict[entry.key] {
          inputString = inputString.replacingOccurrences(of: "\"\(entry.key)\" = \"\(entry.key)\"", with: "\"\(entry.key)\" = \"\(currentValue)\"")
        }
      }
    }

    if dryRun {
      print("This is only dry run, skip writing. Result:")
      print(inputString)
    } else {
      try inputString.write(toFile: outputPath, atomically: true, encoding: .utf8)
      print("All the content has been write to:", outputPath)
    }
  }

  private func writeStringToTemp(inputString: String) throws -> URL {
    let tempDirectoryString = NSTemporaryDirectory()

    guard let temporaryDestinationDirectoryURL = URL(string: tempDirectoryString) else {
      fatalError("Cannot create the URL: \(tempDirectoryString)")
    }
    let temporaryDirectoryURL = try FileManager.default.url(for: .itemReplacementDirectory,
                                                            in: .userDomainMask,
                                                            appropriateFor: temporaryDestinationDirectoryURL,
                                                            create: true)
    let tempFileURL = temporaryDirectoryURL.appendingPathComponent("temp.strings")

    guard let fileData = inputString.data(using: .utf16LittleEndian) else {
      fatalError("Cannot convert temp string to data")
    }
    try fileData.write(to: tempFileURL)

    return tempFileURL
  }

  private func refineOutPath(_ outPath: String) -> String {
    if outputPath.hasPrefix("/") {
      return outputPath
    }
    guard let url = URL(string: FileManager.default.currentDirectoryPath)?.appendingPathComponent(outPath) else {
      return outputPath
    }
    return url.standardized.absoluteString
  }
}

BetterGenStrings.main()
