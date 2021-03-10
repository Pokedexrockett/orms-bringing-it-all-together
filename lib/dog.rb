class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        
        sql = <<-SQL
        CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            );
        SQL

        
        DB[:conn].execute(sql)

    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs;")

        
    end

    def save
        if self.id
            self
          else
            sql = <<-SQL
              INSERT INTO dogs (name, breed)
              VALUES (?, ?)
            SQL
      
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
          end
    end

    def self.create(attr_hash)
        dog = self.new(name: attr_hash[:name], breed: attr_hash[:breed])
        dog.save
    end

    def self.new_from_db(arr)
        self.new(name: arr[1], breed: arr[2], id: arr[0])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
           
        SQL

        attr_array = DB[:conn].execute(sql, id).first
        self.new(id: attr_array[0], name: attr_array[1], breed: attr_array[2])
    end

    def self.find_or_create_by(name:, breed:)
        attr_array = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !attr_array.empty?
          dog = attr_array[0]
          attr_array = self.new(id: dog[0], name: dog[1], breed: dog[2])
        else
          attr_array = self.create(name: name, breed: breed)
        end
        attr_array
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        attr_array = DB[:conn].execute(sql, name).first
        self.new(id: attr_array[0], name: attr_array[1], breed: attr_array[2])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end