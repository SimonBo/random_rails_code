class ScheduleQuizzesFromCategory
  attr_reader :student, :quiz_category

  def initialize(params = {})
    @student_quiz_subscription = params[:student_quiz_subscription]
    @quiz_category = @student_quiz_subscription.quiz_category
    @student = @student_quiz_subscription.student
  end

  def call
    return if already_scheduled_enough_for_today?
    quizzes_to_schedule.each do |quiz_question|
      ScheduledQuiz.create quiz_question: quiz_question, student: student, scheduled_date: date
    end
  end

  private

  def category_question_ids
    quiz_category.quiz_questions.ids
  end

  def quizzes_to_schedule
    if available_quizzes.size < number_of_quizzes_needed
      return available_quizzes.concat answered_quizzes
    else
      available_quizzes
    end
  end

  def available_quizzes
    if number_of_quizzes_needed < 1
      @available_quizzes ||= []
    else
      @available_quizzes ||= quiz_category.quiz_questions_available_for_scheduling_for(student).concat(quizzes_answered_incorrectly).shuffle.take(number_of_quizzes_needed)
    end
  end

  def answered_quizzes
    quiz_category.appropriate_answered_questions_by_student(student).shuffle.take(number_of_quizzes_needed - available_quizzes.size)
  end

  def number_of_quizzes_needed
    number_of_quizzes_to_schedule - category_quizzes_scheduled_for_today.count
  end

  def number_of_quizzes_to_schedule
    quiz_category.number_of_quizzes_to_schedule
  end

  def category_quizzes_scheduled_for_today
    student.scheduled_quizzes.where(quiz_question_id: quiz_category.quiz_questions.ids, scheduled_date: date, answered: false)
  end

  def date
    Date.today
  end

  def quizzes_answered_incorrectly
    quiz_category.quiz_questions.joins(:student_quiz_answers).where(student_quiz_answers: { correct: false, student: student }).select { |qq| qq.student_quiz_answers.where(student: student).last.correct == false }
  end

  def already_scheduled_enough_for_today?
    student.scheduled_quizzes.where(quiz_question_id: category_question_ids, scheduled_date: date, answered: false).count >= number_of_quizzes_to_schedule
  end
end