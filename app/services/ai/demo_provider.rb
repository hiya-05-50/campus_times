module Ai
  class DemoProvider
    SUGGESTIONS = {
      "student" => ["What classes do I have today?", "When are my assignment deadlines?", "How is my attendance?", "Am I eligible for placements?"],
      "faculty" => ["What submissions need grading?", "Which projects need review?", "How is department attendance?", "What should I prioritize today?"],
      "admin" => ["Which students are at attendance risk?", "Give me a campus operations overview.", "What are today’s priorities?", "Show department attendance."]
    }.freeze

    def answer(question:, user:, history: [])
      role = role_for(user)
      normalized = question.downcase
      return "I can help with classes, deadlines, attendance, placements, projects, events, complaints, notifications, grading, and campus priorities. Choose a suggested question to get started." if normalized.match?(/^(hi|hello|hey)\b/)

      "I’m running in demo mode, so I don’t have live campus records yet. I can help you explore #{role} topics such as #{SUGGESTIONS.fetch(role).first(2).join(' or ').downcase}. Connect the campus data services to get account-specific answers."
    end

    def self.suggestions_for(user)
      SUGGESTIONS.fetch(role_for(user), SUGGESTIONS.fetch("student"))
    end

    def self.role_for(user)
      value = user.respond_to?(:role) ? user.role.to_s.downcase : "student"
      %w[student faculty admin].include?(value) ? value : "student"
    end

    private

    def role_for(user)
      self.class.role_for(user)
    end
  end
end
