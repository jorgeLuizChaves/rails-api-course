class ArticleSerializer < ActiveModel::Serializer
  attributes :title, :content, :slug
end
