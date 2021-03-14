/* eslint-disable no-console */
const { TonClient } = require('@tonclient/core');
const { libNode } = require('@tonclient/lib-node');
const fs = require('fs').promises;
const path = require('path');

TonClient.useBinaryLibrary(libNode);

class Ton {
  /*
   * @ret
   */
  constructor() {
    this.client = new TonClient({
      network: {
        server_address: process.env.TON_NODE,
      },
    });
  }

  async fundAccount(account, amount) {
    // Address of giver on TON OS SE, https://docs.ton.dev/86757ecb2/p/00f9a3-ton-os-se-giver
    const giverAddress =
      '0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94';
    // Giver ABI on TON OS SE
    const giverAbi = {
      'ABI version': 1,
      functions: [
        {
          name: 'constructor',
          inputs: [],
          outputs: [],
        },
        {
          name: 'sendGrams',
          inputs: [
            { name: 'dest', type: 'address' },
            { name: 'amount', type: 'uint64' },
          ],
          outputs: [],
        },
      ],
      events: [],
      data: [],
    };

    const params = {
      send_events: false,
      message_encode_params: {
        address: giverAddress,
        abi: {
          type: 'Contract',
          value: giverAbi,
        },
        call_set: {
          function_name: 'sendGrams',
          input: {
            dest: account,
            amount,
          },
        },
        signer: { type: 'None' },
      },
    };
    return this.client.processing.process_message(params);
  }

  static async readContractFiles(contractPath) {
    const ABIfilePath = `${path.resolve(contractPath)}.abi`;
    const TVCfilePath = `${path.resolve(contractPath)}.tvc`;
    const abi = await fs.readFile(ABIfilePath).catch(console.error);
    if (!abi) {
      console.error(
        `Please check contract path and encure that ABI files exists here ${ABIfilePath}`,
      );
    }

    let contractABI;
    try {
      contractABI = JSON.parse(abi);
    } catch (e) {
      console.error(e);
      console.error(
        `Contract ABI not a valid JSON. Please check it ${ABIfilePath}`,
      );
      return false;
    }

    const TVCfileContent = await fs
      .readFile(TVCfilePath, { encoding: 'base64' })
      .catch(console.error);

    if (!TVCfileContent) {
      console.error(
        `Please check contract path and encure that TVC file exists here ${TVCfilePath}`,
      );
    }

    return {
      abi: contractABI,
      tvcInBase64: TVCfileContent,
    };
  }

  static stringToBytesArray(dataString) {
    return Buffer.from(dataString).toString('hex');
  }

  async deployContract(contractPath, keys, constructorParams = {}) {
    if (!keys) {
      console.error('Keys not provided. Please provide it before use');
      return false;
    }

    const contractFiles = await this.constructor.readContractFiles(
      contractPath,
    );

    if (!contractFiles) {
      console.error('Not able to detect Contract files. Please check patch');
      return false;
    }

    const deployOptions = {
      abi: {
        type: 'Contract',
        value: contractFiles.abi,
      },
      deploy_set: {
        tvc: contractFiles.tvcInBase64,
        initial_data: {},
      },
      call_set: {
        function_name: 'constructor',
        input: constructorParams,
      },
      signer: {
        type: 'Keys',
        keys,
      },
    };

    const result = await this.client.abi
      .encode_message(deployOptions)
      .catch((e) => {
        console.error(deployOptions);
        console.error(e);
      });
    if (!result) {
      console.error(' Not able to deploy. Please check errors');
      return false;
    }

    console.log(`Future address of the contract will be: ${result.address}`);

    const addressInfo = await this.getAddresInfo(result.address);

    if (!addressInfo.balance) {
      console.log('Will fund account');
      const fundStatus = await this.fundAccount(
        result.address,
        10_000_000_000,
      ).catch(console.error);
      console.log('Success');
    }

    if (addressInfo.isInited) {
      console.error('Address already exists. Please check your code');
      return false;
    }

    const deployResult = await this.client.processing
      .process_message({
        send_events: false,
        message_encode_params: deployOptions,
      })
      .catch(console.error);

    console.log(`Success: ${deployResult.transaction.account_addr} `);

    return true;
  }

  async getAddresInfo(address) {
    const answer = {
      isExist: false,
      isInited: false,
      balance: 0,
    };
    const { result } = await this.client.net.query_collection({
      collection: 'accounts',
      filter: {
        id: {
          eq: address,
        },
      },
      result: 'acc_type balance code',
    });
    if (result.length === 0) {
      return answer;
    }

    return {
      balance: BigInt(result[0].balance),
      isExist: true,
      isInited: !!result[0].acc_type,
    };
  }

  /**
   * Generate public and secret key pairs.
   */
  async generateWalletKeys() {
    return this.client.crypto.generate_random_sign_keys();
  }
}

module.exports = Ton;
