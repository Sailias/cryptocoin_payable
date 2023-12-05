describe CryptocoinPayable::Adapters::Bitcoin, :vcr do
  def expect_transaction_result(response)
    expect(response).to match_array(
      [
        {
          transaction_hash: 'dbdd77c3f855611e98b236ab2dbaecdf857b310867ba9bd25d00a9ae97efdfaf',
          block_hash: '00000000000022f2b5ecdf15c843d43211f10325dc203ef83ddc1f185c55830e',
          block_time: be_within(1.day).of(Time.iso8601('2023-11-29T15:41:00.000000000+00:00')),
          estimated_time: be_within(1.day).of(Time.iso8601('2023-11-29T15:41:00.000000000+00:00')),
          estimated_value: 4_838_729,
          confirmations: be_between(1, 1_000_000)
        },
        {
          transaction_hash: '81f397b78bafb09186fa8c97ca7f571c83e7bfa11f26dfb66c725a75f0ce3212',
          block_hash: '0000000000003e41554f6dbbd197c6d09261304b5460fa918b6dab3e3bdee929',
          block_time: be_within(1.day).of(Time.iso8601('2023-11-28T15:41:00.000000000+00:00')),
          estimated_time: be_within(1.day).of(Time.iso8601('2023-11-28T15:41:00.000000000+00:00')),
          estimated_value: 8_000,
          confirmations: be_between(1, 1_000_000)
        }
      ]
    )
  end

  it 'gets transactions for a given address' do
    response = subject.fetch_transactions('tb1qqmw2g6tghrcqdgeas2eawpcpyr537xc0ukf222')
    expect_transaction_result(response)
  end

  it 'returns zero estimated value for zero-value transactions' do
    pending 'need to find a zero-value transaction to test with'
    response = subject.fetch_transactions('1PKKkNRPPfPjrPiufHzuLFX2gMAVJbcN8H')
    expect(response.first[:estimated_value]).not_to be_nil
    expect(response.first[:estimated_value]).to be_zero
  end

  it 'gets an empty result when no transactions found' do
    response = subject.fetch_transactions('tb1qdnynffwkqrtykapjmaeqvyncl8rfu58pqxamp8')
    expect(response).to eq([])
  end

  it 'raises an error when an invalid address is passed' do
    expect { subject.fetch_transactions('foo') }.to raise_error CryptocoinPayable::ApiError
  end

  context 'when the BlockSteam API fails' do
    before do
      stub_request(:any, %r{blockstream.info/})
        .to_return(body: '502 Gateway Error', headers: { 'Content-Type' => 'text/html' })

      allow(subject).to receive(:fetch_block_cypher_transactions).and_call_original
    end

    it 'falls back to using the BlockCypher API' do
      response = subject.fetch_transactions('tb1qqmw2g6tghrcqdgeas2eawpcpyr537xc0ukf222')
      expect(subject).to have_received(:fetch_block_cypher_transactions).once
      expect_transaction_result(response)
    end
  end

  it 'creates BIP32 addresses' do
    3.times do
      expect(subject.create_address(0)).to eq('mvsv9qmXGueDqTgAUNssazQY7kapmHQbsc')
      expect(subject.create_address(1)).to eq('n3Y9hm8hzsrE8bzy83zHQEpLmxMLup967N')
      expect(subject.create_address(2)).to eq('msJ7jKfZTx5VU47523H7tTBeaivyXMtVPz')
    end
  end
end
