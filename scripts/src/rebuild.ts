import { readdirSync } from 'fs'

import triggerRebuild from './rebuild/trigger'

async function main(dir: string) {
  const dirs = readdirSync(dir)

  for (const pkg of dirs) {
    try {
     try {
        await triggerRebuild(pkg, `${dir}/${pkg}`)
      } catch (err) {
        console.error(err)
      }
    } catch (err) {
      console.error(err)
      continue
    }
  }
}

(async () => {
  // for packages in "packages" folder
  await main(__dirname + "/../../../packages")

  // for packages in "long-build" folder
  await main(__dirname + "/../../../long-build")
})()
