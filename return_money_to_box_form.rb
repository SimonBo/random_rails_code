class ReturnMoneyToBoxForm
  include ActiveModel::Model

  attr_accessor :box_id, :user_id, :amount, :comment

  validate :amount_cant_be_higher_than_user_balance
  validate :amount_cant_be_higher_than_total_withdrawn_from_box
  validates :amount, numericality: { greater_than: 0 }

  def persisted?
    false
  end

  def save
    if valid? and returned_money?
      true
    else
      false
    end
  end

  private

  def returned_money?
    HandleReturnMoneyToBox.new(amount: amount, user_id: user_id, box_id: box_id, comment: comment).call
  end

  def user
    User.find user_id
  end

  def amount_cant_be_higher_than_user_balance
    if user.virtual_balance < amount.to_d
      errors.add(:amount, "nie może być wyższa niż twoje saldo")
    end
  end

  def amount_cant_be_higher_than_total_withdrawn_from_box
    if amount.to_d > Box.find(box_id).total_withdrawn
      errors.add(:amount, "nie może być wyższa niż suma wypłat ze zbiórki.")
    end
  end
end