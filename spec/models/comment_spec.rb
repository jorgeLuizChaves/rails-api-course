require 'rails_helper'

RSpec.describe Comment, type: :model do

  describe ".validations" do
    it 'should have a valid factory' do
      comment = build :comment
      expect(comment).to be_valid
    end

    it 'validate the presence of comment' do
      comment = build :comment, content: nil
      expect(comment).not_to be_valid
      expect(comment.errors.messages[:content]).to include("can't be blank")
    end

    it 'validate the presence of user' do
      comment = build :comment, user: nil
      expect(comment).not_to be_valid
      expect(comment.errors.messages[:user]).to include("must exist")
    end

    it 'validate the presence of article' do
      comment = build :comment, article: nil
      expect(comment).not_to be_valid
      expect(comment.errors.messages[:article]).to include("must exist")
    end

  end
end
