## ~/.config/fish/conf.d/functions.fish
## All custom functions — sourced automatically by fish at startup.

# ── NixOS rebuild helpers ─────────────────────────────────────────────────────

#function nrs --description 'nixos-rebuild switch'
#    sudo nixos-rebuild switch --flake /etc/nixos $argv
#end

#function nrt --description 'nixos-rebuild test'
#    sudo nixos-rebuild test --flake /etc/nixos $argv
#end

#function nrb --description 'nixos-rebuild boot'
#    sudo nixos-rebuild boot --flake /etc/nixos $argv
#end

#function nup --description 'flake update + rebuild switch'
#    pushd /etc/nixos
#    nix flake update
#    sudo nixos-rebuild switch --flake /etc/nixos $argv
#    popd
#end

#function nrollback --description 'roll back to previous generation'
#    sudo nixos-rebuild switch --rollback
#end

#function ngens --description 'list system generations'
#    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
#end

function ndiff --description 'diff current system vs next rebuild'
    set next (nix build /etc/nixos#nixosConfigurations.default.config.system.build.toplevel \
        --no-link --print-out-paths 2>/dev/null)
    nvd diff /run/current-system $next
end

function nsh --description 'ephemeral nix shell: nsh <pkg>'
    nix shell nixpkgs#$argv[1] $argv[2..]
end

function dev --description 'nix develop [.#name]'
    if test (count $argv) -eq 0
        nix develop
    else
        nix develop .#$argv[1]
    end
end

# ── Filesystem helpers ────────────────────────────────────────────────────────

function mkcd --description 'mkdir -p + cd'
    mkdir -p $argv[1] && cd $argv[1]
end

function fcd --description 'fuzzy cd into subdirectory'
    set dir (find . -type d 2>/dev/null | fzf +m)
    and cd $dir
end

function fe --description 'fuzzy open file in $EDITOR'
    set file (fzf +m)
    and $EDITOR $file
end

function bak --description 'copy <file> to <file>.bak'
    cp $argv[1] $argv[1].bak
end

function ex --description 'extract any archive'
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2';  tar xjf $argv[1]
            case '*.tar.gz';   tar xzf $argv[1]
            case '*.tar.xz';   tar xJf $argv[1]
            case '*.tar.zst';  tar --zstd -xf $argv[1]
            case '*.bz2';      bunzip2 $argv[1]
            case '*.gz';       gunzip $argv[1]
            case '*.tar';      tar xf $argv[1]
            case '*.tbz2';     tar xjf $argv[1]
            case '*.tgz';      tar xzf $argv[1]
            case '*.zip';      unzip $argv[1]
            case '*.7z';       7z x $argv[1]
            case '*.zst';      zstd -d $argv[1]
            case '*';          echo "'$argv[1]' cannot be extracted"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# ── Misc ──────────────────────────────────────────────────────────────────────

function every --description 'repeat <cmd> every <s> seconds'
    set interval $argv[1]
    set cmd $argv[2..]
    while true
        eval $cmd
        sleep $interval
    end
end

function pr --description 'push branch + gh pr create --fill'
    git push --set-upstream origin (git branch --show-current)
    gh pr create --fill
end

function paths --description 'print $PATH one entry per line'
    string split : $PATH
end
