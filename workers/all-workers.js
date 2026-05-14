const { spawn } = require("child_process");

const workers = [
  ["runtime-worker", "workers/runtime-worker.js"],
  ["super-worker", "workers/super-worker.js"],
  ["connection-sync-worker", "workers/connection-sync-worker.js"],
  ["launch-worker", "workers/launch-worker.js"]
];

for (const [name, file] of workers) {
  const child = spawn("node", [file], {
    stdio: "inherit",
    env: process.env
  });

  child.on("exit", (code) => {
    console.log(`${name} exited with code ${code}`);
  });
}

console.log("UNIC.ai all workers started.");
