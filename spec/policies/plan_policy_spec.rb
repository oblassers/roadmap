require "rails_helper"

describe PlanPolicy, type: :policy do

  describe ".new" do

    let!(:user) { create(:user) }

    let!(:plan) { create(:plan, :publicly_visible) }

    subject { PlanPolicy.new(user, plan) }

    context "when user param is nil" do




    end

    context "when plan param is nil" do



    end
  end

end