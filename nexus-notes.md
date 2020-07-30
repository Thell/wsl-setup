# Nexus Repository Notes

An explanation of what I'm doing with the Nexus setup.

For something like a Github repo with a 'latest' tagged release the URL is:

`https://github.com/jgm/pandoc/releases/latest`

Which resolves to a download page of assets for `${TAG}` release. On that page I identify the desired asset download URL.

`https://github.com/jgm/pandoc/releases/download/${TAG}/pandoc-${TAG}-1-amd64.deb`

Then omit the remote domain portion of the URL `github.com` and create aa similar raw proxy repository on nexus `github` with the remote URL.

This is done in an attempt to keep the URL translation close to the original URL...

```bash
# Remote
https://github.com/mathjax/MathJax/archive/3.0.5.tar.gz
https://github.com/mathjax/Mathjax-third-party-extensions/archive/master.tar.gz
https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-1-amd64.deb
https://s3.amazonaws.com/rstudio-ide-build/desktop/bionic/amd64/rstudio-1.3.1073-amd64.deb

# Nexus (raw proxy type repositories)
http://localhost:8081/repository/github/mathjax/MathJax/archive/3.0.5.tar.gz
http://localhost:8081/repository/github/mathjax/Mathjax-third-party-extensions/archive/master.tar.gz
http://localhost:8081/repository/github/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-1-amd64.deb
http://localhost:8081/repository/rstudio-ide-build/desktop/bionic/amd64/rstudio-1.3.1073-amd64.deb
```

## Resolving the URLs

As explained above...
- Manually identify the repo URL and ensure it uses the 'latest' tag.
- Manually identify the repo release download URL.

then these steps are a fair template on what happens...
1. Use curl's 'follow', 'header' only, and 'write-out' to resolve the latest URL.
2. Use bash variable expansion to keep the tag part of the URL path.
3. Substitute the tag into the release URL.
4. Test Nexus status and substitute the remote domain with the local URL path.
5. Return the appropriate download URL.

Below is an example of getting Pandoc's latest `_amd64.deb` build.

```bash
# When going over this script start at the bottom and work your way up.

_nexus_status() {
  HTTP_STATUS=$(curl -s -w '%{http_code}\n' -X GET http://localhost:8081/service/rest/v1/status)
  [[ ${HTTP_STATUS} -eq 200 ]]
}

_url_effective() {
  curl -s -I -w '%{url_effective}\n' -L $1 -o /dev/null
}

_gh_latest_release_tag() {
  URL=$(_url_effective $1)
  echo ${URL##*/}
}

nexus_pandoc_latest_amd64() {
  # Translate Latest Github Release Tag URL
  URL=https://github.com/jgm/pandoc/releases/latest
  TAG=$(_gh_latest_release_tag ${URL})
  URL=https://github.com/jgm/pandoc/releases/download/${TAG}/pandoc-${TAG}-1-amd64.deb
  if _nexus_status
  then
    URL=$(echo ${URL} | sed 's|s://github.com|://localhost:8081/repository/github|')
  fi
  echo ${URL}
}

## More `nexus_repo_release` functions would follow with similar structure.
```

```bash
# In the build script...
. ./99-nexus-translate.sh
wget -q -O rstudio.deb $(nexus_rstudio_latest_amd64)
wget -q -O pandoc.deb $(nexus_pandoc_latest_amd64)
wget -q -O mathjax.tar.gz $(nexus_mathjax_latest)
wget -q -O mathjax-contrib.tar.gz $(nexus_mathjax_3rd_party_latest)
```

Compared to the original code blocks which use a variety of tools...

```bash
# What a mess...

URL=https://www.rstudio.com/products/rstudio/download/preview/
EXPR='a:contains("Ubuntu") json{}'
EXPR2='.[]|select(.text|contains("RStudio 1.3.1073 - Ubuntu 18/Debian 10 (64-bit)"))|.href|select(endswith("deb"))'
curl -sS -L $URL | pup "${EXPR}" | jq -r "${EXPR2}" > input.txt
printf "\tout=rstudio.deb\n" >> input.txt

URL=https://api.github.com/repos/jgm/pandoc/releases
EXPR='.[]|.assets[]|select(.name|endswith("-amd64.deb"))|.browser_download_url'
curl -sS -L $URL | jq -r "${EXPR}" | head -n 1 >> input.txt
printf "\tout=pandoc.deb\n" >> input.txt

URL=https://api.github.com/repos/MathJax/MathJax/releases/latest
curl -sS -L $URL | jq -r '.tarball_url' >> input.txt
printf "\tout=mathjax.tar.gz\n" >> input.txt

URL=https://github.com/mathjax/MathJax-third-party-extensions/archive/master.tar.gz
printf "${URL}\n\tout=mathjax-contrib.tar.gz\n" >> input.txt

aria2c -q -x 4 -i input.txt
```
