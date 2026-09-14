require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "validations" do
    it "nameが必須であること" do
      project = build(:project, name: nil)

      expect(project).to be_invalid
    end

    it "completedがtrue/falseであること" do
      project = build(:project, completed: nil)

      expect(project).to be_invalid
    end
  end
end
