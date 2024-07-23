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
  const browser = await puppeteer.launch({ headless: false, slowMo: 200 });
  const page = await browser.newPage();
  await page.goto(url);
  await page.goto('https://'+process.env.HOME_REGION+'.console.aws.amazon.com/singlesignon/home?region='+process.env.HOME_REGION+'#!/');
  await page.waitForSelector("::-p-xpath(//button[@data-testid='enable-sso-btn'])");
  const button = await page.waitForSelector("::-p-xpath(//button[@data-testid='enable-sso-btn'])");
  button.click();
}

exports.handler()






















// (async () => {
//   const browser = await puppeteer.launch({ headless: false, slowMo: 200 });
//   const page = await browser.newPage();
//   await page.goto('https://signin.aws.amazon.com/federation?Action=login&Issuer=test.com&Destination=https%3A%2F%2Fconsole.aws.amazon.com%2F&SigninToken=w1QCUTzYdYqEF5tmbYqPVjmrd-7hi9eyizQ-PNUSs6bL3_FszGobbNW3zO1ivlkCsk27Y40-I9hPX12Yv2caW25Zr6Ep587VyFcBuKNYAy390buzYQUFA1GCIRD5txx26QvBN5egfqWU9Hw_Mc-FcmzKmYOHRw2kXOkUR-gdKaqUPYlHCckoQ1HqHjI3gNEBtdq6aZHROUUOUJLsFjOX-SmP_4063wsfrgeV3lXfz1BPK7MgLUFT0EkxZnS_UcHzLjM6QJB_jFkollZvZ9O-A1weeZuZz9e2w-EFfj-bTGc1zXqHpvMNvhtHwuKZkWHyUK2AN4fA4-38Vsrs8YYWtSVzq1l0SLXE1KnsMzdHdEcKcbIW1lwP3CeiPY71nOhxO6JT9RqTiKkSE4dHyEcNm-yE-LiivDAXFnl0f3T6_XeZT-o5RrylHQNsamEWZECu-i2U2KwVItlxtaI1bFb7uC2l5pk_vGXGeuDPJ2oFQwGd0Abj9WbwWYKZUC1cl6adat-DD6hK1GcttdiGNxnksiXdsTMHnGFk-f36jbcC9WrEi1y_DIL_DIf5rfJWBUW8WJDww-tvZZDwrbrHzT13AfvVEgNtT2i314LJgdhK2g_pf22Temz53UXBMr_pZJUlBkAMoC15J107VLdL8U0i09fPJUMxIzAkFxecGGVPonHoX_S3943L1X3W_EG7Gayy167y8O7757cQrWTk23vVUgRPFNIOodnH6Ac-W-nYD27lBlSqtJR1RxFOL5DplsAs0rlwKXLjs8ZmXNQjszy44ngKO-7x5pTbGG-ktWO1RNsbvH4qFURpIbNi8NNGnG8bAMNBTJ9p2H_9-OUBXgYy9yOcUWRntBZvsqysStplXD0oS9-bJqiCtoqd0k8LgqiZrzGPt-N1sqskdK2mZXgfCJ3rldFo--_b49U-DxNkM5nSKD-QWMr9g2zXlVBFAy1X6dBh6FIZgb1M0TQg_ISgtmIpGIFjw8PQ3dR1lsihMSDlVGgcpYoaGNYRwc20pjZ6EBulRJxpX6aJlYEH4nN4pAW2bCEEZnQw3r573ybT8kYth8uHiBhGajHhubVoOhqSHb3xE_4v0fPz1xdAj0eVsRHlPCw8LmPleFIrX5-PMAWcBf10GUliNpdp_0f3gGX3ls3k6_eRYFQxkniDx5ecca3p2LoPpW4YGeLPlZmNcIyIfEdlrE7O_cSf6yNcBm1A3ggQHmh7h8fixa1vYaGJxd0PgOfXCyBC-cZfWtEvHWexAFfgf4f2VcODpLvWmSIu4t0Y79-gHIUsax8dHIzkeXMYifuNH_y6QZdEV_yXopepkuyV6XE_FYy-oLuT2UFL86B6y-vO3tI3Dnjy2Zy347iCs0tSh9CQ9KcKwU1EtMStbOf0Mf7J0B7_8pFhmSFQJTDILEJYd4sg7QJGWcja9j0cK_aq0NQDmtagSVzhHP5Vr3SOmgKQF7uqXLloeZfJtA');
//   // await page.goto('https://us-east-1.console.aws.amazon.com/wickr/home?region=us-east-1#/');
//   // await page.goto('https://us-east-1.console.aws.amazon.com/wickr/home?region=us-east-1#/manage-networks');
//   await page.goto('https://us-east-1.console.aws.amazon.com/wickr/home?region=us-east-1#/create-network');


  // formfieldlist = document.querySelectorAll('[id^="formField"]');
  // Array.prototype.forEach.call(formfieldlist, callback);
  // function callback(element, iterator) {
  //   console.log(iterator, element.id);
  // }

  // const result = await page.evaluate(() => {
  //   return document.querySelectorAll('input[id^=formField]')
  // });

  //const formid = await page.evaluate(() => document.querySelectorAll('[id^="formField"]'));

  // console.log(result);

  // const test = await page.evaluate() => {
  //   let elements = Array.from(document.querySelectorAll('[id^="formField"]'));
  //   let buttons = elements.map(element => {
  //     return element
  //   })
  //   return buttons; 
  // }


  // formfieldlist = document.querySelectorAll('[id^="formField"]');
  // Array.prototype.forEach.call(formfieldlist, callback);
  
  // function callback(element, iterator) {
  //     console.log(iterator, element.id);
  // }
  
  // console.log(await page.$("iframe"))
  // await page.waitForSelector('iframe');
  // const test = await page.evaluate() => {
  //   let elements = Array.from(document.querySelectorAll('[id^="formField"]'));
  //   let buttons = elements.map(element => {
  //     return element
  //   })
  //   return buttons; 
  // }
  // const formfieldid = await page.evaluate(_ => {
  //   return document.querySelectorAll('[id^="formField"]').getAttributeNames();
  // });
  // console.info(test)

  // await page.waitForSelector('[id*="formField"]');
  // const f = await page.$("#txtSearchText")
  // //enter text
  // f.type("Puppeteer")
  // console.info(items)
// })();

