# ZenDisp

Free, open-source macOS virtual and external display utility designed for Apple Silicon Macs.

## Features

* Native Swift with zero external dependencies
* Virtual HiDPI display creation via private CoreGraphics APIs
* Low-latency Picture-in-Picture (PiP) and full-screen stream viewer powered by ScreenCaptureKit
* GPU-accelerated aspect-fit downscaling
* Under 30 MB memory footprint

## Building and Running

Ensure Xcode command line tools or Swift 5.9+ is installed.

```bash
chmod +x scripts/build_app.sh
./scripts/build_app.sh
```

To run the built bundle:

```bash
open build/ZenDisp.app
```

## Permissions

ZenDisp requires the following permissions in macOS System Settings:
* **Screen & System Audio Recording**: Required by ScreenCaptureKit to stream the virtual display into the PiP viewer.
* **Accessibility**: Required for cursor wrapping and input events.

## License

MIT License
