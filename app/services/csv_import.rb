module CsvImport
  Result = Data.define(:imported, :errors)

  def self.grade_levels(club, file)
    imported = 0
    errors = []

    each_row(file, required: %w[rank name]) do |row, line|
      gl = club.grade_levels.new(
        rank: row["rank"]&.strip&.to_i,
        name: row["name"]&.strip
      )
      if gl.save
        imported += 1
      else
        errors << "Row #{line}: #{gl.errors.full_messages.to_sentence}"
      end
    rescue => e
      errors << "Row #{line}: #{e.message}"
    end

    Result.new(imported:, errors:)
  end

  def self.courts(club, file)
    imported = 0
    errors = []

    each_row(file, required: %w[name surface]) do |row, line|
      court = club.courts.new(
        name: row["name"]&.strip,
        surface: row["surface"]&.strip&.downcase
      )
      if court.save
        imported += 1
      else
        errors << "Row #{line}: #{court.errors.full_messages.to_sentence}"
      end
    rescue => e
      errors << "Row #{line}: #{e.message}"
    end

    Result.new(imported:, errors:)
  end

  def self.players(club, file)
    imported = 0
    errors = []
    grade_level_cache = club.grade_levels.index_by { |g| g.name.downcase }

    each_row(file, required: %w[name gender]) do |row, line|
      grade_level = grade_level_cache[row["grade"]&.strip&.downcase]
      grade_offset = row["grade_offset"]&.strip&.to_f || 0.0
      avoids_hard_courts = %w[true yes 1].include?(row["avoids_hard_courts"]&.strip&.downcase)

      player = club.players.new(
        name: row["name"]&.strip,
        gender: row["gender"]&.strip&.downcase,
        grade_level:,
        grade_offset:,
        avoids_hard_courts:
      )
      if player.save
        imported += 1
      else
        errors << "Row #{line}: #{player.errors.full_messages.to_sentence}"
      end
    rescue => e
      errors << "Row #{line}: #{e.message}"
    end

    Result.new(imported:, errors:)
  end

  private_class_method def self.each_row(file, required:, &block)
    content = file.read.encode("UTF-8", invalid: :replace, undef: :replace)
    content.sub!("\xEF\xBB\xBF", "") # strip UTF-8 BOM

    csv = CSV.parse(content, headers: true, header_converters: ->(h) { h&.strip&.downcase })

    missing = required - csv.headers.compact
    raise ArgumentError, "CSV is missing columns: #{missing.join(', ')}" if missing.any?

    csv.each_with_index do |row, i|
      block.call(row, i + 2) # line 1 = headers, data starts at line 2
    end
  end
end
