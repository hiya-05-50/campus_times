Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get "ai-assistant", to: "ai_assistant#show", as: :ai_assistant
  post "ai-assistant", to: "ai_assistant#create"
  delete "ai-assistant/reset", to: "ai_assistant#reset", as: :reset_ai_assistant

  resources :courses do
    resources :enrollments, only: %i[create destroy]
    resources :assignments, only: %i[index new create show edit update] do
      resources :submissions, only: %i[create update show]
    end
  end

  resources :class_sessions, only: %i[index show new create] do
    member { patch :close }
  end
  resources :attendances, only: %i[index create]
  get "attendances/mark", to: "attendances#mark", as: :mark_attendance
  get "class_sessions/:token/attend", to: "attendances#mark", as: :attend_session

  root "attendances#index"
end
