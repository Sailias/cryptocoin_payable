require 'chunky_png'
CryptocoinPayable.configure do |config|
  config.currency = :usd
  config.testnet = true
  config.expire_payments_after = 15.minutes
  config.request_delay = 0.5

  # config.qrcode = nil to disable qrcode generation
  config.qrcode = { bit_depth: 1,
                    border_modules: 4,
                    color_mode: ChunkyPNG::COLOR_GRAYSCALE,
                    color: 'black',
                    file: nil,
                    fill: 'white',
                    module_px_size: 6,
                    resize_exactly_to: false,
                    resize_gte_to: false,
                    size: 1200 }

  config.configure_btc do |btc_config|
    btc_config.node_path = 'm/0/'
    # rubocop:disable Metrics/LineLength
    btc_config.master_public_key = 'tpubD6NzVbkrYhZ4X3cxCktWVsVvMDd35JbNdhzZxb1aeDCG7LfN6KbcDQsqiyJHMEQGJURRgdxGbFBBF32Brwb2LsfpE2jQfCZKwzNBBMosjfm'
    # rubocop:enable Metrics/LineLength
  end

  config.configure_eth do |eth_config|
    # Will default to 4 if `config.testnet` is true, otherwise 1 but can be
    # overriden.
    #
    # 1: Frontier, Homestead, Metropolis, the Ethereum public main network
    # 4: Rinkeby, the public Geth Ethereum testnet
    # See https://ethereum.stackexchange.com/a/17101/26695
    # eth_config.chain_id = 1
  end
end
