# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
user = User.create({login: "jonh-connor", provider: "github"})

Article.create([{title: "My awesome article 1", content: "The content of my awesome article 1", slug: "my-awesome-article-1", user: user },
                {title: "My awesome article 2", content: "The content of my awesome article 2", slug: "my-awesome-article-2", user: user },
                {title: "My awesome article 3", content: "The content of my awesome article 3", slug: "my-awesome-article-3", user: user }])