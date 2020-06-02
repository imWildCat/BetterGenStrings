import ArgumentParser
import Foundation

struct BetterGenStrings: ParsableCommand {
  @Option(name: .shortAndLong, help: "The input file")
  var input: String?

  @Argument(help: "The path of output file")
  var outputPath: String

  @Flag(help: "Dry run, without writing the result")
  var dryRun: Bool

  func run() throws {
    var inputString: String

    if let input = input {
      inputString = try! String(contentsOfFile: input) // std input
    } else {
      inputString = readLine(strippingNewline: false) ?? ""
    }

    if inputString.isEmpty {
      print("Error: input string is empty")
      return
    }

    guard let tempFileURL = try? writeStringToTemp(inputString: inputString) else {
      print("Error: cannot create temp file")
      return
    }
    let inputDict = NSDictionary(contentsOf: tempFileURL)

    let outputDict = NSDictionary(contentsOfFile: outputPath)

    if let inputDict = inputDict as? [String: String],
      let outputDict = outputDict as? [String: String] {
      for (_, entry) in inputDict.enumerated() {
        if let currentValue = outputDict[entry.key] {
          inputString = inputString.replacingOccurrences(of: "\"\(entry.key)\" = \"\(entry.key)\"", with: "\"\(entry.key)\" = \"\(currentValue)\"")
        }
      }
    }

    print(inputString)

    if dryRun {
      print("This is only dry run, skip writing")
    } else {
      try! inputString.write(toFile: outputPath, atomically: true, encoding: .utf8)
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

    guard let fileData = inputString.data(using: .utf8) else {
      fatalError("Cannot convert temp string to data")
    }
    try fileData.write(to: tempFileURL)

    return tempFileURL
  }
}

BetterGenStrings.main()
