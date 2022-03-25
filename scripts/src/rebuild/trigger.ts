import { readFileSync } from "fs"
import YAML from "yaml"

import shell from "../shell"
import inputs from "./inputs"
import { YamlConfig } from "../types/yaml"

async function triggerRebuild(pkg: string, pkgdir: string) {
  const file = readFileSync(`${pkgdir}/auto-update.yaml`, 'utf8')

  let config: YamlConfig = YAML.parse(file)

  // if trigger rebuild enabled
  if (config.rebuild?.trigger == inputs.rebuild) {
    await shell("bash", ["-c", `GITHUB_TOKEN=${inputs.github_token} && gh workflow run build.yml -f packages="${pkg}"`])
  }
}

export default triggerRebuild
