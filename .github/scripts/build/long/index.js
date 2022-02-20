"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const artifact_1 = __importDefault(require("@actions/artifact"));
const core_1 = __importDefault(require("@actions/core"));
const exec_1 = __importDefault(require("@actions/exec"));
const github_1 = __importDefault(require("@actions/github"));
const fs_1 = require("fs");
const shell = async (commandLine, args, options) => {
    const code = await exec_1.default.exec(commandLine, args, options);
    if (code !== 0)
        throw new Error(`Stage: A ${commandLine} command errored with code ${code}`);
};
(async () => {
    const output = () => {
        console.log('Stage: Setting output', {
            'finished': input.finished,
            'package': input.package,
            'use-registry': input.useRegistry,
            'image-tag': input.imageTag
        });
        core_1.default.setOutput('finished', input.finished);
        core_1.default.setOutput('use-registry', input.useRegistry);
        core_1.default.setOutput('image-tag', input.imageTag);
    };
    const artifact = artifact_1.default.create();
    const input = {
        finished: core_1.default.getInput('finished') === 'true',
        progressName: core_1.default.getInput('progress-name'),
        package: core_1.default.getInput('package', { required: true }),
        useRegistry: core_1.default.getInput('use-registry') === 'true',
        registryToken: core_1.default.getInput('registry-token'),
        imageTag: core_1.default.getInput('image-tag')
    };
    console.log('Stage: Got input', input);
    if (input.finished)
        return output();
    // Taken from https://github.com/easimon/maximize-build-space/blob/master/action.yml
    await core_1.default.group('Stage: Free space on GitHub Runner...', async () => {
        await shell('sudo rm -rf /usr/share/dotnet');
        await shell('sudo rm -rf /usr/local/lib/android');
        await shell('sudo rm -rf /opt/ghc');
    });
    if (input.useRegistry) {
        await core_1.default.group('Stage: Logging into docker registry...', () => shell('docker', ['login', 'ghcr.io', '-u', github_1.default.context.actor, '-p', input.registryToken]));
        await core_1.default.group('Stage: Pulling image from registry...', () => shell('docker', ['pull', input.imageTag]));
    }
    else {
        await core_1.default.group('Stage: Downloading image artifact...', () => artifact.downloadArtifact('image'));
        await core_1.default.group('Stage: Loading image from file...', () => shell('docker load --input image'));
        await core_1.default.group('Stage: Removing image file...', () => shell('rm image'));
    }
    await core_1.default.group('Stage: Creating input, output and progress directory...', () => shell('mkdir input output progress'));
    if (input.progressName !== '') {
        await core_1.default.group('Stage: Downloading progress artifact...', () => artifact.downloadArtifact(input.progressName));
        await core_1.default.group('Stage: Moving progress archive into input directory...', () => shell('mv progress.tar.zst input'));
    }
    const mount = (directory) => ['--mount', `type=bind,source=${process.cwd()}/${directory},target=/mnt/${directory}`];
    await core_1.default.group('Stage: Running docker container...', () => shell('docker', ['run', '-e', 'TIMEOUT=330', ...mount('input'), ...mount('output'), ...mount('progress'), input.imageTag]));
    if ((0, fs_1.readdirSync)('output').length !== 0) {
        console.log('Stage: Successfully built package');
        input.finished = true;
    }
    await core_1.default.group('Stage: Uploading progress...', () => artifact.uploadArtifact(github_1.default.context.job, (0, fs_1.readdirSync)('progress').map(node => `progress/${node}`), 'progress'));
    if (input.finished)
        await core_1.default.group('Stage: Uploading package...', () => artifact.uploadArtifact(input.package, (0, fs_1.readdirSync)('output').map(node => `output/${node}`), 'output'));
    output();
})().catch(core_1.default.setFailed);
