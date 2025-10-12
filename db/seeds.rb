# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Club.create(name: "club basketball", description: "Students who love to play basketball")
Club.create(name: "club soccer", description: "Students who love to play soccer")
Club.create(name: "club tennis", description: "Students who love to play tennis")
Club.create(name: "club volleyball", description: "Students who love to play volleyball")
Club.create(name: "club swimming", description: "Students who love to swim")
Club.create(name: "club chess", description: "Students who love to play chess")
Club.create(name: "club debate", description: "Students who are looking to become future lawyers")
Club.create(name: "club music", description: "Students who love to play music")
Club.create(name: "club coding", description: "Students who love to code")
Club.create(name: "club medical", description: "Students who are looking to become future medical professionals")
Club.create(name: "korean american student association", description: "Any and all students who are interested in Korean culture and language")
Club.create(name: "international student association", description: "Organization for international students to connect")
Club.create(name: "south asian student association", description: "Any students willing to learn about the culture and history of South Asia")
Club.create(name: "chinese student association", description: "Any students looking to learn about the culture and history of China")
Club.create(name: "professional business fraternity", description: "Students who are looking for professional experience in business")
Club.create(name: "professional medicine fraternity", description: "Students aspiring to make connections with peers in the medical field")
Club.create(name: "Theater club", description: "Students who love to act and perform")
Club.create(name: "Opera Club", description: "Students who love to sing and perform")
Club.create(name: "Robotics Club", description: "Any Students who are interested in robotics")
Club.create(name: "Formula SAE", description: "Students who are interested in Formula SAE")