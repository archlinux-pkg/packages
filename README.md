# Unofficial Repository for Arch Linux

![GIT Repository Size](https://img.shields.io/github/repo-size/archlinux-pkg/packages)

***The build and automatic update scripts are from the [Termux repository](https://github.com/termux/termux-packages) and have been modified to work with makepkg***

## How to use this repo?

**First, install the primary key - it can then be used to install our mirrorlist**

```bash
$ sudo pacman-key --recv-key 7A6646A6C14690C0
$ sudo pacman-key --lsign-key 7A6646A6C14690C0
$ sudo pacman -U 'https://arch-repo.magicuser.cf/packages/medzikuser-mirrorlist-latest-any.pkg.tar.xz'
```

**Append (adding to the end of the file) to `/etc/pacman.conf`:**

```toml
[chaotic-aur]
Include = /etc/pacman.d/medzikuser-mirrorlist
```
