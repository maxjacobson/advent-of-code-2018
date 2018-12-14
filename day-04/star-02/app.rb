require "irb"
require "time"

input = File.read("./input.txt")

class Event
  PATTERN = /\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2})\] (.+)/
  WakesUp = Class.new
  FallsAsleep = Class.new
  BeginsShift = Struct.new(:guard_id)

  attr_reader :line

  def initialize(line)
    @line = line
  end

  def <=>(other)
    timestamp <=> other.timestamp
  end

  def kind
    @kind ||= begin
                case match_data[2]
                when "wakes up" then WakesUp.new
                when "falls asleep" then FallsAsleep.new
                when /Guard #(\d+) begins shift/
                  BeginsShift.new($1.to_i)
                else
                  raise "what?"
                end
              end
  end

  def minutes_since(previous)
    previous.timestamp.min...timestamp.min
  end

  protected

  def timestamp
    @timestamp ||= Time.parse(match_data[1])
  end

  private

  def match_data
    @match_data ||= @line.match(PATTERN)
  end
end

class SleepyTime
  attr_accessor :current_guard, :previous_event

  def initialize
    @data = {}
  end

  def handle(event)
    case event.kind
    when Event::BeginsShift
      self.current_guard = event.kind.guard_id
    when Event::FallsAsleep
      # This space intentionally left blank
    when Event::WakesUp
      event.minutes_since(previous_event).each do |minute|
        data[current_guard] ||= {}
        data[current_guard][minute] ||= 0
        data[current_guard][minute] += 1
      end
    else
      raise "what?"
    end

    self.previous_event = event
    self
  end

  def sleepiest_pair
    possibility = possibilities.max_by(&:frequency)

    [possibility.guard, possibility.minute]
  end

  private

  attr_reader :data

  def sum(times)
    times.values.inject(&:+)
  end

  Possibility = Struct.new(:guard, :minute, :frequency)

  def possibilities
    Enumerator.new do |yielder|
      data.each do |guard, breakdown|
        breakdown.each do |minute, frequency|
          yielder.yield Possibility.new(guard, minute, frequency)
        end
      end
    end
  end
end

events = input.lines.map { |line| Event.new(line.chomp) }.sort

sleepy_time = events.inject(SleepyTime.new) do |data, event|
  data.handle(event)
end

guard_id, minute = sleepy_time.sleepiest_pair

puts "Result: #{guard_id * minute}"
