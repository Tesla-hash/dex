const Ton = require('../../utils/Ton');
const keys = require('../../utils/keys.json');

const ton = new Ton();

Ton.readContractFiles(
  './dex_debot/tonydex/',
).then(async (data) => {
  const walletCode = await ton.client.boc.get_code_from_tvc({
    tvc: data.tvcInBase64,
  });
  const res = await ton.deployContract(
    './dex_debot/tonydex/',
    keys[0],
    {
      name: Ton.stringToBytesArray('Our test token'),
      symbol: Ton.stringToBytesArray('OTT'),
      decimals: 0,
      root_public_key: `0x${keys[0].public}`,
      root_owner:
        '0x0000000000000000000000000000000000000000000000000000000000000000',
      wallet_code: walletCode.code,
      total_supply: 0,
    },
  );
  console.log(res);
});
