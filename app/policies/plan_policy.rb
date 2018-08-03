# frozen_string_literal: true

# Handles the permissions governing acess to a Plan.
#
class PlanPolicy < ApplicationPolicy

  # ==============
  # = Attributes =
  # ==============

  ##
  # The User we're governing access for
  attr_reader :user

  ##
  # The Plan we're governing access to
  attr_reader :plan

  # =============
  # = Constants =
  # =============

  # Error message shown when {user} is nil
  NIL_USER_ERROR = _("must be logged in")

  # Error shown when {plan} is nil
  UNAUTHORIZED_ERROR = _("are not authorized to view that plan")

  # ===========================
  # = Public instance methods =
  # ===========================

  def initialize(user, plan)
    raise Pundit::NotAuthorizedError, NIL_USER_ERROR if user.nil?
    unless plan&.publicly_visible?
      raise Pundit::NotAuthorizedError, UNAUTHORIZED_ERROR
    end
    @user = user
    @plan = plan
  end

  def show?
    plan.readable_by?(user.id)
  end

  def share?
    plan.editable_by?(user.id)
  end

  def export?
    plan.readable_by?(user.id)
  end

  def download?
    plan.readable_by?(user.id)
  end

  def edit?
    plan.readable_by?(user.id)
  end

  def update?
    plan.editable_by?(user.id)
  end

  def destroy?
    plan.editable_by?(user.id)
  end

  def status?
    plan.readable_by?(user.id)
  end

  def duplicate?
    plan.editable_by?(user.id)
  end

  def visibility?
    plan.administerable_by?(user.id)
  end

  def set_test?
    plan.administerable_by?(user.id)
  end

  def answer?
    plan.readable_by?(user.id)
  end

  def request_feedback?
    plan.administerable_by?(user.id)
  end

  def overview?
    plan.readable_by?(user.id)
  end

  def select_guidances_list?
    plan.readable_by?(user.id)
  end

  def update_guidances_list?
    plan.editable_by?(user.id)
  end

  def phase_status?
    plan.readable_by?(user.id)
  end
end
