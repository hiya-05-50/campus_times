module Ai
  class AssistantService
    MAX_HISTORY = 8
    MAX_QUESTION_LENGTH = 1_000

    def initialize(user:, provider: default_provider, history: [])
      @user = user
      @provider = provider
      @history = normalize_history(history)
    end

    def call(question)
      question = question.to_s.strip.first(MAX_QUESTION_LENGTH)
      return response("Ask me a question about your campus work.") if question.blank?

      answer = @provider.answer(question:, user: @user, history: @history)
      response(answer, question)
    rescue StandardError => error
      Rails.logger.error("Campus AI failed: #{error.class}: #{error.message}")
      response("I couldn’t answer that just now. Please try again.", question)
    end

    private

    def response(answer, question = nil)
      { answer: answer, history: (@history + (question ? [{ "role" => "user", "content" => question }, { "role" => "assistant", "content" => answer }] : [])).last(MAX_HISTORY) }
    end

    def normalize_history(history)
      Array(history).filter_map do |item|
        next unless item.is_a?(Hash)
        role = item[:role] || item["role"]
        content = item[:content] || item["content"]
        next unless %w[user assistant].include?(role.to_s) && content.is_a?(String)
        { "role" => role.to_s, "content" => content.first(MAX_QUESTION_LENGTH) }
      end.last(MAX_HISTORY)
    end

    def self.default_provider
      if ENV["CAMPUS_AI_PROVIDER"] == "external" && ENV["CAMPUS_AI_API_KEY"].present?
        ExternalProvider.new
      else
        DemoProvider.new
      end
    end

    def default_provider
      self.class.default_provider
    end
  end
end
