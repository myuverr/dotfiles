# Inherit git completion rules for the dotfiles aliases
complete -c dot --wraps git
complete -c dotpriv --wraps git

# Force loading of system git completions to define helper functions
if not functions -q __fish_git_files
    complete -C "git " >/dev/null 2>&1
end

# Wrap __fish_git_files to filter out 'untracked' when executing completions for the dotfiles repo
if functions -q __fish_git_files; and not functions -q __fish_git_files_orig
    functions -c __fish_git_files __fish_git_files_orig

    function __fish_git_files
        if string match -q -r -- '--git-dir=.*\.dotfiles(-private)?($|/)' (commandline -opc)
            __fish_git_files_orig (string match -v -- untracked $argv)
        else
            __fish_git_files_orig $argv
        end
    end
end
