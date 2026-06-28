# Set path
fish_add_path -gp /usr/local/bin
fish_add_path -gp /usr/bin
fish_add_path -gp /bin
fish_add_path -gp /usr/local/sbin
fish_add_path -ga $HOME/.local/bin
fish_add_path -ga $HOME/.cargo/bin
fish_add_path -ga $HOME/.bun/bin

# Set environments
set -l _envd_generator /usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator
set -l _envd_target $HOME/.config/environment.d/headless-compat.conf

if test -x $_envd_generator; and test -f $_envd_target
    set -l _tmpdir (mktemp -d)

    # Baseline: generator with an empty user environment.d
    mkdir -p $_tmpdir/empty/environment.d
    set -l _baseline (XDG_CONFIG_HOME=$_tmpdir/empty $_envd_generator 2>/dev/null)

    # With target file: copy it into a fresh user environment.d
    mkdir -p $_tmpdir/target/environment.d
    cp $_envd_target $_tmpdir/target/environment.d/
    set -l _with_file (XDG_CONFIG_HOME=$_tmpdir/target $_envd_generator 2>/dev/null)

    # Import only lines that are new or changed
    for _line in $_with_file
        if not contains -- $_line $_baseline
            set -l _parts (string split -m1 '=' -- $_line)
            if set -q _parts[2]
                set -l _val $_parts[2]
                # Generator outputs POSIX shell double-quoted values;
                # strip quotes and unescape \\, \$, \", \`
                if string match -qr '^".*"$' -- $_val
                    set _val (string sub -s 2 -e -1 -- $_val)
                    set _val (string replace -a "\\\\" \ue000 -- $_val)
                    set _val (string replace -a "\\\$" '$' -- $_val)
                    set _val (string replace -a "\\\"" '"' -- $_val)
                    # set _val (string replace -a "\\`" '`' -- $_val)
                    set _val (string replace -a "\\"\x60 \x60 -- $_val)
                    set _val (string replace -a \ue000 "\\" -- $_val)
                end
                if set -q _parts[1]; and test -n "$_parts[1]"
                    set -gx $_parts[1] $_val
                end
            end
        end
    end

    rm -rf $_tmpdir
else if test -f $_envd_target
    # Fallback: manually parse environment.d(5) format
    set -l _line_num 0
    while read -l _line
        set _line_num (math $_line_num + 1)

        # Skip empty lines and comments
        test -z "$_line"; and continue
        string match -qr '^\s*#' -- $_line; and continue

        # Validate KEY=VALUE format (key must be a valid variable name)
        if not string match -qr '^[A-Za-z_][A-Za-z_0-9]*=' -- $_line
            status is-interactive
            and echo (set_color yellow)"environment.d: $_envd_target:$_line_num: invalid line, skipping"(set_color normal) >&2
            continue
        end

        set -l _key (string replace -r '=.*' '' -- $_line)
        set -l _val (string replace -r '^[^=]*=' '' -- $_line)

        # Strip optional surrounding double quotes
        set _val (string replace -r '^"(.*)"$' '$1' -- $_val)

        # Expand variable references iteratively
        set -l _i 0
        while test $_i -lt 50; and string match -qr '\$' -- $_val
            set _i (math $_i + 1)
            set -l _prev $_val

            # ${VAR:-DEFAULT} — use $VAR if non-empty, else DEFAULT
            if string match -qr '\$\{[A-Za-z_][A-Za-z_0-9]*:-[^}]*\}' -- $_val
                set -l _m (string match -r '^(.*?)\$\{([A-Za-z_][A-Za-z_0-9]*):-([^}]*)\}(.*)$' -- $_val)
                set -l _vn $_m[3]
                if test -n "$$_vn"
                    set _val "$_m[2]$$_vn$_m[5]"
                else
                    set _val "$_m[2]$_m[4]$_m[5]"
                end

            # ${VAR:+ALTERNATE} — use ALTERNATE if $VAR non-empty, else empty
            else if string match -qr '\$\{[A-Za-z_][A-Za-z_0-9]*:\+[^}]*\}' -- $_val
                set -l _m (string match -r '^(.*?)\$\{([A-Za-z_][A-Za-z_0-9]*):\+([^}]*)\}(.*)$' -- $_val)
                set -l _vn $_m[3]
                if test -n "$$_vn"
                    set _val "$_m[2]$_m[4]$_m[5]"
                else
                    set _val "$_m[2]$_m[5]"
                end

            # ${VAR}
            else if string match -qr '\$\{[A-Za-z_][A-Za-z_0-9]*\}' -- $_val
                set -l _m (string match -r '^(.*?)\$\{([A-Za-z_][A-Za-z_0-9]*)\}(.*)$' -- $_val)
                set -l _vn $_m[3]
                set _val "$_m[2]$$_vn$_m[4]"

            # $VAR
            else if string match -qr '\$[A-Za-z_]' -- $_val
                set -l _m (string match -r '^(.*?)\$([A-Za-z_][A-Za-z_0-9]*)(.*)$' -- $_val)
                set -l _vn $_m[3]
                set _val "$_m[2]$$_vn$_m[4]"

            else
                break
            end

            # Guard against infinite loops
            test "$_val" = "$_prev"; and break
        end

        set -q _key; and test -n "$_key"; and set -gx $_key $_val
    end < $_envd_target
end

# Source local-only config
set -l _local_config (status dirname)/config.local.fish
test -f $_local_config; and source $_local_config

if status is-interactive
    # Alias commands
    abbr rm "tp"
    abbr mv "mv -i"
    alias tp "trash-put"
    alias ls "eza --icons --time-style=long-iso --git"
    alias tree "eza --icons --tree --level=3 --time-style=long-iso --git"
    alias dot 'git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    alias dotpriv 'git --git-dir=$HOME/.dotfiles-private/ --work-tree=$HOME'

    # Activations
    starship init fish | source
    zoxide init fish | source
    fzf --fish | source

    # Set theme
    fish_config theme choose tokyonight_night
    set -gx fish_color_valid_path --underline
end
