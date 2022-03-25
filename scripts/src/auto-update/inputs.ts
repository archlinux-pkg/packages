import { getInput } from "@actions/core"

// check inputs from GitHub Actions or environment variables
const inputs = {
  github_token: getInput("token") || process.env.GITHUB_TOKEN,
  commit: getInput("commit") || process.env.COMMIT || true,
  push: getInput("push") || process.env.PUSH || true,
  rebuild: getInput("rebuild") || process.env.REBUILD,
  user: getInput("user") || process.env.MAKEPKG_USER || 'build',
}

export default inputs
