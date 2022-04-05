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

  // rebuild packages
  if (inputs.rebuild && inputs.rebuild != "") {
    if (config.every && config.every == inputs.rebuild) {
      const response = await octokit.request("POST /repos/archlinux-pkg/packages/actions/workflows/{workflow_id}/dispatches", {
        workflow_id: 'build.yml',
        ref: 'main',
        inputs: {
          packages: pkg
        }
      })

      console.log(response.data[0])
    }

    return
  }

  // update AUR package
  if (config.aur) {
    // AUR package commit hash
    const commit_shell = await shell("bash", ["-c", `git ls-remote https://aur.archlinux.org/${config.aur.name}.git refs/heads/master | awk '{print $1}'`])
    if (commit_shell.exitCode != 0) {
      throw new Error(`exited command with code = ${commit_shell.exitCode}`)
    }

    const commit = commit_shell.stdout.replace('\n', '')
    if (commit == "") {
      throw new Error(`commit variable is empty`)
    }

    // check pkgver
    let pkgbuild_shell = await shell("wget", [`https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=${config.aur.name}`, "-O", `${TEMP_DIR}/${pkg}_PKGBUILD`])
    if (pkgbuild_shell.exitCode != 0) {
      throw new Error(`exited command with code = ${pkgbuild_shell.exitCode}`)
    }

    let pkg_version = (await shell("bash", ["-c", `. ${TEMP_DIR}/${pkg}_PKGBUILD && printf $pkgver`])).stdout.replace('\n', '')
    let pkg_rel = (await shell("bash", ["-c", `. ${TEMP_DIR}/${pkg}_PKGBUILD && printf $pkgrel`])).stdout.replace('\n', '')

    if (pkg_version == "" || pkg_rel == "") {
      throw new Error(`pkg_rel or pkg_version is empty`)
    }

    if (config.aur.commit != commit) {
      config.aur.commit = commit

      writeFileSync(`${pkgdir}/auto-update.yaml`, YAML.stringify(config))

      // commit new version
      if (inputs.commit) {
        await shell("git", ["add", `${pkgdir}/auto-update.yaml`])
        await shell("git", ["commit", "-m", `upgpkg: '${pkg}' to '${pkg_version}-${pkg_rel}'`])

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
    data = data.replace(/pkgrel=.*/, `pkgrel=1`)

    // write changes
    writeFileSync(PKGBUILD, data)

    // update package checksum
    await shell("chown", ["-R", inputs.user, pkg_dir])
    await shell("su", ["-c", `cd ${pkg_dir} && updpkgsums`, inputs.user])

    // commit new version
    if (inputs.commit) {
      await shell("git", ["add", `${pkg_dir}/PKGBUILD`])
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
