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
  const browser = await puppeteer.launch({ headless: true, args: [
    `--no-sandbox`,
    `--disable-setuid-sandbox`
  ], 
    slowMo: 200 });
  const page = await browser.newPage();
  await page.goto(url);
  await page.goto('https://'+process.env.region+'.console.aws.amazon.com/singlesignon/home?region='+process.env.region+'#!/');
  await page.waitForSelector("::-p-xpath(//button[@data-testid='enable-sso-btn'])");
  const button = await page.waitForSelector("::-p-xpath(//button[@data-testid='enable-sso-btn'])");
  button.click();
}

exports.handler()