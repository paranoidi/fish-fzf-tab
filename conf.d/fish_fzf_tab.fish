# fish-fzf-tab — fzf-powered tab completion for fish
#
# Install via fisher:
#   fisher install paranoidi/fish-fzf-tab
#
# Manual install:
#   set -U fish_function_path $fish_function_path ~/.config/fish/functions
#   cp functions/__fzf_complete.fish ~/.config/fish/functions/
#
# The key binding is NOT enabled by default to avoid overriding
# fish's built-in pager. Uncomment the line below in your
# config.fish to activate:
#
#   bind \t '__fzf_complete'
#
# To disable the binding at any point (without removing the plugin):
#   set -g fish_fzf_tab_disabled 1
#
# You can pass extra flags to fzf via $fzf_complete_opts, e.g.:
#   set -g fzf_complete_opts --multi --bind=ctrl-a:toggle-all

# Check for fzf dependency on first load
if not command -q fzf
    echo >&2 "fish-fzf-tab: fzf not found. Install fzf first: https://github.com/junegunn/fzf"
end

# Auto-bind if user opted in via universal variable
if status is-interactive
    and not set -q fish_fzf_tab_disabled
    and not bind \t 2>/dev/null | grep -q '__fzf_complete'
    # Only auto-bind if the user explicitly requested it — keep this commented out
    # bind \t '__fzf_complete'
end