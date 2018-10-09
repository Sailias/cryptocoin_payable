require 'active_record'
require 'cryptocoin_payable'

describe CryptocoinPayable::Adapters::Ethereum, :vcr do
  it 'gets transactions for a given address' do
    response = subject.get_transactions_for('0xfc8cfb26c31931572e65e450f7fa498bcc11651c')

    expect(response).to eq(
      [
        {
          tx_hash: '0xa88b799514e9621962e3d0de25e7e0bc7a123e33085f322c7acdb99cc2585c6d',
          block_hash: '0x752c50e426f65820f5bf6fd49acbb08d79464f8e7e8ea5b77e2299b69fd6398b',
          block_time: nil,
          estimated_tx_time: '2018-07-05T12:58:33+07:00',
          estimated_tx_value: 33753640000000000,
          confirmations: 569771
        },
        {
          tx_hash: '0xb325a8cf241f332bca92c7f715987e4d34be9a6b3bb78d2425c83086b4aced26',
          block_hash: '0x1c2b73a16fd8c4d25feeccaa2f0bf5c82b8f415f1beaf4d34aaf870daf89689d',
          block_time: nil,
          estimated_tx_time: '2018-07-05T13:35:07+07:00',
          estimated_tx_value: 2190144444444444,
          confirmations: 569629
        },
        {
          tx_hash: '0xcd874917be5ad177e7ebd88b5c4a7d4283796e00e43345da5b63fb4f78130b37',
          block_hash: '0x4ce71d11146445f123680ea9beba7db968b04dc675caddf60248c9d9d6f5739e',
          block_time: nil,
          estimated_tx_time: '2018-07-05T13:55:53+07:00',
          estimated_tx_value: 1007518888888888,
          confirmations: 569549
        },
        {
          tx_hash: '0x799ec2aaafbddbc2e746334f96f59f6127dec62e5693480576db351aaf840bfb',
          block_hash: '0xc1361b19b2266e2259ac433b9e18b4fbc81339304988bbc62dd93aa24fac6449',
          block_time: nil,
          estimated_tx_time: '2018-08-26T16:05:44+07:00',
          estimated_tx_value: 15678420000000000,
          confirmations: 261969
        }
      ]
    )
  end
end
