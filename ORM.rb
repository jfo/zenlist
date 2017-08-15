require 'sqlite3'
require 'json'

$db = SQLite3::Database.new "data.db"

class Model
    attr_accessor :new_record, :columns

    def initialize(varhash = {})
        @table = self.class.to_s.downcase + 's'
        @columns = $db.table_info(@table).map do |column|
            column['name']
        end

        @columns.each_with_index do |column_name, idx|
            self.class.class_eval { attr_accessor column_name.to_sym }
            instance_variable_set("@#{column_name}", varhash[column_name])
        end
        @new_record = true
         if self.methods.include? :initORM then self.send(:initORM) end
    end

    def store
        if @new_record
            insert
            @new_record = false
        else
            update
        end
    end

    def self.findManyByColumn(col, val)
        table = self.to_s.downcase + 's'
        columns = $db.table_info(table).map do |column|
            column['name']
        end
        query = "SELECT * FROM #{table} WHERE #{col}=?"
        records = $db.execute(query, val)
        input_hash = {}

        records.collect! do |arr|
            item = self.new(columns.zip(arr).to_h)
            item.new_record = false
            item
        end
        records
    end

    def self.find(pk)
        table = self.to_s.downcase + 's'
        columns = $db.table_info(table).map do |column|
            column['name']
        end
        record = $db.execute("select * from #{table} where id=#{pk}").first

        return nil if record.nil?

        model = self.new
        columns.each_with_index do |column, idx|
            self.class_eval { attr_accessor column.to_sym }
            instance_variable_set("@#{column}", (record ? record[idx] : nil))
            model.send(column + "=", record[idx])
        end
        model.new_record = false
        model
    end

    def to_h
        outhash = @columns.map do |column|
             [column, instance_variable_get("@#{column}")]
        end.to_h
        outhash["class"] = self.class.to_s.downcase
        outhash
    end

    def to_json
        to_h.to_json
    end

    private

    def insert
        q = @columns[1..-1].map{'?'}.join(', ')
        values = @columns[1..-1].map{|e| instance_variable_get("@#{e}")}
        query = "insert into #{@table}(#{@columns[1..-1].join(', ')}) values(#{q});"
        $db.execute(query, values)
        @new_record = false
        @id = $db.execute("SELECT last_insert_rowid()").first.first
    end

    def update
        inserts = @columns[1..-1].map {|col| col + '=?'}
        query = "UPDATE #{@table} SET #{inserts.join(", ")} WHERE ID=#{@id}"
        values = @columns[1..-1].map{|e| instance_variable_get("@#{e}")}

        $db.execute(query, values)
    end
end
