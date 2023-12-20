class CryptocoinPayable::CoinPaymentsController < ApplicationController
  before_action :set_cryptocoin_payable_coin_payment, only: %i[ show edit update destroy ]

  # GET /cryptocoin_payable/coin_payments
  def index
    @cryptocoin_payable_coin_payments = CryptocoinPayable::CoinPayment.all
  end

  # GET /cryptocoin_payable/coin_payments/1
  def show
  end

  # GET /cryptocoin_payable/coin_payments/new
  def new
    @cryptocoin_payable_coin_payment = CryptocoinPayable::CoinPayment.new
  end

  # GET /cryptocoin_payable/coin_payments/1/edit
  def edit
  end

  # POST /cryptocoin_payable/coin_payments
  def create
    @cryptocoin_payable_coin_payment = CryptocoinPayable::CoinPayment.new(cryptocoin_payable_coin_payment_params)

    if @cryptocoin_payable_coin_payment.save
      redirect_to @cryptocoin_payable_coin_payment, notice: "Coin payment was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cryptocoin_payable/coin_payments/1
  def update
    if @cryptocoin_payable_coin_payment.update(cryptocoin_payable_coin_payment_params)
      redirect_to @cryptocoin_payable_coin_payment, notice: "Coin payment was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /cryptocoin_payable/coin_payments/1
  def destroy
    @cryptocoin_payable_coin_payment.destroy!
    redirect_to cryptocoin_payable_coin_payments_url, notice: "Coin payment was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cryptocoin_payable_coin_payment
      @cryptocoin_payable_coin_payment = CryptocoinPayable::CoinPayment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cryptocoin_payable_coin_payment_params
      params.require(:cryptocoin_payable_coin_payment).permit(:price, :reason, :address, :coin_type)
    end
end
