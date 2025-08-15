Kill Steam Web Helper on Game Launch (for Winlator)

This script automatically disables steamwebhelper.exe when launching a Steam game inside a Winlator Wine container.

Why?
Steam’s steamwebhelper.exe can consume a lot of RAM. On lower-memory systems, this can cause Wine containers to crash—especially if the game tries to load quickly. By temporarily removing or killing steamwebhelper.exe, this script helps free up memory and keep your game running smoothly.
How It Works

    When you launch your game via the shortcut, the script renames and delete steamwebhelper.exe so Steam can’t load it.

    After the game starts, it kills any running Steam Web Helper processes.

    On the next Steam launch, it restores the original file.

    (Optional) If needed, it can run in a loop to repeatedly kill steamwebhelper.exe.

Note : if you have an issue to delete steamwebhelper, you can comment the line that delete steamwebhelper.exe (check launch.bat) but then it will consume CPU to kill steamwebhelper as it will loop.  

Usage

    Place the script
    Copy this script to the root of your Wine container:

    C:/

    Prepare your game shortcut

        Install your game through Steam.

        In Winlator’s Computer view, locate your game’s .exe file.

        Right-click and create a shortcut.

    Gather game details

        Open your game.desktop file and note the value after Icon= (this is your game’s icon name).

        Find your game’s Steam ID in the .url file that Steam created on your desktop.

    Edit the desktop shortcut

        Open game.desktop.

        Copy the contents of template.desktop into it.

        Replace:

            STEAMIdGame → your game’s Steam ID (from the .url file)

            GAMENAME → the name of your game’s .exe (without .exe)

            PLACEICONHERE → your game’s icon name (from Icon= in the .desktop file)

    Launch your game

        In Winlator CMOD, use your edited shortcut.

        The .bat file will run first, then start Steam and your game.

Recommendations

    Use Steam Big Picture Mode by default.
    Sometimes Steam shows pop-up “help” dialogs before launching a game. If that happens, just open the game’s page manually—this won’t break the script.


