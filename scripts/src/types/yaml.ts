type YamlConfig = {
  aur: YamlConfigAur
  github: YamlConfigGitHub
  npm: YamlConfigNPM
  rebuild: YamlConfigRebuild
}

type YamlConfigAur = {
  name: string
  commit: string
}

type YamlConfigGitHub = {
  author: string
  repo: string
  tag: boolean
}

type YamlConfigNPM = {
  name: string
}

type YamlConfigRebuild = {
  trigger: string
}

export { YamlConfig }
