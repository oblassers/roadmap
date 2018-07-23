# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  plan_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  access     :integer          default(0), not null
#  active     :boolean          default(TRUE)
#

FactoryBot.define do
  factory :role do
    user
    plan
    access 1

    trait :reviewer do
      reviewer true
    end
    trait :administrator do
      administrator true
    end
    trait :editor do
      editor true
    end
    trait :commenter do
      commenter true
    end
  end
end
