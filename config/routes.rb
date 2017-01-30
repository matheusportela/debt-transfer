Rails.application.routes.draw do
  root 'debt_transfer#home'
  get '/simulate', to: 'debt_transfer#simulate'
end
