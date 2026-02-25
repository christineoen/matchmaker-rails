# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Sample club
club = Club.find_or_create_by!(slug: "riverside-tennis") do |c|
  c.name = "Riverside Tennis Club"
end

# Grade levels (higher rank = stronger)
grade_names = [ "Grade 5", "Grade 4", "Grade 3", "Grade 2", "Grade 1" ]
grade_names.each_with_index do |name, index|
  GradeLevel.find_or_create_by!(club: club, rank: index + 1) do |g|
    g.name = name
  end
end

grades = club.grade_levels.ordered.to_a

# Courts
[
  { name: "1", surface: "grass", position: 1 },
  { name: "2", surface: "grass", position: 2 },
  { name: "3", surface: "grass", position: 3 },
  { name: "4", surface: "hard", position: 4 }
].each do |attrs|
  Court.find_or_create_by!(club: club, name: attrs[:name]) do |c|
    c.surface = attrs[:surface]
    c.position = attrs[:position]
  end
end

# Admin user
admin = User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.first_name = "Alice"
  u.last_name = "Admin"
  u.password = "password"
end
Membership.find_or_create_by!(user: admin, club: club) { |m| m.role = :admin }

# Sample players
[
  { first_name: "Bob",   last_name: "Smith",   gender: :male,   grade: grades[4], plus_minus: :neutral },
  { first_name: "Carol", last_name: "Jones",   gender: :female, grade: grades[3], plus_minus: :plus },
  { first_name: "Dave",  last_name: "Brown",   gender: :male,   grade: grades[3], plus_minus: :minus },
  { first_name: "Eve",   last_name: "Wilson",  gender: :female, grade: grades[2], plus_minus: :neutral },
  { first_name: "Frank", last_name: "Taylor",  gender: :male,   grade: grades[2], plus_minus: :neutral },
  { first_name: "Grace", last_name: "Lee",     gender: :female, grade: grades[1], plus_minus: :plus },
  { first_name: "Hank",  last_name: "Martin",  gender: :male,   grade: grades[1], plus_minus: :neutral },
  { first_name: "Ivy",   last_name: "Clark",   gender: :female, grade: grades[0], plus_minus: :minus }
].each do |attrs|
  Player.find_or_create_by!(club: club, first_name: attrs[:first_name], last_name: attrs[:last_name]) do |p|
    p.gender = attrs[:gender]
    p.grade_level = attrs[:grade]
    p.plus_minus = attrs[:plus_minus]
  end
end

puts "Seeded: #{club.name}"
puts "  #{club.grade_levels.count} grade levels"
puts "  #{club.courts.count} courts"
puts "  #{club.players.count} players"
puts "  #{club.memberships.count} memberships"
