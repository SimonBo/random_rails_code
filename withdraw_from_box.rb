class WithdrawFromBox
  def initialize(params = {})
    @box = params[:box]
    @user = params[:user]
    @transfert_to = params[:transfert_to]
    @is_bank_transfer = params[:is_bank_transfer]
    @amount = params[:amount].to_d
    @comment = params.fetch(:comment, '')
  end

  def call
    ActiveRecord::Base.transaction do
      create_payment
      update_user
      create_transfer if @is_bank_transfer
      update_box_balance_before_withdrawal if @box.balance_before_withdrawal.nil?
      update_box_balance
    end
  end

  private

  def create_payment
    @payment = Payment.create!(
      destination: @transfert_to,
      source: @box,
      amount: @amount,
      destination_balance_after: new_target_user_balance,
      destination_virtual_balance_after: new_target_user_virtual_balance,
      source_balance_after: new_box_balance,
      transaction_type: 'withdraw_from_box',
      comment: @comment
      )
  end

  def create_transfer
    Transfer.withdraw_money_as!(@transfert_to, {
      title: FormatStringForCitiTransfer.new(string: "Wypłata pieniędzy ze zbiórki: #{@box.name} #{@box.group.name}").call,
      amount: @payment.amount,
      payment_id: @payment.id,
      })
  end

  def new_target_user_balance
    @transfert_to.balance + @amount
  end

  def new_target_user_virtual_balance
    @transfert_to.virtual_balance + @amount
  end

  def new_box_balance
    @box.balance - @amount
  end

  def update_box_balance
    @box.update_attributes!(
      balance: new_box_balance
      )
  end

  def update_box_balance_before_withdrawal
    @box.update_attributes!(
      balance_before_withdrawal: @box.balance
      )
  end

  def update_user
    @transfert_to.update_attributes!(balance: new_target_user_balance)
  end
end