var url;
const puppeteer = require('puppeteer');
exports.handler = async function() {
  const https = require('https');

  const session = JSON.stringify({
    sessionId: process.env.AWS_ACCESS_KEY_ID,
    sessionKey: process.env.AWS_SECRET_ACCESS_KEY,
    sessionToken: process.env.AWS_SESSION_TOKEN
  });

  

  const baseUrl = 'https://signin.aws.amazon.com/federation'

  const getSigninToken = (cb) => {
    https.get(`${baseUrl}?Action=getSigninToken&Session=${encodeURIComponent(session)}`, (res) => {
      res.setEncoding('utf8');
      let response = '';
      res.on('data', (chunk) => {
        response = response + chunk;
      });
      res.on('end', () => {
        cb(JSON.parse(response).SigninToken);
      });
    });
  }

  getSigninToken((signinToken) => {
    const destination = 'https://console.aws.amazon.com/';
    url = `${baseUrl}?Action=login&Destination=${encodeURIComponent(destination)}&SigninToken=${encodeURIComponent(signinToken)}`;
  });
  const browser = await puppeteer.launch({ headless: true, 
    args: [
    `--no-sandbox`,
    `--disable-setuid-sandbox`
  ], 
    slowMo: 500 });
  const page = await browser.newPage();
  await page.goto(url);
  await page.goto('https://'+process.env.region+'.console.aws.amazon.com/singlesignon/home?region='+process.env.region+'#!/');
  await page.goto('https://'+process.env.region+'.console.aws.amazon.com/singlesignon/home?region='+process.env.region+'#!/enable-iam-identity-center');
  
  try {
    // Wait for the page to load completely
    await page.waitForTimeout(2000);
    
    // Try to find the button by data-analytics attribute
    const button = await page.$('[data-analytics="enable-idc-actions__enable"]');
    if (button) {
      await button.click();
    } else {
      // If not found, try to find by XPath
      const xpathButton = await page.$x('//*[@data-analytics="enable-idc-actions__enable"]');
      if (xpathButton.length > 0) {
        await xpathButton[0].click();
      } else {
        console.log('Button not found by attribute or XPath, searching by text content...');
        // Search for button by text content
        const enableButtons = await page.$eval('button', buttons => 
          buttons.filter(button => 
            button.textContent.toLowerCase().includes('enable')
          ).map(button => button.outerHTML)
        );
        
        if (enableButtons.length > 0) {
          console.log('Found button with "enable" text:', enableButtons[0]);
          await page.evaluate(() => {
            const buttons = Array.from(document.querySelectorAll('button'));
            const enableButton = buttons.find(button => 
              button.textContent.toLowerCase().includes('enable')
            );
            if (enableButton) enableButton.click();
          });
        } else {
          console.log('No button with "enable" text found');
        }
      }
    }
  } catch (error) {
    console.error('Error finding or clicking button:', error);
  }
  
  await new Promise(r => setTimeout(r, 60000));
  await browser.close();
  process.exit(0)
}

exports.handler()