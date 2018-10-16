require 'active_record'
require 'cryptocoin_payable'

describe CryptocoinPayable::Adapters::Bitcoin, :vcr do
  def expect_transaction_result(response)
    expect(response).to match_array(
      [
        {
          transaction_hash: '5bdeaf7829148d7e0e1e7b5233512a2c5ae54ef7ccbc8e68b2f85b7e49c917a0',
          block_hash: '0000000000000000048e8ea3fdd2c3a59ddcbcf7575f82cb96ce9fd17da9f2f4',
          block_time: DateTime.iso8601('2016-09-13T15:41:00.000000000+00:00'),
          estimated_time: be_within(1.day).of(DateTime.iso8601('2016-09-13T15:41:00.000000000+00:00')),
          estimated_value: 499_000_000,
          confirmations: 116_077
        },
        {
          transaction_hash: 'e7bcdb13d9c903973bd8a740054d4c056a559bae67d4e8f6d0a42b4bab552623',
          block_hash: '000000000000000001af27feb303ad97af81a5882157f166781784c639f8e896',
          block_time: DateTime.iso8601('2016-09-13T15:22:42.000000000+00:00'),
          estimated_time: be_within(1.day).of(DateTime.iso8601('2016-09-13T15:22:42.000000000+00:00')),
          estimated_value: 1_000_000,
          confirmations: 116_080
        }
      ]
    )
  end

  it 'gets transactions for a given address' do
    response = subject.fetch_transactions('3HR9xYD7MybbE7JLVTjwijYse48BtfEKni')
    expect_transaction_result(response)
  end

  it 'gets an empty result when no transactions found' do
    response = subject.fetch_transactions('1twtr17A65VAPhJDJRxhoMSpLBTR5Xy44')
    expect(response).to eq([])
  end

  it 'raises an error when an invalid address is passed' do
    expect { subject.fetch_transactions('foo') }.to raise_error CryptocoinPayable::ApiError
  end

  context 'when the Block Explorer API fails' do
    before do
      stub_request(:any, %r{blockexplorer.com/api})
        .to_return(body: '502 Gateway Error', headers: { 'Content-Type' => 'text/html' })

      allow(subject).to receive(:fetch_block_cypher_transactions).and_call_original
    end

    it 'falls back to using the BlockCypher API' do
      response = subject.fetch_transactions('3HR9xYD7MybbE7JLVTjwijYse48BtfEKni')
      expect(subject).to have_received(:fetch_block_cypher_transactions).once
      expect_transaction_result(response)
    end
  end

  context 'when configured with a master public key' do
    before do
      CryptocoinPayable.configure do |config|
        config.configure_btc do |btc_config|
          # Created using BIP39 mnemonic 'dose rug must junk rug spell bracket
          # inside tissue artist patrol evil turtle brass ivory'
          # See https://iancoleman.io/bip39
          # rubocop:disable Metrics/LineLength
          btc_config.master_public_key = 'xpub688gtTMXY1ykq6RKrrSyVzGad7HTsTNVfT5UzyWL72fs73skbBFEuBfiYH5BhST5xzfUx7SFw5BF7jbJRDnxSjUtdfTS4Be9veEBdqZW1qg'
          # rubocop:enable Metrics/LineLength
        end
      end
    end

    it 'creates BIP32 addresses' do
      3.times do
        expect(subject.create_address(0)).to eq('1D5qJDG6No5xcHovLmyNU1b3vq7xkEzTRH')
        expect(subject.create_address(1)).to eq('17A91ZXzkJQkSrbNWcY8ywDC7D9aW9roKo')
        expect(subject.create_address(2)).to eq('16Ak3B8ahHWbrZvukMUe8PUDLR5HScM6LK')
      end
    end
  end
end
