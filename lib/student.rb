require_relative "../config/environment.rb"

class Student
attr_accessor :id, :name, :grade
@@all = []
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade)
    @id = nil
    @name = name
    @grade = grade
    @@all << self
  end

  def self.all
    @@all
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY, 
      name TEXT,
      grade TEXT
    );
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
    if 
      self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students(name, grade) 
      VALUES(?,?);
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
 end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(student)
    new_student = Student.new(student[1], student[2])
    new_student.id = student[0]
          # sql = <<-SQL
          #   SELECT * FROM students
          # SQL
          # DB[:conn].execute(sql)
    new_student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL
    find_student = DB[:conn].execute(sql, name)[0]
    found_student = Student.new(find_student[1], find_student[2])
    found_student.id = find_student[0]
    found_student
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
