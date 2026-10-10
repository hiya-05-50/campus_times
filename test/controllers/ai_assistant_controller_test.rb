require "test_helper"

class AiAssistantControllerTest < ActionDispatch::IntegrationTest
  test "demo mode renders the assistant in development and test environments" do
    get ai_assistant_path

    assert_response :success
    assert_select "h1", "Campus AI"
  end

  test "asking a question returns to the conversation with a demo response" do
    post ai_assistant_path, params: { question: "What are my deadlines?" }

    assert_response :see_other
    follow_redirect!
    assert_response :success
    assert_select ".ai-message-assistant", text: /demo mode/i
  end

  test "clearing the conversation removes its stored history" do
    post ai_assistant_path, params: { question: "Hello" }
    delete reset_ai_assistant_path

    assert_response :see_other
    assert_nil session[:campus_ai_history]
  end
end
