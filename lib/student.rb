require_relative "../config/environment.rb"

# Remember, you can access your database connection anywhere in this class
#  with DB[:conn]

require 'pry'

class Student
  attr_accessor :id, :name, :grade

  def initialize(name, grade)
    @name = name
    @grade = grade
    @id = nil
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    # new_student = self.new
    # new_student.id = row[0]
    # new_student.name = row[1]
    # new_student.grade = row[2]
    new_student = self.new(row[1], row[2])
    new_student.id = row[0]
    new_student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
      SELECT * FROM students
    SQL
    all_array = DB[:conn].execute(sql)
    all_array.map { |student| self.new_from_db(student)}
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT * FROM students
      WHERE students.name = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
    new_student
  end

  def save
    if !self.id
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      self.update
    end
    DB[:conn].execute("SELECT * FROM students ORDER BY id DESC LIMIT 1")
    # binding.pry
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET (name, grade) = (?, ?)
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
