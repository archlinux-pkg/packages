# Add new packages to the repo

A short tutorial on how to add a new package to the repo

## New package from AUR

- In the `packages` folder, create a folder with a name corresponding to the package
- Create a `auto-update.yaml` file in which you add a few lines:
```yaml
aur:
  name: '{{AUR_PACKAGE_NAME}}'
  commit: '{{AUR_PACKAGE_LATEST_COMMIT}}'
```
- replace `{{AUR_PACKAGE_NAME}}` with a package name like `imgurs`
- and replace `{{AUR_PACKAGE_NAME}}` with the latest commit from AUR e.g. `d7277ef73f29714dc22c5f3e8265c847bc0fdd41` to get it, type:
  - `git clone https://aur.archlinux.org/{{AUR_PACKAGE_NAME}}.git`
  - `cd {{AUR_PACKAGE_NAME}}`
  - `git log -n 1 --pretty=format:'%H'`
- Send [PR]

---

## New package that is not in the AUR (or does not compile, or is outdated/dropped)

- In the `packages` folder, create a folder with a name corresponding to the package e.g `imgurs`
- Create a `PKGBUILD` file according to [archlinux docs](https://wiki.archlinux.org/title/PKGBUILD)
- Send [PR]

[PR]: https://github.com/archlinux-pkg/packages/pulls
