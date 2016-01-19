class StudentDecorator < Draper::Decorator
  delegate_all
  include Draper::LazyHelpers

  def last_login_date
    if object.current_sign_in_at
      localize object.current_sign_in_at, format: :dnia
    else
      content_tag :p, '-'
    end
  end

  def correct_quiz_answers_overview(params = {})
    days = params[:days]
    content_tag :p, "#{object.number_of_correct_quiz_answers_within(days: days)} / #{object.total_number_of_quiz_answers_within(days)} #{correct_quiz_answer_proportion(days)}"
  end

  def incorrect_quiz_answers_overview(params = {})
    days = params[:days]
    content_tag :p, "#{object.number_of_incorrect_quiz_answers_within(days: days)} / #{object.total_number_of_quiz_answers_within(days)} #{incorrect_quiz_answer_proportion(days)}"
  end

  def new_to_active_spb_overview(days)
    "#{object.number_of_spbs_created_within(days: days)} / #{object.total_number_of_active_spbs_within_last(days)} #{new_to_active_spb_proportion(days)}"
  end

  def spb_relocation_overview(days)
    "#{object.number_of_spb_relocations_within(days)} / #{object.total_number_of_active_spbs_within_last(days)} #{spb_relocation_proportion(days)}"
  end

  def select_gift_category_link(gift_category)
    link_to 'Wybierz', game_zone_students_gift_category_path(object, gift_category), class: 'select_gift_btn', remote: true
  end

  def back_to_gift_categories_link(params = {})
    active = params[:active]
    link_to 'Wybierz kategorię', game_zone_students_gift_categories_path(object), remote: true, class: "btn btn-default #{'active_breadcrumb' if active == 'select_cat'}"
  end

  def back_to_gifts_link(params = {})
    active = params[:active]
    gift = params[:gift]
    link_to 'Wybierz prezent', game_zone_students_gift_category_path(object, gift.gift_category), remote: true, class: "btn btn-default #{'active_breadcrumb' if active == 'select_gift'}"
  end


  def new_bought_gift_link(gift)
    link_to 'Wybierz', game_zone_students_new_bought_gift_path(object, gift), class: 'select_gift_btn', remote: true
  end

  def membership_links
    if object.memberships.accepted.any?
      links_to_groups
    else
      join_new_group_link
    end
  end

  private

  def join_new_group_link
    content_tag :li do
      link_to 'Dołącz do nowej klasy', new_student_membership_path(object), class: 'btn btn-back'
    end
  end

  def links_to_groups
    result = ''
    object.memberships.accepted.map(&:group).each do |group|
      li = content_tag :li do
        link_to group, group, class: 'btn btn-back'
      end
      result << li
    end
    result.html_safe
  end

  def correct_quiz_answer_proportion(days)
    total_number_of_quiz_answers = object.total_number_of_quiz_answers_within(days)
    if total_number_of_quiz_answers > 0
      proportion = object.number_of_correct_quiz_answers_within(days: days).to_f * 100 / total_number_of_quiz_answers.to_f
      return "(#{number_with_precision proportion, precision: 1, strip_insignificant_zeros: true}%)"
    end
  end

  def incorrect_quiz_answer_proportion(days)
    total_number_of_quiz_answers = object.total_number_of_quiz_answers_within(days)
    if total_number_of_quiz_answers > 0
      proportion = object.number_of_incorrect_quiz_answers_within(days: days).to_f * 100 / total_number_of_quiz_answers.to_f
      return "(#{number_with_precision proportion, precision: 1, strip_insignificant_zeros: true}%)"
    end
  end

  def new_to_active_spb_proportion(days)
    total_number_of_spbs = object.total_number_of_active_spbs_within_last(days)
    if total_number_of_spbs > 0
      proportion = object.number_of_spbs_created_within(days: days).to_f * 100 / total_number_of_spbs.to_f
      return "(#{number_with_precision proportion, precision: 1, strip_insignificant_zeros: true}%)"
    end
  end

  def spb_relocation_proportion(days)
    total_number_of_spbs = object.total_number_of_active_spbs_within_last(days)
    if total_number_of_spbs > 0
      proportion = object.number_of_spb_relocations_within(days).to_f * 100 / total_number_of_spbs.to_f
      return "(#{number_with_precision proportion, precision: 1, strip_insignificant_zeros: true}%)"
    end
  end
end
