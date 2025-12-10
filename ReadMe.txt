ATTENTION!!!

You must perform once-per-mod setup before you can begin working on your mod.

To do so, run either "SETUP.bat" or "SETUP_LEGACY.bat" in the mod project folder. "SETUP.bat" has the advantage of guiding you through a few common configuration steps, but these may not be relevant to your mod.

If you did not close ModBuddy, you will get a popup message about files being modified outside the source editor. Click "Yes to All".

That is all.

IMPORTANT!!!

When you create the mod project, project Name, Solution name and Title must match *exactly*. Otherwise the first time setup will fail.


Enhanced Mod Project Template v1.5

Get news and updates here:

https://github.com/Iridar/EnhancedModProjectTemplate

v1.5

Simplified X2PG setup to a Boolean flag in X2MBC. (Doesn't do anything if X2PG is unavailable, though.)
Added new guided setup script, which guides the user through:
    - Finding the SDK and game folders
    - Setting up a Git repository (does nothing if Git is unavailable)
    - Enabling building against the Highlander, from any of the following:
        - GitHub
        - Project-specific path to a local copy of the Highlander
        - Environment variable pointing to a local copy of the Highlander
    - Toggling the X2PG flag in X2MBC
    - Enabling cooking
    - Enabling building against any number of extra dependencies
Deprecated old setup script. The new setup uses it under the hood, but you probably don't want to use it directly anymore.
Added VSCode workspace, which is automatically set up to include the SDK and any dependencies for IntelliSense.
Added build automation scripts, shamelessly stolen and tweaked from Long War of the Chosen.

v1.4

Filled X2DLCInfo and XComGame.int with examples. 
Added an alternative example for using X2MBC to build against Highlander to build.ps1.
New mod preview image.
Added more global macros to globals_uci.
Expanded and updated ConfigEngine with more functions and improved performance.
Improved Help.uc formatting.
Added useful stuff into .gitignore

v1.3

Removed X2DLCInfo contents, as they caused issues when trying to build the mod not against Highlander.

v1.2

Fixed the GetLocalizedString() function not working... Again.

v1.1

Fixed the GetLocalizedString() function not working.

v1.0

Initial release.
