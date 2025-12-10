@echo off
REM SETUP_ADVANCED uses delayed expansion while SETUP
REM expects it to be disabled. I chose not to bother changing that, but
REM need to clean up after the previous script.
SETLOCAL DisableDelayedExpansion

REM ***********************
REM *** SOLUTION CONFIG ***
REM ***********************

REM vstemplate cannot create files near solution file, only inside the project folder.
REM And X2ModBuildCommon files need to be in the solution folder.
REM The only solution is to create X2MBC files inside project folder, and then use this batch file to move them to the solution folder.

move ".gitignore" "..\.gitignore"
move ".scripts" "..\.scripts"

REM vstemplate cannot create empty folders, so we do it here.

mkdir "Content"
mkdir "ContentForCook"

REM Use the shipped text editor.
REM vstemplate requires the XCOM2.targets to be present and readable, and the XCOM2.targets is located in the X2MBC folder we have moved,
REM so we adjust the .x2proj file to point to the new location of the .targets file.

replace_text.exe $ModSafeName$.x2proj "<SolutionRoot>$(MSBuildProjectDirectory)\</SolutionRoot>" "<SolutionRoot>$(MSBuildProjectDirectory)\..\</SolutionRoot>"

REM All files created by vstemplate need to be referenced in .x2proj file during project creation,
REM but X2MBC and some of the others don't need to be there, so clean them out.

replace_text.exe $ModSafeName$.x2proj --remove --c-style ".scripts\\X2ModBuildCommon\\XCOM2.targets"
replace_text.exe $ModSafeName$.x2proj --remove --c-style ".scripts\\X2ModBuildCommon\\README.md"
replace_text.exe $ModSafeName$.x2proj --remove --c-style ".scripts\\X2ModBuildCommon\\LICENSE"
replace_text.exe $ModSafeName$.x2proj --remove --c-style ".scripts\\X2ModBuildCommon\\InvokePowershellTask.cs"
replace_text.exe $ModSafeName$.x2proj --remove --c-style ".scripts\\X2ModBuildCommon\\EmptyUMap"
replace_text.exe $ModSafeName$.x2proj --remove --c-style ".scripts\\X2ModBuildCommon\\clean_cooker_output.ps1"
replace_text.exe $ModSafeName$.x2proj --remove --c-style ".scripts\\X2ModBuildCommon\\clean.ps1"
replace_text.exe $ModSafeName$.x2proj --remove --c-style ".scripts\\X2ModBuildCommon\\CHANGELOG.md"
replace_text.exe $ModSafeName$.x2proj --remove --c-style ".scripts\\X2ModBuildCommon\\build_common.ps1"
replace_text.exe $ModSafeName$.x2proj --remove --c-style ".scripts\\build.ps1"
replace_text.exe $ModSafeName$.x2proj --remove --c-style ".gitignore"
replace_text.exe $ModSafeName$.x2proj --remove --c-style "SETUP.bat"
replace_text.exe $ModSafeName$.x2proj --remove --c-style "SETUP_LEGACY.bat"
replace_text.exe $ModSafeName$.x2proj --remove --c-style "build.bat"
replace_text.exe $ModSafeName$.x2proj --remove --c-style "build_debug.bat"
replace_text.exe $ModSafeName$.x2proj --remove --c-style "build_default.bat"
replace_text.exe $ModSafeName$.x2proj --remove --c-style "clean.bat"
replace_text.exe $ModSafeName$.x2proj --remove --c-style "replace_text.exe"
replace_text.exe $ModSafeName$.x2proj --remove --c-style "vscode.code-workspace.default"

REM " and \ are tough to handle, so it needs to be done in two steps.

replace_text.exe $ModSafeName$.x2proj --remove --c-style .scripts\\X2ModBuildCommon\\
replace_text.exe $ModSafeName$.x2proj --remove --c-style .scripts\\

replace_text.exe $ModSafeName$.x2proj --remove --c-style "<Folder Include=\"\" />"
replace_text.exe $ModSafeName$.x2proj --remove --c-style "<Content Include=\"\" />"

REM Bandaid fix for path to XCOM2.targets file we ruined by one of the commands above.

replace_text.exe $ModSafeName$.x2proj "$(SolutionRoot)" $(SolutionRoot).scripts\\

REM ************************
REM *** HIGHLANDER SETUP ***
REM ************************

REM Option 1: From Git
IF "%1" == "FromGit" ( 
    REM Go outside to grab the Highlander (we're presuming the repo already exists).
    cd ..
    git submodule add https://github.com/X2CommunityCore/X2WOTCCommunityHighlander.git

    REM Now go back here for more convenient access to FART,
    REM and reconfigure X2MBC to use our Git Highlander.
    cd $ModSafeName$
    replace_text.exe --c-style ..\.scripts\build.ps1 "# $builder.IncludeSrc("\""$srcDirectory" "$builder.IncludeSrc"("\""$srcDirectory"

    REM Also configure the VSCode workspace!
    replace_text.exe --c-style vscode.code-workspace.default "$HIGHLANDER" "{\""path\"": \"../X2WOTCCommunityHighlander/X2WOTCCommunityHighlander/Src\"}"
    GOTO highlanderFinished
)

REM Option 2: From local Highlander folder
IF "%1" == "FromPath" (
    REM We'll take an extra argument for the path here, so let's shift all the indices up to keep it consistent.
    SHIFT

    REM Running FART in C-style mode screws with inserting file paths,
    REM and I don't want to escape an arbitrary string inside a batch script.
    REM Frankly, I'm tempted to try rewriting the whole thing in PowerShell
    REM to avoid all this fiddling with FART and batch scripts...
    replace_text.exe ..\.scripts\build.ps1 "# $builder.IncludeSrc(\"""C:\Users\Iridar\Documents\Firaxis ModBuddy\X2WOTCCommunityHighlander\X2WOTCCommunityHighlander\Src" "$builder.IncludeSrc"(\""%1"

    REM Also configure the VSCode workspace!
    replace_text.exe vscode.code-workspace.default "$HIGHLANDER" "{\""path\"": \"%1\"}"
    GOTO highlanderFinished
)

REM Option 3: From local Highlander folder, via the X2EMPT_HIGHLANDER_FOLDER environment variable.
IF "%1" == "FromEnvVar" (
    replace_text.exe --c-style ..\.scripts\build.ps1 "# $builder.IncludeSrc($env" "$builder.IncludeSrc($env"
    replace_text.exe --c-style vscode.code-workspace.default "$HIGHLANDER" "{\""path\"": \"%X2EMPT_HIGHLANDER_FOLDER%\"}"
    GOTO highlanderFinished
)

REM Option 4 is just skipping the Highlander outright, so we only need to clean up the VSCode workspace.
REM SETUP.bat will pass "NoHighlander" because we're working with
REM positional arguments and need *something*, but we don't actually care what we get here.
replace_text.exe vscode.code-workspace.default --remove --c-style "$HIGHLANDER,\r\n"
REM In case it's using LF line endings!
replace_text.exe vscode.code-workspace.default --remove --c-style "$HIGHLANDER,\n"
:highlanderFinished

REM ********************************
REM *** X2ProjectGenerator SETUP ***
REM ********************************

REM Option 1: Use X2ProjectGenerator
IF "%2" == "UseX2PG" (
    replace_text.exe --c-style ..\.scripts\build.ps1 "$useX2PG = $false" "$useX2PG = $true"
)

REM Option 2 is just skipping X2PG outright, so no scripting needed.
REM As above, SETUP.bat will pass "NoX2PG", but we don't actually care what we get.

REM *********************
REM *** COOKING SETUP ***
REM *********************

REM Option 1: Enable cooking
IF "%3" == "EnableCooking" (
    replace_text.exe --c-style ..\.scripts\build.ps1 "# $builder.SetContent" "$builder.SetContent"
)

REM Option 2 is just keeping cooking off, so no scripting needed.
REM As above, SETUP.bat will pass "NoCooking", but we don't really care.

REM ************************
REM *** CUSTOM SRC SETUP ***
REM ************************

IF NOT "%4" == "" (
    :insertCustomSrc
        REM As mentioned above, C-style screws with inserting file paths,
        REM and I don't want to escape an arbitrary string inside a batch script.
        REM So we'll run in regular mode, printing \\n to represent a linebreak,
        REM then do a C-style postprocessing pass to turn it into a real linebreak.
        REM
        REM We're using \\n instead of \n because \n could legitimately occur
        REM in the filesystem, but \\n should be illegal. I think.
        replace_text.exe ..\.scripts\build.ps1 "# PLACEHOLDER_CUSTOMSRC" "$builder.IncludeSrc(\""%%path\"")\\n# PLACEHOLDER_CUSTOMSRC"
        replace_text.exe --c-style ..\.scripts\build.ps1 \\\\n \n

        replace_text.exe vscode.code-workspace.default "$DEPENDENCY" "{\""path\"": \"%1\"},\\n$DEPENDENCY"
        replace_text.exe --c-style vscode.code-workspace.default \\\\n$DEPENDENCY \n\t\t$DEPENDENCY

        REM We want to loop through all remaining arguments until we run out of paths.
        SHIFT
    IF NOT "%4" == "" GOTO insertCustomSrc
)

REM ***************
REM *** CLEANUP ***
REM ***************

echo X2ModBuildCommon v1.2.1 successfully installed. > ReadMe.txt
echo.
echo Edit .scripts\build.ps1 if you want to enable/disable cooking or building against Highlander. >> ReadMe.txt
echo. >> ReadMe.txt
echo Enjoy making your mod, and may the odds be ever in your favor. >> ReadMe.txt
echo. >> ReadMe.txt
echo. >> ReadMe.txt
echo Created with Enhanced Mod Project Template v1.4 >> ReadMe.txt
echo. >> ReadMe.txt
echo Get news and updates here: >> ReadMe.txt
echo https://github.com/Iridar/EnhancedModProjectTemplate >> ReadMe.txt

REM Clean up PLACEHOLDER_CUSTOMSRC.
replace_text.exe --remove --c-style ..\.scripts\build.ps1 "# PLACEHOLDER_CUSTOMSRC: Placeholder used by EMPT setup to automatically add custom source folders.\n"

REM Finalize VSCode workspace.
replace_text.exe vscode.code-workspace.default --remove --c-style "$DEPENDENCY,\r\n"
REM In case it's using LF line endings!
replace_text.exe vscode.code-workspace.default --remove --c-style "$DEPENDENCY,\n"
REM ... It's a line-by-line search, so the extra tabs need extra cleanup.
replace_text.exe vscode.code-workspace.default --c-style "\t\t\t\t" "\t\t"
REM So it turns out workspaces can't reference environment variables.
REM Good thing we're already using FART, I guess...
replace_text.exe vscode.code-workspace.default "$XCOM2SDKPATH$" "%XCOM2SDKPATH%"
replace_text.exe vscode.code-workspace.default --c-style "\\" "/"

REM Move VSCode workspace and the helper scripts where they belong.
move vscode.code-workspace.default ../$ModSafeName$.code-workspace
move build_default.bat ../build_default.bat
move build_debug.bat ../build_debug.bat
move build.bat ../build.bat
move clean.bat ../clean.bat

REM Delete text editor.
del replace_text.exe

REM Delete advanced setup file.
del SETUP.bat

REM If we're using Git, now is a good time to make an initial commit!
cd ..
git add **/* :!$ModSafeName$\SETUP_LEGACY.bat
git commit -m "EMPT w/ Git: Initial commit"
cd $ModSafeName$

REM Delete this batch file.
REM This is a bit fancier than Iridar's original,
REM because:
REM - My use of SHIFT means %0 is no longer the path to the current script.
REM - The original threw an error and I didn't like that.
REM Source/explanation: https://stackoverflow.com/a/20333152
(GOTO) 2>NUL & del SETUP_LEGACY.bat && echo Setup complete! && pause