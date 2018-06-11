# frozen_string_literal: true

require_relative("./../../core/watson-ruby/tone_analyzer_v3.rb")
require("json")
require("minitest/autorun")

# Integration tests for the Tone Analyzer V3 Service
class ToneAnalyzerV3Test < Minitest::Test
  Minitest::Test.parallelize_me!
  def test_tone
    tone_text = File.read(Dir.getwd + "/resources/personality.txt")
    service = ToneAnalyzerV3.new(
      version: "2017-09-21",
      username: ENV["TONE_ANALYZER_USERNAME"],
      password: ENV["TONE_ANALYZER_PASSWORD"]
    )
    service_response = service.tone(
      tone_input: tone_text,
      content_type: "text/plain"
    )
    assert((200..299).cover?(service_response.status))
  end

  def test_tone_with_args
    tone_text = File.read(Dir.getwd + "/resources/personality.txt")
    service = ToneAnalyzerV3.new(
      version: "2017-09-21",
      username: ENV["TONE_ANALYZER_USERNAME"],
      password: ENV["TONE_ANALYZER_PASSWORD"]
    )
    service_response = service.tone(
      tone_input: tone_text,
      content_type: "text/plain",
      sentences: false
    )
    assert((200..299).cover?(service_response.status))
  end

  def test_tone_chat
    service = ToneAnalyzerV3.new(
      version: "2017-09-21",
      username: ENV["TONE_ANALYZER_USERNAME"],
      password: ENV["TONE_ANALYZER_PASSWORD"]
    )
    utterances = [
      {
        "text" => "I am very happy",
        "user" => "glenn"
      }
    ]
    service_response = service.tone_chat(
      utterances: utterances
    )
    assert((200..299).cover?(service_response.status))
  end
end
