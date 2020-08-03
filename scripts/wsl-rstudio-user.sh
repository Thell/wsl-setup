#!/bin/bash
. ./scripts/99-nexus-translate.sh

: << '//NOTES//'

Execute this script from Windows as user:
wsl -d Ubuntu -u root -- ./scripts/RStudio.sh

It will
- setup RStudio prefs
- setup tinytex

//NOTES//

cd ~
# Complete R environment config.
mkdir -p $(R -s -e "cat(Sys.getenv(c('R_LIBS_USER')))")

# Setup windows browser as environment BROWSER
wsl-open -w

# Complete tinytex package install.
# TODO: eliminate networking calls that aren't going to proxy.
export TINYTEX_DIR=${XDG_LIB_HOME}/tinytex
export CTAN_REPO=http://localhost:8081/repository/texlive/tlnet
wget -O - $(nexus_tinytex_latest) | tar zxf -
mv ./tinytex-* ./tinytex
chmod +x ./tinytex/tools/install-unx.sh
./tinytex/tools/install-unx.sh
mv ~/bin/* ${XDG_BIN_DIR}
rm -r ~/bin ./tinytex

# Setup RStudio Prefs
mkdir -p ${XDG_PROJECTS_DIR}/scratch
RS_PREF_JSON=${XDG_CONFIG_HOME}/rstudio/rstudio-prefs.json
mkdir -p ${RS_PREF_JSON%/*}
cat > ${RS_PREF_JSON} << EOF
{
    "auto_append_newline": true,
    "default_encoding": "UTF-8",
    "default_project_location": "${XDG_PROJECTS_DIR}",
    "editor_theme": "Idle Fingers",
    "font_size_points": 11,
    "highlight_r_function_calls": true,
    "highlight_selected_line": true,
    "initial_working_directory": "${XDG_PROJECTS_DIR}/scratch",
    "line_ending_conversion": "posix",
    "pdf_previewer": "rstudio",
    "posix_terminal_shell": "bash",
    "reduced_motion": true,
    "remove_history_duplicates": true,
    "show_indent_guides": true,
    "strip_trailing_whitespace": true,
    "style_diagnostics": true,
    "syntax_color_console": true,
    "terminal_close_behavior": "clean",
    "use_secure_download": false,
    "use_tinytex": true,
    "warn_variable_defined_but_not_used": true
}
EOF

RS_PREF_INI=${XDG_CONFIG_HOME}/RStudio/desktop.ini
mkdir -p ${RS_PREF_INI%/*}
cat > ${RS_PREF_INI} << \EOF
[General]
desktop.renderingEngine=auto
font.fixedWidth=Cascadia Code PL
EOF
