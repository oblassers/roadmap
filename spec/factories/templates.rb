# == Schema Information
#
# Table name: templates
#
#  id               :integer          not null, primary key
#  title            :string
#  description      :text
#  published        :boolean
#  org_id           :integer
#  locale           :string
#  is_default       :boolean
#  created_at       :datetime
#  updated_at       :datetime
#  version          :integer
#  visibility       :integer
#  customization_of :integer
#  family_id        :integer
#  archived         :boolean
#  links            :text             default({"funder"=>[], "sample_plan"=>[]})
#

FactoryBot.define do
  factory :template do
    org
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    locale "en_GB"
    is_default false
    published false
    archived false

    trait :archived do
      archived true
    end

    trait :default do
      is_default true
    end

    trait :published do
      published true
    end

    trait :unpublished do
      published false
    end
  end
end
