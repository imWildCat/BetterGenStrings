# BetterGenStrings

A command line tool to improve the experience while using `genstrings`.

The built-in tool called `genstring` will overwrite the existing .strings file instead of only adding new items. `BetterGenStrings` is designed to achive the incremental iteration of your .strings file.

## Usage example

```shell
#!/usr/bin/env sh

tmpdir=$(mktemp -d)
tmpfile="$tmpdir/Localizable.strings"
find YourMainTarget YourSecondOptionalTarget -name \*.swift -print0 | xargs -0 genstrings -SwiftUI -o $tmpdir
BetterGenStrings -i $tmpfile ./YourMainTarget/zh-Hans.lproj/Localizable.strings
```

## License 

MIT.
