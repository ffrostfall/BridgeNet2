const {
  mkdirSync,
  writeFileSync,
  readFile,
  writeFile,
  readFileSync,
} = require("fs");
const { copySync } = require("fs-extra");
const { join, dirname, basename } = require("path");
const { execFile, execFileSync } = require("child_process");
const { rimraf } = require("rimraf");
const parseArgs = require("minimist");
const { Octokit } = require("octokit");
const moment = require("moment/moment");

const ownerName = "ffrostflame";
const repo = "BridgeNet2";

const cliArgs = parseArgs(process.argv.slice(2), {
  version: {
    short: "v",
    type: "string",
  },
});
const versionString = cliArgs.v;

async function buildStandalone() {
  return new Promise((resolve) => {
    const projectName = basename(dirname(__filename));

    const srcDir = join(projectName, "../src");
    const packageDir = join(projectName, "../Packages");
    const destinationDir = join(projectName, "../standalone");
    const destSrcDir = join(destinationDir, "./src");
    const standaloneProject = join(projectName, "../standalone.project.json");

    mkdirSync(destinationDir);
    mkdirSync(destSrcDir);
    writeFileSync(
      join(destinationDir, "./init.luau"),
      "return require(script.src)"
    );
    writeFileSync(
      standaloneProject,
      `{"name": "${projectName}","tree": {"$path" : "standalone"}}`
    );

    copySync(packageDir, destinationDir);
    copySync(srcDir, destSrcDir);

    execFile(
      "rojo",
      ["build", "-o=standalone.rbxm", "standalone.project.json"],
      () => {
        rimraf(destinationDir)
          .catch((err) => {
            console.log(err);
          })
          .then(() => {
            rimraf(standaloneProject);
            resolve();
          });
      }
    );
  });
}

// absolutely love javascript
let githubAuthToken = readFileSync(
  `${process.env.USERPROFILE}\\github_auth`.replace(/\\/g, "/")
).toString();

const octokit = new Octokit({
  auth: githubAuthToken,
});

readFile("wally.toml", (err, contents) => {
  if (err) {
    console.log(err);
  } else {
    let wallyString = contents.toString();
    let start = wallyString.search('version = "');
    let startVersionString = wallyString.lastIndexOf('"', start + 11) + 1;
    let endVersionString = wallyString.indexOf('"', startVersionString + 3);
    let sectionToReplace = wallyString.slice(
      startVersionString,
      endVersionString
    );
    writeFile(
      "wally.toml",
      wallyString.replace(sectionToReplace, versionString),
      (err) => {
        if (err) {
          console.log(err);
        } else {
          execFileSync("wally.exe", ["publish"]);
        }
      }
    );
  }
});

readFile("CHANGELOG.md", (err, contents) => {
  if (err) {
    console.log(err);
  } else {
    let changelogString = contents.toString();
    let latestStart = changelogString.search(`## version ${versionString}`);
    
    changelogString = changelogString.replace(
      `## version ${versionString}`,
      `## [version ${versionString}](${"testurl"})`
    );
    
    let endOfVersionLine = changelogString.indexOf("\n", latestStart) - 1;
    
    changelogString = [
      changelogString.slice(0, endOfVersionLine),
      `: ${moment().format("l")}`,
      changelogString.slice(endOfVersionLine + 1),
    ].join("");
    
    let latestChangelog = changelogString.slice(
      latestStart,
      changelogString.indexOf("\n## ", latestStart + 5)
    );

    console.log(latestChangelog);
    octokit
      .request("POST /repos/{owner}/{repo}/releases", {
        owner: ownerName,
        repo: repo,
        tag_name: `v${versionString}`,
        target_commitish: "master",
        name: `v${versionString}`,
        body: latestChangelog,
        draft: false,
        prerelease: false,
        make_latest: "false",
        generate_release_notes: false,
        headers: {
          "X-GitHub-Api-Version": "2022-11-28",
        },
      })
      .then((response) => {
        changelogString.replace(
          `testurl`,
          response.data.url
        );
        writeFile("CHANGELOG.md", changelogString, (err) => {
          if (err) {
            console.log(err);
          } else {
            let releaseId = response.data.id;

            buildStandalone().then(() => {
              readFile("standalone.rbxm", (err, rbxmContents) => {
                if (err) {
                  console.log(err);
                } else {
                  octokit.rest.repos
                    .uploadReleaseAsset({
                      owner: ownerName,
                      repo: repo,
                      release_id: releaseId,
                      name: "standalone.rbxm",
                      data: rbxmContents,
                    })
                }
              });
            });
          }
        });
      });
  }
});
