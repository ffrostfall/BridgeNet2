const { mkdirSync, writeFileSync } = require("fs");
const { copySync } = require("fs-extra")
const { join } = require('path');
const { execFileSync } = require('child_process');
const deletedir = require('rimraf');

const projectName = "BridgeNet2"

const srcDir = join(projectName, "../src");
const packageDir = join(projectName, "../Packages");
const destinationDir = join(projectName, "../standalone");
const destSrcDir = join(destinationDir, "./src");
const standaloneProject = join(projectName, "../standalone.project.json")

mkdirSync(destinationDir);
mkdirSync(destSrcDir);
writeFileSync(join(destinationDir, "./init.luau"), 'return require(script.src)');
writeFileSync(standaloneProject, `{"name": "${ projectName }","tree": {"$path" : "standalone"}}`);

copySync(packageDir, destinationDir);
copySync(srcDir, destSrcDir);

execFileSync('rojo.exe', ["build", "-o standalone.rbxm", "standalone.project.json"]);

deletedir(destinationDir, (err) => {
    if (err) {
        console.log(err)
    } else {
        deletedir(standaloneProject, (s) => {})
        console.log("Built the release and deleted the standalone folder")
    }
});