describe CryptocoinPayable::Adapters::Ethereum, :vcr do
  def expect_transaction_result(response)
    expect(response).to match_array(
      [
        {
          transaction_hash: '0xeeadb31b3c646b74a8c1270626ab8e539d7a7e2369e98541f85f8a41cc4b49e9',
          block_hash: '0x3cd7ca8c2b1a4d2df804538462676c7dde471654f45cb15476982a9b3d3845fe',
          block_time: nil,
          estimated_time: be_within(1.day).of(Time.iso8601('2023-11-30T12:58:33.000000000+07:00')),
          estimated_value: 51_504_000_000_000_000,
          gas: 21_000,
          gas_price: 2_166_305_619,
          gas_used: 21_000,
          confirmations: 22
        },
        {
          transaction_hash: '0x72579c512ac244134f890bd617fa28c576d52a81e275c68a15bd5eb180f396ae',
          block_hash: '0x73b73bbbbaf3e9ffcb42b843e1948231bac0193e278225957f773ede3670fe44',
          block_time: nil,
          estimated_time: be_within(1.day).of(Time.iso8601('2023-11-30T13:35:07.000000000+07:00')),
          estimated_value: 58_123_650_000_000_000,
          gas: 21_000,
          gas_price: 2_192_798_508,
          gas_used: 21_000,
          confirmations: 11
        }
      ]
    )
  end

  it 'gets transactions for a given address' do
    response = subject.fetch_transactions('0xebB838Cdb3e3F628f50BF0EDaC1E92b208149984')
    expect_transaction_result(response)
  end

  it 'gets an empty result when no transactions found' do
    response = subject.fetch_transactions('0x772fDD41BFB34C9903B253322baccdbE2C10851e')
    expect(response).to eq([])
  end

  it 'raises an error when an invalid address is passed' do
    expect { subject.fetch_transactions('foo') }.to raise_error CryptocoinPayable::ApiError
  end

  it 'creates BIP32 addresses' do
    3.times do
      expect(subject.create_address(0).to_s).to eq('0xcDe321aCfa5B779dCD174850C3FB6E5Ff15cDEAf')
      expect(subject.create_address(1).to_s).to eq('0x0CA6E0C53EEb559c0D8803076D4F02b72f0FAE9C')
      expect(subject.create_address(2).to_s).to eq('0xD87D2476c93411242778fe0ef6e758De19ed19E8')
    end
  end
end
