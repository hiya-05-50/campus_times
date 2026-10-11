require "net/http"
require "json"

module Ai
  class ExternalProvider
    ENDPOINT = URI("https://api.openai.com/v1/chat/completions")

    def initialize(api_key: ENV["CAMPUS_AI_API_KEY"])
      @api_key = api_key
    end

    def answer(question:, user:, history: [])
      raise "Campus AI external provider is not configured" if @api_key.blank?

      # Only the current question and short conversation are sent. Campus records
      # must be explicitly authorized and supplied by a future data adapter.
      messages = [{ role: "system", content: "You are a helpful campus assistant. Do not claim access to records that were not provided." }]
      messages.concat(Array(history).last(Ai::AssistantService::MAX_HISTORY))
      messages << { role: "user", content: question }
      request = Net::HTTP::Post.new(ENDPOINT)
      request["Authorization"] = "Bearer #{@api_key}"
      request["Content-Type"] = "application/json"
      request.body = { model: ENV.fetch("CAMPUS_AI_MODEL", "gpt-4o-mini"), messages: messages }.to_json
      result = Net::HTTP.start(ENDPOINT.host, ENDPOINT.port, use_ssl: true, read_timeout: 15, open_timeout: 5) { |http| http.request(request) }
      raise "Campus AI provider returned HTTP #{result.code}" unless result.is_a?(Net::HTTPSuccess)
      JSON.parse(result.body).dig("choices", 0, "message", "content").presence || "I couldn’t create an answer. Please try again."
    end
  end
end
