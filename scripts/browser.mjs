#!/usr/bin/env node

/**
 * Playwright ブラウザ自動操作 CLI
 *
 * 使い方:
 *   node scripts/browser.mjs scrape <url> [--selector <css>]
 *   node scripts/browser.mjs screenshot <url> [--output <path>] [--full-page]
 *   node scripts/browser.mjs search <query> [--num <n>] [--lang <code>]
 *   node scripts/browser.mjs interact <url> --actions '<json>'
 *
 * 共通オプション:
 *   --headful            ブラウザウィンドウを表示（デフォルトはheadless）
 *   --timeout <ms>       タイムアウト（デフォルト: 30000ms）
 *   --user-agent <str>   カスタムUser-Agent文字列
 */

import { chromium } from 'playwright-core';
import { writeFile, mkdir } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { parseArgs } from 'node:util';

// --- 引数パース ---

const { values: flags, positionals } = parseArgs({
  allowPositionals: true,
  strict: false,
  options: {
    selector: { type: 'string' },
    output: { type: 'string' },
    'full-page': { type: 'boolean', default: false },
    num: { type: 'string', default: '10' },
    lang: { type: 'string', default: 'ja' },
    actions: { type: 'string' },
    headful: { type: 'boolean', default: false },
    timeout: { type: 'string', default: '30000' },
    'user-agent': { type: 'string' },
    help: { type: 'boolean', default: false },
  },
});

const [command, ...rest] = positionals;
const timeout = parseInt(flags.timeout, 10);

// --- 定数 ---

const DEFAULT_USER_AGENT =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36';

// --- ヘルパー ---

function printUsage() {
  console.log(`Usage:
  node cli.mjs scrape <url> [--selector <css>]
  node cli.mjs screenshot <url> [--output <path>] [--full-page]
  node cli.mjs search <query> [--num <n>] [--lang <code>]
  node cli.mjs interact <url> --actions '<json>'

Common options:
  --headful            Show browser window
  --timeout <ms>       Timeout (default: 30000)
  --user-agent <str>   Custom User-Agent`);
}

function fail(message) {
  console.error(JSON.stringify({ error: message }));
  process.exit(1);
}

function output(data) {
  console.log(JSON.stringify(data, null, 2));
}

async function ensureDir(filePath) {
  await mkdir(dirname(resolve(filePath)), { recursive: true });
}

async function launchBrowser() {
  return chromium.launch({
    channel: 'chrome',
    headless: !flags.headful,
    args: [
      '--disable-blink-features=AutomationControlled',
    ],
  });
}

async function newPage(browser) {
  const context = await browser.newContext({
    userAgent: flags['user-agent'] || DEFAULT_USER_AGENT,
    viewport: { width: 1920, height: 1080 },
    locale: flags.lang || 'ja-JP',
    timezoneId: 'Asia/Tokyo',
    extraHTTPHeaders: {
      'Accept-Language': 'ja,en-US;q=0.9,en;q=0.8',
    },
  });
  const page = await context.newPage();
  // navigator.webdriver を隠す
  await page.addInitScript(() => {
    Object.defineProperty(navigator, 'webdriver', { get: () => false });
  });
  page.setDefaultTimeout(timeout);
  return page;
}

// --- コマンド ---

async function scrape(url, selector) {
  const browser = await launchBrowser();
  try {
    const page = await newPage(browser);
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout });

    const result = await page.evaluate((sel) => {
      const getMeta = (name) => {
        const el =
          document.querySelector(`meta[name="${name}"]`) ||
          document.querySelector(`meta[property="${name}"]`);
        return el ? el.getAttribute('content') : null;
      };

      const root = sel ? document.querySelector(sel) : document.body;
      if (!root) return { error: `Selector "${sel}" not found` };

      const headings = [...root.querySelectorAll('h1, h2, h3, h4, h5, h6')].map((h) => ({
        level: parseInt(h.tagName[1], 10),
        text: h.textContent.trim(),
      }));

      const links = [...root.querySelectorAll('a[href]')].map((a) => ({
        text: a.textContent.trim(),
        href: a.href,
      }));

      const images = [...root.querySelectorAll('img')].map((img) => ({
        src: img.src,
        alt: img.alt || '',
      }));

      const text = root.innerText || root.textContent || '';

      return {
        url: location.href,
        title: document.title,
        meta: {
          description: getMeta('description'),
          'og:title': getMeta('og:title'),
          'og:description': getMeta('og:description'),
          'og:image': getMeta('og:image'),
          'og:type': getMeta('og:type'),
          'og:url': getMeta('og:url'),
          canonical:
            document.querySelector('link[rel="canonical"]')?.href || null,
        },
        headings,
        links,
        images,
        text: text.substring(0, 50000),
      };
    }, selector || null);

    output(result);
  } finally {
    await browser.close();
  }
}

async function screenshot(url, outputPath, fullPage) {
  const filePath = outputPath || `./screenshots/${Date.now()}.png`;
  await ensureDir(filePath);

  const browser = await launchBrowser();
  try {
    const page = await newPage(browser);
    await page.goto(url, { waitUntil: 'load', timeout });
    await page.screenshot({
      path: resolve(filePath),
      fullPage: !!fullPage,
    });
    output({ path: resolve(filePath), url });
  } finally {
    await browser.close();
  }
}

async function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function search(query, num, lang) {
  const count = Math.min(parseInt(num, 10), 30);
  const params = new URLSearchParams({
    q: query,
    num: String(count),
    hl: lang,
  });
  const searchUrl = `https://www.google.com/search?${params}`;

  const browser = await launchBrowser();
  try {
    const page = await newPage(browser);

    // まずトップページにアクセスしてからリダイレクト（直接検索URLより自然）
    await page.goto('https://www.google.com/', { waitUntil: 'domcontentloaded', timeout });
    await sleep(500 + Math.random() * 1000);
    await page.goto(searchUrl, { waitUntil: 'domcontentloaded', timeout });
    await sleep(300 + Math.random() * 700);

    // Bot検知チェック
    const blocked = await page.evaluate(() => {
      return !!document.querySelector('#captcha-form, form[action*="sorry"]');
    });
    if (blocked) {
      fail('Google bot detection triggered. Try again later or use --headful to solve CAPTCHA.');
    }

    const results = await page.evaluate(() => {
      const items = [];
      // h3要素から検索結果を抽出（Google DOM構造の変化に対応）
      document.querySelectorAll('h3').forEach((h3) => {
        const anchor = h3.closest('a[href]');
        if (!anchor) return;
        const href = anchor.href;
        if (!href || href.includes('google.com/search') || href.startsWith('javascript:')) return;

        // スニペット: h3の親コンテナから隣接テキストを探す
        const container = anchor.closest('[data-sokoban-container]')
          || anchor.closest('div.g')
          || anchor.closest('[data-hveid]');
        let snippet = '';
        if (container) {
          const snippetEl =
            container.querySelector('[data-sncf]')
            || container.querySelector('div[style*="-webkit-line-clamp"]')
            || container.querySelector('div.VwiC3b')
            || container.querySelector('span.st, div.IsZvec');
          if (snippetEl) snippet = snippetEl.textContent.trim();
        }

        items.push({
          title: h3.textContent.trim(),
          url: href,
          snippet,
        });
      });
      return items;
    });

    output({ query, lang, results: results.slice(0, count) });
  } finally {
    await browser.close();
  }
}

async function interact(url, actionsJson) {
  let actions;
  try {
    actions = JSON.parse(actionsJson);
  } catch {
    fail('Invalid JSON for --actions');
  }
  if (!Array.isArray(actions)) {
    fail('--actions must be a JSON array');
  }

  const browser = await launchBrowser();
  try {
    const page = await newPage(browser);
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout });

    const results = [];

    for (const step of actions) {
      const { action, selector, value, path, time } = step;

      switch (action) {
        case 'click':
          await page.click(selector, { timeout });
          results.push({ action: 'click', selector, ok: true });
          break;

        case 'fill':
          await page.fill(selector, value, { timeout });
          results.push({ action: 'fill', selector, ok: true });
          break;

        case 'select':
          await page.selectOption(selector, value, { timeout });
          results.push({ action: 'select', selector, ok: true });
          break;

        case 'wait':
          if (selector) {
            await page.waitForSelector(selector, { timeout });
            results.push({ action: 'wait', selector, ok: true });
          } else if (time) {
            await page.waitForTimeout(time);
            results.push({ action: 'wait', time, ok: true });
          } else {
            results.push({ action: 'wait', error: 'Provide selector or time' });
          }
          break;

        case 'screenshot': {
          const ssPath = path || `./screenshots/${Date.now()}.png`;
          await ensureDir(ssPath);
          await page.screenshot({
            path: resolve(ssPath),
            fullPage: step.fullPage || false,
          });
          results.push({ action: 'screenshot', path: resolve(ssPath), ok: true });
          break;
        }

        case 'scrape': {
          const data = await page.evaluate((sel) => {
            const root = sel ? document.querySelector(sel) : document.body;
            if (!root) return { error: `Selector "${sel}" not found` };

            const headings = [...root.querySelectorAll('h1, h2, h3, h4, h5, h6')].map((h) => ({
              level: parseInt(h.tagName[1], 10),
              text: h.textContent.trim(),
            }));

            const links = [...root.querySelectorAll('a[href]')].map((a) => ({
              text: a.textContent.trim(),
              href: a.href,
            }));

            const images = [...root.querySelectorAll('img')].map((img) => ({
              src: img.src,
              alt: img.alt || '',
            }));

            const text = root.innerText || root.textContent || '';

            return {
              url: location.href,
              title: document.title,
              headings,
              links,
              images,
              text: text.substring(0, 50000),
            };
          }, selector || null);
          results.push({ action: 'scrape', data });
          break;
        }

        case 'scroll':
          if (step.to === 'bottom') {
            await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
          } else if (step.to === 'top') {
            await page.evaluate(() => window.scrollTo(0, 0));
          } else if (step.y !== undefined) {
            await page.evaluate((y) => window.scrollBy(0, y), step.y);
          } else if (selector) {
            await page.evaluate(
              (sel) => document.querySelector(sel)?.scrollIntoView({ behavior: 'smooth' }),
              selector
            );
          }
          results.push({ action: 'scroll', ok: true });
          break;

        case 'evaluate': {
          const evalResult = await page.evaluate(step.expression);
          results.push({ action: 'evaluate', result: evalResult });
          break;
        }

        default:
          results.push({ action, error: `Unknown action: ${action}` });
      }
    }

    output({ url: page.url(), results });
  } finally {
    await browser.close();
  }
}

// --- メイン ---

async function main() {
  if (flags.help || !command) {
    printUsage();
    process.exit(flags.help ? 0 : 1);
  }

  try {
    switch (command) {
      case 'scrape':
        if (!rest[0]) fail('URL is required for scrape');
        await scrape(rest[0], flags.selector);
        break;

      case 'screenshot':
        if (!rest[0]) fail('URL is required for screenshot');
        await screenshot(rest[0], flags.output, flags['full-page']);
        break;

      case 'search':
        if (!rest[0]) fail('Query is required for search');
        await search(rest.join(' '), flags.num, flags.lang);
        break;

      case 'interact':
        if (!rest[0]) fail('URL is required for interact');
        if (!flags.actions) fail('--actions is required for interact');
        await interact(rest[0], flags.actions);
        break;

      default:
        fail(`Unknown command: ${command}`);
    }
  } catch (err) {
    fail(err.message);
  }
}

main();
