Here's the simplified README section focusing only on **Step 3** for both Bash and WezTerm configurations:

---

## Step 3: Update Your Configuration Files

### **For Bash Configuration:**

1. **Modify `.bashrc` to Source External File:**

   Open your `.bashrc` file in a text editor:

   ```bash
   nano ~/.bashrc
   ```

   Add the following lines to source the external Bash aliases and functions:

   ```bash
   # Source external bash aliases and functions from .dotfiles
   if [ -f "$HOME/.dotfiles/.bash_aliases" ]; then
     source "$HOME/.dotfiles/.bash_aliases"
   fi
   ```

2. **Apply Changes:**

   Reload your `.bashrc` to apply the changes:

   ```bash
   source ~/.bashrc
   ```

---

### **For WezTerm Configuration:**

1. **Modify WezTerm Configuration File to Source External File:**

   Open your main WezTerm configuration file (`~/.wezterm.lua`) in a text editor:

   ```bash
   nano ~/.wezterm.lua
   ```

   Add the following code to load the external WezTerm configuration:

   ```lua
   -- Pull in the wezterm API
   local wezterm = require("wezterm")

   -- Load the external config from the absolute path
   return dofile("C:/Users/shuke/.dotfiles/.wezterm.lua")
   ```

2. **Apply Changes:**

   Restart WezTerm to apply the new configuration.

---

This section assumes you have already created the external configuration files as specified. Let me know if you need any more details!
