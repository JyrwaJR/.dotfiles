@echo off
SETLOCAL

REM Specify the username and paths
SET "USERNAME=<YourUsername>"  REM Replace with your actual username
SET "DOTFILES_DIR=C:\Users\%USERNAME%\dotfiles"  REM Directory for dotfiles
SET "WEZTERM_LINK=C:\Users\%USERNAME%\.wezterm.lua"  REM Link for wezterm
SET "BASHRC_LINK=C:\Users\%USERNAME%\.bashrc"  REM Link for bashrc

REM Create symbolic links
echo Creating symlinks for dotfiles...

REM Create symlink for wezterm.lua
mklink "%WEZTERM_LINK%" "%DOTFILES_DIR%\.wezterm.lua"
IF ERRORLEVEL 1 (
    echo Failed to create symlink for wezterm.lua. Please check your paths and try again.
) ELSE (
    echo Symbolic link created successfully: %WEZTERM_LINK% -> %DOTFILES_DIR%\.wezterm.lua
)

REM Create symlink for .bashrc
mklink "%BASHRC_LINK%" "%DOTFILES_DIR%\.bashrc"
IF ERRORLEVEL 1 (
    echo Failed to create symlink for .bashrc. Please check your paths and try again.
) ELSE (
    echo Symbolic link created successfully: %BASHRC_LINK% -> %DOTFILES_DIR%\.bashrc
)

ENDLOCAL
pause  REM Pause to view the output
