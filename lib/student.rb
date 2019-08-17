require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_reader :id
  attr_accessor :name, :grade

  def initialize(id= nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT);"
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
  
  
  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
    
  end
  
  def update
    sql = "UPDATE students SET name = ?, grade = ?"
    DB[:conn].execute(sql, self.name, self.grade)
  end
  
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    # id = row[0]
    # name = row[1]
    # grade = row[2]
    # self.new(id, name, grade)
    student = self.new(row[0],row[1],row[2])
    student
  end

  def self.all
    sql = "SELECT * FROM students"
    DB[:conn].execute(sql).map {|row| self.new_from_db(row)}
    
  end
  
  def self.find_by_name(name)
    # DB[:conn].execute(sql, name).map{|row| self.new_from_db(row)}.first
    sql = "SELECT * FROM students WHERE name = ?"
    student = DB[:conn].execute(sql, name).first
    self.new_from_db(student)
  end



  
end
