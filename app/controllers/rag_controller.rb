class RagController < ApplicationController
  before_action :authenticate_user! # 确保用户已登录

  def query
    # 获取当前用户 ID
    user_id = current_user.id
    knowledge_base_id = params[:knowledge_base_id]
    question = params[:question]

    begin
      # 动态生成 class_name
      class_name = generate_class_name(user_id, knowledge_base_id)

      # 获取知识库内容
      context = fetch_knowledge_base_content(knowledge_base_id)

      # 初始化检索器并执行检索
      retriever = MyRetriever.new(client: $client, model: $model, class_name: class_name)
      retrieved_docs = retriever.get_relevant_documents(question)
      retrieved_context = retrieved_docs.map(&:page_content).join("\n")

      # 调用大模型生成回答
      model_response = get_model_response(question, retrieved_context)

      # 存储聊天历史
      save_chat_history(user_id, knowledge_base_id, 'User', question)
      save_chat_history(user_id, knowledge_base_id, 'GPT', model_response, 'rag')

      render json: { ragAnswer: model_response }
    rescue StandardError => e
      render json: { error: e.message }, status: 500
    end
  end
  def current_user
    user_id = decoded_token['user_id']
    @current_user ||= User.find_by(id: decoded_token['user_id'])
  end

  # 解析 JWT 令牌
  def decoded_token
    token = request.headers['Authorization']&.split(' ')&.last
    JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256').first
  rescue JWT::DecodeError
    {}
  end

  # 用户认证
  def authenticate_user!
    unless current_user
      render json: { error: '请先登录' }, status: :unauthorized
    end
  end
  private

  def fetch_knowledge_base_content(knowledge_base_id)
    # 验证知识库是否属于当前用户
    knowledge_base = KnowledgeBase.find_by(id: knowledge_base_id, user_id: current_user.id)
    unless knowledge_base
      raise ActiveRecord::RecordNotFound, "知识库不存在或您无权访问"
    end

    knowledge_base.files.pluck(:file_content).join("\n")
  end

  def generate_class_name(user_id, knowledge_base_id)
    "Text_#{user_id}_#{knowledge_base_id}_class"
  end

  def save_chat_history(user_id, knowledge_base_id, sender, message, type = nil)
    ChatHistory.create!(
      user_id: user_id,
      knowledge_base_id: knowledge_base_id,
      sender: sender,
      message: message,
      type: type,
      created_at: Time.now
    )
  end
end
