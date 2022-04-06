import { ExecOptions, ExecOutput, getExecOutput } from '@actions/exec'

// exec shell comand
async function shell(commandLine: string, args?: Array<string>, options?: ExecOptions): Promise<ExecOutput> {
  const output = await getExecOutput(commandLine, args, options);

  if (output.exitCode !== 0)
    throw new Error(`${commandLine} command error with code ${output.exitCode}`)

  return output
}

export default shell
