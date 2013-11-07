require 'nokogiri'

cavern_content = File.read("Caverns.xml")
cavern_xml = Nokogiri::XML(cavern_content)

names = cavern_xml.xpath("/Root/Body/p[@aid:pstyle='MonsterName']")
stats = cavern_xml.xpath("/Root/Body/p[@aid:pstyle='MonsterStats']")
qualities = cavern_xml.xpath("/Root/Body/p[@aid:pstyle='MonsterQualities']")
description = cavern_xml.xpath("/Root/Body/p[@aid:pstyle='MonsterDescription']")
actions = cavern_xml.xpath("/Root/Body/ul")

total = names.count

class Monster
  attr_accessor :name, :tags, :hp, :armor, :attack, :description, :actions
end

class Attack
  def self.parse(text)
    name = text[/^(\w+)/,1]
    damage = text[/\(([^\)]+)\)/,1]
    new name, damage
  end

  def initialize(name,damage)
    @name = name
    @damage = damage
  end

  attr_reader :name, :damage
  attr_accessor :tags

  def to_s
    "#{name} (#{damage}) [#{tags.join(", ")}]"
  end
end

monsters = total.times.map do |index|
  monster = Monster.new
  name_and_tag = names[index]

  name = name_and_tag.children.first.text
  tags = name_and_tag.children.last.text.split(",").map {|t| t.strip }

  monster.name = name
  monster.tags = tags

  attack_stats_index = index * 2
  attack_tags_index = index * 2 + 1

  stats_text = stats[attack_stats_index].text

  hp = stats_text[/(\d+) HP/,1]
  armor = stats_text[/(\d+) Armor/,1]

  monster.hp = hp
  monster.armor = armor

  attack = stats_text.gsub(/\d+ HP/,'').gsub(/\d+ Armor/,'').strip

  monster.attack = Attack.parse(attack)
  monster.attack.tags = stats[attack_tags_index].text.split(",").map {|t| t.strip }

  # All monsters
  # monster.qualities = qualities[index].text
  monster.description = description[index].text
  monster.actions = actions[index].children.map {|c| c.text.strip }.reject {|c| c == ""}
  monster
end

monster = monsters.first

puts "Name: #{monster.name}"
puts "Tags: #{monster.tags.join(", ")}"
puts "HP: #{monster.hp}"
puts "Armor: #{monster.armor}"
puts "Attack: #{monster.attack}"
puts ""
puts "Description: #{monster.description}"
puts ""
puts "Actions: #{monster.actions.join(", ")}"

monsters.each do |monster|
  puts "Name: #{monster.name}"
  puts "Attack: #{monster.attack}"
end