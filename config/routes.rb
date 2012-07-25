Podmarker::Application.routes.draw do
  namespace :api do
    namespace :v2, path: '2' do
      # subscriptions
      get  'subscriptions/:username/:device_id.:format' => 'subscriptions#show',   constraints: { device_id: /[\w.-]+/ }
      post 'subscriptions/:username/:device_id.:format' => 'subscriptions#update', constraints: { device_id: /[\w.-]+/ }

      # devices
      get  'devices/:username.:format'            => 'devices#show'
      post 'devices/:username/:device_id.:format' => 'devices#update', constraints: { device_id: /[\w.-]+/ }

      # episodes
      get  'episodes/:username.:format' => 'episodes#show'
      post 'episodes/:username.:format' => 'episodes#update'
    end
  end

  root to: 'public#index'
end
