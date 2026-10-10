class AiAssistantController < ApplicationController
  before_action :require_signed_in_user

  def show
    @suggestions = Ai::DemoProvider.suggestions_for(current_user)
    @messages = Array(session[:campus_ai_history]).last(Ai::AssistantService::MAX_HISTORY)
  end

  def create
    result = Ai::AssistantService.new(user: current_user, history: session[:campus_ai_history]).call(params[:question])
    session[:campus_ai_history] = result[:history]
    redirect_to "/ai-assistant", status: :see_other
  end

  def reset
    session.delete(:campus_ai_history)
    redirect_to "/ai-assistant", status: :see_other
  end

  private

  def require_signed_in_user
    return if respond_to?(:current_user, true) && current_user

    head :unauthorized
  end
end
