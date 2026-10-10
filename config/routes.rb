Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Placements Module Routes
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

  root "placement_drives#index"
end
