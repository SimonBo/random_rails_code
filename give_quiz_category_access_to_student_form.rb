class GiveQuizCategoryAccessToStudentForm
  include ActiveModel::Model

  attr_accessor :student_id, :quiz_category_id, :period

  validate :student_cant_be_subscribed_to_the_category

  def persisted?
    false
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    create_subscription
    send_email
  end

  def create_subscription
    StudentQuizSubscription.create(student_id: student_id, status: 'subscribed', sponsored_to: sponsored_to, sponsored_by_sk: true, quiz_category_id: quiz_category_id)
  end

  def sponsored_to
    Date.today + period.to_i.months
  end

  def send_email
    SubscriptionSponsorMailer.notify_parents_about_sk_sponsored_quiz(student: student, quiz_category: quiz_category, period: period).deliver
  end

  def student
    Student.find(student_id)
  end

  def quiz_category
    QuizCategory.find(quiz_category_id)
  end

  def student_cant_be_subscribed_to_the_category
    if student.student_quiz_subscriptions.where(status: StudentQuizSubscription::ACTIVE_STATES, quiz_category_id: quiz_category_id).any?
      errors.add(:quiz_category_id, "Uczeń został już przypisany do tej ścieżki")
    end
  end
end
