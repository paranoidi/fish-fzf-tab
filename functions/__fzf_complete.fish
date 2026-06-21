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

    # Preview: pass selected item as argv to avoid word-splitting on spaces
    set -l preview 'fish -c '"'"'__fzf_complete_preview $argv[1]'"'"' -- "{}"'

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
                --bind=tab:down \
                --bind=ctrl-j:preview-down \
                --bind=ctrl-k:preview-up \
                --preview "$preview" \
                --preview-window=right:60%:wrap \
                --prompt="file> " \
                $fzf_complete_opts
        )

        if test -n "$selected"
            commandline -t -- (string replace -a "'" "\\'" -- (string replace -a ' ' '\ ' -- "$selected"))
        end
        commandline -f repaint
        return 0
    else if test (count $comp_list) -eq 1
        # Only one completion — apply it directly, skip fzf
        set -l completion (string split \t -- "$comp_list[1]")[1]
        commandline -t -- (string replace -a "'" "\\'" -- (string replace -a ' ' '\ ' -- "$completion"))
        commandline -f repaint
        return 0
    else
        # Multiple completions — skip fzf if exactly one is a file (non-directory)
        set -l file_vals
        for c in $comp_list
            set -l val (string split \t -- "$c")[1]
            string match -q '*/' -- "$val"; or set -a file_vals "$val"
        end
        if test (count $file_vals) -eq 1
            commandline -t -- (string replace -a "'" "\\'" -- (string replace -a ' ' '\ ' -- "$file_vals[1]"))
            commandline -f repaint
            return 0
        end
    end

    # Pipe completions through fzf with aligned columns
    set -l selected (
        printf "%s\n" $comp_list |
        awk -F'\t' '
            { lines[NR]=$0; f1[NR]=$1; f2[NR]=$2; if(length($1)>max) max=length($1) }
            END { for(i=1;i<=NR;i++) {
                if(f2[i]!="") printf "%-*s\t%s\n", max+2, f1[i], f2[i]
                else printf "%s\n", f1[i]
            }}
        ' |
        fzf \
            --query="$token" \
            --height=~40% \
            --layout=reverse \
            --ansi \
            --bind=tab:down \
            --bind=ctrl-j:preview-down \
            --bind=ctrl-k:preview-up \
            --preview "$preview" \
            --preview-window=right:60%:wrap \
            --prompt="complete> " \
            $fzf_complete_opts
    )

    # Extract the actual completion value (strip description after tab, then strip padding)
    set -l completion (string split \t -- "$selected")[1]
    set -l completion (string trim -r -- "$completion")

    if test -n "$completion"
        commandline -t -- (string replace -a "'" "\\'" -- (string replace -a ' ' '\ ' -- "$completion"))
    end

    commandline -f repaint
end
