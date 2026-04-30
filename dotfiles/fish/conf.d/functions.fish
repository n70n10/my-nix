## ~/.config/fish/conf.d/functions.fish

# ── NixOS helpers ─────────────────────────────────────────────────────────

function nrs --description 'nh os switch'
    set -l path (test -n "$argv[1]"; and echo "$argv[1]"; or echo "/etc/nixos")
    set -l host (test -n "$argv[2]"; and echo "$argv[2]"; or echo (hostname))

    echo "🔄 Switching to new system configuration..."
    echo "📁 Path: $path"
    echo "🖥️  Host: $host"

    nh os switch $path -H $host $argv[3..]

    if test $status -eq 0
        echo "✅ System switched successfully!"
    else
        echo "❌ System switch failed!"
    end
end

function nrt --description 'nh os test'
    set -l path (test -n "$argv[1]"; and echo "$argv[1]"; or echo "/etc/nixos")
    set -l host (test -n "$argv[2]"; and echo "$argv[2]"; or echo (hostname))

    echo "🧪 Testing new system configuration..."
    echo "📁 Path: $path"
    echo "🖥️  Host: $host"

    nh os test $path -H $host $argv[3..]

    if test $status -eq 0
        echo "✅ System test successful! Run 'nrs' to make permanent."
    else
        echo "❌ System test failed!"
    end
end

function nrb --description 'nh os boot'
    set -l path (test -n "$argv[1]"; and echo "$argv[1]"; or echo "/etc/nixos")
    set -l host (test -n "$argv[2]"; and echo "$argv[2]"; or echo (hostname))

    echo "💾 Building system configuration for next boot..."
    echo "📁 Path: $path"
    echo "🖥️  Host: $host"

    nh os boot $path -H $host $argv[3..]

    if test $status -eq 0
        echo "✅ System built successfully! Reboot to apply changes."
    else
        echo "❌ System build failed!"
    end
end

function nup --description 'flake update + nh rebuild switch'
    set -l path (test -n "$argv[1]"; and echo "$argv[1]"; or echo "/etc/nixos")
    set -l host (test -n "$argv[2]"; and echo "$argv[2]"; or echo (hostname))

    if not test -d "$path"
        echo "❌ Error: Directory '$path' does not exist"
        return 1
    end

    echo "📦 Updating flake inputs..."
    pushd $path

    nix flake update

    if test $status -ne 0
        echo "❌ Flake update failed!"
        popd
        return 1
    end

    echo "🔄 Rebuilding system with updated inputs..."
    nh os switch . -H $host $argv[3..]

    popd

    if test $status -eq 0
        echo "✅ System updated and switched successfully!"
    else
        echo "❌ System rebuild failed!"
    end
end

function nfu --description 'nix flake update'
    set -l path (test -n "$argv[1]"; and echo "$argv[1]"; or echo "/etc/nixos")

    echo "📦 Updating flake inputs in: $path"
    nix flake update --flake $path $argv[2..]

    if test $status -eq 0
        echo "✅ Flake inputs updated successfully!"
    else
        echo "❌ Flake update failed!"
    end
end

function nfc --description 'nix flake check'
    set -l path (test -n "$argv[1]"; and echo "$argv[1]"; or echo "/etc/nixos")

    echo "🔍 Checking flake integrity..."
    nix flake check $path $argv[2..]

    if test $status -eq 0
        echo "✅ Flake check passed!"
    else
        echo "❌ Flake check failed!"
    end
end

function nrollback --description 'nh os rollback'
    echo "⏪ Rolling back to previous system generation..."
    nh os rollback

    if test $status -eq 0
        echo "✅ Rollback successful! Previous generation is now active."
    else
        echo "❌ Rollback failed!"
    end
end

function ngens --description 'nh os info (list generations)'
    echo "📋 Listing system generations:"
    echo "─────────────────────────────────"
    nh os info
end

function ncheck --description 'preview changes before applying (nh dry)'
    set -l path (test -n "$argv[1]"; and echo "$argv[1]"; or echo "/etc/nixos")
    set -l host (test -n "$argv[2]"; and echo "$argv[2]"; or echo (hostname))

    echo "🔍 Checking what will change..."
    nh os switch $path -H $host --dry
end

function nup-preview --description 'update flake and preview changes without applying'
    set -l path (test -n "$argv[1]"; and echo "$argv[1]"; or echo "/etc/nixos")
    set -l host (test -n "$argv[2]"; and echo "$argv[2]"; or echo (hostname))

    if not test -d "$path"
        echo "❌ Error: Directory '$path' does not exist"
        return 1
    end

    echo "📦 Updating flake inputs..."
    pushd $path

    sudo nix flake update

    if test $status -ne 0
        echo "❌ Flake update failed!"
        popd
        return 1
    end

    echo "🔍 Previewing changes (dry run)..."
    nh os switch . -H $host --dry

    popd

    echo ""
    echo "💡 To apply these changes, run: nup $path $host"
end

function nsh --description 'ephemeral nix shell: nsh <pkg>'
    if test -z "$argv[1]"
        echo "❌ Usage: nsh <package> [additional packages...]"
        echo "Example: nsh hello"
        echo "Example: nsh python3 curl"
        return 1
    end

    echo "📦 Entering ephemeral shell with: $argv"
    nix shell nixpkgs#$argv[1] $argv[2..]
end

function dev --description 'nix develop [.#name]'
    if test (count $argv) -eq 0
        echo "🔧 Entering default devshell..."
        nix develop
    else
        echo "🔧 Entering devshell: .#$argv[1]"
        nix develop .#$argv[1]
    end
end

function ngc --description "Delete system generations older than specified age and clean bootloader"
    if test -z "$argv[1]"
        echo "❌ Usage: ngc <age>"
        echo "📖 Examples: ngc 7d, ngc 30d, ngc 2w"
        return 1
    end

    set -l age $argv[1]
    set -l path (test -n "$argv[2]"; and echo "$argv[2]"; or echo "/etc/nixos")
    set -l host (test -n "$argv[3]"; and echo "$argv[3]"; or echo (hostname))

    # Validate age format
    if not string match -r '^\d+[dhw]|^\d{4}-\d{2}-\d{2}$' $age
        echo "❌ Error: Invalid age format '$age'"
        echo "📖 Use formats like: 7d, 12h, 2w, or 2024-01-15"
        return 1
    end

    echo "🗑️  Cleaning up generations older than $age..."

    # Use nh's built-in cleanup if available
    if type -q nh
        echo "🧹 Using nh clean..."
        nh clean --keep-since $age
    end

    # ── Nix profile cleanup ────────────────────────────────────────────

    echo "📁 Wiping system profile history..."
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than $age

    # Home-manager cleanup
    if test -d ~/.local/state/nix/profiles/home-manager
        echo "🏠 Wiping home-manager profile history..."
        nix profile wipe-history --profile ~/.local/state/nix/profiles/home-manager --older-than $age
    end

    echo "👤 Wiping user profile history..."
    nix profile wipe-history --older-than $age

    # ── Bootloader cleanup ─────────────────────────────────────────────

    echo "🖥️  Cleaning bootloader entries..."

    # Detect which bootloader is being used
    if test -d /boot/loader/entries
        echo "🔧 Detected systemd-boot"

        # Get actual generation numbers from nix profile (skip header line)
        set -l keep_gens (sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -n +2 | awk '{print $1}')

        echo "📌 Keeping boot entries for generations: $keep_gens"

        # Get boot entry files and extract generation numbers (unique)
        set -l boot_files /boot/loader/entries/nixos-generation-*.conf
        set -l removed_count 0

        for file in $boot_files
            if test -f "$file"
                # Extract generation number from filename
                set gen (echo $file | string replace -r '.*nixos-generation-([0-9]+)\.conf' '$1')

                # Check if this generation should be kept
                if not contains $gen $keep_gens
                    echo "🗑️  Removing boot entry for generation $gen"
                    sudo rm -f "$file"
                    set removed_count (math $removed_count + 1)
                end
            end
        end

        echo "✅ Removed $removed_count boot entries"

        # Regenerate bootloader configuration using nh
        echo "🔄 Regenerating bootloader configuration..."
        nh os boot $path -H $host > /dev/null 2>&1

        echo "✅ Bootloader configuration regenerated"

    else if test -f /boot/grub/grub.cfg
        echo "🔧 Detected GRUB bootloader"
        nh os boot $path -H $host > /dev/null 2>&1
        echo "✅ GRUB configuration regenerated"
    else
        echo "⚠️  Could not detect bootloader type, skipping bootloader cleanup"
    end

    # ── Garbage collection ────────────────────────────────────────────

    echo "🧹 Running garbage collection as root..."
    sudo nix-collect-garbage --delete-old

    echo "🧹 Running garbage collection as user..."
    nix-collect-garbage --delete-old

    echo "✅ Done!"

    # Show summary
    echo ""
    echo "📊 Summary:"
    echo "  • System profiles cleaned for age: $age"

    if test -d /boot/loader/entries
        set remaining (ls /boot/loader/entries/nixos-generation-*.conf 2>/dev/null | wc -l)
        echo "  • Remaining boot entries: $remaining"
    end

    echo "  • Disk usage on /nix/store:"
    df -h /nix/store | tail -1 | awk '{print "    " $3 " used / " $4 " available (" $5 ")"}'
end

# ── Filesystem helpers ────────────────────────────────────────────────────────

function mkcd --description 'mkdir -p + cd'
    if test -z "$argv[1]"
        echo "❌ Usage: mkcd <directory>"
        return 1
    end

    echo "📁 Creating directory: $argv[1]"
    mkdir -p $argv[1] && cd $argv[1]

    if test $status -eq 0
        echo "✅ Now in: "(pwd)
    else
        echo "❌ Failed to create directory"
    end
end

function fcd --description 'fuzzy cd into subdirectory'
    echo "🔍 Searching for directories..."
    set -l dir (find . -type d 2>/dev/null | fzf +m)

    if test -n "$dir"
        echo "📁 Changing to: $dir"
        cd $dir
        echo "✅ Now in: "(pwd)
    else
        echo "❌ No directory selected"
        return 1
    end
end

function fe --description 'fuzzy open file in $EDITOR'
    if test -z "$EDITOR"
        echo "⚠️  Warning: \$EDITOR not set, using 'vim'"
        set -l EDITOR vim
    end

    echo "🔍 Searching for files..."
    set -l file (fzf +m)

    if test -n "$file"
        echo "✏️  Opening: $file"
        $EDITOR $file
    else
        echo "❌ No file selected"
        return 1
    end
end

function bak --description 'copy <file> to <file>.bak'
    if test -z "$argv[1]"
        echo "❌ Usage: bak <filename>"
        return 1
    end

    if not test -f "$argv[1]"
        echo "❌ Error: '$argv[1]' is not a valid file"
        return 1
    end

    echo "💾 Creating backup: $argv[1].bak"
    cp $argv[1] $argv[1].bak

    if test $status -eq 0
        echo "✅ Backup created successfully"
    else
        echo "❌ Backup failed"
    end
end

function ex --description 'extract any archive'
    if test -z "$argv[1]"
        echo "❌ Usage: ex <archive-file>"
        return 1
    end

    if not test -f $argv[1]
        echo "❌ Error: '$argv[1]' is not a valid file"
        return 1
    end

    echo "📦 Extracting: $argv[1]"

    switch $argv[1]
        case '*.tar.bz2'
            tar xjf $argv[1]
        case '*.tar.gz'
            tar xzf $argv[1]
        case '*.tar.xz'
            tar xJf $argv[1]
        case '*.tar.zst'
            tar --zstd -xf $argv[1]
        case '*.bz2'
            bunzip2 $argv[1]
        case '*.gz'
            gunzip $argv[1]
        case '*.tar'
            tar xf $argv[1]
        case '*.tbz2'
            tar xjf $argv[1]
        case '*.tgz'
            tar xzf $argv[1]
        case '*.zip'
            unzip $argv[1]
        case '*.7z'
            7z x $argv[1]
        case '*.zst'
            zstd -d $argv[1]
        case '*'
            echo "❌ Error: '$argv[1]' cannot be extracted (unknown format)"
            return 1
    end

    if test $status -eq 0
        echo "✅ Extraction complete!"
    else
        echo "❌ Extraction failed!"
    end
end

# ── Git ──────────────────────────────────────────────────────────────────────

function gsquash --description 'squash last N commits'
    if test -z "$argv[1]"
        echo "❌ Usage: gsquash <N> [commit-message]"
        echo "📖 Examples:"
        echo "   gsquash 3                    # Squash last 3 commits, edit message"
        echo "   gsquash 3 'Fix all bugs'     # Squash with custom message"
        return 1
    end

    if not string match -r '^\d+$' $argv[1]
        echo "❌ Error: N must be a number"
        return 1
    end

    echo "📦 Squashing last $argv[1] commit(s)..."
    git reset --soft "HEAD~$argv[1]"

    if test $status -ne 0
        echo "❌ Failed to reset commits"
        return 1
    end

    if test -n "$argv[2]"
        echo "💾 Committing with message: $argv[2]"
        git commit -m "$argv[2]"
    else
        echo "✏️  Please enter commit message..."
        git commit
    end

    if test $status -eq 0
        echo "✅ Squash successful!"
    else
        echo "❌ Squash failed!"
    end
end

# ── Emacs ─────────────────────────────────────────────────────────────────────

function ew --description 'run emacs in gui mode (detached)'
    set -l path (test -n "$argv[1]"; and echo "$argv[1]"; or echo ".")
    emacs $path &; disown
end

function et --description 'run emacs in terminal mode'
    set -l path (test -n "$argv[1]"; and echo "$argv[1]"; or echo ".")
    emacs $path
end

# ── Fonts ─────────────────────────────────────────────────────────────────────

function install-iosevka --description 'install/update Iosevka SS12 and Aile fonts'
    set -l font_dir "$HOME/.local/share/fonts"
    set -l fonts_to_install "IosevkaSS12" "IosevkaAile"
    
    # Fetch latest version from GitHub
    echo "🔍 Checking for latest version..."
    set -l latest_version (curl -s https://api.github.com/repos/be5invis/Iosevka/releases/latest | jq -r '.tag_name' | string trim -c 'v')
    
    if test -z "$latest_version"
        echo "❌ Failed to fetch latest version"
        return 1
    end
    
    echo "🆕 Latest version: $latest_version"
    echo ""
    
    # Create font directory if it doesn't exist
    if not test -d "$font_dir"
        echo "📁 Creating font directory: $font_dir"
        mkdir -p "$font_dir"
    end
    
    set -l any_installed false
    set -l any_failed false
    
    # Install each font
    for font_name in $fonts_to_install
        set -l install_dir "$font_dir/$font_name"
        set -l version_file "$install_dir/.version"
        
        # Get current version if installed
        set -l current_version ""
        if test -f "$version_file"
            set current_version (cat "$version_file")
            echo "📦 $font_name: currently v$current_version"
        else
            echo "📦 $font_name: not installed"
        end
        
        # Check if update is needed
        if test "$current_version" = "$latest_version" -a -d "$install_dir"
            echo "✅ $font_name: already up to date (v$latest_version)"
            echo ""
            continue
        end
        
        # Create install directory
        if not test -d "$install_dir"
            mkdir -p "$install_dir"
        end
        
        # Download the zip file
        set -l zip_url "https://github.com/be5invis/Iosevka/releases/download/v$latest_version/PkgTTC-$font_name-$latest_version.zip"
        set -l temp_zip (mktemp)
        
        echo "📥 Downloading $font_name v$latest_version..."
        curl -L --progress-bar -o "$temp_zip" "$zip_url"
        
        if test $status -ne 0
            echo "❌ Failed to download $font_name"
            rm -f "$temp_zip"
            set any_failed true
            echo ""
            continue
        end
        
        # Remove old font files
        if test -d "$install_dir"
            find "$install_dir" -maxdepth 1 -type f \( -name "*.ttc" -o -name "*.ttf" \) -delete 2>/dev/null
        end
        
        # Extract the zip
        echo "📦 Extracting $font_name..."
        unzip -q -o "$temp_zip" -d "$install_dir"
        
        if test $status -ne 0
            echo "❌ Failed to extract $font_name"
            rm -f "$temp_zip"
            set any_failed true
            echo ""
            continue
        end
        
        # Cleanup
        rm -f "$temp_zip"
        
        # Save version info
        echo "$latest_version" > "$version_file"
        
        echo "✅ $font_name v$latest_version installed"
        echo ""
        set any_installed true
    end
    
    # Refresh font cache if anything changed
    if test "$any_installed" = "true" -o "$any_failed" = "false"
        echo "🔄 Refreshing font cache..."
        if type -q fc-cache
            fc-cache -fv "$font_dir" > /dev/null 2>&1
            echo "✅ Font cache refreshed"
        else
            echo "⚠️  fc-cache not found. Fonts may not be available until reboot or login"
        end
    end
    
    echo ""
    if test "$any_failed" = "true"
        echo "⚠️  Some fonts failed to install. Check the errors above."
        return 1
    else
        echo "✅ All Iosevka fonts are up to date!"
        echo ""
        echo "🔍 To verify installation, run: fc-list | grep -i iosevka"
        return 0
    end
end

# ── Misc ──────────────────────────────────────────────────────────────────────

function every --description 'repeat <cmd> every <s> seconds'
    if test -z "$argv[1]" -o -z "$argv[2]"
        echo "❌ Usage: every <seconds> <command>"
        echo "📖 Example: every 5 'date'"
        echo "📖 Example: every 10 'ls -la'"
        return 1
    end

    if not string match -r '^\d+$' $argv[1]
        echo "❌ Error: Interval must be a number (seconds)"
        return 1
    end

    set -l interval $argv[1]
    set -l cmd $argv[2..]

    echo "⏰ Running '$cmd' every $interval seconds..."
    echo "⚠️  Press Ctrl+C to stop"
    echo ""

    while true
        eval $cmd
        sleep $interval
    end
end

function pr --description 'push branch + gh pr create --fill'
    set -l current_branch (git branch --show-current)

    if test -z "$current_branch"
        echo "❌ Not in a git repository or no branch checked out"
        return 1
    end

    echo "📤 Pushing branch: $current_branch"
    git push --set-upstream origin $current_branch

    if test $status -ne 0
        echo "❌ Push failed!"
        return 1
    end

    echo "🔀 Creating pull request..."
    gh pr create --fill

    if test $status -eq 0
        echo "✅ Pull request created successfully!"
    else
        echo "❌ Pull request creation failed!"
    end
end

function paths --description 'print $PATH one entry per line'
    echo "📋 Current PATH entries:"
    echo "─────────────────────────"
    string split : $PATH | while read -l line
        if test -n "$line"
            echo "  $line"
        end
    end
end
