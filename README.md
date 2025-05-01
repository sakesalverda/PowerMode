## What is PowerMode
PowerMode is a menubar application to quickly change the energy mode on supported MacBooks. These select models are most notably Apple Silicon Macbooks only, where low power mode is supported by most but high power mode is only available on some select MacBook pros.

For more information about the app you can visit the website <https://sakesalverda.nl/powermode/>

## Download
You can download the app from the website: <https://sakesalverda.nl/powermode/>

## Note for Developers
The repo is not currently very well formatted and still contains some old code that is not used in the app anymore. Feel free to contribute or come with suggestions.

When debugging or contributing to the app, please be aware that there are issues when mixing development and release builds on your local device. Due to the way launchctl works, a development build of the helper application will not work with a release version of the main app and vica versa.
Uninstalling the helper is not recognized properly by macOS and somewhere a cache is kept to the development helper when installing from the release build. I do not know the exact workings of this but the only fix I have found so far is to reset the helper by running **sfltool resetbtm**, please note that this command will reset most applications that should launch on login, meaning you have to set that up again.

## How does the app work?
PowerMode is mainly a UI app that wraps around a helper application. The main app allows the user to configure the app layout and to change the energy mode.

The only way to change energy modes, that I know of, is using the `pmset` terminal command, this requires user authentication to make any changes. Therefore PowerMode includes a small helper application, a so-called Daemon, that is a wrapper around this terminal api to faciliate energy mode changes. 
This helper is sandboxed but with some temporary sbql exception rules (to allow writing to a file that pmset writes to), which is not really recommended by Apple. I chose to use this as in some recent update of macOS (e.g. macOS 14 or 15), a daemon must have the same sandbox state as the main application, i.e. either both or sandboxed or both are not (both meaning the main app and the helper). 

The app is written in SwiftUI, but some components provided by Apple, such as the `MenuBarExtra` are not really well implemented, yet. Detection of opening/closing and more is very pour, I included some fixed for this but they are quite sensitive to order of calling.

