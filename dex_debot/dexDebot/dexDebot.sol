pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "../../ton-labs-contracts/debots/Debot.sol";
import "../../ton-labs-contracts/debots/Terminal.sol";
import "../../ton-labs-contracts/debots/AddressInput.sol";
import "../../ton-labs-contracts/debots/Sdk.sol";
import "../../ton-labs-contracts/debots/Menu.sol";




abstract contract DexDebot is Debot {

  address m_wallet;
  uint128 m_balance;
  bool m_bounce;
  uint128 m_tons;
  address m_dest;
  uint128 m_price;
  uint128 m_amount;
  address m_address;



  /*
  * DexDebot Basic
  */

  function start() public override {
    Menu.select("Main menu", "Hello, i'm a dex debot.", [
      MenuItem("Check orders for buying TON Crystal", "", tvm.functionId(check_order)),
      MenuItem("Add orders for buying TON Crystal", "", tvm.functionId(add_order)),
      MenuItem("Check orders for selling TON Crystal", "", tvm.functionId(zaglushka)),
      MenuItem("Add orders for selling TON Crystal", "", tvm.functionId(zaglushka)),
      MenuItem("Check all orders", "", tvm.functionId(zaglushka)),
      MenuItem("List of trading pairs", "", tvm.functionId(zaglushka)),
      MenuItem("Cancel", "", 0)
    ]);
  }

  function zaglushka() public {


  }
  function getVersion() public override returns (string name, uint24 semver) {
    (name, semver) = ("Dex Debot", 1 << 16);
  }
  /*
  * Dex:Check orders for buying TON Crystal(not working)
  */
  function check_order() public {
    Menu.select("Check orders for buying", "", [
      MenuItem("For buy orders", "", tvm.functionId(zaglushka)),
      MenuItem("For sell orders", "", tvm.functionId(zaglushka)),
      MenuItem("Cancel", "", tvm.functionId(zaglushka))
    ]);
  }
  /*
  * Dex:Add orders for buying TON Crystal
  */
  function add_order() public {
    Terminal.inputInt(tvm.functionId(setPrice), "At what price do you want to buy TON Crystals? Specify in USDTons");
    Terminal.inputInt(tvm.functionId(setAmount), "How much do you want yo buy?");

  }
  /* Вывод объявления */

  function place_order() public {
    (uint64 dec_p, uint64 float_p) = tokens(m_price);
    (uint64 dec_m, uint64 float_m) = tokens(m_amount);
    string fmt = format("Place order with {}.{} price for sum {}.{} ?", dec_p, float_p, dec_m, float_m );
    Terminal.inputBoolean(tvm.functionId(submit), fmt);
  }

  function submut() public {
    Terminal.inputInt(tvm.functionId(setAddress), "Enter your USDTon wallet address to receive funds");
    string test = "Test";
    Terminal.inputBoolean(tvm.functionId(submit_trans), test);

  }

  function submit_trans(bool value) public {
    /*  if (!value) {
    Terminal.print(0, "Ok, maybe next time. Bye!");
    return;
  }
  TvmCell empty;
  optional(uint256) pubkey = 0;
  IMultisig(m_wallet).submitTransaction{
  abiVer: 2,
  extMsg: true,
  sign: true,
  pubkey: pubkey,
  time: uint64(now),
  expire: 0,
  callbackId: tvm.functionId(setResult),
  onErrorId: 0
}(m_dest, m_tons, m_bounce, false, empty);*/
}

/*тут нужно доработть*/
function submit(bool value) public {
  /*  if (!value) {
  Terminal.print(0, "Ok, maybe next time. Bye!");
  return;
}
TvmCell empty;
optional(uint256) pubkey = 0;
IMultisig(m_wallet).submitTransaction{
abiVer: 2,
extMsg: true,
sign: true,
pubkey: pubkey,
time: uint64(now),
expire: 0,
callbackId: tvm.functionId(setResult),
onErrorId: 0
}(m_dest, m_tons, m_bounce, false, empty);*/
}

function setResult() public {
  Terminal.print(0, "The ad was succesful posted. Bye!");
}

/* Цена */

function setPrice(uint128 value) public {
  m_price = value;
}
/* Количество */

function setAmount(uint128 value) public {
  m_amount = value;
}

function setAddress(address value) public{
  m_address = value;
}

/*
* Public(позже их адаптирую в нужное место)
*/
function selectWallet(uint32 index) public {
  index = index;
  Terminal.print(0, "Enter multisignature wallet address");
  AddressInput.select(tvm.functionId(checkWallet));
}

function checkWallet(address value) public {
  Sdk.getBalance(tvm.functionId(setBalance), value);
  Sdk.getAccountType(tvm.functionId(getWalletInfo), value);
  m_wallet = value;
}

function setBalance(uint128 nanotokens) public {
  m_balance = nanotokens;
}

function getWalletInfo(int8 acc_type) public {
  if (acc_type == -1)  {
    Terminal.print(0, "Wallet doesn't exist");
    return;
  }
  if (acc_type == 0) {
    Terminal.print(0, "Wallet is not initialized");
    return;
  }
  if (acc_type == 2) {
    Terminal.print(0, "Wallet is frozen");
    return;
  }

  //(uint64 dec, uint64 float) = tokens(m_balance);
  //  Terminal.print(tvm.functionId(queryCustodians), format("Wallet balance is {}.{} tons", dec, float));
}

function setTons(uint128 value) public {
  m_tons = value;
}

function setDest(address value) public {
  m_dest = value;
  (uint64 dec, uint64 float) = tokens(m_tons);
  string fmt = format("Transfer {}.{} tokens to account {} ?", dec, float, m_dest);
  Terminal.inputBoolean(tvm.functionId(submit), fmt);
}

function setBounce(bool value) public {
  m_bounce = value;
}


function tokens(uint128 nanotokens) private pure returns (uint64, uint64) {
  uint64 decimal = uint64(nanotokens / 1e9);
  uint64 float = uint64(nanotokens - (decimal * 1e9));
  return (decimal, float);
}

}
