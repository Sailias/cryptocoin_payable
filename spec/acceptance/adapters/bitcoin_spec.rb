require 'active_record'
require 'cryptocoin_payable'

describe CryptocoinPayable::Adapters::Bitcoin, :vcr do
  it 'gets transactions for a given address' do
    response = subject.get_transactions_for('3HR9xYD7MybbE7JLVTjwijYse48BtfEKni')

    expect(response).to eq(
      [
        {
          tx_hash: '5bdeaf7829148d7e0e1e7b5233512a2c5ae54ef7ccbc8e68b2f85b7e49c917a0',
          block_hash: '0000000000000000048e8ea3fdd2c3a59ddcbcf7575f82cb96ce9fd17da9f2f4',
          block_time: DateTime.iso8601('2016-09-13T15:41:00.000000000+00:00'),
          estimated_tx_time: DateTime.iso8601('2016-09-13T15:41:00.000000000+00:00'),
          estimated_tx_value: 499000000,
          confirmations: 115297
        },
        {
          tx_hash: 'e7bcdb13d9c903973bd8a740054d4c056a559bae67d4e8f6d0a42b4bab552623',
          block_hash: '000000000000000001af27feb303ad97af81a5882157f166781784c639f8e896',
          block_time: DateTime.iso8601('2016-09-13T15:22:42.000000000+00:00'),
          estimated_tx_time: DateTime.iso8601('2016-09-13T15:22:42.000000000+00:00'),
          estimated_tx_value: 1000000,
          confirmations: 115300
        }
      ]
    )
  end
end
