type YamlConfig = {
  aur?: YamlConfigAur
  github?: YamlConfigGitHub
  npm?: YamlConfigNPM
  every?: string
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

export default YamlConfig
export { YamlConfig }
