# Jubilant Octo Pancake

A macOS database workbench scaffolded with SwiftUI and XcodeGen.

## Getting Started

Generate the Xcode project:

```sh
xcodegen generate
```

Build from the command line:

```sh
xcodebuild -project JubilantOctoPancake.xcodeproj -scheme JubilantOctoPancake build
```

When building inside a restricted workspace, keep DerivedData local:

```sh
xcodebuild -project JubilantOctoPancake.xcodeproj -scheme JubilantOctoPancake -derivedDataPath .build/DerivedData build
```

Open in Xcode when you want previews, signing controls, or App Store packaging:

```sh
open JubilantOctoPancake.xcodeproj
```

## Product Direction

The initial scaffold is shaped like a database IDE:

- connection sidebar
- database object browser
- query editor
- result grid placeholder
- settings for query editor behavior

The next real implementation layer should add database driver services, secure credential storage in Keychain, persisted connections, and a real SQL editor component.

## Connection Storage

PostgreSQL connection metadata is saved to:

```text
~/Library/Application Support/JubilantOctoPancake/connections.json
```

Passwords are stored separately in macOS Keychain using `Security.framework`; they are keyed by the connection UUID and are not written to the JSON file.
