# Dotfiles Symlink Setup

This document provides instructions for creating symbolic links for `wezterm.lua` and `.bashrc` on Windows. This setup centralizes configuration management by linking these files from a `~/.dotfiles` directory.

### Directory Structure

Ensure your dotfiles are organized as follows:

```
~\.dotfiles\
  ├── wezterm\
  │   └── wezterm.lua
  └── bash\
      └── .bashrc
```

### Creating Symlinks

To create symbolic links, follow these steps:

#### **1. Open Command Prompt or PowerShell as Administrator**

- Search for `cmd` or `powershell` in the Start menu.
- Right-click and choose "Run as administrator."

#### **2. Create Symlinks**

**For `wezterm.lua`:**

1. **Create the Symlink:**

   ```cmd
   mklink "C:\Users\<YourUsername>\wezterm.lua" "C:\Users\<YourUsername>\.dotfiles\wezterm\wezterm.lua"
   ```

**For `.bashrc`:**

1. **Create the Symlink:**

   ```cmd
   mklink "C:\Users\<YourUsername>\.bashrc" "C:\Users\<YourUsername>\.dotfiles\bash\.bashrc"
   ```

### Verifying Symlinks

To ensure that the symlinks were created successfully:

1. **Use File Explorer**: Navigate to the symlinked files and verify that they point to the correct locations.

2. **Use Command Prompt or PowerShell:**

   ```powershell
   Get-Item "C:\Users\<YourUsername>\wezterm.lua"
   Get-Item "C:\Users\<YourUsername>\.bashrc"
   ```

   The output should show that these items are symbolic links pointing to your dotfiles directory.
