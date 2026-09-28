import puppeteer from 'puppeteer-core';
// Usage: node shoot.mjs <url> <out.png> <cssWidth> <cssHeight> [deviceScaleFactor]
const [,, url, out, w, h, dsf = '1'] = process.argv;
const browser = await puppeteer.launch({
  executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe',
  headless: true, args: ['--enable-unsafe-swiftshader', '--use-angle=swiftshader', '--hide-scrollbars'],
});
const page = await browser.newPage();
await page.setViewport({ width: +w, height: +h, deviceScaleFactor: +dsf });
page.on('console', m => { if (m.type() === 'error') console.log('console:', m.text()); });
await page.goto(url, { waitUntil: 'networkidle0', timeout: 90000 });
await page.waitForFunction('window.__done === true', { timeout: 90000 });
await page.screenshot({ path: out });
await browser.close();
console.log('saved', out);
