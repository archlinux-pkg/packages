import { group } from '@actions/core'
import { readdirSync } from 'fs'

import autoUpdate from './auto-update/autoUpdate'

const timer = (ms: number) => new Promise(res => setTimeout(res, ms))

async function main(dir: string) {
  const dirs = readdirSync(dir)

  for (const pkg of dirs) {
    await timer(1 * 1000)

    try {
      await group<void>(`Updating package '${pkg}'...`, async () => {
        try {
          await autoUpdate(pkg, `${dir}/${pkg}`)
        } catch (err) {
          console.error(err)
        }
      })
    } catch (err) {
      console.error(err)
      continue
    }
  }
}

(async () => {
  // for packages in "packages" folder
  await main(__dirname + "/../../packages")

  // for packages in "long-build" folder
  await main(__dirname + "/../../long-build")
})()
