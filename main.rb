


require 'gosu'
require './draw.rb'

module ZOrder 
  BACKGROUND, DISPLAY, ENTITIES, HOOK = *0..3
end

module GameMsg
  Return, PlayerName, FinshScore = *"Press ESC to return", "Enter your name:", "Your score is:"
end

module Error
  NoFile = *"Can't open file"
end

class Fish
  attr_accessor :image, :x, :y, :speed_x, :speed_y, :y_vel, :fish_spawn_chance, :spawn_range

  def initialize(image, x, y, speed_x, speed_y, y_vel, fish_spawn_chance, spawn_range)
    @image = image
    @x = x
    @y = y
    @speed_x = speed_x
    @speed_y = speed_y
    @y_vel = y_vel
    @fish_spawn_chance = fish_spawn_chance
    @spawn_range = spawn_range
  end
end

class HighScore
  attr_accessor :name, :score

  def initialize name, score
    @name = name
    @score = score
  end
end

class FishingGame < Gosu::Window

  def initialize
    @window = super(800, 600)
    self.caption = "Boat Cat Fishing Adventure"

    @timer = 30

    @menu_bg = Gosu::Image.new("./img/menu.png")
    @select_bg = Gosu::Image.new("./img/select_bg.png")
    @play_bg = Gosu::Image.new("./img/play_bg.png")
    @fish_shelf_bg = Gosu::Image.new("./img/fish_shelf.png")

    @play_button = Gosu::Image.new("./img/button_play.png")
    @exit_button = Gosu::Image.new("./img/button_exit.png")
    @menu_button = Gosu::Image.new("./img/button_menu.png")
    @back_button = Gosu::Image.new("./img/button_back.png")
    @score_button = Gosu::Image.new("./img/button_score.png")
    @start_button = Gosu::Image.new("./img/button_start.png")
    @newgame_button = Gosu::Image.new("./img/button_newgame.png")
    @fish_collection_button = Gosu::Image.new("./img/fish_collection_button.png")
    @return_button = Gosu::Image.new("./img/button_troll_return.png")

    @title = Gosu::Image.new("./img/title.png")
    @weak_cat = Gosu::Image.new("./img/Fraser.png")
    @weak_cat_name = Gosu::Image.new("./img/weak_cat_name.png")
    @strong_cat = Gosu::Image.new("./img/Duc.png")
    @strong_cat_name = Gosu::Image.new("./img/strong_cat_name.png")
    @hook = Gosu::Image.new("./img/hook.png")

    @fish_bowl = Gosu::Image.new("./img/fish_bowl.png")
    @small_fish = Gosu::Image.new("./img/Ruoi.png")
    @medium_fish = Gosu::Image.new("./img/Huybubi.png")
    @shark = Gosu::Image.new("./img/HaiAnh.png")
    @gold_fish = Gosu::Image.new("./img/Klinh.png")
    @jelly_fish = Gosu::Image.new("./img/Nam.png")

    @font = Gosu::Font.new(40)
    @info_font = Gosu::Font.new(35)
    @settings_font = Gosu::Image.new("./img/settings_font.png")
    @finish_font = Gosu::Image.new("./img/game_over.png")
    @score_font = Gosu::Image.new("./img/score_font.png")
    @fish_collection_font = Gosu::Image.new("./img/fish_collection_font.png")
    @diff_font = Gosu::Image.new("./img/difficulty_font.png") 
    @diff_font_easy = Gosu::Image.new("./img/difficulty_font_easy.png") 
    @diff_font_hard = Gosu::Image.new("./img/difficulty_font_hard.png") 
    @info_board = Gosu::Image.new("./img/info_board.png")
    @double_points_font = Gosu::Image.new("./img/double_points_font.png")
    @small_fish_point_font = Gosu::Image.new("./img/small_fish_point_font.png")
    @medium_fish_point_font = Gosu::Image.new("./img/medium_fish_point_font.png")
    @shark_point_font = Gosu::Image.new("./img/shark_point_font.png")
    @gold_fish_point_font = Gosu::Image.new("./img/gold_fish_point_font.png")
    @jelly_fish_point_font = Gosu::Image.new("./img/jelly_fish_point_font.png")

    @score = 0
    @msg_x = 300
    @msg_y = 500
    @input_name = ""

    @menu = true
    @playing, @game_over, @select, @scoreboard_menu, @scoreboard_end, @fish_collection = false

    @rotation_angle = 0
    @rotation_speed = 3
    @hook_x = (@window.width - @hook.width) / 2
    @hook_y = 15
    @hook_speed_x = 0
    @hook_speed_y = 0
    @launching = false
    @hook_back = false
    @hook_speed = 6
    @initial_hook_x = @hook_x
    @initial_hook_y = @hook_y
    @hook_trail = []
    @caught_fish = nil
    @reeling = false

    @difficulty = 0
    @cat_selected = false

    small_fish = Fish.new(@small_fish, rand(0..(@window.width - @small_fish.width)), rand((150 + @small_fish.height)..(@window.height - @small_fish.height)), -2, 0, 0.02, 2, 0..(@window.width))
    medium_fish = Fish.new(@medium_fish, rand(0..(@window.width - @medium_fish.width)), rand((150 + @medium_fish.height)..(@window.height - @medium_fish.height)), 3, 0, 0.04, 2, 0..(@window.width))
    shark = Fish.new(@shark, rand(0..(@window.width - @shark.width)), rand((150 + @shark.height)..(@window.height - @shark.height)), 4, 0, 0.04, 2, 0..(@window.width))
    gold_fish = Fish.new(@gold_fish, rand(0..(@window.width - @gold_fish.width)), rand((150 + @gold_fish.height)..(@window.height - @gold_fish.height)), -4, 0, 0.06, 1, 0..(@window.width))
    jelly_fish = Fish.new(@jelly_fish, rand(0..(@window.width - @jelly_fish.width)), rand((150 + @jelly_fish.height)..(@window.height - @jelly_fish.height)), 1, 0, 0.05, 2, 0..(@window.width))    

    @fish_pool = [small_fish, medium_fish, shark, gold_fish, jelly_fish]
    @fishes = []
    @max_fish_count = 10
  end

  def update
    radians = 0

    if @select
      if @difficulty == 0
        set_difficulty(1)
      end
    end

    if @playing

      @timer -= 1.0 / 60 
      if @timer <= 0
        @playing = false
        @game_over = true
      end

      if @launching
        # Store the hook's previous position in the trail
        @hook_trail << [@hook_x, @hook_y]
      end
    
      if !@launching
        rotate_hook  # Update the hook's angle
      end
      
      if @hook_x != @initial_hook_x || @hook_y != @initial_hook_y
        @hook_trail << [@hook_x, @hook_y]
      end

      if @difficulty == 2
        @hook_x += @hook_speed_x
        @hook_y += @hook_speed_y
      elsif @difficulty == 1
        @hook_x += @hook_speed_x * 1.5
        @hook_y += @hook_speed_y * 1.5
      end

      if @hook_x < 0 || @hook_x > @window.width || @hook_y > @window.height
        radians = (@rotation_angle + 90) * Math::PI / 180
        # Invert the direction to retract
        @hook_speed_x = -@hook_speed_x
        @hook_speed_y = -@hook_speed_y
        @hook_back = true
      end

      if @hook_speed_x < 0 || @hook_speed_y < 0 
        @hook_trail.clear
      end

      if @hook_x == @launch_start_x or @hook_y == @launch_start_y or @hook_y <= @initial_hook_y
        @hook_x = @initial_hook_x
        @hook_y = @initial_hook_y
        @hook_speed_x = 0
        @hook_speed_y = 0
        @launching = false
        @hook_trail.clear
        @reeling = false
        @hook_back = false
      else
        @hook_trail << [@hook_x, @hook_y]
      end

      if @reeling
        if @hook_x == @initial_hook_x && @hook_y == @initial_hook_y
          if @caught_fish
            @caught_fish.speed_x = 0
            @caught_fish.speed_y = 0
            @caught_fish.y_vel = 0
            @caught_fish.x = @hook_x
            @caught_fish.y = @hook_y
          end
        elsif @caught_fish
          @caught_fish.speed_x = 0
          @caught_fish.speed_y = 0
          @caught_fish.y_vel = 0
          @caught_fish.x = @hook_x
          @caught_fish.y = @hook_y
        end
      end

      spawn_fish
    end
  
    @fishes.each do |fish|
      fish_swim(fish)
      if hook_collision?(fish) && @hook_trail.empty?

        if @difficulty == 2
          @timer += 1
        elsif @difficulty == 1
          @timer += 1.5
        end

        @fishes.delete(fish)
        if fish.image == @small_fish
          if @difficulty == 2
            @score += 20
          elsif @difficulty == 1
            @score += 10
          end
        elsif fish.image == @medium_fish
          if @difficulty == 2
            @score += 40
          elsif @difficulty == 1
            @score += 20
          end
        elsif fish.image == @shark
          if @difficulty == 2
            @score += 100
          elsif @difficulty == 1
            @score += 50
          end
        elsif fish.image == @jelly_fish
          if @difficulty == 2
            if @score >= 20
              @score -= 20 
            end
          elsif @difficulty == 1
            if @score >= 10
              @score -= 10 
            end
          end
        elsif fish.image == @gold_fish
          if @difficulty == 2
            @score += 200
          end
        end
      end
    end
  end

  def set_difficulty(diff)
    if diff == 2
      @difficulty = 2
      @rotation_speed = 5
      @fish_pool.each do |fish|
        if fish.speed_x > 0
          fish.speed_x += 1
        else
          fish.speed_x -= 1
        end
        if fish.image == @gold_fish
          fish.fish_spawn_chance = 1
        end
      end
    elsif diff == 1 
      @difficulty = 1
      @rotation_speed = 3
      @fish_pool.each do |fish|
        if fish.image == @gold_fish
          fish.fish_spawn_chance = 0
        end
      end
    elsif diff == 0
      @difficulty = 0
      @rotation_speed = 3
    end
  end

  def spawn_fish
    if @fishes.length < @max_fish_count
      total_chance = @fish_pool.map { |fish| fish.fish_spawn_chance }.sum
      random_chance = rand(total_chance)
      cumulative_chance = 0
  
      @fish_pool.each do |fish|
        cumulative_chance += fish.fish_spawn_chance
        if random_chance < cumulative_chance
          # Randomize the initial position within the spawn range
          initial_x = rand(fish.spawn_range)
          if fish.image == @gold_fish
            initial_y = rand(350..@window.height - fish.image.height)
          else
            initial_y = rand(150..@window.height - fish.image.height)
          end
          new_fish = Fish.new(fish.image, initial_x, initial_y, fish.speed_x, fish.speed_y, fish.y_vel, fish.fish_spawn_chance, fish.spawn_range)
          @fishes.push(new_fish)
          break
        end
      end
    end
  end

  def fish_swim(fish)
    fish.x += fish.speed_x
    fish.y += fish.speed_y

    if fish.x < 0
      fish.x = self.width
    elsif fish.x > self.width
      fish.x = 0
    end

    fish.speed_y += fish.y_vel
    if (fish.speed_y > 1) || (fish.speed_y < -1)
      fish.y_vel *= -1
    end
  end

  def needs_cursor?; true; end

  def draw
    if @menu
      draw_menu
      @difficulty = 0
    elsif @scoreboard_menu || @scoreboard_end
      draw_scoreboard
    elsif @fish_collection
      draw_fish_collection
    elsif @select
      draw_select
    elsif @playing
      draw_hook_trail
      draw_game
    elsif @game_over
      draw_game_over
    end
  end

  def rotate_hook
    if @rotation_angle >= 75 || @rotation_angle <= -75
      @rotation_speed *= -1
    end
    @rotation_angle += @rotation_speed
  end

  def hook_collision?(fish)
    return false if @reeling  # Do not process collisions while reeling

    fish_right = fish.x + fish.image.width
    fish_bottom = fish.y + fish.image.height
    hook_right = @hook_x + @hook.width
    hook_bottom = @hook_y + @hook.height

    if (
      @hook_x < fish_right &&
      hook_right > fish.x &&
      @hook_y < fish_bottom &&
      hook_bottom > fish.y &&
      !@hook_back
    )

      if fish.image == @small_fish
        @hook_speed_x = -@hook_speed_x * 1.1
        @hook_speed_y = -@hook_speed_y * 1.1
        @reeling = true
        @hook_back = true
        @caught_fish = fish  # Store the caught fish
        return true
      elsif fish.image == @medium_fish
        @hook_speed_x = -@hook_speed_x
        @hook_speed_y = -@hook_speed_y
        @hook_back = true
        @reeling = true
        @caught_fish = fish  # Store the caught fish
        return true
      elsif fish.image == @shark
        @hook_speed_x = -@hook_speed_x / 2
        @hook_speed_y = -@hook_speed_y / 2
        @hook_back = true
        @reeling = true
        @caught_fish = fish  # Store the caught fish
        return true
      elsif fish.image == @jelly_fish
        @hook_speed_x = -@hook_speed_x * 1.25
        @hook_speed_y = -@hook_speed_y * 1.25
        @hook_back = true
        @reeling = true
        @caught_fish = fish  # Store the caught fish
        return true
      elsif fish.image == @gold_fish
        @hook_speed_x = -@hook_speed_x * 1.25
        @hook_speed_y = -@hook_speed_y * 1.25
        @hook_back = true
        @reeling = true
        @caught_fish = fish  # Store the caught fish
        return true
      end
    end

    false
  end

  def sorting_score (highscore_list)
    score_num = highscore_list.count
    for i in 0..score_num - 1
      highest_score = -1
      current_index = 0
      for j in i..score_num - 1
        if highest_score < highscore_list[j].score
          current_index = j
          highest_score = highscore_list[j].score
        end
      end
      highscore_list[i], highscore_list[current_index] = highscore_list[current_index], highscore_list[i]
    end
    return highscore_list
  end

  def button_down(id)
    case id
    when Gosu::KbSpace
      if @playing
        if !@launching
          radians = (@rotation_angle + 90) * Math::PI / 180  # Add 90 degrees to the angle
          @hook_speed_x = @hook_speed * Math.cos(radians)
          @hook_speed_y = @hook_speed * Math.sin(radians)
          @launching = true
          # Store the launch position and direction
          @launch_start_x = @hook_x
          @launch_start_y = @hook_y
          @launch_speed_x = @hook_speed_x
          @launch_speed_y = @hook_speed_y
        end
      end
    when Gosu::KB_ESCAPE
      if @fish_collection
        @fish_collection = false
        @menu = true
      elsif @select
        @difficulty = 0
        @cat_selected = false
        @select = false
        @menu = true
      elsif @scoreboard_menu
        @scoreboard_menu = false
        @menu = true
      elsif @scoreboard_end
        @scoreboard_end = false
        @game_over = true
      elsif @game_over && @input_name != ""
        if @difficulty == 1
          file_name = "highscore_easy.txt"
        elsif @difficulty == 2
          file_name = "highscore_hard.txt"
        end
        file = File.new(file_name, "r")
        #Start working with file if file exists
        if (file != nil)
          play_num = file.gets
          if play_num != nil
            play_num = play_num.chomp.to_i
          else
            play_num = 0
          end
          highscore_list = Array.new()
          i = 0
          
          #Get records in file
          while i < play_num
            name = file.gets.chomp
            score = file.gets.chomp.to_i
            highscore_list << HighScore.new(name, score)
            i += 1
          end
          
          #Add current records to record list
          if play_num < 5
            play_num += 1
          end
          highscore_list << HighScore.new(@input_name, @score)
          file.close
          
          #Start re-write the record file
          file = File.new(file_name, "w")
          file.puts play_num
          
          #Sort to find out the top 5
          highscore_list = sorting_score(highscore_list)
          index = 0
          
          #Write each record from list to file
          while index < 5 && index < play_num
            file.puts highscore_list[index].name
            file.puts highscore_list[index].score.to_s
            index += 1
          end
          file.close
          reset_game
        end
        @game_over = false
        @menu = true
      end
    when Gosu::MsLeft
      if @menu
        if mouse_x.between?(470, 705) && mouse_y.between?(315, 380)
          @select = true
          @menu = false
        elsif mouse_x.between?(10, 80) && mouse_y.between?(10, 80)
          @fish_collection = true
          @menu = false
        elsif mouse_x.between?(470, 705) && mouse_y.between?(410, 475)
          @scoreboard_menu = true
          @menu = false 
        elsif mouse_x.between?(470, 705) && mouse_y.between?(505, 570)
          close
        end
      elsif @fish_collection
        if (mouse_x.between?(720, 790) && mouse_y.between?(520, 590))
          @fish_collection = false
          @menu = true
        end
      elsif @scoreboard_menu || @scoreboard_end
        if (mouse_x.between?(720, 790) && mouse_y.between?(520, 590)) && @scoreboard_menu
          @scoreboard_menu = false
          @menu = true
        elsif (mouse_x.between?(720, 790) && mouse_y.between?(520, 590)) && @scoreboard_end
          @scoreboard_end = false
          @game_over = true
        end
      elsif @select
        if (mouse_x.between?(720, 790) && mouse_y.between?(10, 80))
          @cat_selected = false
          @select = false
          @menu = true
        elsif (mouse_x.between?(70, 166) && mouse_y.between?(130, 200))
          @cat_selected = true
          set_difficulty(2)
        elsif (mouse_x.between?(605, 695) && mouse_y.between?(125, 195))
          @cat_selected = true
          set_difficulty(1)
        elsif (mouse_x.between?(250, 495) && mouse_y.between?(500, 570) && @cat_selected)
          @cat_selected = false
          @playing = true
          @select = false
        end
      elsif @game_over
        if (mouse_x.between?(280, 520) && mouse_y.between?(302, 360))
          if @input_name != ""
            if @difficulty == 1
              file_name = "highscore_easy.txt"
            elsif @difficulty == 2
              file_name = "highscore_hard.txt"
            end
            file = File.new(file_name, "r")
            #Start working with file if file exists
            if (file != nil)
              play_num = file.gets
              if play_num != nil
                play_num = play_num.chomp.to_i
              else
                play_num = 0
              end
              highscore_list = Array.new()
              i = 0
    
              #Get records in file
              while i < play_num
                name = file.gets.chomp
                score = file.gets.chomp.to_i
                highscore_list << HighScore.new(name, score)
                i += 1
              end
    
              #Add current records to record list
              if play_num < 5
                play_num += 1
              end
              highscore_list << HighScore.new(@input_name, @score)
              file.close
    
              #Start re-write the record file
              file = File.new(file_name, "w")
              file.puts play_num
    
              #Sort to find out the top 5
              highscore_list = sorting_score(highscore_list)
              index = 0
    
              #Write each record from list to file
              while index < 5 && index < play_num
                file.puts highscore_list[index].name
                file.puts highscore_list[index].score.to_s
                index += 1
              end
              file.close
              reset_game
            end
            @select = true
            @game_over = false
          end
        elsif (mouse_x.between?(280, 520) && mouse_y.between?(405, 470))
          @scoreboard_end = true
          @game_over = false
        elsif (mouse_x.between?(280, 520) && mouse_y.between?(505, 570))
          close
        end
      end
    end

    if @game_over
      # ASCII values
      if id >= 4 && id <= 29 && @input_name.length < 10
        #Letters add
        next_char = id + 61
        @input_name += next_char.chr
      elsif id >= 30 && id <= 39 && @input_name.length < 10
        #Numbers add
        if id != 39
          @input_name += (id - 29).to_s
        else
          @input_name += "0"
        end
      elsif id == 42
        #Delete in KB Enumeration has an ID of 42
        @input_name = @input_name.chop
      end
    end
  end

  def reset_game
    @rotation_angle = 0
    @rotation_speed = 3
    @hook_x = (@window.width - @hook.width) / 2
    @hook_y = 15
    @hook_speed_x = 0
    @hook_speed_y = 0
    @launching = false
    @hook_back = false
    @initial_hook_x = @hook_x
    @initial_hook_y = @hook_y
    @hook_trail = []
    @caught_fish = nil
    @reeling = false
    @difficulty = 0
    @cat_selected = false
    @input_name = ""
    @timer = 30
    @score = 0
    @difficulty = 0
    @fishes = []
  end
end

FishingGame.new.show