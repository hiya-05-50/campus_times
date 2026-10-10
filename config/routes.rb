Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Dashboards
  get "dashboard", to: "dashboards#show", as: :dashboard
  get "admin/overview", to: "dashboards#admin_overview", as: :admin_dashboard_overview

  # Attendance & Class Sessions
  resources :class_sessions, only: %i[index show new create] do
    member do
      patch :close
    end
  end

  resources :attendances, only: %i[index create]
  get "attendances/mark", to: "attendances#mark", as: :mark_attendance
  get "class_sessions/:token/attend", to: "attendances#mark", as: :attend_session

  root "dashboards#show"
end
