Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "ai-assistant", to: "ai_assistant#show", as: :ai_assistant
  post "ai-assistant", to: "ai_assistant#create"
  delete "ai-assistant/reset", to: "ai_assistant#reset", as: :reset_ai_assistant

  resources :courses do
    resources :enrollments, only: %i[create destroy]
  end

  resources :class_sessions, only: %i[index show new create] do
    member do
      patch :close
    end
  end

  resources :attendances, only: %i[index create]
  get "attendances/mark", to: "attendances#mark", as: :mark_attendance
  get "class_sessions/:token/attend", to: "attendances#mark", as: :attend_session

  root "attendances#index"
end
