const Ton = require('../../utils/Ton');
const keys = require('../../utils/keys.json');

const ton = new Ton();

Ton.readContractFiles('./dex_debot/tonydex/dexDebot').then(async (data) => {
  const res = await ton.deployContract(
    './dex_debot/tonydex/dexDebot',
    keys[0],
    {
      abi: data.abi,
    },
  );
  console.log(res);
});
