class MatchGenerator
  REPEAT_PENALTY_WEIGHT = 10.0

  def initialize(event, round_number:)
    @event = event
    @round_number = round_number
  end

  def call
    available = @event.event_players
      .where(sitting_out: false)
      .includes(player: :grade_level)

    courts = @event.courts.to_a

    recent_partner_pairs = load_recent_partner_pairs

    playing, sitters = split_sitters(available.to_a, courts.count)

    groups = group_players(playing, courts.count)

    court_assignments = assign_courts(groups, courts)

    ActiveRecord::Base.transaction do
      @event.rounds.find_by(number: @round_number)&.destroy

      round = Round.create!(event: @event, number: @round_number)

      court_assignments.each do |(group, court)|
        next if group.size < 4

        team_a_players, team_b_players = balance_teams(group, recent_partner_pairs)
        match = Match.create!(round: round, court: court)
        team_a_players.each { |ep| MatchPlayer.create!(match: match, player: ep.player, team: :team_a) }
        team_b_players.each { |ep| MatchPlayer.create!(match: match, player: ep.player, team: :team_b) }
      end

      round
    end
  end

  private

  def load_recent_partner_pairs
    recent_rounds = @event.rounds.where(number: (@round_number - 2)..(@round_number - 1))
    pairs = Set.new

    recent_rounds.each do |round|
      round.matches.each do |match|
        by_team = match.match_players.group_by(&:team)
        by_team.each_value do |mps|
          player_ids = mps.map(&:player_id)
          player_ids.combination(2).each do |pair|
            pairs.add(pair.sort)
          end
        end
      end
    end

    pairs
  end

  def split_sitters(available, court_count)
    playing_capacity = court_count * 4

    if available.count <= playing_capacity
      return [ available, [] ]
    end

    sit_count = available.count - playing_capacity

    # Players who played last round (did NOT sit out) get higher sit-out priority
    last_round = @event.rounds.order(number: :desc).first

    sorted = available.shuffle.sort_by do |ep|
      if last_round.nil?
        0
      elsif last_round.match_players.exists?(player_id: ep.player_id)
        1  # played last round → higher sit-out priority
      else
        0  # sat out last round → lower sit-out priority (should play)
      end
    end

    sitters = sorted.last(sit_count)
    playing = sorted.first(available.count - sit_count)

    [ playing, sitters ]
  end

  def group_players(playing, court_count)
    return [] if court_count == 0

    if @event.mixed?
      group_mixed(playing, court_count)
    else
      group_same_sex(playing, court_count)
    end
  end

  def group_mixed(playing, court_count)
    males   = playing.select { |ep| ep.player.male? }.sort_by { |ep| -effective_rank(ep) }
    females = playing.select { |ep| ep.player.female? }.sort_by { |ep| -effective_rank(ep) }

    groups = Array.new(court_count) { [] }

    court_count.times do |i|
      groups[i] << males[i * 2]       if males[i * 2]
      groups[i] << females[i * 2]     if females[i * 2]
      groups[i] << males[i * 2 + 1]   if males[i * 2 + 1]
      groups[i] << females[i * 2 + 1] if females[i * 2 + 1]
    end

    # Distribute any overflow players (gender imbalance) into incomplete groups
    overflow = (males[court_count * 2..] + females[court_count * 2..])
                 .sort_by { |ep| -effective_rank(ep) }

    overflow.each do |ep|
      target = groups.min_by(&:size)
      break if target.size >= 4
      target << ep
    end

    groups.reject(&:empty?)
  end

  def group_same_sex(playing, court_count)
    sorted = playing.sort_by { |ep| -effective_rank(ep) }
    sorted.each_slice(4).first(court_count).to_a
  end

  def balance_teams(group, recent_partner_pairs)
    return [ group[0..1], group[2..3] || [] ] if group.size < 4

    a, b, c, d = group

    splits = [
      [ [ a, b ], [ c, d ] ],
      [ [ a, c ], [ b, d ] ],
      [ [ a, d ], [ b, c ] ]
    ]

    splits.min_by { |split| score_split(split[0], split[1], recent_partner_pairs) }
  end

  def score_split(team1, team2, recent_partner_pairs)
    rank_diff = (avg_rank(team1) - avg_rank(team2)).abs
    repeat = count_repeat_pairs(team1, recent_partner_pairs) +
             count_repeat_pairs(team2, recent_partner_pairs)
    rank_diff + repeat * REPEAT_PENALTY_WEIGHT
  end

  def avg_rank(players)
    return 0.0 if players.empty?
    players.sum { |ep| effective_rank(ep) } / players.size.to_f
  end

  def count_repeat_pairs(players, recent_partner_pairs)
    player_ids = players.map(&:player_id)
    player_ids.combination(2).count { |pair| recent_partner_pairs.include?(pair.sort) }
  end

  def assign_courts(groups, courts)
    # Sort courts: non-hard first, hard last
    sorted_courts = courts.sort_by { |c| c.surface == "hard" ? 1 : 0 }

    # Sort groups by number of avoids_hard_courts players desc
    sorted_groups = groups.sort_by { |g| -g.count { |ep| ep.player.avoids_hard_courts? } }

    sorted_groups.zip(sorted_courts).reject { |group, court| court.nil? || group.nil? }
  end

  def effective_rank(event_player)
    player = event_player.player
    player.grade_level&.rank.to_f + player.grade_offset.to_f
  end
end
