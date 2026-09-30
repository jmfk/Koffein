# Koffein

Koffein is a small, native macOS menu-bar app that keeps your Mac awake when you need it—and gets out of the way when you don't.

## Features

- Keep the Mac awake while allowing the display to sleep.
- Keep both the Mac and display awake.
- Choose 30 minutes, 1 hour, 2 hours, 4 hours, or indefinitely.
- See a live remaining-time indicator.
- Optionally launch at login.
- No analytics, accounts, network access, or administrator privileges.

Koffein uses macOS IOKit power assertions. It prevents idle sleep only: closing a MacBook lid, choosing Sleep, a critically low battery, and other system-required sleep events still take precedence.

## Requirements

- macOS 13 or later
- Xcode 15 or later

## Build

Open `Koffein.xcodeproj` in Xcode and run the `Koffein` scheme.

The project file is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen). You only need XcodeGen if you change the project specification:

```sh
xcodegen generate
```

For an unsigned local command-line build:

```sh
xcodebuild -project Koffein.xcodeproj \
  -scheme Koffein \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## How it works

Koffein creates a native power-management assertion using `IOPMAssertionCreateWithDescription` and releases it when the session ends, you stop it, or the app exits. It does not simulate mouse or keyboard input and does not alter your global Energy settings.

The stable internal workload identifier is `r7m4x9`; the Koffein name remains a replaceable display identity.

## Contributing

Issues and pull requests are welcome. Please keep changes focused, explain the user-visible outcome, and include the local verification you ran.

## License

Koffein is available under the [MIT License](LICENSE).
