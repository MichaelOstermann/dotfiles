set fish_greeting
starship init fish | source
fish_add_path "/home/michael/.bun/bin"
fish_add_path ~/.npm-global/bin

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

set -gx EDITOR nvim

if status is-interactive
    # Commands to run in interactive sessions can go here
end
