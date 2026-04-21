const fs = require('fs');
const path = require('path');

const TARGETS = [
  '../../CoursePSKP/server/src/services/bookingService.js',
  '../../CoursePSKP/server/src/services/subscriptionService.js',
  '../../CoursePSKP/server/src/services/visitService.js',
];

const TMP_DIR = path.resolve(__dirname, 'coverage', 'tmp');

function loadCoverageEntries() {
  const files = fs.readdirSync(TMP_DIR);
  const merged = new Map();

  for (const f of files) {
    const data = JSON.parse(fs.readFileSync(path.join(TMP_DIR, f), 'utf8'));
    for (const r of data.result) {
      const decoded = decodeURIComponent(r.url.replace(/^file:\/\/\//, ''));
      if (!TARGETS.some((t) => decoded.endsWith(path.basename(t)))) continue;

      if (!merged.has(decoded)) merged.set(decoded, r.functions);
      else {
        const existing = merged.get(decoded);
        for (let i = 0; i < r.functions.length; i++) {
          for (let j = 0; j < r.functions[i].ranges.length; j++) {
            const nc = r.functions[i].ranges[j].count;
            if (nc > (existing[i]?.ranges[j]?.count || 0)) {
              existing[i].ranges[j] = r.functions[i].ranges[j];
            }
          }
        }
      }
    }
  }
  return merged;
}

function isByteCovered(offset, ranges) {
  let currentCount = 0;
  for (const r of ranges) {
    if (r.startOffset <= offset && offset < r.endOffset) currentCount = r.count;
  }
  return currentCount > 0;
}

function coveredLinesFromRanges(source, functions) {
  const lineStarts = [0];
  for (let i = 0; i < source.length; i++) {
    if (source[i] === '\n') lineStarts.push(i + 1);
  }
  const totalLines = lineStarts.length;

  const allRanges = [];
  for (const fn of functions) for (const r of fn.ranges) allRanges.push(r);
  allRanges.sort((a, b) => a.startOffset - b.startOffset || b.endOffset - a.endOffset);

  let covered = 0;
  let countableLines = 0;
  for (let i = 0; i < lineStarts.length; i++) {
    const start = lineStarts[i];
    const end = i + 1 < lineStarts.length ? lineStarts[i + 1] - 1 : source.length;
    const lineText = source.slice(start, end).trim();
    if (!lineText || lineText.startsWith('//') || lineText.startsWith('*') || lineText === '/**' || lineText === '*/') continue;
    countableLines++;
    let lineCovered = false;
    for (let off = start; off < end; off++) {
      if (/\s/.test(source[off])) continue;
      if (isByteCovered(off, allRanges)) {
        lineCovered = true;
        break;
      }
    }
    if (lineCovered) covered++;
  }
  return { totalLines: countableLines, coveredLines: covered };
}

function main() {
  if (!fs.existsSync(TMP_DIR)) {
    console.error('Нет данных покрытия. Сначала запусти: npm run test:coverage');
    process.exit(1);
  }
  const merged = loadCoverageEntries();

  console.log('\n==========  ОТЧЁТ О ПОКРЫТИИ  ==========\n');
  console.log('File                         |  Lines  |  %    |  Ranges |  %    |');
  console.log('-----------------------------+---------+-------+---------+-------+');

  let totalLines = 0;
  let coveredLines = 0;
  let totalRanges = 0;
  let coveredRanges = 0;

  for (const target of TARGETS) {
    const absPath = path.resolve(__dirname, target);
    const [, fns] = [...merged.entries()].find(([k]) => k.replace(/\\/g, '/').endsWith(target.split('/').pop())) || [];
    if (!fns) {
      console.log(`${path.basename(target).padEnd(29)} |  NO DATA`);
      continue;
    }

    const src = fs.readFileSync(absPath, 'utf8');
    const { totalLines: tL, coveredLines: cL } = coveredLinesFromRanges(src, fns);

    let tR = 0;
    let cR = 0;
    for (const fn of fns) {
      for (const r of fn.ranges) {
        tR++;
        if (r.count > 0) cR++;
      }
    }

    const linePct = ((cL / tL) * 100).toFixed(1);
    const rangePct = ((cR / tR) * 100).toFixed(1);
    console.log(
      `${path.basename(target).padEnd(29)} | ${String(cL + '/' + tL).padEnd(7)} | ${linePct.padStart(5)} | ${String(cR + '/' + tR).padEnd(7)} | ${rangePct.padStart(5)} |`
    );

    totalLines += tL;
    coveredLines += cL;
    totalRanges += tR;
    coveredRanges += cR;
  }

  console.log('-----------------------------+---------+-------+---------+-------+');
  console.log(
    `${'TOTAL'.padEnd(29)} | ${String(coveredLines + '/' + totalLines).padEnd(7)} | ${((coveredLines / totalLines) * 100).toFixed(1).padStart(5)} | ${String(coveredRanges + '/' + totalRanges).padEnd(7)} | ${((coveredRanges / totalRanges) * 100).toFixed(1).padStart(5)} |`
  );
  console.log('\nRanges = V8-блоки функций (аналог branch coverage).\n');
}

main();
