Rails.application.routes.draw do
  get "files/upload"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # config/routes.rb


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  root 'chat#index'

  # 获取所有的 conversationid
  get 'api/conversations', to: 'chat#conversations'

  # 定义聊天页面的主路由
  get 'chat', to: 'chat#index'

  # 定义根据会话 ID 显示特定对话记录的路由
  get 'api/chat/:id', to: 'chat#show', as: 'conversation'
  # 在视图中你可以用 conversation_path(1) 来生成 /conversations/1 的链接。

  # 添加一个 POST 路由用于发送消息
  post 'api/chat', to: 'chat#index'

  # 添加用于创建新会话的路由
  post 'api/chat/new', to: 'chat#create', as: 'new_conversation'

  # API 聊天相关路由
  post 'api/chat/:id/update', to: 'chat#update'

  # API 登陆注册相关路由
  post 'api/login/account', to: 'user#login'

  post 'api/register', to: 'user#register'

  post 'api/login/outLogin', to: 'user#out_login'

  get '/api/currentUser', to: 'user#current_user'

  # 新增 /api/collect 路由
  get 'api/collect', to: 'chat#collect'

  post '/api/upload_folder', to: 'files#upload'
#   curl -X PUT http://localhost:3000/chat/1 \
#     -H "Content-Type: application/json" \
#     -d '{
#   "messages": [
#     {
#       "user": "Chatbot",
#       "text": "这是我的固定回复",
#       "created_at": "2024-10-11T03:38:29.949Z",
#       "updated_at": "2024-10-11T03:38:29.949Z",
#       "user_id": null
#     }
#   ]
# }'
  post '/api/knowledge_bases', to: 'knowledge_bases#create'
  get '/api/knowledge_bases', to: 'knowledge_bases#index'
  post '/api/knowledge_bases/upload_and_process', to: 'knowledge_bases#upload_and_process'
  post '/api/rag_query', to: 'rag#query'
  patch '/api/messages/:ansid/collect', to: 'messages#collect_message'
  patch '/api/messages/:ansid/delete', to: 'messages#delete'
  delete 'api/chat/:id', to: 'chat#destroy'
end
