# Unofficial Repository for Arch Linux

## How to use this repo?

**First, install the primary key - it can then be used to install our mirrorlist**

```bash
sudo pacman-key --recv-key 7A6646A6C14690C0
sudo pacman-key --lsign-key 7A6646A6C14690C0
sudo pacman -U 'https://arch-repo.magicuser.cf/medzikuser-mirrorlist.pkg.tar.xz'
```

**This command will add what repo to pacman.conf**

```bash
echo '
[medzikuser]
SigLevel = DatabaseOptional
Include = /etc/pacman.d/mirrorlist-medzikuser' | sudo tee --append /etc/pacman.conf
```

[Built-AUR](https://github.com/built-aur/packages)
