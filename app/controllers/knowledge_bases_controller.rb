class KnowledgeBasesController < ApplicationController
  before_action :authenticate_user! # 确保用户已登录

  def create
    knowledge_base_name = params[:name]

    if knowledge_base_name.blank?
      render json: { success: false, message: '知识库名称不能为空' }, status: 400
      return
    end

    knowledge_base = KnowledgeBase.new(name: knowledge_base_name, user_id: current_user.id)

    if knowledge_base.save
      render json: { success: true, id: knowledge_base.id, name: knowledge_base.name }
    else
      render json: { success: false, message: knowledge_base.errors.full_messages.join(', ') }, status: 500
    end
  end

  def index
    knowledge_bases = current_user.knowledge_bases.select(:id, :name)

    if knowledge_bases.empty?
      render json: { success: true, knowledgeBases: [], message: '当前用户没有任何知识库，请创建一个知识库' }
    else
      render json: { success: true, knowledgeBases: knowledge_bases }
    end
  rescue StandardError => e
    Rails.logger.error("Error fetching knowledge bases: #{e.message}")
    render json: { success: false, message: e.message }, status: 500
  end

  def upload_and_process
    knowledge_base_id = params[:knowledge_base_id]
    uploaded_files = params[:files]

    if knowledge_base_id.blank?
      render json: { success: false, message: '知识库 ID 不能为空' }, status: 400
      return
    end

    if uploaded_files.blank?
      render json: { success: false, message: '未上传任何文件' }, status: 400
      return
    end

    # 保存文件到本地
    saved_files = save_uploaded_files(uploaded_files)

    if saved_files.empty?
      render json: { success: false, message: '上传文件无效或保存失败' }, status: 400
      return
    end

    # 动态生成 class_name
    class_name = generate_class_name(current_user.id, knowledge_base_id)
    payload = { class_name: class_name, file_paths: saved_files }
    puts "Payload before post: #{payload.to_json}"
    # 调用 Python 服务处理文件
    begin
      response = RestClient.post(
        "http://127.0.0.1:8002/process_files",
        { class_name: class_name, file_paths: saved_files }.to_json,
        {    content_type: :json,
             accept: :json }
      )

      result = JSON.parse(response.body)

      if result['success']
        render json: { success: true, message: '文件处理完成' }
      else
        render json: { success: false, message: result['error'] }, status: 500
      end
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error("调用文件处理服务失败: #{e.response}")
      render json: { success: false, message: "调用文件处理服务失败: #{e.response}" }, status: 500
    rescue StandardError => e
      Rails.logger.error("处理过程中发生错误: #{e.message}")
      render json: { success: false, message: "处理过程中发生错误: #{e.message}" }, status: 500
    ensure
      cleanup_files(saved_files)
    end
  end

  private

  # 保存上传文件到本地
  def save_uploaded_files(uploaded_files)
    upload_dir = Rails.root.join('tmp', 'uploads')
    FileUtils.mkdir_p(upload_dir) unless File.directory?(upload_dir)

    Array(uploaded_files).map do |file|
      if file.is_a?(ActionDispatch::Http::UploadedFile)
        filename = "#{SecureRandom.hex(8)}_#{file.original_filename}"
        file_path = upload_dir.join(filename)

        File.open(file_path, 'wb') { |f| f.write(file.read) }
        file_path.to_s
      else
        Rails.logger.error("Invalid file format: #{file.inspect}")
        next
      end
    end.compact
  end

  # 清理临时文件
  def cleanup_files(file_paths)
    file_paths.each do |file_path|
      File.delete(file_path) if File.exist?(file_path)
    end
  end

  def generate_class_name(user_id, knowledge_base_id)
    "Text_#{user_id}_#{knowledge_base_id}_class"
  end

  def current_user
    @current_user ||= User.find_by(id: decoded_token['user_id'])
  end

  def decoded_token
    token = request.headers['Authorization']&.split(' ')&.last
    JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256').first
  rescue JWT::DecodeError
    {}
  end

  def authenticate_user!
    unless current_user
      render json: { error: '请先登录' }, status: :unauthorized
    end
  end
end
