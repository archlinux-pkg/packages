import { getInput } from "@actions/core"

// check inputs from GitHub Actions or environment variables
const inputs = {
  github_token: getInput("token") || process.env.GITHUB_TOKEN,
  rebuild: getInput("commit") || process.env.REBUILD_TYPE || "all",
}

export default inputs
