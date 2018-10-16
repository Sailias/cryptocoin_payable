require 'active_record'
require 'cryptocoin_payable'

describe CryptocoinPayable::Adapters::BitcoinCash, :vcr do
  it 'gets transactions for a given address' do
    response = subject.fetch_transactions('bitcoincash:qzmdvhfdxv7j79hs6080hdm47szxfxqpccemzq6n52')

    expect(response).to eq(
      [
        {
          transaction_hash: '10d9d3927a21d90c573a5fbbb347f409af37219ceb93f7475d6c4cca4231d29f',
          block_hash: '0000000000000000015493ab50fde669130f9b64f0918031a5b6dcc44f14698f',
          block_time: DateTime.iso8601('2018-10-12T07:28:21.000000000+00:00'),
          estimated_time: DateTime.iso8601('2018-10-12T07:28:21.000000000+00:00'),
          estimated_value: 4_128_450,
          confirmations: 2
        }
      ]
    )
  end

  it 'gets an empty result when no transactions found' do
    response = subject.fetch_transactions('bitcoincash:qqu5af4540fw6eg3cqr3t8ndhplpd0xf0vmqpw59ef')
    expect(response).to eq([])
  end

  it 'raises an error when an invalid address is passed' do
    expect { subject.fetch_transactions('foo') }.to raise_error CryptocoinPayable::ApiError
  end

  context 'when configured with a master public key' do
    before do
      CryptocoinPayable.configure do |config|
        config.configure_bch do |bch_config|
          # Created using BIP39 mnemonic 'over dentist endorse dial muscle
          # decline front canvas initial business fashion priority clay tribe
          # praise'
          # See https://iancoleman.io/bip39
          # rubocop:disable Metrics/LineLength
          bch_config.master_public_key = 'xpub69m5Zouf7QU8wRjLfQX2F5VtgyTNJ45Xy6xg6SbrynM5D31U7uowkwe55y569b5Aonz9LJySajB1qkdkhFCdLVQE6U51VB6aGMeejKafAET'
          # rubocop:enable Metrics/LineLength
        end
      end
    end

    it 'creates BIP32 addresses' do
      3.times do
        expect(subject.create_address(0)).to eq('bitcoincash:qpfspf58t6vcsvq7xeumpuudqhvj38s5sus4uutspg')
        expect(subject.create_address(1)).to eq('bitcoincash:qz94rwzlgccnkvaaea5klmtmad32l8gndgrcfwaryc')
        expect(subject.create_address(2)).to eq('bitcoincash:qrgpwhl6x5qvf8ratcdl992r5afuv6286ujfa82xrh')
      end
    end
  end
end
