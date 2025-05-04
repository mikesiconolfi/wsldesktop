# Setting Up Nerd Fonts for Windows and VSCode

This guide provides step-by-step instructions for manually installing Nerd Fonts on Windows and configuring Visual Studio Code to use them.

## Why Nerd Fonts?

Nerd Fonts patch developer-targeted fonts with a high number of glyphs (icons). They're particularly useful for:
- Terminal applications with icon support
- Coding with ligatures
- Developer tools that use icons in the UI
- Creating a visually appealing development environment

## Installing Nerd Fonts on Windows

### Method 1: Manual Download and Installation

1. **Download Nerd Fonts**:
   - Visit the [Nerd Fonts website](https://www.nerdfonts.com/font-downloads)
   - Recommended fonts:
     - JetBrainsMono Nerd Font (best overall coding font with excellent ligatures)
     - FiraCode Nerd Font (great alternative with good ligatures)
     - Hack Nerd Font (clean and simple)
     - CaskaydiaCove Nerd Font (Cascadia Code with icons)

2. **Extract the downloaded zip file**:
   - Right-click the downloaded zip file and select "Extract All..."
   - Choose a location to extract the files

3. **Install the fonts**:
   - Select all the extracted `.ttf` or `.otf` files
   - Right-click and select "Install" or "Install for all users" (requires admin privileges)
   - Alternatively, drag the font files to `C:\Windows\Fonts`

### Method 2: Using Windows Package Manager (winget)

If you have winget installed, you can use it to install Nerd Fonts:

```powershell
# Open PowerShell as Administrator and run:
winget install JanDeDobbeleer.OhMyPosh -s winget
oh-my-posh font install JetBrainsMono
```

### Method 3: Using Chocolatey

If you have Chocolatey installed:

```powershell
# Open PowerShell as Administrator and run:
choco install nerd-fonts-jetbrainsmono
```

## Configuring VSCode to Use Nerd Fonts

### Step 1: Update User Settings

1. Open Visual Studio Code
2. Press `Ctrl+Shift+P` to open the Command Palette
3. Type "Preferences: Open Settings (JSON)" and select it
4. Add or update these settings in your `settings.json` file:

```json
{
    "editor.fontFamily": "JetBrainsMono Nerd Font, JetBrains Mono, Consolas, 'Courier New', monospace",
    "editor.fontLigatures": true,
    "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font Mono, JetBrains Mono, Consolas, 'Courier New', monospace"
}
```

5. Save the file (`Ctrl+S`)

### Step 2: Additional Font Customization (Optional)

You can further customize your font settings by adding these options to your `settings.json`:

```json
{
    "editor.fontSize": 14,
    "terminal.integrated.fontSize": 14,
    "editor.fontWeight": "normal",
    "editor.lineHeight": 1.5,
    "editor.letterSpacing": 0.5
}
```

### Step 3: Verify Font Installation

1. Open a new terminal in VSCode (`Ctrl+` `)
2. Type some text that should display special characters, like:
   ```
   echo -e "\uf015 \uf09b \uf121"
   ```
3. If you see icons instead of squares or question marks, the font is working correctly

## Configuring Windows Terminal to Use Nerd Fonts

If you use Windows Terminal, you can also configure it to use Nerd Fonts:

1. Open Windows Terminal
2. Click on the dropdown arrow in the title bar and select "Settings" (or press `Ctrl+,`)
3. In the Settings UI:
   - Click on your WSL profile in the left sidebar
   - Scroll down to "Appearance"
   - Under "Font face", select one of the Nerd Fonts you installed:
     * JetBrainsMono NF
     * JetBrainsMono Nerd Font
     * JetBrainsMono Nerd Font Mono
   - Click "Save"

Alternatively, you can edit the settings.json file directly:

1. Open Windows Terminal Settings
2. Click on "Open JSON file" in the bottom left corner
3. Find your WSL profile in the "profiles" -> "list" section
4. Add or modify the "font" section:

```json
{
    "guid": "{your-wsl-profile-guid}",
    "name": "Ubuntu",
    // ... other settings ...
    "font": {
        "face": "JetBrainsMono Nerd Font",
        "size": 10
    }
}
```

## Troubleshooting

### Font Not Showing in VSCode

1. **Verify font installation**:
   - Open Windows Font settings (Start > Settings > Personalization > Fonts)
   - Search for "Nerd" or "JetBrains" to confirm the font is installed

2. **Check font name**:
   - The exact font name might vary slightly
   - Try variations like "JetBrainsMono NF", "JetBrains Mono Nerd Font", etc.

3. **Restart VSCode**:
   - Sometimes VSCode needs a full restart to recognize new fonts

4. **Clear VSCode font cache**:
   - Close VSCode
   - Delete the folder: `%APPDATA%\Code\Cache`
   - Restart VSCode

### Icons Not Displaying Correctly

1. **Check terminal compatibility**:
   - Not all terminals support all Nerd Font icons
   - Try using Windows Terminal which has excellent font support

2. **Try a different Nerd Font**:
   - Some fonts may have better icon coverage than others

3. **Verify you're using the Mono version for terminals**:
   - For terminals, use the "Mono" version of the font (e.g., "JetBrainsMono Nerd Font Mono")
   - For the editor, the regular version is usually better

## Recommended Extensions for VSCode

To enhance your font experience, consider these VSCode extensions:

1. **Material Icon Theme**:
   - Adds file icons to the explorer
   - Works well with Nerd Fonts

2. **Bracket Pair Colorizer 2**:
   - Colorizes matching brackets
   - Makes code more readable with custom fonts

3. **Indent Rainbow**:
   - Colorizes indentation
   - Improves code readability

4. **Better Comments**:
   - Enhances comment styling
   - Works well with custom fonts

## Reverting to Default Fonts

If you want to revert to the default VSCode fonts:

1. Open VSCode Settings (JSON)
2. Replace your font settings with:

```json
{
    "editor.fontFamily": "Consolas, 'Courier New', monospace",
    "editor.fontLigatures": false,
    "terminal.integrated.fontFamily": ""
}
```

3. Save the file and restart VSCode

---

*This guide is part of the WSL Desktop Setup project.*
