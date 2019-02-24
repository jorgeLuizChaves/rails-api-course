class CommentSerializer < ApplicationSerializer
  attributes :content
  has_one :article
  has_one :user
end
