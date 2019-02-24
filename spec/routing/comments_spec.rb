require "rails_helper"

RSpec.describe CommentsController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(:get => "/articles/1/comments/1").to route_to("comments#show", :article_id => "1", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/articles/1/comments").to route_to("comments#create", :article_id => "1")
    end
  end
end
