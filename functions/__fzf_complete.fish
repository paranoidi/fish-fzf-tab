function __fzf_complete -d "Interactively select shell completions via fzf with file/preview support"
    # Grab current command state
    set -l buffer (commandline -b)
    set -l token (commandline -ct)
    set -l cursor (commandline -C)

    # Bail early if nothing to complete
    if test -z "$buffer"
        commandline -f repaint
        return 1
    end

    # Trim buffer up to cursor position
    set -l trimmed (string sub -s 1 -l $cursor -- "$buffer")

    # --- preview commands ---
    # directory lister
    set -l dir_cmd (
        if type -q eza
            echo "eza -lah --git --icons --color=always"
        else
            echo "ls -lah"
        end
    )

    # file viewer
    set -l file_cmd (
        if type -q bat
            echo "bat --style=numbers --color=always --paging=never --wrap=never"
        else
            echo "cat"
        end
    )

    # Build preview script (single-quote-safe via fish -c with escaped vars)
    set -l preview '
fish -c "
    set f {}
    if test -d \$f
        '"$dir_cmd"' \$f
    else if test -f \$f
        '"$file_cmd"' \$f
    else if command -q \$f
        whatis \$f 2>/dev/null
    else if test -e \$f
        '"$dir_cmd"' \$f
    else
        echo \$f
    end
"
'

    # Gather completions from fish's own completion system
    set -l comp_list (complete --do-complete "$trimmed" 2>/dev/null)

    if test -z "$comp_list"
        # No completions available — fall back to fzf over files/dirs directly
        set -l selected (
            fd --type f --type d --hidden --follow --exclude '.git' . 2>/dev/null |
            fzf \
                --query="$token" \
                --height=~40% \
                --layout=reverse \
                --ansi \
                --bind=tab:accept \
                --preview "$preview" \
                --preview-window=down:50%:wrap \
                --prompt="file> " \
                $fzf_complete_opts
        )

        if test -n "$selected"
            commandline -t -- "$selected"
        end
        commandline -f repaint
        return 0
    end

    # Pipe completions through fzf
    set -l selected (
        printf "%s\n" $comp_list |
        fzf \
            --query="$token" \
            --height=~40% \
            --layout=reverse \
            --ansi \
            --bind=tab:accept \
            --preview "$preview" \
            --preview-window=down:50%:wrap \
            --prompt="complete> " \
            $fzf_complete_opts
    )

    # Extract the actual completion value (strip description after tab)
    set -l completion (string split \t -- "$selected")[1]

    if test -n "$completion"
        commandline -t -- "$completion"
    end

    commandline -f repaint
end