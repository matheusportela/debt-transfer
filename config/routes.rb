Rails.application.routes.draw do
  root 'debt_transfer#home'
  get '/result', to: 'debt_transfer#result'
end
