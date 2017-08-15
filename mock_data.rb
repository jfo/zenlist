MenuItem.new({"id" => 1, "name" => "Root Node" }).store
    MenuItem.new({"id" => 2, "name" => "Child Menu 1", "parent" => "1" }).store
        MenuItem.new({ "id" => 3, "name" => "Child Menu 1.1", "parent" => "2" }).store
            Article.new({"id" => 1, "title" => "Child Article 1.1.1", "body" => "I'm an article", "parent" => "3" }).store
        MenuItem.new({"id" => 4, "name" => "Child Menu 1.2", "parent" => "2" }).store
            MenuItem.new({"id" => 7, "name" => "Child Menu 1.2.1", "parent" => "4" }).store
        MenuItem.new({"id" => 5, "name" => "Child Menu 1.3", "parent" => "2" }).store
    Article.new({"id" => 2, "title" => "Child Article 2", "body" => "I am an article, too", "parent" => "1" }).store
    MenuItem.new({"id" => 6, "name" => "Child Menu 2", "parent" => "1" }).store
    Article.new({"id" => 3, "title" => "Child Article 1", "body" => "I'm a top level article", "parent" => "1" }).store
