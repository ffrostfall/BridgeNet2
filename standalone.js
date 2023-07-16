const {
  mkdirSync,
  writeFileSync
} = require("fs");
const { copySync } = require("fs-extra");
const { join, dirname, basename } = require("path");
const { execFile } = require("child_process");
const { rimraf } = require("rimraf");

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

buildStandalone()