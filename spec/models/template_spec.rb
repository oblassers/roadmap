require 'rails_helper'

RSpec.describe Template, type: :model do

  context "validations" do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:description) }

    it { is_expected.to allow_values(true, false).for(:published) }

    # This is currently being set in the defaults before validation
    # it { is_expected.not_to allow_value(nil).for(:published) }

    it { is_expected.to validate_presence_of(:org) }

    it { is_expected.to validate_presence_of(:locale) }

    it { is_expected.to allow_values(true, false).for(:is_default) }

    # This is currently being set in the defaults before validation
    # it { is_expected.not_to allow_value(nil).for(:is_default) }

    # This is currently being set in the defaults before validation
    # it { is_expected.to validate_presence_of(:version) }

    # This is currently being set in the defaults before validation
    # it { is_expected.to validate_presence_of(:visibility) }

    # This is currently being set in the defaults before validation
    # it { is_expected.to validate_presence_of(:family_id) }

    it { is_expected.to allow_values(true, false).for(:archived) }

    # This is currently being set in the defaults before validation
    # it { is_expected.not_to allow_value(nil).for(:archived) }
  end

  context "associations" do

    it { is_expected.to belong_to :org }

    it { is_expected.to have_many :plans }

    it { is_expected.to have_many :phases }

    it { is_expected.to have_many :sections }

    it { is_expected.to have_many :questions }

    it { is_expected.to have_many :annotations }

  end

  describe '.archived' do

    subject { Template.archived }

    context "when template is archived" do

      let!(:template) { create(:template, archived: true) }

      it { is_expected.to include(template) }

    end

    context "when template is archived" do

      let!(:template) { create(:template, archived: false) }

      it { is_expected.not_to include(template) }

    end
  end

  describe '.unarchived' do

    subject { Template.unarchived }

    context "when template is archived" do

      let!(:template) { create(:template, archived: true) }

      it { is_expected.not_to include(template) }

    end

    context "when template is archived" do

      let!(:template) { create(:template, archived: false) }

      it { is_expected.to include(template) }

    end
  end

  describe '.default' do

    subject { Template.default }

    context "when default published template exists" do


      before do
        @a = create(:template, :default, :published)
        @b = create(:template, :default, :published)
      end

      it "returns the latest record" do
        expect(subject).to eql(@b)
      end

    end

    context "when default template is not published" do

      before do
        create(:template, :default, :unpublished)
      end

      it { is_expected.to be_nil }

    end

    context "when none of the published templates are default" do

      before do
        create(:template, :published, is_default: false)
      end

      it { is_expected.to be_nil }

    end

  end

  describe '.published' do

    subject { Template.published }

    context "when template is published" do

      let!(:template) { create(:template, :unpublished) }

      it { is_expected.not_to include(template) }

    end

    context "when none of the published templates are default" do

      let!(:template) { create(:template, :published) }

      it { is_expected.to include(template) }

    end

  end

  describe ".latest_version" do

    let!(:family_id) { nil }

    subject { Template.latest_version(family_id) }

    it "returns an ActiveRecord::Relation" do
      expect(subject).to be_a(ActiveRecord::Relation)
    end

    context "when family_id is present" do

      let!(:family_id) { "1235" }

      let!(:template) do
        create(:template, :unpublished, family_id: "1235", version: 12)
      end

      before do
        create(:template, :unpublished, family_id: "1235", version: 11)
        create(:template, :unpublished, family_id: "9999", version: 13)
      end

      it "filters results by family_id" do
        expect(subject).to include(template)
      end

    end

    context "when family_id is absent" do

      let!(:family_id) { nil }

      let!(:template) { create(:template, :unpublished, version: 12) }

      before do
        create(:template, :unpublished, version: 11)
        create(:template, :unpublished, version: 10)
      end

      it "returns the " do
        expect(subject).to include(template)
      end

    end

    context "when template is archived" do

      let!(:family_id) { nil }

      let!(:template) { create(:template, :archived, :unpublished, version: 12) }

      before do
        @a = create(:template, :unpublished, version: 11)
        @b = create(:template, :unpublished, version: 10)
      end

      it "excludes from the results" do
        expect(subject).not_to include(template)
      end

    end

  end

  describe ".published" do


    subject { Template.published(family_id) }

    before do
      @a = create(:template, :published, family_id: family_id, version: 1)
      @b = create(:template, :published, version: 3)
      @c = create(:template, :unpublished, family_id: family_id, version: 2)
      @d = create(:template, :unpublished, version: 5)
    end

    context "when family_id is present" do

      let!(:family_id) { "1234" }

      it "includes records with family id" do
        expect(subject).to include(@a)
      end

      it "excludes records without family id" do
        expect(subject).not_to include(@b)
      end

      it "excludes unpublished records" do
        expect(subject).not_to include(@c)
        expect(subject).not_to include(@d)
      end

    end

    context "when family_id is absent" do

      let!(:family_id) { nil }

      it "includes all published records" do
        expect(subject).to include(@a)
        expect(subject).to include(@b)
      end

      it "excludes all published records" do
        expect(subject).not_to include(@c)
        expect(subject).not_to include(@d)
      end
    end
  end

  # # Retrieves the latest templates, i.e. those with maximum version associated.
  # # It can be filtered down if family_id is passed. NOTE, the template objects
  # # instantiated only contain version and family attributes populated. See
  # # Template::latest_version scope method for an adequate instantiation of
  # # template instances.
  # scope :latest_version_per_family, -> (family_id = nil) {
  #   chained_scope = unarchived.select("MAX(version) AS version", :family_id)
  #   if family_id.present?
  #     chained_scope = chained_scope.where(family_id: family_id)
  #   end
  #   chained_scope.group(:family_id)
  # }
  #
  # scope :latest_customized_version_per_customised_of, -> (customization_of=nil,
  #                                                         org_id = nil) {
  #   chained_scope = select("MAX(version) AS version", :customization_of)
  #   chained_scope = chained_scope.where(customization_of: customization_of)
  #   if org_id.present?
  #     chained_scope = chained_scope.where(org_id: org_id)
  #   end
  #   chained_scope.group(:customization_of)
  # }
  #
  # # Retrieves the latest templates, i.e. those with maximum version associated.
  # # It can be filtered down if family_id is passed
  # scope :latest_version, -> (family_id = nil) {
  #   unarchived.from(latest_version_per_family(family_id), :current)
  #     .joins(<<~SQL)
  #       INNER JOIN templates ON current.version = templates.version
  #         AND current.family_id = templates.family_id
  #       INNER JOIN orgs ON orgs.id = templates.org_id
  #     SQL
  # }
  #
  # # Retrieves the latest customized versions, i.e. those with maximum version
  # # associated for a set of family_id and an org
  # scope :latest_customized_version, -> (family_id = nil, org_id = nil) {
  #   unarchived
  #     .from(latest_customized_version_per_customised_of(family_id, org_id),
  #           :current)
  #     .joins(<<~SQL)
  #       INNER JOIN templates ON current.version = templates.version
  #         AND current.customization_of = templates.customization_of
  #       INNER JOIN orgs ON orgs.id = templates.org_id
  #     SQL
  #     .where(templates: { org_id: org_id })
  # }
  #
  # # Retrieves the latest templates, i.e. those with maximum version associated
  # # for a set of org_id passed
  # scope :latest_version_per_org, -> (org_id = nil) {
  #   if org_id.respond_to?(:each)
  #     family_ids = families(org_id).pluck(:family_id)
  #   else
  #     family_ids = families([org_id]).pluck(:family_id)
  #   end
  #   latest_version(family_ids)
  # }
  #
  # # Retrieve all of the latest customizations for the specified org
  # scope :latest_customized_version_per_org, -> (org_id=nil) {
  #   family_ids = families(org_id).pluck(:family_id)
  #   latest_customized_version(family_ids, org_id)
  # }
  #
  # # Retrieves templates with distinct family_id. It can be filtered down if
  # # org_id is passed
  # scope :families, -> (org_id=nil) {
  #   if org_id.respond_to?(:each)
  #     unarchived.where(org_id: org_id, customization_of: nil).distinct
  #   else
  #     unarchived.where(customization_of: nil).distinct
  #   end
  # }
  #
  # # Retrieves the latest version of each customizable funder template (and the
  # # default template)
  # scope :latest_customizable, -> {
  #   family_ids = families(Org.funder.collect(&:id)).distinct.pluck(:family_id) << default.family_id
  #   published(family_ids.flatten).where('visibility = ? OR is_default = ?', visibilities[:publicly_visible], true)
  # }
  #
  # # Retrieves unarchived templates with public visibility
  # scope :publicly_visible, -> {
  #   unarchived.where(visibility: visibilities[:publicly_visible])
  # }
  #
  # # Retrieves unarchived templates with organisational visibility
  # scope :organisationally_visible, -> {
  #   unarchived.where(visibility: visibilities[:organisationally_visible])
  # }
  #
  # # Retrieves unarchived templates whose title or org.name includes the term
  # # passed
  # scope :search, -> (term) {
  #   unarchived.where("templates.title LIKE :term OR orgs.name LIKE :term",
  #                      { term: "%#{term}%" })
  # }
  #
end
