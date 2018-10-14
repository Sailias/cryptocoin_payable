require 'active_record'
require 'cryptocoin_payable'

describe CryptocoinPayable::Adapters::Ethereum, :vcr do
  def expect_transaction_result(response)
    expect(response).to match_array(
      [
        {
          tx_hash: '0xa88b799514e9621962e3d0de25e7e0bc7a123e33085f322c7acdb99cc2585c6d',
          block_hash: '0x752c50e426f65820f5bf6fd49acbb08d79464f8e7e8ea5b77e2299b69fd6398b',
          block_time: nil,
          estimated_tx_time: be_within(1.day).of(DateTime.iso8601('2018-07-05T12:58:33.000000000+07:00')),
          estimated_tx_value: 33_753_640_000_000_000,
          confirmations: 569_771
        },
        {
          tx_hash: '0xb325a8cf241f332bca92c7f715987e4d34be9a6b3bb78d2425c83086b4aced26',
          block_hash: '0x1c2b73a16fd8c4d25feeccaa2f0bf5c82b8f415f1beaf4d34aaf870daf89689d',
          block_time: nil,
          estimated_tx_time: be_within(1.day).of(DateTime.iso8601('2018-07-05T13:35:07.000000000+07:00')),
          estimated_tx_value: 2_190_144_444_444_444,
          confirmations: 569_629
        },
        {
          tx_hash: '0xcd874917be5ad177e7ebd88b5c4a7d4283796e00e43345da5b63fb4f78130b37',
          block_hash: '0x4ce71d11146445f123680ea9beba7db968b04dc675caddf60248c9d9d6f5739e',
          block_time: nil,
          estimated_tx_time: be_within(1.day).of(DateTime.iso8601('2018-07-05T13:55:53.000000000+07:00')),
          estimated_tx_value: 1_007_518_888_888_888,
          confirmations: 569_549
        },
        {
          tx_hash: '0x799ec2aaafbddbc2e746334f96f59f6127dec62e5693480576db351aaf840bfb',
          block_hash: '0xc1361b19b2266e2259ac433b9e18b4fbc81339304988bbc62dd93aa24fac6449',
          block_time: nil,
          estimated_tx_time: be_within(1.day).of(DateTime.iso8601('2018-08-26T16:05:44.000000000+07:00')),
          estimated_tx_value: 15_678_420_000_000_000,
          confirmations: 261_969
        }
      ]
    )
  end

  it 'gets transactions for a given address' do
    response = subject.fetch_transactions('0xfc8cfb26c31931572e65e450f7fa498bcc11651c')
    expect_transaction_result(response)
  end

  it 'gets an empty result when no transactions found' do
    response = subject.fetch_transactions('0x772fDD41BFB34C9903B253322baccdbE2C10851e')
    expect(response).to eq([])
  end

  it 'raises an error when an invalid address is passed' do
    expect { subject.fetch_transactions('foo') }.to raise_error CryptocoinPayable::ApiError
  end

  context 'when configured with a master public key' do
    before do
      CryptocoinPayable.configure do |config|
        config.configure_eth do |eth_config|
          # Created using BIP39 mnemonic 'cute season foam off pistol interest
          # soup wasp slice oxygen nominee anxiety step raven teach'
          # See https://iancoleman.io/bip39
          # rubocop:disable Metrics/LineLength
          eth_config.master_public_key = 'xpub69AhsZVugHWJ2iwbrYYhJ79W1KsbzUqGuUHRuMguZGa8ZSP6qFNCpy8pvkCUDdc2hNfVFeJL2vxxdgaDxeBGXuWL5hUVfuE9tjDDbX4eRUh'
          # rubocop:enable Metrics/LineLength
        end
      end
    end

    it 'creates BIP32 addresses' do
      3.times do
        expect(subject.create_address(0)).to eq('0xcDe321aCfa5B779dCD174850C3FB6E5Ff15cDEAf')
        expect(subject.create_address(1)).to eq('0x0CA6E0C53EEb559c0D8803076D4F02b72f0FAE9C')
        expect(subject.create_address(2)).to eq('0xD87D2476c93411242778fe0ef6e758De19ed19E8')
      end
    end
  end
end
