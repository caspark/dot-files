# WSL tweaks

Due to WSL2 taking up too much memory and not releasing it back to Windows, we
need to limit the amount of memory used by WSL2 by setting some settings in
`.wslconfig` in the Windows User's directory.

Source: https://github.com/microsoft/WSL/issues/4166

Info on the workaround:

* https://github.com/microsoft/WSL/issues/4166#issuecomment-526725261
* https://docs.microsoft.com/en-us/windows/wsl/release-notes#build-18945

If memory is running low because it's consumed by Linux caching everything, then
clear the cache with:

``` sh
echo "sync && echo 3 > /proc/sys/vm/drop_caches" | sudo sh
```
