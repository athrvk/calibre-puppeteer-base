const puppeteer = require('puppeteer');

(async () => {
    try {
        const browser = await puppeteer.launch({
            args: ['--no-sandbox', '--disable-setuid-sandbox']
        });
        const page = await browser.newPage();
        await page.goto('https://google.com');
        console.log('Puppeteer is installed and working correctly.');
        await browser.close();
    } catch (error) {
        console.error('Error verifying Puppeteer installation:', error);
    }
})();