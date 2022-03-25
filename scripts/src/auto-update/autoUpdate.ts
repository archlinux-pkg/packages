import { Octokit } from "@octokit/core"
import { mkdtempSync, readFileSync, writeFileSync } from "fs"
import { tmpdir } from "os"

import fetch from "cross-fetch"
import YAML from "yaml"

import shell from "../shell"
import inputs from "./inputs"
import { YamlConfig } from "../types/yaml"

// create a client for GitHub API
const octokit = new Octokit({ auth: inputs.github_token })

const TEMP_DIR = mkdtempSync(`${tmpdir()}/medzik-`)

async function autoUpdate(pkg: string, pkgdir: string) {
  const file = readFileSync(`${pkgdir}/auto-update.yaml`, 'utf8')

  let config: YamlConfig = YAML.parse(file)

  // update AUR package
  if (config.aur) {
    await shell("git", ["clone", `https://aur.archlinux.org/${config.aur.name}.git`, `${TEMP_DIR}/${pkg}`])

    // AUR package commit hash
    const commit_long = (await shell("bash", ["-c", `cd ${TEMP_DIR}/${pkg} && git log -n 1 --pretty=format:"%H"`])).stdout.replace('\n', '')
    const commit_short = (await shell("bash", ["-c", `cd ${TEMP_DIR}/${pkg} && git log -n 1 --pretty=format:"%h"`])).stdout.replace('\n', '')

    // check pkgver from the `PKGBUILD` file
    let pkg_version = (await shell("bash", ["-c", `. ${TEMP_DIR}/${pkg}/PKGBUILD && printf $pkgver`])).stdout.replace('\n', '')
    let pkg_rel = (await shell("bash", ["-c", `. ${TEMP_DIR}/${pkg}/PKGBUILD && printf $pkgrel`])).stdout.replace('\n', '')

    if (config.aur.commit != commit_long) {
      config.aur.commit = commit_long

      writeFileSync(`${pkgdir}/auto-update.yaml`, YAML.stringify(config))

      // commit new version
      if (inputs.commit) {
        await shell("git", ["add", `${pkgdir}`])
        await shell("git", ["commit", "-m", `upgpkg: '${pkg}' to AUR commit '${commit_short}' (${pkg_version}-${pkg_rel})`])

        // push changes to remote
        if (inputs.push) {
          await shell("git", ["push"])
        }
      }
    }
  }

  // update PKGBUILD
  let version: string

  // check latest version from GitHub by Tags
  if (config.github?.tag) {
    const response = await octokit.request("GET /repos/{author}/{repo}/tags", {
      author: config.github.author,
      repo: config.github.repo
    })

    version = response.data[0].name
      // replace "_" into ".": some packages use underscores to seperate
      // version numbers, but we require them to be separated by dot
      .replace(/_/g, '.')

      // remove leading "v" or "r"
      .replace(/^v|^r/, '')

      // replace "-" into "."
      // pacman does not support "-" in pkgver
      .replace(/-/g, '.')
  }

  // check latest version from GitHub by Releases
  else if (config.github) {
    const response = await octokit.request("GET /repos/{author}/{repo}/releases/latest", {
      author: config.github.author,
      repo: config.github.repo
    })

    version = response.data.tag_name
      // replace "_" into ".": some packages use underscores to seperate
      // version numbers, but we require them to be separated by dot
      .replace(/_/g, '.')

      // remove leading "v" or "r"
      .replace(/^v|^r/, '')

      // replace "-" into "."
      // pacman does not support "-" in pkgver
      .replace(/-/g, '.')
  }

  // check latest version from npmjs.org
  else if (config.npm) {
    let res = await fetch(`https://unpkg.com/${config.npm.name}/package.json`)
    let data = await res.json()

    version = data.version
  }

  // if no automatic update method detected do not continue
  else {
    return
  }

  // check pkgver from the `PKGBUILD` file
  let pkg_version = (await shell("bash", ["-c", `. ${pkgdir}/PKGBUILD && printf $pkgver`])).stdout.replace('\n', '')

  // compare versions
  let ver = (await shell("bash", ["-c", `echo -e "${pkg_version}\n${version}" | sort -V | head -n 1`])).stdout.replace('\n', '')

  // if new version
  if (ver != version) {
    console.log(`Updating version: ${version} -> ${pkg_version}`)

    let pkg_dir = `${pkgdir}`
    let PKGBUILD = `${pkg_dir}/PKGBUILD`

    let data = readFileSync(PKGBUILD, 'utf8')

    // replace `pkgver` to new version
    data = data.replace(/pkgver=.*/, `pkgver='${version}'`)

    // write changes
    writeFileSync(PKGBUILD, data)

    // update package checksum
    await shell("chown", ["-R", inputs.user, pkg_dir])
    await shell("su", ["-c", `cd ${pkg_dir} && updpkgsums`, inputs.user])

    // commit new version
    if (inputs.commit) {
      await shell("git", ["add", `${pkg_dir}`])
      await shell("git", ["commit", "-m", `upgpkg: '${pkg}' to '${version}'`])

      // push changes to remote
      if (inputs.push) {
        await shell("git", ["push"])
      }
    }
  } else {
    console.log(`Latest Version -> ${version}`)
    console.log(`Package Version -> ${pkg_version}`)
  }
}

export default autoUpdate
