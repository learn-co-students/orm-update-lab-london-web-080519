require_relative "../config/environment.rb"
require 'pry'

class Student

  @@all = []
  attr_reader :id
  attr_accessor :name, :grade
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
    @@all << self
  end

  def self.all
    @@all
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE students (id INTEGER PRIMARY KEY, name TEXT, age INTEGER);
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
        DROP TABLE students;
      SQL

      DB[:conn].execute(sql)
  end

  def save
    if self.id
      update
    else
      # INSERT INTO table
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id=?;
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    student = Student.new(name, grade, id)
  end

  def self.find_by_name(name)
    # sql = <<-SQL
    #     SELECT id FROM students WHERE name = ?;
    #   SQL

    # id = DB[:conn].execute(sql, name)[0][0]
    # self.all.select{|student| student.id == id}
    # self.all.select{|student| student.name == name}
    # binding.pry
    sql = <<-SQL
        SELECT * FROM students WHERE name = ?;
      SQL

    row = DB[:conn].execute(sql, name)[0]
    # binding.pry
    self.new_from_db(row)
  end

end
