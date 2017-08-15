require_relative 'ORM'

class MenuItem < Model
    attr_accessor :children, :has_articles_in_branch

    def to_h
        out = super.to_h
        out["children"] = @children.map { |e| e.to_h }
        out["has_articles_in_branch"] = @has_articles_in_branch
        out
    end

    def to_json
        self.to_h.to_json
    end

    protected def initORM
        @children = []
    end
end

class Article < Model; end

class Menu
    attr_accessor :root
    def initialize(root_id)
        @root = MenuItem::find(root_id)
        if !@root.nil?
            @root.children = populate_node_children(@root)
            @root.has_articles_in_branch = append_article_existence_in_branch(@root)
        end
    end

    def to_json
        @root.to_json
    end

    private

    def populate_node_children(menuitem)
        childmenuitems = MenuItem::findManyByColumn('parent', menuitem.id)
        childmenuitems.each {|e| e.children = populate_node_children(e) }
        childmenuitems += Article::findManyByColumn('parent', menuitem.id)
    end

    def append_article_existence_in_branch(menuitem)
        menuitem.has_articles_in_branch = menuitem.children.map do |e|
            e.is_a?(Article) || append_article_existence_in_branch(e)
        end.to_a.include?(true)
        menuitem.has_articles_in_branch
    end
end
