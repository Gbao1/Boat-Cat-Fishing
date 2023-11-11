def draw_menu
  @title.draw((@window.width - @title.width) / 2, 30, ZOrder::DISPLAY)
  @menu_bg.draw(0, 0, ZOrder::BACKGROUND)
  @fish_collection_button.draw(10, 10, ZOrder::DISPLAY)
  # x1: 470, y1: 315; x2: 705, y2: 380
  @play_button.draw((@window.width - @play_button.width) / 1.2, (@window.height - @play_button.height) / 1.7, ZOrder::DISPLAY)
  # x1: 470, y1: 315; x2: 705, y2: 380
  @score_button.draw((@window.width - @score_button.width) / 1.2, (@window.height - @score_button.height) / 1.3, ZOrder::DISPLAY)
  # x1: 470, y1: 315; x2: 705, y2: 380
  @exit_button.draw((@window.width - @exit_button.width) / 1.2, (@window.height - @exit_button.height) - 30, ZOrder::DISPLAY)
end

def draw_fish_collection
  @fish_collection_font.draw((@window.width - @fish_collection_font.width) / 2, 30, ZOrder::DISPLAY)
  @fish_shelf_bg.draw(0, (@window.height - @fish_shelf_bg.height), ZOrder::BACKGROUND)
  @return_button.draw((@window.width - @return_button.width) - 10, (@window.height - @return_button.height) - 10, ZOrder::DISPLAY)
  for i in 0..(@fish_pool.length - 1)
    @fish_bowl.draw(35 + i * 150, 105, ZOrder::DISPLAY)
  end
  @small_fish.draw(35 + (@fish_bowl.width / 4), 105 + (@fish_bowl.height / 4), ZOrder::ENTITIES)
  @small_fish_point_font.draw(35, 220, ZOrder::ENTITIES)

  @medium_fish.draw(185 + (@fish_bowl.width / 4), 105 + (@fish_bowl.height / 2.6), ZOrder::ENTITIES)
  @medium_fish_point_font.draw(185, 220, ZOrder::ENTITIES)

  @shark.draw(335 + (@fish_bowl.width / 7), 105 + (@fish_bowl.height / 4), ZOrder::ENTITIES)
  @shark_point_font.draw(335, 220, ZOrder::ENTITIES)

  @gold_fish.draw(485 + (@fish_bowl.width / 2.6), 105 + (@fish_bowl.height / 2.6), ZOrder::ENTITIES)
  @gold_fish_point_font.draw(485, 220, ZOrder::ENTITIES)

  @jelly_fish.draw(635 + (@fish_bowl.width / 3), 105 + (@fish_bowl.height / 5), ZOrder::ENTITIES)
  @jelly_fish_point_font.draw(635, 220, ZOrder::ENTITIES)
end

def draw_select
  @select_bg.draw(0, 0, ZOrder::BACKGROUND)
  @return_button.draw((@window.width - @return_button.width) - 10, 10, ZOrder::DISPLAY)
  
  if mouse_x.between?(70, 166) && mouse_y.between?(130, 200)
    scale_x_weak = 1.25
    scale_y_weak = 1.25
  else
    scale_x_weak = 1
    scale_y_weak = 1
  end
  if (mouse_x.between?(605, 695) && mouse_y.between?(125, 195))
    scale_x_strong = 1.25
    scale_y_strong = 1.25
  else
    scale_x_strong = 1
    scale_y_strong = 1
  end

  if @difficulty == 1 && @cat_selected
    @strong_cat.draw_rot(615, 515, ZOrder::ENTITIES, 0, 0.5, 0.5)
    @start_button.draw((@window.width - @start_button.width) / 2.2, (@window.height - @start_button.height) - 30, ZOrder::DISPLAY)
    @strong_cat_name.draw((@window.width - @strong_cat_name.width) / 2.2, 220, ZOrder::ENTITIES)
    @diff_font_easy.draw((@window.width - @diff_font_easy.width) / 2.205, 310, ZOrder::ENTITIES)
    @info_board.draw((@window.width - @info_board.width) / 2.2, 0, ZOrder::DISPLAY)
    # 220
  else
    @strong_cat.draw_rot(650, 161, ZOrder::ENTITIES, 0, 0.5, 0.5, scale_x_strong, scale_y_strong)
  end

  if @difficulty == 2 && @cat_selected
    @weak_cat.draw_rot(615, 515, ZOrder::ENTITIES, 0, 0.5, 0.5)
    @start_button.draw((@window.width - @start_button.width) / 2.2, (@window.height - @start_button.height) - 30, ZOrder::DISPLAY)
    @weak_cat_name.draw((@window.width - @weak_cat_name.width) / 2.2, 220, ZOrder::ENTITIES)
    @diff_font_hard.draw((@window.width - @diff_font_hard.width) / 2.205, 310, ZOrder::ENTITIES)
    @double_points_font.draw((@window.width - @double_points_font.width) / 2.205, 360, ZOrder::ENTITIES)
    @info_board.draw((@window.width - @info_board.width) / 2.2, 0, ZOrder::DISPLAY)
  else 
    @weak_cat.draw_rot(118, 161, ZOrder::ENTITIES, 0, 0.5, 0.5, scale_x_weak, scale_y_weak)
  end
end

def draw_game
  @play_bg.draw(0, 0, ZOrder::BACKGROUND)
  @info_font.draw_text("Time: #{@timer.to_i}", 10, 10, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::BLACK)
  @info_font.draw_text("Score: #{@score.to_i}", 10, 50, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::BLACK)
  @hook.draw_rot(@hook_x, @hook_y, ZOrder::ENTITIES, @rotation_angle, 0.5, 0, 1.0)
  
  @fishes.each do |fish|
    fish.image.draw(fish.x, fish.y, ZOrder::ENTITIES)
  end
end

def draw_game_over
  @play_bg.draw(0, 0, ZOrder::BACKGROUND)
  @finish_font.draw((@window.width - @finish_font.width) / 2, 40, ZOrder::DISPLAY)

  score_msg = GameMsg::FinshScore + " " + @score.to_s
  name_msg = GameMsg::PlayerName + " " + @input_name
  query_font = Gosu::Font.new(25)

  if @difficulty == 1
    file_name = "highscore_easy.txt"
  else
    file_name = "highscore_hard.txt"
  end
  file = File.new(file_name)
  if file == nil
    @file_error = true
  end

  # Only save scores if the file exists, otherwise draw an error message
  if !@file_error
    query_font.draw_text(name_msg, 100, 150, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::BLACK)
    query_font.draw_text(score_msg, 100, 200, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::BLACK)
    @newgame_button.draw((@window.width - @newgame_button.width) / 2, 300, ZOrder::DISPLAY)
    @score_button.draw((@window.width - @score_button.width) / 2, 400, ZOrder::DISPLAY)
    @exit_button.draw((@window.width - @exit_button.width) / 2, 500, ZOrder::DISPLAY)
  else
    query_font.draw_text(Error::NoFile, @msg_x, @msg_y, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::BLACK)
  end
end

def draw_hook_trail
  return if @hook_trail.empty?

  # Set the line color to black
  Gosu.draw_line(
    @initial_hook_x,
    @initial_hook_y,
    Gosu::Color::BLACK,
    @hook_x,
    @hook_y,
    Gosu::Color::BLACK,
    ZOrder::HOOK
  )

  (1...@hook_trail.length).each do |i|
    x1, y1 = @hook_trail[i - 1]
    x2, y2 = @hook_trail[i]
    Gosu.draw_line(
      x1, y1,
      Gosu::Color::BLACK,
      x2, y2,
      Gosu::Color::BLACK,
      ZOrder::HOOK
    )
  end
end

def draw_scoreboard
  @score_font.draw((@window.width - @score_font.width) / 2, 40, ZOrder::DISPLAY)
  @return_button.draw((@window.width - @return_button.width) - 10, (@window.height - @return_button.height) - 10, ZOrder::DISPLAY)
  header_font = Gosu::Font.new(40)
  record_font = Gosu::Font.new(25)
  
  if @difficulty == 0
    score_name = ["Easy", "Hard"]
    files = ["highscore_easy.txt", "highscore_hard.txt"]
    for i in 0..(files.length - 1)
      file_name = files[i]
      header_font.draw_text(score_name[i], 150 + (i * 400), 125, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::WHITE)
      header_font.draw_text("Name", 50 + (i * 400), 200, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::WHITE)
      header_font.draw_text("Score", 250 + (i * 400), 200, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::WHITE)
      
      file = File.new(file_name, "r")

      if file != nil
        play_num = file.gets
        if play_num != nil
          play_num = play_num.chomp.to_i
        else
          play_num = 0
        end
        index = 0

        # Getting records from file, each at a time
        while index < play_num and index < 5
          line = file.gets
          if line
            name = line.chomp
            record_font.draw_text(name, 50 + (i * 400), 275 + index * 50, ZOrder::ENTITIES, 1.0, 1.0, Gosu::Color::WHITE)
          end

          line = file.gets
          if line
            score = line.chomp.to_i
            record_font.draw_text(score.to_s, 250 + (i * 400), 275 + index * 50, ZOrder::ENTITIES, 1.0, 1.0, Gosu::Color::WHITE)
          end
          index += 1
        end
        file.close
      else
        record_font.draw_text(Error::NoFile, 150, 150 + index * 50, ZOrder::ENTITIES, 1.0, 1.0, Gosu::Color::WHITE)
      end
    end
    record_font.draw_text(GameMsg::Return, @msg_x, @msg_y + 50, ZOrder::ENTITIES, 1.0, 1.0, Gosu::Color::WHITE)

  elsif @difficulty == 1
    file_name = "highscore_easy.txt"
    header_font.draw_text("Easy", 350, 125, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::WHITE)
    header_font.draw_text("Name", 250, 200, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::WHITE)
    header_font.draw_text("Score", 450, 200, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::WHITE)
    
  elsif @difficulty == 2
    file_name = "highscore_hard.txt"
    header_font.draw_text("Hard", 350, 125, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::WHITE)
    header_font.draw_text("Name", 250, 200, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::WHITE)
    header_font.draw_text("Score", 450, 200, ZOrder::DISPLAY, 1.0, 1.0, Gosu::Color::WHITE)
  end
    
  if @difficulty != 0
    file = File.new(file_name, "r")

    if file != nil
      play_num = file.gets
      if play_num != nil
        play_num = play_num.chomp.to_i
      else
        play_num = 0
      end
      index = 0

      # Getting records from file, each at a time
      while index < play_num and index < 5
        line = file.gets
        if line
          name = line.chomp
          record_font.draw_text(name, 250, 275 + index * 50, ZOrder::ENTITIES, 1.0, 1.0, Gosu::Color::WHITE)
        end

        line = file.gets
        if line
          score = line.chomp.to_i
          record_font.draw_text(score.to_s, 450, 275 + index * 50, ZOrder::ENTITIES, 1.0, 1.0, Gosu::Color::WHITE)
        end

        index += 1
      end
      file.close
    else
      # Message if can't find file (Defensive)
      record_font.draw_text(Error::NoFile, 150, 150 + index * 50, ZOrder::ENTITIES, 1.0, 1.0, Gosu::Color::WHITE)
    end
    record_font.draw_text(GameMsg::Return, @msg_x, @msg_y + 50, ZOrder::ENTITIES, 1.0, 1.0, Gosu::Color::WHITE)
  end
end