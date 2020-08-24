# Nexus Repository Notes

Ideally, all of the assets downloaded during the build would be the 'latest' version and would be cached in the Nexus proxy repository.

To do this the original source url giving the tag value for the latest version is identified along with the pattern used for the download url.

For example, the latest tag for pandoc can be found at:

`tag_url=https://github.com/jgm/pandoc/releases/latest`

And the associated release download url follows the pattern of:

`url=https://github.com/jgm/pandoc/releases/download/${TAG}/pandoc-${TAG}-1-amd64.deb`

Originally I was getting the latest tag versions by following the headers for the `tag_url`.

```bash
_url_effective() {
  curl -s -I -w '%{url_effective}\n' -L $1 -o /dev/null
}

_gh_latest_release_tag() {
  URL=$(_url_effective $1)
  echo ${URL##*/}
}
```

Since the `url_effective` was a redirect only the final download was cached.
Adding a proxy to the source of the `latest` tag and making the request to that url allows tag caching too.

`tag_url=https://api.github.com/repos/jgm/pandoc/releases/latest`


```bash
_gh_latest_release_tag() {
  path=$1
  url=https://api.github.com/repos${path}/latest
  [[ ${base_url:-} ]] && url=${url/"http"?":/"/"${base_url}"}
  tag=$(jq -r '.tag_name' <(curl -s ${url}))
  echo ${tag}
}
```

Pretty straight forward.

## Resolving the URLs

As explained above...

- Manually identify the source's URL and ensure its 'latest' tag.
- Manually identify the source's release download URL.

then these steps are a fair template on what happens...

1. Get the latest tag.
2. Substitute the tag into the release URL.
4. Test Nexus status and insert the proxy url path.
5. Return the appropriate download URL.

Below is an example of getting Pandoc's latest `_amd64.deb` build.

```bash
asset=$1

if (echo "GET /service/rest/v1/status" >/dev/tcp/localhost/8081) &>/dev/null
then
  base_url="http://localhost:8081/repository"
fi

_gh_latest_release_tag() {
  path=$1
  url=https://api.github.com/repos${path}/latest
  [[ ${base_url:-} ]] && url=${url/"http"?":/"/"${base_url}"}
  tag=$(jq -r '.tag_name' <(curl -s ${url}))
  echo ${tag}
}

case "${asset,,}" in
  # ...
  "pandoc")
    path=/jgm/pandoc/releases
    tag=$(_gh_latest_release_tag ${path})
    : https://github.com${path}/download/${tag}/pandoc-${tag}-1-amd64.deb
  ;;
  # ...
esac
url="$_"

[[ ${base_url:-} ]] && url=${url/"http"?":/"/"${base_url}"}
echo ${url}
```

The translator, `wsl-proxied-url`, is installed during the base build and used like...

```bash
wget -O rstudio.deb $(wsl-proxied-url rstudio)
wget -O pandoc.deb $(wsl-proxied-url pandoc)
wget -O mathjax.tar.gz $(wsl-proxied-url mathjax)
wget -O mathjax-contrib.tar.gz $(wsl-proxied-url mathjax-third-party-extensions)
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

This is all fine and dandy if working with sources hosted on github but what about when they aren't?

RStudio provides download pages for stable, preview and daily builds. They also provide links to download the latest build of each for a variety of platforms. These builds are hosted on Amazon AWS and accessed via redirection from rstudio.org.

Caching both the tag and package in the Nexus repository is done by using a github repo for the tags, a repository for `raw.githubusercontent.com` and another for `s3.amazonaws.com`. A script to generate a json containing the latest direct urls is updated daily, then the raw content is requested, which gets cached, and the desired RStudio build is directly downloaded, which is also cached, with a package name that contains the version.

With these few things setup the usage is just as straight forward as the earlier pandoc example...

```bash
  "rstudio")
    path=".preview.desktop.bionic.rstudio"
    url=https://raw.githubusercontent.com/thell/rstudio-latest-urls/master/latest.json
    [[ ${base_url:-} ]] && url=${url/"http"?":/"/"${base_url}"}
    : $(jq -r ${path} <(curl -s ${url}))
  ;;
```
