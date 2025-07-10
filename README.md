-----

# dotfiles

My dotfiles

-----

## Installation

```bash
# Install Stow (if you haven't already)
sudo dnf install stow

# Clone the dotfiles repository
git clone https://github.com/lossthannothing/.dotfiles.git

# Deploy all modules using Stow
cd ~/.dotfiles
for module in *; do
  if [ -d "$module" ] && [ "$module" != ".git" ]; then
    stow "$module"
  fi
done
```

-----

## Cleanup (Undo All Modules)

```bash
# Go to your home directory
cd ~

# Undeploy all modules using Stow
for dir in ~/.dotfiles/*; do
  if [ -d "$dir" ] && [ "$(basename "$dir")" != ".git" ]; then
    stow -D -t ~ "$(basename "$dir")"
  fi
done

# Clean up any residual, incorrect top-level symlinks (e.g., ~/bash, ~/config)
if [ -L ~/bash ]; then rm ~/bash; fi
if [ -L ~/config ]; then rm ~/config; fi
if [ -L ~/ssh ]; then rm ~/ssh; fi
if [ -L ~/zsh ]; then rm ~/zsh; fi
```
