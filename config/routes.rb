Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout
  get "dashboard", to: "dashboards#show", as: :dashboard
  get "admin/overview", to: "dashboards#admin_overview", as: :admin_dashboard_overview

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

  resources :companies
  resources :placement_drives, path: "placements" do
    resources :applications, controller: "placement_applications", only: %i[index create]
  end
  resources :placement_applications, only: %i[index show update destroy] do
    member do
      patch :withdraw
      delete :withdraw
    end
  end

  root "dashboards#show"
end
