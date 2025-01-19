# Show this help message.
@default:
    just --list --unsorted

# List all recipes.
@list:
    just --list --unsorted

alias help := list

# ┌┬─────────────────────────┐
# ││ Deploy recipes          │
# └┴─────────────────────────┘

# Build and activate the new configuration.
[group('deploy')]
@deploy:
    nixos-rebuild switch --flake . --use-remote-sudo

# Debug mode for the deploy recipe.
[group('deploy')]
@debug:
    nixos-rebuild switch --flake . --use-remote-sudo --no-eval-cache --show-trace --print-build-logs --verbose

# ┌┬─────────────────────────┐
# ││ Update recipes          │
# └┴─────────────────────────┘

# Update all flake inputs.
[group('update')]
@up:
    nix flake update

# Update a specific flake input.
[group('update')]
@up-only input:
    nix flake update {{input}}

# ┌┬─────────────────────────┐
# ││ Maintenance recipes     │
# └┴─────────────────────────┘

# Show the differences between subsequent versions of the system profile.
[group('maintenance')]
@history:
    nix profile diff-closures --profile /nix/var/nix/profiles/system

# Show the changes in the current version of the system profile.
[group('maintenance')]
changes:
    #!/usr/bin/env bash
    set -euo pipefail
    curr=$(nixos-rebuild list-generations --json | jq -r .[0].generation | perl -pe 'chomp if eof')
    prev=$(nixos-rebuild list-generations --json | jq -r .[1].generation | perl -pe 'chomp if eof')
    echo "Changes from generation $prev to generation $curr:"
    diff=$(nix store diff-closures /nix/var/nix/profiles/system-{$prev,$curr}-link)
    if [[ -z "$diff" ]]; then
        echo 'No changes.'
    else
        printf '%s' "$diff"
    fi

# Remove all system and user generations older than 90 days.
[confirm('This will DELETE all system and user generations older than 90 days. Do you want to continue?')]
[group('maintenance')]
@gc:
    sudo nix-collect-garbage --delete-older-than 90d
    nix-collect-garbage --delete-older-than 90d

# Remove all system and user generations older than 45 days.
[confirm('This will DELETE all system and user generations older than 45 days. Do you want to continue?')]
[group('maintenance')]
@gc-more:
    sudo nix-collect-garbage --delete-older-than 45d
    nix-collect-garbage --delete-older-than 45d

# ┌┬─────────────────────────┐
# ││ Development recipes     │
# └┴─────────────────────────┘

# Enter the Nix REPL with nixpkgs loaded.
[group('develop')]
@repl:
  nix repl -f flake:nixpkgs

# Build and run the configuration of the selected host inside a VM.
[group('develop')]
@vm host:
    nixos-rebuild build-vm --flake .#{{host}} && ./result/bin/run-{{host}}-vm
