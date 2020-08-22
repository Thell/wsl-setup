#!/usr/bin/env bash

: <<\#*************************************************************************

Execute this script from Windows as user:
  wsl -d Ubuntu -u root -- ./scripts/wsl-rstudio-user.sh

It will
- setup RStudio prefs
- setup tinytex

#*************************************************************************

# Complete R user environment config.
cd ~
mkdir -p $(R -s -e "cat(Sys.getenv(c('R_LIBS_USER')))")

# Setup windows browser as environment BROWSER for WSL interop.
wsl-open -w

##### TinyTeX
# Utilize pre-built TinyTex bundle.
cd /tmp
CTAN_REPO=http://localhost:8081/repository/texlive/tlnet
TINYTEX_HOME=${XDG_LIB_HOME}/TinyTeX
mkdir -p ${TINYTEX_HOME}
mkdir -p ${XDG_DATA_HOME}/info
mkdir -p ${XDG_DATA_HOME}/man
wget -O TinyTeX.tar.gz $(wsl-proxied-url tinytex)
tar zxf TinyTeX.tar.gz -C ${TINYTEX_HOME} --strip=1

# Customize install paths.
cd ${TINYTEX_HOME}/bin/*/
./tlmgr repository add ${CTAN_REPO} nexus_ctan
./tlmgr option repository nexus_ctan
./tlmgr option sys_bin ${XDG_BIN_DIR}
./tlmgr option sys_info ${XDG_DATA_HOME}/info
./tlmgr option sys_man ${XDG_DATA_HOME}/man
./tlmgr path add

##### RStudio
# User preferences.
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

# Default Font Setup
RS_PREF_INI=${XDG_CONFIG_HOME}/RStudio/desktop.ini
mkdir -p ${RS_PREF_INI%/*}
cat > ${RS_PREF_INI} << \EOF
[General]
desktop.renderingEngine=auto
font.fixedWidth=Fira Code
EOF
