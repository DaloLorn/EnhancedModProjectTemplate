@echo off

REM **********************
REM *** WELCOME SCREEN ***
REM **********************

echo Welcome to the EMPT Advanced Setup! Let's just run through a few settings...
echo You may close this setup at any time before completion if you change your mind
echo about any of your chosen settings.
echo.
SETLOCAL EnableDelayedExpansion

REM Set initial values so we can reliably navigate back from the commit screen.
SET gitMode=
SET highlanderMode=
SET x2PGMode=
SET cookingMode=
SET customSrc=
SET skipCustomSrc=

REM ******************
REM *** GIT SCREEN ***
REM ******************

:gitSetup
echo Do you want to use Git for version control? (You need to have installed it before, or this won't do anything...)
echo   1. Yes, I want to use Git.
echo   2. No, I don't want to use Git right now.
SET /p "gitMode=Please enter the number corresponding to your preferred option: "

IF "!gitMode!" == "1" (
    SET gitMode=UseGit
    GOTO gitFinished
) 
IF "!gitMode!" == "2" (
    SET gitMode=NoGit
    GOTO gitFinished
)
echo Sorry, that's not a valid option^^!
echo.
SET gitMode=
GOTO gitSetup

:gitFinished
echo.
echo Git mode has been set to "!gitMode!"^^! (1/5)
echo Moving on to the meaty bits...
echo.

REM *************************
REM *** HIGHLANDER SCREEN ***
REM *************************

:highlanderSetup
echo How do you want to build against the Community Highlander?
echo   1. Get the Highlander from GitHub. (This will forcibly enable Git mode^^!)
echo   2. Use a local copy of the Highlander from a project-specific path...
echo   3. Use a local copy of the Highlander from a global path...
echo   4. I don't want to build against the Highlander right now.
SET /p "highlanderMode=Please enter the number corresponding to your preferred option: "

IF "!highlanderMode!" == "1" (
    SET gitMode=UseGit
    SET highlanderMode=FromGit
    GOTO highlanderFinished
) 
IF "!highlanderMode!" == "2" (
    :highlanderPathSetup
    SET highlanderPath=
    SET /p "highlanderPath=Now, please specify the path to the Highlander's Src folder (e.g. C:\Users\Iridar\Documents\Firaxis ModBuddy\X2WOTCCommunityHighlander\X2WOTCCommunityHighlander\Src): "
    IF NOT EXIST "!highlanderPath!\X2WOTCCommunityHighlander\Classes" (
        echo ERROR: Could not detect Highlander source code^^! Please double-check the path and try again^^!
        GOTO highlanderPathSetup
    )
    SET highlanderMode=FromPath "!highlanderPath!"
    GOTO highlanderFinished
) 
IF "!highlanderMode!" == "3" (
    IF NOT EXIST "!X2EMPT_HIGHLANDER_FOLDER!\X2WOTCCommunityHighlander\Classes" (
        echo WARNING: Could not detect Highlander source code^^!
        echo It is highly recommended that you set the X2EMPT_HIGHLANDER_FOLDER environment variable
        echo to a valid location before proceeding. This setup can set it for you, if you wish.
        echo.

        :offerEnvSetup
        SET setupEnv=
        SET highlanderPath=
        SET /p "setupEnv=Do you wish to set up X2EMPT_HIGHLANDER_FOLDER? (Y/N) "
        IF "!setupEnv!" == "Y" (
            :highlanderEnvSetup
            SET /p "highlanderPath=Please specify the path to the Highlander's Src folder (e.g. C:\Users\Iridar\Documents\Firaxis ModBuddy\X2WOTCCommunityHighlander\X2WOTCCommunityHighlander\Src): "

            IF NOT EXIST "!highlanderPath!\X2WOTCCommunityHighlander\Classes" (
                echo ERROR: Could not detect Highlander source code^^! Please double-check the path and try again^^!
                GOTO highlanderEnvSetup
            )
            SETX X2EMPT_HIGHLANDER_FOLDER "!highlanderPath!"
            GOTO highlanderEnvFinished
        )
        IF NOT "!setupEnv!" == "N" (
            echo Sorry, that's not a valid option^^!
            echo.
            GOTO offerEnvSetup
        )
    )

    :highlanderEnvFinished
    SET highlanderMode=FromEnvVar
    GOTO highlanderFinished
)
IF "!highlanderMode!" == "4" (
    SET highlanderMode=NoHighlander
    GOTO highlanderFinished
)

echo Sorry, that's not a valid option^^!
echo.
SET highlanderMode=
GOTO highlanderSetup

:highlanderFinished
echo.
echo Highlander mode has been set to "!highlanderMode!"^^! (2/5)
echo Moving on...
echo.

REM *********************************
REM *** X2ProjectGenerator SCREEN ***
REM *********************************

:x2PGSetup
IF NOT "!x2PGMode!" == "" GOTO cookingSetup
echo Do you want to use Xymanek's X2ProjectGenerator
echo to automatically verify your project before compiling?
echo.
echo Note that even if enabled, X2PG will not do anything until you add
echo X2ProjectGenerator.exe to your PATH.
echo   1. Yes, please enable automatic verification.
echo   2. No, I don't want to enable automatic verification right now.
SET /p "x2PGMode=Please enter the number corresponding to your preferred option: "

IF "!x2PGMode!" == "1" (
    SET x2PGMode=UseX2PG
    GOTO x2PGFinished
) 
IF "!x2PGMode!" == "2" (
    SET x2PGMode=NoX2PG
    GOTO x2PGFinished
)
echo Sorry, that's not a valid option^^!
echo.
SET x2PGMode=
GOTO x2PGSetup

:x2PGFinished
echo.
echo X2PG mode has been set to "!x2PGMode!"^^! (2/4)
echo Next up...
echo.

REM **********************
REM *** COOKING SCREEN ***
REM **********************

:cookingSetup
IF NOT "!cookingMode!" == "" GOTO customSrcSetup
echo Do you want to enable cooking? If you're not 100%% sure when you need to do this,
echo that's alright: The author of this setup isn't sure yet, either. :^(
echo   1. Yes, please enable cooking.
echo   2. No, I don't think this project benefits from cooking.
SET /p "cookingMode=Please enter the number corresponding to your preferred option: "

IF "!cookingMode!" == "1" (
    SET cookingMode=EnableCooking
    GOTO cookingFinished
)
IF "!cookingMode!" == "2" (
    SET cookingMode=NoCooking
    GOTO cookingFinished
)
echo Sorry, that's not a valid option^^!
echo.
SET cookingMode=
GOTO cookingSetup

:cookingFinished
echo.
echo Cooking mode has been set to "!cookingMode!"^^! (4/5)
echo Almost there...
echo.

REM *************************
REM *** CUSTOM SRC SCREEN ***
REM *************************

:customSrcSetup
REM Since this one keeps iteratively adding to customSrc, we need a separate flag
REM to tell us we came here from the commit screen.
IF !skipCustomSrc! == TRUE GOTO commitScreen
SET moreSrc=
SET /p "moreSrc=Are there any other mods you want to build against? (Y/N) "
IF "!moreSrc!" == "Y" (
    echo Okay^^! We can do this folder-by-folder, or as a space-delimited list of folders.
    echo Remember to target the mods' Src folders^^! This setup isn't smart enough
    echo to do it for you.
    SET /p "moreSrc=Please specify the path(s) to the mod(s) you wish to build against: "
    IF NOT "!customSrc!" == "" SET customSrc=!customSrc! !moreSrc!
    IF "!customSrc!" == "" SET customSrc=!moreSrc!
    echo.
    echo Dependency registered^^! Current dependencies: !customSrc!
    echo.
    GOTO customSrcSetup
) 
IF NOT "!moreSrc!" == "N" (
    echo Sorry, that's not a valid option^^!
    echo.
    GOTO customSrcSetup
)

SET skipCustomSrc=TRUE
echo.
echo Finished registering dependencies^^! (5/5)
echo Setup is ready to do its thing^^!
echo.

REM *********************
REM *** COMMIT SCREEN ***
REM *********************

:commitScreen
SET commit=
echo Here's the final config, for verification:
echo 1. Is using Git: !gitMode!
echo 2. Highlander source: !highlanderMode!
echo 3. Automatic validation: !x2PGMode!
echo 4. Is using cooking: !cookingMode!
echo 5. Dependency paths: !customSrc!
echo.
SET /p "commit=Does that look okay? Enter a number 1-5 to return to its corresponding step, or 6 to finish setup: "

IF "!commit!" == "1" (
    IF "!highlanderMode!" == "FromGit" (
        echo Sorry, can't disable Git if you're using it to build against the Highlander^^!
        echo.
        GOTO commitScreen
    )
    echo Returning to Git config now^^!
    echo.
    SET gitMode=
    GOTO gitSetup
)
IF "!commit!" == "2" (
    echo Okay, returning to Highlander config^^!
    echo.
    SET highlanderMode=
    GOTO highlanderSetup
) 
IF "!commit!" == "3" (
    echo Got it, returning to X2PG config^^!
    echo.
    SET x2PGMode=
    GOTO x2PGSetup
) 
IF "!commit!" == "4" (
    echo Going back to cooking config now^^!
    echo.
    SET cookingMode=
    GOTO cookingSetup
) 
IF "!commit!" == "5" (
    echo Ouch. Going back to dependency config... hopefully not for long...
    echo.
    SET skipCustomSrc=
    SET customSrc=
    GOTO customSrcSetup
) 
IF "!commit!" == "6" (
    GOTO runSetup
)
echo Sorry, that's not a valid option^^!
echo.
GOTO commitScreen

:runSetup
echo Beginning project setup^^! Do not close this window...
echo.
IF "!gitMode!" == "UseGit" (
    cd ..
    git init
    cd $ModSafeName$
)

REM RUN_THIS expects delayed expansion to be off.
REM I chose not to bother changing that, but
REM the setting will be inherited from the previous script.
SETLOCAL DisableDelayedExpansion
RUN_THIS.bat !highlanderMode! !x2PGMode! !cookingMode! !customSrc!