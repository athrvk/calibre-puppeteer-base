#!/bin/bash
set -e

echo "=== Architecture Verification Script ==="
echo ""

echo "1. System Architecture:"
uname -m
echo ""

echo "2. TARGETARCH (if set during build):"
echo "${TARGETARCH:-Not set}"
echo ""

echo "3. Checking Chrome binary location and architecture:"
CHROME_PATH=$(find /root/.cache/puppeteer -name chrome -type f 2>/dev/null || echo "Chrome not found in puppeteer cache")
if [ "$CHROME_PATH" != "Chrome not found in puppeteer cache" ]; then
    echo "Chrome binary: $CHROME_PATH"
    file "$CHROME_PATH"
    echo ""
    
    echo "4. Testing Chrome can execute:"
    "$CHROME_PATH" --version 2>&1 || echo "Failed to execute Chrome"
else
    echo "Chrome binary not found!"
    echo "Searching for chrome in common locations:"
    find /root -name "*chrome*" -type f 2>/dev/null | head -10
fi
echo ""

echo "5. Node.js and Puppeteer info:"
node -v
npm -v
npm list -g puppeteer 2>/dev/null || echo "Puppeteer not found globally"
echo ""

echo "6. Testing Puppeteer programmatically:"
node -e "
const puppeteer = require('puppeteer');
(async () => {
  console.log('Puppeteer executable path:', puppeteer.executablePath());
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const version = await browser.version();
  console.log('Browser version:', version);
  await browser.close();
  console.log('✓ Puppeteer successfully launched Chrome!');
})().catch(err => {
  console.error('✗ Puppeteer failed:', err.message);
  process.exit(1);
});
"
