const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;
const COV_DIR = path.join(ROOT, 'coverage');

function rimraf(p) {
  if (fs.existsSync(p)) fs.rmSync(p, { recursive: true, force: true });
}

rimraf(COV_DIR);
fs.mkdirSync(path.join(COV_DIR, 'tmp'), { recursive: true });

const jestCli = path.join(ROOT, 'node_modules', 'jest', 'bin', 'jest.js');

const res = spawnSync(process.execPath, [jestCli, '--runInBand'], {
  cwd: ROOT,
  env: { ...process.env, NODE_V8_COVERAGE: path.join(COV_DIR, 'tmp') },
  stdio: 'inherit',
});

if (res.status !== 0) {
  console.error('Jest упал, покрытие не считаем.');
  process.exit(res.status || 1);
}

require('./coverage-report');
